Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m74HqNgQ006668
	for <linux-mm@kvack.org>; Tue, 5 Aug 2008 03:52:23 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m74Hr3TL103572
	for <linux-mm@kvack.org>; Tue, 5 Aug 2008 03:53:04 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m74Hr3Da007258
	for <linux-mm@kvack.org>; Tue, 5 Aug 2008 03:53:03 +1000
Message-ID: <489741F8.2080104@linux.vnet.ibm.com>
Date: Mon, 04 Aug 2008 23:22:56 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: Race condition between putback_lru_page and mem_cgroup_move_list
References: <28c262360808040736u7f364fc0p28d7ceea7303a626@mail.gmail.com> <1217863870.7065.62.camel@lts-notebook> <2f11576a0808040937y70f274e0j32f6b9c98b0f992d@mail.gmail.com>
In-Reply-To: <2f11576a0808040937y70f274e0j32f6b9c98b0f992d@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, MinChan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> Hi
> 
>>> I think this is a race condition if mem_cgroup_move_lists's comment isn't right.
>>> I am not sure that it was already known problem.
>>>
>>> mem_cgroup_move_lists assume the appropriate zone's lru lock is already held.
>>> but putback_lru_page calls mem_cgroup_move_lists without holding lru_lock.
>> Hmmm, the comment on mem_cgroup_move_lists() does say this.  Although,
>> reading thru' the code, I can't see why it requires this.  But then it's
>> Monday, here...
> 
> I also think zone's lru lock is unnecessary.
> So, I guess below "it" indicate lock_page_cgroup, not zone lru lock.
> 

We need zone LRU lock, since the reclaim paths hold them. Not sure if I
understand why you call zone's LRU lock unnecessary, could you elaborate please?

>  >> But we cannot safely get to page_cgroup without it, so just try_lock it:
> 
> if my assumption is true, comment modifying is better.
> 
> 
>>> Repeatedly, spin_[un/lock]_irq use in mem_cgroup_move_list have a big overhead
>>> while doing list iteration.
>>>
>>> Do we have to use pagevec ?
>> This shouldn't be necessary, IMO.  putback_lru_page() is used as
>> follows:
>>
>> 1) in vmscan.c [shrink_*_list()] when an unevictable page is
>> encountered.  This should be relatively rare.  Once vmscan sees an
>> unevictable page, it parks it on the unevictable lru list where it
>> [vmscan] won't see the page again until it becomes reclaimable.
>>
>> 2) as a replacement for move_to_lru() in page migration as the inverse
>> to isolate_lru_page().  We did this to catch patches that became
>> unevictable or, more importantly, evictable while page migration held
>> them isolated.  move_to_lru() already grabbed and released the zone lru
>> lock on each page migrated.
>>
>> 3) In m[un]lock_vma_page() and clear_page_mlock(), new with in the
>> "mlocked pages are unevictable" series.  This one can result in a storm
>> of zone lru traffic--e.g., mlock()ing or munlocking() a large segment or
>> mlockall() of a task with a lot of mapped address space.  Again, this is
>> probably a very rare event--unless you're stressing [stressing over?]
>> mlock(), as I've been doing :)--and often involves a major fault [page
>> allocation], per page anyway.
>>
>> Ii>>? originally did have a pagevec for the unevictable lru but it
>> complicated ensuring that we don't strand evictable pages on the
>> unevictable list.  See the retry logic in putback_lru_page().
>>
>> As for the !UNEVICTABLE_LRU version, the only place this should be
>> called is from page migration as none of the other call sites are
>> compiled in or reachable when !UNEVICTABLE_LRU.
>>
>> Thoughts?
> 
> I think both opinion is correct.
> unevictable lru related code doesn't require pagevec.
> 
> but mem_cgroup_move_lists is used by active/inactive list transition too.
> then, pagevec is necessary for keeping reclaim throuput.
> 

It's on my TODO list. I hope to get to it soon.

> Kim-san, Thank you nice point out!
> I queued this fix to my TODO list.


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
