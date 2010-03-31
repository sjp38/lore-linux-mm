Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3C8A56B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 13:28:59 -0400 (EDT)
Date: Wed, 31 Mar 2010 10:27:26 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [RFC][PATCH] memcg documentation update v2
Message-Id: <20100331102726.81973fd8.randy.dunlap@oracle.com>
In-Reply-To: <20100331175157.1c3a6940.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100329154245.455227d9.kamezawa.hiroyu@jp.fujitsu.com>
	<49b004811003291747s23c146ffx4a1aecc404b88145@mail.gmail.com>
	<20100331175157.1c3a6940.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 31 Mar 2010 17:51:57 +0900 KAMEZAWA Hiroyuki wrote:

> Added more changes since v1. 
> I'm not in hurry, please see when you have free time.

OK, I have some comments for you to consider.


> ==
> Documentation update. We have too much files now....
> 
> Changlog:
>  - added memory.soft_limit_in_bytes to summary.
>  - rewrite Testing section
>  - fixed text about page_cgroup allocation
>  - passed aspell(1) ;)
>  - rewrote Locking section
>  - update memory.stat file explanation
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  Documentation/cgroups/memory.txt |  187 ++++++++++++++++++++++++++++-----------
>  1 file changed, 139 insertions(+), 48 deletions(-)
> 
> Index: mmotm-2.6.34-Mar24/Documentation/cgroups/memory.txt
> ===================================================================
> --- mmotm-2.6.34-Mar24.orig/Documentation/cgroups/memory.txt
> +++ mmotm-2.6.34-Mar24/Documentation/cgroups/memory.txt

> @@ -33,6 +23,45 @@ d. A CD/DVD burner could control the amo
>  e. There are several other use cases, find one or use the controller just
>     for fun (to learn and hack on the VM subsystem).
>  
> +Current Status: linux-2.6.34-mmotom(development version of 2010/March)

                               -mmotm

> +
> +Features:
> + - accounting anonymous pages, file caches, swap caches usage and limit them.
> + - private LRU and reclaim routine. (system's global LRU and private LRU
> +   work independently from each other)
> + - optionally, memory+swap usage can be accounted and limited.
> + - hierarchical accounting
> + - soft limit
> + - moving(recharging) account at moving a task is selectable.
> + - usage threshold notifier
> + - oom-killer disable knob and oom-notifier
> + - Root cgroup has no limit controls.
> +
> + Kernel memory and Hugepages are not under control yet. We just manage
> + pages on LRU. To add more controls, we have to take care of performance.
> +
> +Brief summary of control files.
> +
> + tasks				 # attach a task(thread)
> + cgroup.procs			 # attach a process(all threads under it)
> + cgroup.event_control		 # an interface for event_fd()
> + memory.usage_in_bytes		 # show current memory(RSS+Cache) usage.
> + memory.memsw.usage_in_bytes	 # show current memory+Swap usage
> + memory.limit_in_bytes		 # set/show limit of memory usage
> + memory.memsw.limit_in_bytes	 # set/show limit of memory+Swap usage
> + memory.failcnt			 # show the number of memory usage hit limits
> + memory.memsw.failcnt		 # show the number of memory+Swap hit limits
> + memory.max_usage_in_bytes	 # show max memory usage recorded
> + memory.memsw.usage_in_bytes	 # show max memory+Swap usage recorded
> + memory.soft_limit_in_bytes	 # set/show soft limit of memory usage
> + memory.stat			 # show various statistics
> + memory.use_hierarchy		 # set/show hierarchical account enabled
> + memory.force_empty		 # trigger forced move charge to parent
> + memory.swappiness		 # set/show swappiness parameter of vmscan
> + 				  (See sysctl's vm.swappiness)
> + memory.move_charge_at_immigrate # set/show controls of moving charges
> + memory.oom_control		 # set/show oom controls.
> +
>  1. History
>  
>  The memory controller has a long history. A request for comments for the memory
> @@ -106,14 +135,14 @@ the necessary data structures and check 
>  is over its limit. If it is then reclaim is invoked on the cgroup.
>  More details can be found in the reclaim section of this document.
>  If everything goes well, a page meta-data-structure called page_cgroup is
> -allocated and associated with the page.  This routine also adds the page to
> -the per cgroup LRU.
> +updated. page_cgroup has its own LRU on cgroup.
> +(*) page_cgroup structure is allocated at boot/memory-hotplug time.
>  
>  2.2.1 Accounting details
>  
>  All mapped anon pages (RSS) and cache pages (Page Cache) are accounted.
> -(some pages which never be reclaimable and will not be on global LRU
> - are not accounted. we just accounts pages under usual vm management.)
> +Some pages which never be reclaimable and will not be on global LRU

Awkward sentence above.  Maybe:

   Some pages which are never reclaimable and will not be on the global LRU

> +are not accounted. we just accounts pages under usual vm management.

                      We just account

Prefer "VM" to "vm". (multiple places)

>  
>  RSS pages are accounted at page_fault unless they've already been accounted
>  for earlier. A file page will be accounted for as Page Cache when it's
> @@ -121,7 +150,12 @@ inserted into inode (radix-tree). While 
>  processes, duplicate accounting is carefully avoided.
>  
>  A RSS page is unaccounted when it's fully unmapped. A PageCache page is
> -unaccounted when it's removed from radix-tree.
> +unaccounted when it's removed from radix-tree. Even if RSS pages are fully
> +unmapped (by kswapd), it may exist as SwapCache in the system until it really

                         they                                          they are really

> +freed. Such SwapCache is also accounted. Swapped-in pages are not accounted
> +until it's mapped. This is because of swapin-readahead.

         they are mapped.

> +
> +A Cache pages is unaccounted when it's removed from inode (radix-tree).

           page

>  
>  At page migration, accounting information is kept.
>  
> @@ -143,6 +177,7 @@ caller of swapoff rather than the users 
>  
>  
>  2.4 Swap Extension (CONFIG_CGROUP_MEM_RES_CTLR_SWAP)
> +
>  Swap Extension allows you to record charge for swap. A swapped-in page is
>  charged back to original page allocator if possible.
>  
> @@ -150,9 +185,15 @@ When swap is accounted, following files 
>   - memory.memsw.usage_in_bytes.
>   - memory.memsw.limit_in_bytes.
>  
> -usage of mem+swap is limited by memsw.limit_in_bytes.
> +memsw means memory+swap. Usage of mem+swap is limited by memsw.limit_in_bytes.

OK, you define "memsw" as memory+swap, then use "mem+swap".  Is that the
same thing?  If so, I would use one of the first 2 choices and drop the last one
instead of having 3 phrases that mean the same thing.

>  
> -* why 'mem+swap' rather than swap.
> +example) Assume a system with 4G of swap. A task which allocates 6G of memory
> +(by mistake) under 2G memory limitation will use all swap.
> +In this case, setting memsw.limit_in_bytes=3G will prevent bad use of swap.
> +(bad process will cause OOM under the memcg. you can avoid system OOM because

    Bad                                         You

> + of no swap.)
> +
> +* why 'memory+swap' rather than swap.
>  The global LRU(kswapd) can swap out arbitrary pages. Swap-out means
>  to move account from memory to swap...there is no change in usage of
>  mem+swap. In other words, when we want to limit the usage of swap without
> @@ -168,12 +209,12 @@ it by cgroup.
>  
>  2.5 Reclaim
>  
> -Each cgroup maintains a per cgroup LRU that consists of an active
> -and inactive list. When a cgroup goes over its limit, we first try
> +Each cgroup maintains a per cgroup LRU which has the same structure as
> +global VM. When a cgroup goes over its limit, we first try
>  to reclaim memory from the cgroup so as to make space for the new
>  pages that the cgroup has touched. If the reclaim is unsuccessful,
>  an OOM routine is invoked to select and kill the bulkiest task in the
> -cgroup.
> +cgroup. (See 10. OOM Control below.)
>  
>  The reclaim algorithm has not been modified for cgroups, except that
>  pages that are selected for reclaiming come from the per cgroup LRU
> @@ -189,11 +230,17 @@ When oom event notifier is registered, e
>  
>  2. Locking
>  
> -The memory controller uses the following hierarchy
> +   lock_page_cgroup()/unlock_page_cgroup() should not be called under
> +   mapping->tree_lock.
>  
> -1. zone->lru_lock is used for selecting pages to be isolated
> -2. mem->per_zone->lru_lock protects the per cgroup LRU (per zone)
> -3. lock_page_cgroup() is used to protect page->page_cgroup
> +   Other lock order is following.

                          following:

> +   PG_locked.
> +   mm->page_table_lock
> +       zone->lru_lock
> +	  lock_page_cgroup.
> +  In many case, just lock_page_cgroup() is called.

             cases,

> +  per-zone-per-cgroup LRU (cgroup's private LRU) is just guarded by
> +  zone->lru_lock, it has no its own lock.

                     it has no lock of its own.

>  
>  3. User Interface
>  
> @@ -202,6 +249,7 @@ The memory controller uses the following
>  a. Enable CONFIG_CGROUPS
>  b. Enable CONFIG_RESOURCE_COUNTERS
>  c. Enable CONFIG_CGROUP_MEM_RES_CTLR
> +d. Enable CONFIG_CGROUP_MEM_RES_CTLR_SWAP (to use swap extension)
>  
>  1. Prepare the cgroups
>  # mkdir -p /cgroups
> @@ -216,16 +264,14 @@ We can alter the memory limit:
>  # echo 4M > /cgroups/0/memory.limit_in_bytes
>  
>  NOTE: We can use a suffix (k, K, m, M, g or G) to indicate values in kilo,
> -mega or gigabytes.
> +mega or gigabytes. (Here, Kilo, Mega, Giga is Kibibytes, Mebibytes, Gibibytes)

                                              are                       ...bytes.)

> +
>  NOTE: We can write "-1" to reset the *.limit_in_bytes(unlimited).
>  NOTE: We cannot set limits on the root cgroup any more.
>  
>  # cat /cgroups/0/memory.limit_in_bytes
>  4194304
>  
> -NOTE: The interface has now changed to display the usage in bytes
> -instead of pages
> -
>  We can check the usage:
>  # cat /cgroups/0/memory.usage_in_bytes
>  1216512
> @@ -248,15 +294,24 @@ caches, RSS and Active pages/Inactive pa
>  
>  4. Testing
>  
> -Balbir posted lmbench, AIM9, LTP and vmmstress results [10] and [11].
> -Apart from that v6 has been tested with several applications and regular
> -daily use. The controller has also been tested on the PPC64, x86_64 and
> -UML platforms.
> +For testing feature and implementation, see memcg_test.txt.

               features

> +
> +Performance test is also important. To see pure memcg's overhead,
> +testing om tmpfs will give you good numbers of small overheads.
> +example) do kernel make on tmpfs.

  Example:

> +
> +Page-fault scalability is also important. At measuring pararell

                                                          parallel

> +page fault test, multi-process test may be better than multi-thread
> +test because multi-thread shares something and need sync.
> +
> +But above 2 is testing extreme situation. Trying usual test under memcg
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
> @@ -264,6 +319,9 @@ terminated. There are several causes for
>  A sync followed by echo 1 > /proc/sys/vm/drop_caches will help get rid of
>  some of the pages cached in the cgroup (page cache pages).
>  
> +To know what happens, disable OOM_Kill by 10.OOM Control(see below) and

           insert space:                     10. OOM Control

> +see what happens will be a help.

   seeing what happens will be helpful.

> +
>  4.2 Task migration
>  
>  When a task migrates from one cgroup to another, it's charge is not
> @@ -271,16 +329,19 @@ carried forward by default. The pages al
>  remain charged to it, the charge is dropped when the page is freed or
>  reclaimed.
>  
> -Note: You can move charges of a task along with task migration. See 8.
> +You can move charges of a task along with task migration.
> +See 8. "Move charges at task migration"
>  
>  4.3 Removing a cgroup
>  
>  A cgroup can be removed by rmdir, but as discussed in sections 4.1 and 4.2, a
>  cgroup might have some charge associated with it, even though all
> -tasks have migrated away from it.
> -Such charges are freed(at default) or moved to its parent. When moved,
> -both of RSS and CACHES are moved to parent.
> -If both of them are busy, rmdir() returns -EBUSY. See 5.1 Also.
> +tasks have migrated away from it. (because we charge against pages, not
> +against tasks.)
> +
> +Such charges are freed or moved to its parent. At moving, both of RSS

                                      their

> +and CACHES are moved to parent.
> +rmdir() may return -EBUSY if freeing/moving fails. See 5.1 Also.

                                                              also.

>  
>  Charges recorded in swap information is not updated at removal of cgroup.
>  Recorded information is discarded and a cgroup which uses swap (swapcache)
> @@ -309,19 +370,41 @@ will be charged as a new owner of it.
>  
>  memory.stat file includes following statistics
>  
> +# per-memcg local status
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
>  		  inactive lru list.
> -active_file	- # of bytes of file-backed memory on active lru list.
>  inactive_file	- # of bytes of file-backed memory on inactive lru list.
> +active_file	- # of bytes of file-backed memory on active lru list.
>  unevictable	- # of bytes of memory that cannot be reclaimed (mlocked etc).
>  
> -The following additional stats are dependent on CONFIG_DEBUG_VM.
> +# status considering hierarchy (see memory.use_hierarchy settings)
> +
> +hierarchical_memory_limit - # of bytes of memory limit with regard to hierarchy
> +			under which the memcg is
> +hierarchical_memsw_limit - # of bytes of memory+swap limit with regard to
> +			hierarchy under which memcg is.
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
> @@ -337,17 +420,25 @@ Memo:
>  Note:
>  	Only anonymous and swap cache memory is listed as part of 'rss' stat.
>  	This should not be confused with the true 'resident set size' or the
> -	amount of physical memory used by the cgroup. Per-cgroup rss
> -	accounting is not done yet.
> +	amount of physical memory used by the cgroup.
> +	'rss + file_mapped" will give you resident set size of cgroup.
> +	(Note: file and shmem may be shared amoung other cgroups. In that case,
> +	 file_mapped is accounted only when the memcg is owner of page cache.)
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
> +This failcnt(== failure count) shows the number of events that usage counter

                                  shows the number of times that a usage counter

> +hit limits. When a memory controller hit limit, failcnt increase and memory

   hit its limit. When a memory controller hits a limit, failcnt increases and memory

> +under it will be reclaimed.
>  
>  6. Hierarchy support
>  


HTH.

---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
