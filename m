Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id m77CgFt2010133
	for <linux-mm@kvack.org>; Thu, 7 Aug 2008 18:12:15 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m77CgEF41658992
	for <linux-mm@kvack.org>; Thu, 7 Aug 2008 18:12:14 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id m77CgEK6009620
	for <linux-mm@kvack.org>; Thu, 7 Aug 2008 18:12:14 +0530
Message-ID: <489AEDA6.5040802@linux.vnet.ibm.com>
Date: Thu, 07 Aug 2008 18:12:14 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: Race condition between putback_lru_page and mem_cgroup_move_list
References: <28c262360808040736u7f364fc0p28d7ceea7303a626@mail.gmail.com> <1217863870.7065.62.camel@lts-notebook> <2f11576a0808040937y70f274e0j32f6b9c98b0f992d@mail.gmail.com> <489741F8.2080104@linux.vnet.ibm.com> <1218041585.6173.45.camel@lts-notebook>
In-Reply-To: <1218041585.6173.45.camel@lts-notebook>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, MinChan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Lee Schermerhorn wrote:
> On Mon, 2008-08-04 at 23:22 +0530, Balbir Singh wrote:
>> KOSAKI Motohiro wrote:
>>> Hi
>>>
>>>>> I think this is a race condition if mem_cgroup_move_lists's comment isn't right.
>>>>> I am not sure that it was already known problem.
>>>>>
>>>>> mem_cgroup_move_lists assume the appropriate zone's lru lock is already held.
>>>>> but putback_lru_page calls mem_cgroup_move_lists without holding lru_lock.
>>>> Hmmm, the comment on mem_cgroup_move_lists() does say this.  Although,
>>>> reading thru' the code, I can't see why it requires this.  But then it's
>>>> Monday, here...
>>> I also think zone's lru lock is unnecessary.
>>> So, I guess below "it" indicate lock_page_cgroup, not zone lru lock.
>>>
>> We need zone LRU lock, since the reclaim paths hold them. Not sure if I
>> understand why you call zone's LRU lock unnecessary, could you elaborate please?
> 
> Hi, Balbir:
> 
> Sorry for the delay in responding.  Distracted...
> 

No problem at all.

> I think that perhaps the zone's LRU lock is unnecessary because I didn't
> see anything in mem_cgroup_move_lists() or it's callees that needed
> protection by the zone lru_lock.  
> 
> Looking at the call sites in the reclaim paths [in
> shrink_[in]active_page()] and activate_page(), they are holding the zone
> lru_lock because they are manipulating the lru lists and/or zone
> statistics. 

Precisely, my point below about updating statistics for zones and you mention
below that the zone LRU excludes the race I mentioned in (1). I am a bit
confused with that statement, do you agree that zone lru_lock excludes the race
and is therefore required?

 The places where pages are moved to a new lru list is where
> you want to insert calls to mem_cgroup_move_lists(), so I think they
> just happen to fall under the zone lru lock.  
> 
> Now, in a subsequent message in this thread, you ask:
> 
> "1. What happens if a global reclaim is in progress at the same time as
> memory cgroup reclaim and they are both looking at the same page?"
> 
> This should not happen, I think.  Racing global and memory cgroup calls
> to __isolate_lru_page() are mutually excluded by the zone lru_lock taken
> in shrink_[in]active_page().

Yes, I was referring to needing the zone lru_lock

  In putback_lru_page(), where we call
> mem_cgroup_move_lists() without holding the zone lru_lock, we've either
> queued up the page for adding to one of the [in]active lists via the
> pagevecs, or we've already moved it to the unevictable list.  If
> mem_cgroup_isolate_pages() finds a page on one of the mz lists before it
> has been drained to the LRU, it will [rightly] skip the page because
> it's "!PageLRU(page)".
> 
> 
> In same message, you state:
> 
> "2. In the shared reclaim infrastructure, we move pages and update
> statistics for pages belonging to a particular zone in a particular
> cgroup."
> 
> Sorry, I don't understand your point.  Are you concerned that the stats
> can get out of sync?  I suppose that, in general, if we called
> mem_cgroup_move_lists() from just anywhere without zone lru_lock
> protection, we could have problems.  In the case of putback_lru_page(),
> again, we've already put the page back on the global unevictable list
> and updated the global stats, or it's on it's way to an [in]active list
> via the pagevecs.  The stats will be updated when the pagevecs are
> drained.
> 
> I think we're OK without explicit zone lru locking around the call to
> mem_cgroup_move_lists() and the global lru list additions in
> putback_lru_page().   
> 

I think I understand what you are stating clearly

We don't need the zone lru_lock in putback_lru_page(). Am I missing something or
do I have it right? (It's Thursday and one of my legs is already in the weekend).


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
