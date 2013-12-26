Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id E0DBD6B0035
	for <linux-mm@kvack.org>; Thu, 26 Dec 2013 01:27:35 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id p10so7716327pdj.4
        for <linux-mm@kvack.org>; Wed, 25 Dec 2013 22:27:35 -0800 (PST)
Received: from e28smtp08.in.ibm.com (e28smtp08.in.ibm.com. [122.248.162.8])
        by mx.google.com with ESMTPS id e8si19901804pac.111.2013.12.25.22.27.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 25 Dec 2013 22:27:34 -0800 (PST)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 26 Dec 2013 11:57:31 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id A8DA8394002D
	for <linux-mm@kvack.org>; Thu, 26 Dec 2013 11:57:28 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBQ6RMH06553974
	for <linux-mm@kvack.org>; Thu, 26 Dec 2013 11:57:23 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBQ6RRoK013896
	for <linux-mm@kvack.org>; Thu, 26 Dec 2013 11:57:28 +0530
Date: Thu, 26 Dec 2013 14:27:26 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: mm: kernel BUG at include/linux/swapops.h:131!
Message-ID: <52bbcc56.280d420a.2c84.ffffc456SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <52B1C143.8080301@oracle.com>
 <52B871B2.7040409@oracle.com>
 <20131224025127.GA2835@lge.com>
 <52B8F8F6.1080500@oracle.com>
 <20131224060705.GA16140@lge.com>
 <20131224074546.GB27156@lge.com>
 <52BB847F.5080600@oracle.com>
 <986cc0ea-1a2d-47c9-ac27-299de16a05fd@email.android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <986cc0ea-1a2d-47c9-ac27-299de16a05fd@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Bob Liu <bob.liu@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, khlebnikov@openvz.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Dec 26, 2013 at 03:18:58PM +0900, Konstantin Khlebnikov wrote:
>Bob Liu <bob.liu@oracle.com> wrote:
>>On 12/24/2013 03:45 PM, Joonsoo Kim wrote:
>>> On Tue, Dec 24, 2013 at 03:07:05PM +0900, Joonsoo Kim wrote:
>>>> On Mon, Dec 23, 2013 at 10:01:10PM -0500, Sasha Levin wrote:
>>>>> On 12/23/2013 09:51 PM, Joonsoo Kim wrote:
>>>>>> On Mon, Dec 23, 2013 at 12:24:02PM -0500, Sasha Levin wrote:
>>>>>>>> Ping?
>>>>>>>>
>>>>>>>> I've also Cc'ed the "this page shouldn't be locked at all" team.
>>>>>> Hello,
>>>>>>
>>>>>> I can't find the reason of this problem.
>>>>>> If it is reproducible, how about bisecting?
>>>>>
>>>>> While it reproduces under fuzzing it's pretty hard to bisect it
>>with
>>>>> the amount of issues uncovered by trinity recently.
>>>>>
>>>>> I can add any debug code to the site of the BUG if that helps.
>>>>
>>>> Good!
>>>> It will be helpful to add dump_page() in migration_entry_to_page().
>>>>
>>>> Thanks.
>>>>
>>> 
>>> Minchan teaches me that there is possible race condition between
>>> fork and migration.
>>> 
>>> Please consider following situation.
>>> 
>>> 
>>> Process A (do migration)			Process B (parents) Process C (child)
>>> 
>>> try_to_unmap() for migration <begin>		fork
>>> setup migration entry to B's vma
>>> ...
>>> try_to_unmap() for migration <end>
>>> move_to_new_page()
>>> 
>>> 						link new vma
>>> 						    into interval tree
>>> remove_migration_ptes() <begin>
>>> check and clear migration entry on C's vma
>>> ...						copy_one_pte:
>>> ...						    now, B and C have migration entry
>>> ...
>>> ...
>>> check and clear migration entry on B's vma
>>> ...
>>> ...
>>> remove_migration_ptes() <end>
>>> 
>>> 
>>> Eventually, migration entry on C's vma is left.
>>> And then, when C exits, above BUG_ON() can be triggered.
>>> 
>>
>>Yes, Looks like this is a potential race condition.
>>
>>> I'm not sure the I am right, so please think of it together. :)
>>> And I'm not sure again that above assumption is related to this
>>trigger report,
>>> since this may exist for a long time.
>>> 
>>> So my question to mm folks is is above assumption possible and do we
>>have
>>> any protection mechanism on this race?
>>> 
>>
>>I think we can down_read(&mm->mmap_sem) before remove_migration_ptes()
>>to fix this issue, but I don't have time to verify it currently.
>
>Hmm. This kind of race looks impossible: dup_mmap() always places child's
>vma in into rmap tree after parent's one. For file-vma it's done explicitly
>(vma_interval_tree_insert_after), for anon vma it's true because rb-tree
>insert function goes to right branch if elements are equal.
>
>Thus remove_migration_ptes() sees parent's pte first:
>If child has the copy this function will check it after that.
>And they are already synchronized with parent's and child's pte locks.i>>?
>

Agreed. 

>Sorry for double posting, gmail cannot into plain text =)
>
>-- 
>Sent from my Android device with K-9 Mail. Please excuse my brevity.
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
