Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id BC38C6B0035
	for <linux-mm@kvack.org>; Wed, 25 Dec 2013 20:21:14 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id md12so7737195pbc.33
        for <linux-mm@kvack.org>; Wed, 25 Dec 2013 17:21:14 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id ek3si19350778pbd.55.2013.12.25.17.21.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 25 Dec 2013 17:21:13 -0800 (PST)
Message-ID: <52BB847F.5080600@oracle.com>
Date: Thu, 26 Dec 2013 09:21:03 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: kernel BUG at include/linux/swapops.h:131!
References: <52B1C143.8080301@oracle.com> <52B871B2.7040409@oracle.com> <20131224025127.GA2835@lge.com> <52B8F8F6.1080500@oracle.com> <20131224060705.GA16140@lge.com> <20131224074546.GB27156@lge.com>
In-Reply-To: <20131224074546.GB27156@lge.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, khlebnikov@openvz.org, LKML <linux-kernel@vger.kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On 12/24/2013 03:45 PM, Joonsoo Kim wrote:
> On Tue, Dec 24, 2013 at 03:07:05PM +0900, Joonsoo Kim wrote:
>> On Mon, Dec 23, 2013 at 10:01:10PM -0500, Sasha Levin wrote:
>>> On 12/23/2013 09:51 PM, Joonsoo Kim wrote:
>>>> On Mon, Dec 23, 2013 at 12:24:02PM -0500, Sasha Levin wrote:
>>>>>> Ping?
>>>>>>
>>>>>> I've also Cc'ed the "this page shouldn't be locked at all" team.
>>>> Hello,
>>>>
>>>> I can't find the reason of this problem.
>>>> If it is reproducible, how about bisecting?
>>>
>>> While it reproduces under fuzzing it's pretty hard to bisect it with
>>> the amount of issues uncovered by trinity recently.
>>>
>>> I can add any debug code to the site of the BUG if that helps.
>>
>> Good!
>> It will be helpful to add dump_page() in migration_entry_to_page().
>>
>> Thanks.
>>
> 
> Minchan teaches me that there is possible race condition between
> fork and migration.
> 
> Please consider following situation.
> 
> 
> Process A (do migration)			Process B (parents) Process C (child)
> 
> try_to_unmap() for migration <begin>		fork
> setup migration entry to B's vma
> ...
> try_to_unmap() for migration <end>
> move_to_new_page()
> 
> 						link new vma
> 						    into interval tree
> remove_migration_ptes() <begin>
> check and clear migration entry on C's vma
> ...						copy_one_pte:
> ...						    now, B and C have migration entry
> ...
> ...
> check and clear migration entry on B's vma
> ...
> ...
> remove_migration_ptes() <end>
> 
> 
> Eventually, migration entry on C's vma is left.
> And then, when C exits, above BUG_ON() can be triggered.
> 

Yes, Looks like this is a potential race condition.

> I'm not sure the I am right, so please think of it together. :)
> And I'm not sure again that above assumption is related to this trigger report,
> since this may exist for a long time.
> 
> So my question to mm folks is is above assumption possible and do we have
> any protection mechanism on this race?
> 

I think we can down_read(&mm->mmap_sem) before remove_migration_ptes()
to fix this issue, but I don't have time to verify it currently.

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
