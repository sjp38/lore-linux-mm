Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id DE0406B002C
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 20:54:05 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 651CF3EE0C0
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 10:54:04 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 48A6545DE5A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 10:54:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1385645DE55
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 10:54:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 00986E08006
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 10:54:04 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A0229E08002
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 10:54:03 +0900 (JST)
Date: Tue, 28 Feb 2012 10:52:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 00/21] mm: lru_lock splitting
Message-Id: <20120228105236.448c0bf3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120223133728.12988.5432.stgit@zurg>
References: <20120223133728.12988.5432.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

On Thu, 23 Feb 2012 17:51:36 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> v3 changes:
> * inactive-ratio reworked again, now it always calculated from from scratch
> * hierarchical pte reference bits filter in memory-cgroup reclaimer
> * fixed two bugs in locking, found by Hugh Dickins
> * locking functions slightly simplified
> * new patch for isolated pages accounting
> * new patch with lru interleaving
> 
> This patchset is based on next-20120210
> 
> git: https://github.com/koct9i/linux/commits/lruvec-v3
> 
I'm sorry I can't have enough review time in these days but the whole series
seems good to me.


BTW, how about trying to merge patch 1/21 -> 13or14/21 first ?
This series adds many changes to various place under /mm. So, step-by-step
merging will be better I think.
(Just says as this because I tend to split a long series of patch to 
 small sets of patches and merge them one by one to reduce my own maintainance cost.)

At final lock splitting, performance number should be in changelog.

Thanks,
-Kame

> ---
> 
> Konstantin Khlebnikov (21):
>       memcg: unify inactive_ratio calculation
>       memcg: make mm_match_cgroup() hirarchical
>       memcg: fix page_referencies cgroup filter on global reclaim
>       memcg: use vm_swappiness from target memory cgroup
>       mm: rename lruvec->lists into lruvec->pages_lru
>       mm: lruvec linking functions
>       mm: add lruvec->pages_count
>       mm: unify inactive_list_is_low()
>       mm: add lruvec->reclaim_stat
>       mm: kill struct mem_cgroup_zone
>       mm: move page-to-lruvec translation upper
>       mm: push lruvec into update_page_reclaim_stat()
>       mm: push lruvecs from pagevec_lru_move_fn() to iterator
>       mm: introduce lruvec locking primitives
>       mm: handle lruvec relocks on lumpy reclaim
>       mm: handle lruvec relocks in compaction
>       mm: handle lruvec relock in memory controller
>       mm: add to lruvec isolated pages counters
>       memcg: check lru vectors emptiness in pre-destroy
>       mm: split zone->lru_lock
>       mm: zone lru vectors interleaving
> 
> 
>  include/linux/huge_mm.h    |    3 
>  include/linux/memcontrol.h |   75 ------
>  include/linux/mm.h         |   66 +++++
>  include/linux/mm_inline.h  |   19 +-
>  include/linux/mmzone.h     |   39 ++-
>  include/linux/swap.h       |    6 
>  mm/Kconfig                 |   16 +
>  mm/compaction.c            |   31 +--
>  mm/huge_memory.c           |   14 +
>  mm/internal.h              |  204 +++++++++++++++++
>  mm/ksm.c                   |    2 
>  mm/memcontrol.c            |  343 +++++++++++-----------------
>  mm/migrate.c               |    2 
>  mm/page_alloc.c            |   70 +-----
>  mm/rmap.c                  |    2 
>  mm/swap.c                  |  217 ++++++++++--------
>  mm/vmscan.c                |  534 ++++++++++++++++++++++++--------------------
>  mm/vmstat.c                |    6 
>  18 files changed, 932 insertions(+), 717 deletions(-)
> 
> -- 
> Signature
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
