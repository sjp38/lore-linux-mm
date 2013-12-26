Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f174.google.com (mail-gg0-f174.google.com [209.85.161.174])
	by kanga.kvack.org (Postfix) with ESMTP id 157B46B0035
	for <linux-mm@kvack.org>; Thu, 26 Dec 2013 01:19:15 -0500 (EST)
Received: by mail-gg0-f174.google.com with SMTP id v2so1645527ggc.33
        for <linux-mm@kvack.org>; Wed, 25 Dec 2013 22:19:14 -0800 (PST)
Received: from mail-pb0-x233.google.com (mail-pb0-x233.google.com [2607:f8b0:400e:c01::233])
        by mx.google.com with ESMTPS id z48si27393916yha.181.2013.12.25.22.19.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Dec 2013 22:19:14 -0800 (PST)
Received: by mail-pb0-f51.google.com with SMTP id up15so7851997pbc.24
        for <linux-mm@kvack.org>; Wed, 25 Dec 2013 22:19:13 -0800 (PST)
In-Reply-To: <52BB847F.5080600@oracle.com>
References: <52B1C143.8080301@oracle.com> <52B871B2.7040409@oracle.com> <20131224025127.GA2835@lge.com> <52B8F8F6.1080500@oracle.com> <20131224060705.GA16140@lge.com> <20131224074546.GB27156@lge.com> <52BB847F.5080600@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain;
 charset=UTF-8
Subject: Re: mm: kernel BUG at include/linux/swapops.h:131!
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Thu, 26 Dec 2013 15:18:58 +0900
Message-ID: <986cc0ea-1a2d-47c9-ac27-299de16a05fd@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, khlebnikov@openvz.org, LKML <linux-kernel@vger.kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Bob Liu <bob.liu@oracle.com> wrote:
>On 12/24/2013 03:45 PM, Joonsoo Kim wrote:
>> On Tue, Dec 24, 2013 at 03:07:05PM +0900, Joonsoo Kim wrote:
>>> On Mon, Dec 23, 2013 at 10:01:10PM -0500, Sasha Levin wrote:
>>>> On 12/23/2013 09:51 PM, Joonsoo Kim wrote:
>>>>> On Mon, Dec 23, 2013 at 12:24:02PM -0500, Sasha Levin wrote:
>>>>>>> Ping?
>>>>>>>
>>>>>>> I've also Cc'ed the "this page shouldn't be locked at all" team.
>>>>> Hello,
>>>>>
>>>>> I can't find the reason of this problem.
>>>>> If it is reproducible, how about bisecting?
>>>>
>>>> While it reproduces under fuzzing it's pretty hard to bisect it
>with
>>>> the amount of issues uncovered by trinity recently.
>>>>
>>>> I can add any debug code to the site of the BUG if that helps.
>>>
>>> Good!
>>> It will be helpful to add dump_page() in migration_entry_to_page().
>>>
>>> Thanks.
>>>
>> 
>> Minchan teaches me that there is possible race condition between
>> fork and migration.
>> 
>> Please consider following situation.
>> 
>> 
>> Process A (do migration)			Process B (parents) Process C (child)
>> 
>> try_to_unmap() for migration <begin>		fork
>> setup migration entry to B's vma
>> ...
>> try_to_unmap() for migration <end>
>> move_to_new_page()
>> 
>> 						link new vma
>> 						    into interval tree
>> remove_migration_ptes() <begin>
>> check and clear migration entry on C's vma
>> ...						copy_one_pte:
>> ...						    now, B and C have migration entry
>> ...
>> ...
>> check and clear migration entry on B's vma
>> ...
>> ...
>> remove_migration_ptes() <end>
>> 
>> 
>> Eventually, migration entry on C's vma is left.
>> And then, when C exits, above BUG_ON() can be triggered.
>> 
>
>Yes, Looks like this is a potential race condition.
>
>> I'm not sure the I am right, so please think of it together. :)
>> And I'm not sure again that above assumption is related to this
>trigger report,
>> since this may exist for a long time.
>> 
>> So my question to mm folks is is above assumption possible and do we
>have
>> any protection mechanism on this race?
>> 
>
>I think we can down_read(&mm->mmap_sem) before remove_migration_ptes()
>to fix this issue, but I don't have time to verify it currently.

Hmm. This kind of race looks impossible: dup_mmap() always places child's
vma in into rmap tree after parent's one. For file-vma it's done explicitly
(vma_interval_tree_insert_after), for anon vma it's true because rb-tree
insert function goes to right branch if elements are equal.

Thus remove_migration_ptes() sees parent's pte first:
If child has the copy this function will check it after that.
And they are already synchronized with parent's and child's pte locks.i>>?

Sorry for double posting, gmail cannot into plain text =)

-- 
Sent from my Android device with K-9 Mail. Please excuse my brevity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
