Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 46F986B0210
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 13:33:22 -0400 (EDT)
Date: Thu, 8 Apr 2010 10:32:09 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] memcg: update documentation v3
Message-Id: <20100408103209.bf6d8329.randy.dunlap@oracle.com>
In-Reply-To: <20100408145800.ca90ad81.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100408145800.ca90ad81.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, randy.dunlap@oracle.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Apr 2010 14:58:00 +0900 KAMEZAWA Hiroyuki wrote:

> 
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Documentation update for memory cgroup
> 
> Some informations are old, and  I think current document doesn't work
> as "a guide for users".
> We need summary of all of our controls, at least.
> 
> This patch updates information for current implementations and add a
> summary of interfaces. etc...

I found some more... (below)


> Changelog:
>  - fixed tons of typos.
>  - replaced "memcg" with "memory cgroup" AMAP.
>  - replaced "mem+swap" with "memory+swap"
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  Documentation/cgroups/memory.txt |  210 ++++++++++++++++++++++++++++-----------
>  1 file changed, 152 insertions(+), 58 deletions(-)
> 
> Index: mmotm-temp/Documentation/cgroups/memory.txt
> ===================================================================
> --- mmotm-temp.orig/Documentation/cgroups/memory.txt
> +++ mmotm-temp/Documentation/cgroups/memory.txt

> @@ -121,12 +150,18 @@ inserted into inode (radix-tree). While 
>  processes, duplicate accounting is carefully avoided.
>  
>  A RSS page is unaccounted when it's fully unmapped. A PageCache page is
> -unaccounted when it's removed from radix-tree.
> +unaccounted when it's removed from radix-tree. Even if RSS pages are fully
> +unmapped (by kswapd), they may exist as SwapCache in the system until they
> +are really freed. Such SwapCaches also also accounted.
> +A swapped-in page is not accounted until it's mapped. It's bacause we can't

                                                         This is because

> +know a page will be finaly mapped at swapin-readahead happens.

                       finally mapped until

> +
> +A Cache pages is unaccounted when it's removed from inode (radix-tree).

           page

>  
>  At page migration, accounting information is kept.
>  
>  Note: we just account pages-on-lru because our purpose is to control amount
> -of used pages. not-on-lru pages are tend to be out-of-control from vm view.
> +of used pages. not-on-lru pages are tend to be out-of-control from VM view.

drop:                              are

>  
>  2.3 Shared Page Accounting
>  

> @@ -248,15 +296,24 @@ caches, RSS and Active pages/Inactive pa
>  
>  4. Testing
>  
> -Balbir posted lmbench, AIM9, LTP and vmmstress results [10] and [11].
> -Apart from that v6 has been tested with several applications and regular
> -daily use. The controller has also been tested on the PPC64, x86_64 and
> -UML platforms.
> +For testing features and implementation, see memcg_test.txt.
> +
> +Performance test is also important. To see pure memory cgroup's overhead,
> +testing on tmpfs will give you good numbers of small overheads.
> +Example) do kernel make on tmpfs.

   Example:

> +
> +Page-fault scalability is also important. At measuring parallel
> +page fault test, multi-process test may be better than multi-thread
> +test because it has noise of shared objects/status.
> +
> +But above 2 is testing extreme situation. Trying usual test under memory cgroup

               are testing extreme situations.

> +is always helpful.
> +
>  
>  4.1 Troubleshooting
>  
>  Sometimes a user might find that the application under a cgroup is
> -terminated. There are several causes for this:
> +terminated by OOM killer. There are several causes for this:
>  
>  1. The cgroup limit is too low (just too low to do anything useful)
>  2. The user is using anonymous memory and swap is turned off or too low

> @@ -296,10 +359,10 @@ will be charged as a new owner of it.
>  
>    # echo 0 > memory.force_empty
>  
> -  Almost all pages tracked by this memcg will be unmapped and freed. Some of
> -  pages cannot be freed because it's locked or in-use. Such pages are moved
> -  to parent and this cgroup will be empty. But this may return -EBUSY in
> -  some too busy case.
> +  Almost all pages tracked by this memory cgroup will be unmapped and freed.
> +  Some of pages cannot be freed because it's locked or in-use. Such pages are

     Some pages                            they are locked

> +  moved to parent and this cgroup will be empty. This may return -EBUSY if
> +  VM is too busy to free/move all pages immediately.
>  
>    Typical use case of this interface is that calling this before rmdir().
>    Because rmdir() moves all pages to parent, some out-of-use page caches can be
> @@ -309,19 +372,41 @@ will be charged as a new owner of it.
>  
>  memory.stat file includes following statistics
>  
> +# per-memory cgroup local status
>  cache		- # of bytes of page cache memory.
>  rss		- # of bytes of anonymous and swap cache memory.
> +mapped_file	- # of bytes of mapped file (includes tmpfs/shmem)
>  pgpgin		- # of pages paged in (equivalent to # of charging events).
>  pgpgout		- # of pages paged out (equivalent to # of uncharging events).
> -active_anon	- # of bytes of anonymous and  swap cache memory on active
> -		  lru list.
> +swap		- # of bytes of swap usage
>  inactive_anon	- # of bytes of anonymous memory and swap cache memory on
> +		  lru list.
> +active_anon	- # of bytes of anonymous and  swap cache memory on active

drop one space between:                   and  swap

>  		  inactive lru list.

It would be better to use LRU throughout the file instead of using LRU in some
places and lru in others (except when referring to variable names, of course).

> -active_file	- # of bytes of file-backed memory on active lru list.
>  inactive_file	- # of bytes of file-backed memory on inactive lru list.
> +active_file	- # of bytes of file-backed memory on active lru list.
>  unevictable	- # of bytes of memory that cannot be reclaimed (mlocked etc).
>  
> -The following additional stats are dependent on CONFIG_DEBUG_VM.
> +# status considering hierarchy (see memory.use_hierarchy settings)
> +
> +hierarchical_memory_limit - # of bytes of memory limit with regard to hierarchy
> +			under which the memory cgroup is
> +hierarchical_memsw_limit - # of bytes of memory+swap limit with regard to
> +			hierarchy under which memory cgroup is.
> +
> +total_cache		- sum of all children's "cache"
> +total_rss		- sum of all children's "rss"
> +total_mapped_file	- sum of all children's "cache"
> +total_pgpgin		- sum of all children's "pgpgin"
> +total_pgpgout		- sum of all children's "pgpgout"
> +total_swap		- sum of all children's "swap"
> +total_inactive_anon	- sum of all children's "inactive_anon"
> +total_active_anon	- sum of all children's "active_anon"
> +total_inactive_file	- sum of all children's "inactive_file"
> +total_active_file	- sum of all children's "active_file"
> +total_unevictable	- sum of all children's "unevictable"
> +
> +# The following additional stats are dependent on CONFIG_DEBUG_VM.
>  
>  inactive_ratio		- VM internal parameter. (see mm/page_alloc.c)
>  recent_rotated_anon	- VM internal parameter. (see mm/vmscan.c)
> @@ -337,17 +422,26 @@ Memo:
>  Note:
>  	Only anonymous and swap cache memory is listed as part of 'rss' stat.
>  	This should not be confused with the true 'resident set size' or the
> -	amount of physical memory used by the cgroup. Per-cgroup rss
> -	accounting is not done yet.
> +	amount of physical memory used by the cgroup.
> +	'rss + file_mapped" will give you resident set size of cgroup.
> +	(Note: file and shmem may be shared amoung other cgroups. In that case,
> +	 file_mapped is accounted only when the memory cgroup is owner of page
> +	 cache.)
>  
>  5.3 swappiness
>    Similar to /proc/sys/vm/swappiness, but affecting a hierarchy of groups only.
>  
>    Following cgroups' swappiness can't be changed.
>    - root cgroup (uses /proc/sys/vm/swappiness).
> -  - a cgroup which uses hierarchy and it has child cgroup.
> +  - a cgroup which uses hierarchy and it has other cgroup(s) below it.
>    - a cgroup which uses hierarchy and not the root of hierarchy.
>  
> +5.4 failcnt
> +
> +The memory controller provides memory.failcnt and memory.memsw.failcnt files.
> +This failcnt(== failure count) shows the number of times that a usage counter
> +hit its limit. When a memory controller hit a limit, failcnt increases and

                                           hits

> +memory under it will be reclaimed.
>  
>  6. Hierarchy support
>  

> @@ -513,9 +607,9 @@ As.
>  
>  This operation is only allowed to the top cgroup of subhierarchy.
>  If oom-killer is disabled, tasks under cgroup will hang/sleep
> -in memcg's oom-waitq when they request accountable memory.
> +in memory cgroup's oom-waitq when they request accountable memory.
>  
> -For running them, you have to relax the memcg's oom sitaution by
> +For running them, you have to relax the memory cgroup's oom sitaution by

It would be better to use OOM instead of oom throughout the file...

>  	* enlarge limit or reduce usage.
>  To reduce usage,
>  	* kill some tasks.
> @@ -526,7 +620,7 @@ Then, stopped tasks will work again.
>  
>  At reading, current status of OOM is shown.
>  	oom_kill_disable 0 or 1 (if 1, oom-killer is disabled)
> -	under_oom	 0 or 1 (if 1, the memcg is under OOM,tasks may
> +	under_oom	 0 or 1 (if 1, the memory cgroup is under OOM,tasks may

space after:                                                      OOM, tasks may

>  				 be stopped.)
>  
>  11. TODO
> 
> --


---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
