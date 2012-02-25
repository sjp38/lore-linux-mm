Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id B189F6B004A
	for <linux-mm@kvack.org>; Sat, 25 Feb 2012 00:31:06 -0500 (EST)
Received: by bkty12 with SMTP id y12so3462344bkt.14
        for <linux-mm@kvack.org>; Fri, 24 Feb 2012 21:31:04 -0800 (PST)
Message-ID: <4F487215.7000307@openvz.org>
Date: Sat, 25 Feb 2012 09:31:01 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH v3 00/21] mm: lru_lock splitting
References: <20120223133728.12988.5432.stgit@zurg> <20120225111515.1275e04c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120225111515.1275e04c.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

KAMEZAWA Hiroyuki wrote:
> On Thu, 23 Feb 2012 17:51:36 +0400
> Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
>
>> v3 changes:
>> * inactive-ratio reworked again, now it always calculated from from scratch
>> * hierarchical pte reference bits filter in memory-cgroup reclaimer
>> * fixed two bugs in locking, found by Hugh Dickins
>> * locking functions slightly simplified
>> * new patch for isolated pages accounting
>> * new patch with lru interleaving
>>
>> This patchset is based on next-20120210
>>
>> git: https://github.com/koct9i/linux/commits/lruvec-v3
>>
>
> I wonder.... I just wonder...if we can split a lruvec in a zone into small
> pieces of lruvec and have splitted LRU-lock per them, do we need per-memcg-lrulock ?

What per-memcg-lrulock? I don't have it.
last patch splits lruvecs in memcg with the same factor.

>
> It seems per-memcg-lrulock can be much bigger lock than small-lruvec-lock.
> (depends on configuraton) and much more complicated..and have to take care
> of many things.. If unit of splitting can be specified by boot option,
> it seems admins can split a big memcg's per-memcg-lru lock into more small pieces.

lruvec count per memcg can be arbitrary and changeable if cgroup is empty.
This is not in this patch, but it's really easy.

>
> BTW, how to think of default size of splitting ? I wonder splitting lru into
> the number of cpus per a node can be a choice. Each cpu may have a chance to
> set prefered-pfn-range at page allocation with additional patches.

If we rework page to memcg linking and add direct lruvec-id into page->flags,
we will able to change lruvec before inserting page to lru.
Thus each cpu will always insert pages into its own lruvec in zone.
I have not thought about races yet, but this would be perfect solution.

>
> Thanks,
> -Kame
>
>
>> ---
>>
>> Konstantin Khlebnikov (21):
>>        memcg: unify inactive_ratio calculation
>>        memcg: make mm_match_cgroup() hirarchical
>>        memcg: fix page_referencies cgroup filter on global reclaim
>>        memcg: use vm_swappiness from target memory cgroup
>>        mm: rename lruvec->lists into lruvec->pages_lru
>>        mm: lruvec linking functions
>>        mm: add lruvec->pages_count
>>        mm: unify inactive_list_is_low()
>>        mm: add lruvec->reclaim_stat
>>        mm: kill struct mem_cgroup_zone
>>        mm: move page-to-lruvec translation upper
>>        mm: push lruvec into update_page_reclaim_stat()
>>        mm: push lruvecs from pagevec_lru_move_fn() to iterator
>>        mm: introduce lruvec locking primitives
>>        mm: handle lruvec relocks on lumpy reclaim
>>        mm: handle lruvec relocks in compaction
>>        mm: handle lruvec relock in memory controller
>>        mm: add to lruvec isolated pages counters
>>        memcg: check lru vectors emptiness in pre-destroy
>>        mm: split zone->lru_lock
>>        mm: zone lru vectors interleaving
>>
>>
>>   include/linux/huge_mm.h    |    3
>>   include/linux/memcontrol.h |   75 ------
>>   include/linux/mm.h         |   66 +++++
>>   include/linux/mm_inline.h  |   19 +-
>>   include/linux/mmzone.h     |   39 ++-
>>   include/linux/swap.h       |    6
>>   mm/Kconfig                 |   16 +
>>   mm/compaction.c            |   31 +--
>>   mm/huge_memory.c           |   14 +
>>   mm/internal.h              |  204 +++++++++++++++++
>>   mm/ksm.c                   |    2
>>   mm/memcontrol.c            |  343 +++++++++++-----------------
>>   mm/migrate.c               |    2
>>   mm/page_alloc.c            |   70 +-----
>>   mm/rmap.c                  |    2
>>   mm/swap.c                  |  217 ++++++++++--------
>>   mm/vmscan.c                |  534 ++++++++++++++++++++++++--------------------
>>   mm/vmstat.c                |    6
>>   18 files changed, 932 insertions(+), 717 deletions(-)
>>
>> --
>> Signature
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
