Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f170.google.com (mail-ea0-f170.google.com [209.85.215.170])
	by kanga.kvack.org (Postfix) with ESMTP id 57E5E6B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 06:05:08 -0500 (EST)
Received: by mail-ea0-f170.google.com with SMTP id k10so3873640eaj.29
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 03:05:07 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y48si353469eew.142.2014.01.14.03.05.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 03:05:07 -0800 (PST)
Message-ID: <52D519DC.9060402@suse.cz>
Date: Tue, 14 Jan 2014 12:05:00 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/mlock: fix BUG_ON unlocked page for nolinear VMAs
References: <1387267550-8689-1-git-send-email-liwanp@linux.vnet.ibm.com>	<52b1138b.0201430a.19a8.605dSMTPIN_ADDED_BROKEN@mx.google.com>	<52B11765.8030005@oracle.com>	<52b120a5.a3b2440a.3acf.ffffd7c3SMTPIN_ADDED_BROKEN@mx.google.com>	<52B166CF.6080300@suse.cz>	<52b1699f.87293c0a.75d1.34d3SMTPIN_ADDED_BROKEN@mx.google.com>	<20131218134316.977d5049209d9278e1dad225@linux-foundation.org>	<52C71ACC.20603@oracle.com>	<CA+55aFzDcFyyXwUUu5bLP3fsiuzxU7VPivpTPHgp8smvdTeESg@mail.gmail.com>	<52C74972.6050909@suse.cz> <CA+55aFzq1iQqddGo-m=vutwMYn5CPf65Ergov5svKR4AWC3rUQ@mail.gmail.com> <6B2BA408B38BA1478B473C31C3D2074E2BF812BC82@SV-EXCHANGE1.Corp.FC.LOCAL> <52CC16DC.9070308@suse.cz> <6B2BA408B38BA1478B473C31C3D2074E2C386DF586@SV-EXCHANGE1.Corp.FC.LOCAL> <52D3F248.7030803@suse.cz>
In-Reply-To: <52D3F248.7030803@suse.cz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Michel Lespinasse <walken@google.com>, Bob Liu <bob.liu@oracle.com>, Nick Piggin <npiggin@suse.de>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 01/13/2014 03:03 PM, Vlastimil Babka wrote:
> On 01/10/2014 06:48 PM, Motohiro Kosaki wrote:
>>> diff --git a/mm/rmap.c b/mm/rmap.c
>>> index 068522d..b99c742 100644
>>> --- a/mm/rmap.c
>>> +++ b/mm/rmap.c
>>> @@ -1389,9 +1389,19 @@ static int try_to_unmap_cluster(unsigned long
>>> cursor, unsigned int *mapcount,
>>>    		BUG_ON(!page || PageAnon(page));
>>>
>>>    		if (locked_vma) {
>>> -			mlock_vma_page(page);   /* no-op if already
>>> mlocked */
>>> -			if (page == check_page)
>>> +			if (page == check_page) {
>>> +				/* we know we have check_page locked */
>>> +				mlock_vma_page(page);
>>>    				ret = SWAP_MLOCK;
>>> +			} else if (trylock_page(page)) {
>>> +				/*
>>> +				 * If we can lock the page, perform mlock.
>>> +				 * Otherwise leave the page alone, it will be
>>> +				 * eventually encountered again later.
>>> +				 */
>>> +				mlock_vma_page(page);
>>> +				unlock_page(page);
>>> +			}
>>>    			continue;	/* don't unmap */
>>>    		}
>>
>> I audited all related mm code. However I couldn't find any race that it can close.
>
> Well, I would say the lock here closes the race with page migration, no? (As discussed below)
>
>> First off,  current munlock code is crazy tricky.
>
> Oops, that's actually a result of my patches to speed up munlock by batching pages (since 3.12).
>
>> munlock
>> 	down_write(mmap_sem)
>> 	do_mlock()
>> 		mlock_fixup
>> 			munlock_vma_pages_range
>> 				__munlock_pagevec
>> 					spin_lock_irq(zone->lru_lock)
>> 					TestClearPageMlocked(page)
>> 					del_page_from_lru_list
>> 					spin_unlock_irq(zone->lru_lock)
>> 					lock_page
>> 					__munlock_isolated_page
>> 					unlock_page
>> 				
>> 	up_write(mmap_sem)
>>
>> Look, TestClearPageMlocked(page) is not protected by lock_page.
>
> Right :( That's my fault, when developing the patch series I didn't see the page
> migration race, and it seemed that lock is only needed to protect the rmap operations
> in __munlock_isolated_page()
>
>> But this is still
>> safe because Page_mocked mean one or more vma marked VM_LOCKED then we
>> only need care about turning down final VM_LOCKED. I.e. mmap_sem protect them.
>>
>> And,
>>
>> 					spin_lock_irq(zone->lru_lock)
>> 					del_page_from_lru_list
>> 					spin_unlock_irq(zone->lru_lock)
>>
>> This idiom ensures I or someone else isolate the page from lru and isolated pages
>> will be put back by putback_lru_page in anycase. So, the pages will move the right
>> lru eventually.
>>
>> And then, taking page-lock doesn't help to close vs munlock race.
>>
>> On the other hands, page migration has the following call stack.
>>
>> some-caller [isolate_lru_page]
>> 	unmap_and_move
>> 		__unmap_and_move
>> 		trylock_page
>> 		try_to_unmap
>> 		move_to_new_page
>> 			migrate_page
>> 				migrate_page_copy
>> 		unlock_page
>>
>> The critical part (i.e. migrate_page_copy) is protected by both page isolation and page lock.
>
> However, none of that protects against setting PG_mlocked in try_to_unmap_cluster() -> mlock_vma_page(),
> or clearing PG_mlocked in __munlock_pagevec().
>
> The race I have in mind for munlock is:
>
> CPU1 does page migration
>   some-caller [isolate_lru_page]
>   	unmap_and_move
>   		__unmap_and_move
>   		trylock_page
>   		try_to_unmap
>   		move_to_new_page
>   			migrate_page
>   				migrate_page_copy
> 					mlock_migrate_page - transfers PG_mlocked from old page to new page
>
> CPU2 does munlock:
>   munlock
>   	down_write(mmap_sem)
>   	do_mlock()
>   		mlock_fixup
>   			munlock_vma_pages_range
>   				__munlock_pagevec
>   					spin_lock_irq(zone->lru_lock)
>   					TestClearPageMlocked(page) - here it finds PG_mlocked already cleared
> 					so it stops, but meanwhile new page already has PG_mlocked set and will
> 					stay inevictable

As Mel pointed out to me, page lock in munlock alone would not help here
anyway, because munlock would just wait for migration to unlock the old 
page and then still fail to clear a flag that has been transferred by 
migration to the new page. So if there was a race, it would be older 
than __munlock_pagevec() removing TestClearPageMlocked(page) from the 
page_lock protected section.

But then I noticed that migration bails out for pages that have elevated 
pins, and this is done after making the page unreachable for 
mlock/munlock via pte migration entries. So this alone should prevent a 
race with m(un)lock, with three possible scenarios:
- m(un)lock sees the migration entry and waits for migration to
   complete (via follow_page_mask), operates on the new page
- m(un)lock gets the page reference before migration entry is set,
   finishes before migration checks the page pin count, migration
   transfers the new PG_mlocked state to the new page
- m(un)lock doesn't finish that quickly, migration bails out, m(un)lock
   changes the old page that is mapped back


>> Page fault path take lock page and doesn't use page isolation. This is correct.
>> try_to_unmap_cluster doesn't take page lock, but it ensure the page is isolated. This is correct too.
>
> I don't see where try_to_unmap_cluster() has guaranteed that pages other than check_page are isolated?
> (I might just be missing that). So in the race example above, CPU2 could be doing try_to_unmap_cluster()
> and set PG_mlocked on old page, with no effect on the new page. Not fatal for the design of lazy mlocking,
> but a distorted accounting anyway.
>
>> Plus, do_wp_page() has the following comment. But it is wrong. This lock is necessary to protect against
>> page migration, but not lru manipulation.
>>
>> 		if ((ret & VM_FAULT_WRITE) && (vma->vm_flags & VM_LOCKED)) {
>> 			lock_page(old_page);	/* LRU manipulation */
>> 			munlock_vma_page(old_page);
>> 			unlock_page(old_page);
>> 		}
>>

So the protection is actually for rmap operations in try_to_munlock.
The comment could be removed from the caller here and appear just at the 
PageLocked assertion in munlock_vma_page().

>> But, you know, this is crazy ugly lock design. I'm ok to change the rule to that PG_mlocked must be protected
>> page lock. If so, I propose to add PageMlocked() like this
>>
>> 			} else if (!PageMlocked() && trylock_page(page)) {
>> 				/*
>> 				 * If we can lock the page, perform mlock.
>> 				 * Otherwise leave the page alone, it will be
>> 				 * eventually encountered again later.
>> 				 */
>> 				mlock_vma_page(page);
>> 				unlock_page(page);
>>
>> This is safe. Even if race is happen and vmscan failed to mark PG_mlocked, that's no problem. Next vmscan may
>> do the right job and will fix the mistake.
>>
>> Anyway,  I'm also sure this is not recent issue. It lived 5 years. It is no reason to rush.

If we agree that page migration is safe as explained above, then 
removing the PageLocked assertion from mlock_vma_page is again an 
option, instead of making sure that all callers lock?

> Yeah but there's the new issue with __munlock_pagevec() :( Perhaps a more serious one as it could leave pages inevictable
> when they shouldn't be. I'm not sure if the performance benefits of that could be preserved with full page locking.
> Another option would be that page migration would somehow deal with the race, or just leave the target pages without
> PG_mlocked and let them be dealt with later.
> But if we go with the rule that page lock must protect PG_mlocked, then there's also clear_page_mlock() to consider.
> And finally, we could then at least replace the atomic test and set with faster non-atomic variants.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
