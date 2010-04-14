Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 75EE46B020A
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 21:26:18 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3E1QCk1021226
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 14 Apr 2010 10:26:12 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F00045DE52
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 10:26:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C2F445DE4F
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 10:26:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D38B1DB803C
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 10:26:12 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 970131DB8037
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 10:26:11 +0900 (JST)
Date: Wed, 14 Apr 2010 10:22:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg: update documentation v7
Message-Id: <20100414102221.2c540a0d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4BC493B4.2040709@oracle.com>
References: <20100408145800.ca90ad81.kamezawa.hiroyu@jp.fujitsu.com>
	<20100409134553.58096f80.kamezawa.hiroyu@jp.fujitsu.com>
	<20100409100430.7409c7c4.randy.dunlap@oracle.com>
	<20100413134553.7e2c4d3d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100413060405.GF3994@balbir.in.ibm.com>
	<20100413152048.55408738.kamezawa.hiroyu@jp.fujitsu.com>
	<20100413064855.GH3994@balbir.in.ibm.com>
	<20100413155841.ca6bc425.kamezawa.hiroyu@jp.fujitsu.com>
	<4BC493B4.2040709@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Apr 2010 08:54:28 -0700
Randy Dunlap <randy.dunlap@oracle.com> wrote:
> > @@ -33,6 +23,45 @@ d. A CD/DVD burner could control the amo
> >  e. There are several other use cases, find one or use the controller just
> >     for fun (to learn and hack on the VM subsystem).
> >  
> > +Current Status: linux-2.6.34-mmotm(development version of 2010/April)
> > +
> > +Features:
> > + - accounting anonymous pages, file caches, swap caches usage and limit them.
> 
>                                                                  and limiting them.
> 
fixed.

> > + - private LRU and reclaim routine. (system's global LRU and private LRU
> > +   work independently from each other)
> > + - optionally, memory+swap usage can be accounted and limited.
> > + - hierarchical accounting
> > + - soft limit
> > + - moving(recharging) account at moving a task is selectable.
> > + - usage threshold notifier
> > + - oom-killer disable knob and oom-notifier
> > + - Root cgroup has no limit controls.
> > +
> > + Kernel memory and Hugepages are not under control yet. We just manage
> > + pages on LRU. To add more controls, we have to take care of performance.
> > +
> > +Brief summary of control files.
> 
> > @@ -121,12 +150,19 @@ inserted into inode (radix-tree). While 
> >  processes, duplicate accounting is carefully avoided.
> >  
> >  A RSS page is unaccounted when it's fully unmapped. A PageCache page is
> > -unaccounted when it's removed from radix-tree.
> > +unaccounted when it's removed from radix-tree. Even if RSS pages are fully
> > +unmapped (by kswapd), they may exist as SwapCache in the system until they
> > +are really freed. Such SwapCaches also also accounted.
> > +A swapped-in page is not accounted until it's mapped.
> > +
> > +Note: The kernel does swapin-readahead and read multiple swaps at once.
> > +This means swapped-in pages may contain pages for other tasks than a task
> > +causing page fault. So, we avoid accounting at swap-in I/O.
> >  
> >  At page migration, accounting information is kept.
> >  
> > -Note: we just account pages-on-lru because our purpose is to control amount
> > -of used pages. not-on-lru pages are tend to be out-of-control from vm view.
> > +Note: we just account pages-on-LRU because our purpose is to control amount
> > +of used pages, not-on-LRU pages tend to be out-of-control from VM view.
> 
> using a         ; there would be even better.
> (yes, I know that you just changed it.)
> 
ok.

> >  
> >  2.3 Shared Page Accounting
> >  
> 
> > @@ -209,31 +260,29 @@ c. Enable CONFIG_CGROUP_MEM_RES_CTLR
> >  
> >  2. Make the new group and move bash into it
> >  # mkdir /cgroups/0
> > -# echo $$ >  /cgroups/0/tasks
> > +# echo $$ > /cgroups/0/tasks
> >  
> >  Since now we're in the 0 cgroup,
> >  We can alter the memory limit:
> 
>    we
> (and no need for 2 lines above)
> 
Sure.

> >  # echo 4M > /cgroups/0/memory.limit_in_bytes
> 
> > @@ -418,7 +516,7 @@ If we want to change this to 1G, we can 
> >  # echo 1G > memory.soft_limit_in_bytes
> >  
> >  NOTE1: Soft limits take effect over a long period of time, since they involve
> > -       reclaiming memory for balancing between memory cgroups
> > +reclaiming memory for balancing between memory cgroups
> 
> Put the indentation back, please.
> 
Ah, I thought I changed that ....seems my mistake, sorry.

==here==

Documentation update.

Some information are old, and  I think current document doesn't work
as "a guide for users".
We need summary of all of our controls, at least.

Changelog: 2010/04/14
* applied feedback
* Add a text about "memory cgroup" at the place explaining "memory controller"
* adjusted onto Nishimura's memcg-move-charge-of-file-pages.patch
  (add an fix mmaped -> mmapped...Hmm? mapped is better ?)

Changelog: 2010/04/13
* applied feedback
* fixed <memory.usage_in_bytes> with <fd of memory.usage_in_bytes>
  at explaining how-to-use eventfd.

Changelog: 2010/04/12
* applied feedback

Changelog: 2010/04/09
* replace 'lru' with 'LRU' and 'oom' with 'OOM'
* fixed double-space breakage
* applied all comments and fixed wrong parts pointed out.
* fixed cgroup.procs

Changelog: 2009/04/07
* fixed tons of typos.
* replaced "memcg" with "memory cgroup" AMAP.
* replaced "mem+swap" with "memory+swap"

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/memory.txt |  289 ++++++++++++++++++++++++++-------------
 1 file changed, 197 insertions(+), 92 deletions(-)

Index: mmotm-temp/Documentation/cgroups/memory.txt
===================================================================
--- mmotm-temp.orig/Documentation/cgroups/memory.txt
+++ mmotm-temp/Documentation/cgroups/memory.txt
@@ -1,18 +1,15 @@
 Memory Resource Controller
 
 NOTE: The Memory Resource Controller has been generically been referred
-to as the memory controller in this document. Do not confuse memory controller
-used here with the memory controller that is used in hardware.
+      to as the memory controller in this document. Do not confuse memory
+      controller used here with the memory controller that is used in hardware.
 
-Salient features
-
-a. Enable control of Anonymous, Page Cache (mapped and unmapped) and
-   Swap Cache memory pages.
-b. The infrastructure allows easy addition of other types of memory to control
-c. Provides *zero overhead* for non memory controller users
-d. Provides a double LRU: global memory pressure causes reclaim from the
-   global LRU; a cgroup on hitting a limit, reclaims from the per
-   cgroup LRU
+(For editors)
+In this document:
+      When we mention a cgroup (cgroupfs's directory) with memory controller,
+      we call it "memory cgroup". When you see git-log and source code, you'll
+      see patch's title and function names tend to use "memcg".
+      In this document, we avoid to use it.
 
 Benefits and Purpose of the memory controller
 
@@ -33,6 +30,45 @@ d. A CD/DVD burner could control the amo
 e. There are several other use cases, find one or use the controller just
    for fun (to learn and hack on the VM subsystem).
 
+Current Status: linux-2.6.34-mmotm(development version of 2010/April)
+
+Features:
+ - accounting anonymous pages, file caches, swap caches usage and limiting them.
+ - private LRU and reclaim routine. (system's global LRU and private LRU
+   work independently from each other)
+ - optionally, memory+swap usage can be accounted and limited.
+ - hierarchical accounting
+ - soft limit
+ - moving(recharging) account at moving a task is selectable.
+ - usage threshold notifier
+ - oom-killer disable knob and oom-notifier
+ - Root cgroup has no limit controls.
+
+ Kernel memory and Hugepages are not under control yet. We just manage
+ pages on LRU. To add more controls, we have to take care of performance.
+
+Brief summary of control files.
+
+ tasks				 # attach a task(thread) and show list of threads
+ cgroup.procs			 # show list of processes
+ cgroup.event_control		 # an interface for event_fd()
+ memory.usage_in_bytes		 # show current memory(RSS+Cache) usage.
+ memory.memsw.usage_in_bytes	 # show current memory+Swap usage
+ memory.limit_in_bytes		 # set/show limit of memory usage
+ memory.memsw.limit_in_bytes	 # set/show limit of memory+Swap usage
+ memory.failcnt			 # show the number of memory usage hits limits
+ memory.memsw.failcnt		 # show the number of memory+Swap hits limits
+ memory.max_usage_in_bytes	 # show max memory usage recorded
+ memory.memsw.usage_in_bytes	 # show max memory+Swap usage recorded
+ memory.soft_limit_in_bytes	 # set/show soft limit of memory usage
+ memory.stat			 # show various statistics
+ memory.use_hierarchy		 # set/show hierarchical account enabled
+ memory.force_empty		 # trigger forced move charge to parent
+ memory.swappiness		 # set/show swappiness parameter of vmscan
+ 				 (See sysctl's vm.swappiness)
+ memory.move_charge_at_immigrate # set/show controls of moving charges
+ memory.oom_control		 # set/show oom controls.
+
 1. History
 
 The memory controller has a long history. A request for comments for the memory
@@ -106,14 +142,14 @@ the necessary data structures and check 
 is over its limit. If it is then reclaim is invoked on the cgroup.
 More details can be found in the reclaim section of this document.
 If everything goes well, a page meta-data-structure called page_cgroup is
-allocated and associated with the page.  This routine also adds the page to
-the per cgroup LRU.
+updated. page_cgroup has its own LRU on cgroup.
+(*) page_cgroup structure is allocated at boot/memory-hotplug time.
 
 2.2.1 Accounting details
 
 All mapped anon pages (RSS) and cache pages (Page Cache) are accounted.
-(some pages which never be reclaimable and will not be on global LRU
- are not accounted. we just accounts pages under usual vm management.)
+Some pages which are never reclaimable and will not be on the global LRU
+are not accounted. We just account pages under usual VM management.
 
 RSS pages are accounted at page_fault unless they've already been accounted
 for earlier. A file page will be accounted for as Page Cache when it's
@@ -121,12 +157,19 @@ inserted into inode (radix-tree). While 
 processes, duplicate accounting is carefully avoided.
 
 A RSS page is unaccounted when it's fully unmapped. A PageCache page is
-unaccounted when it's removed from radix-tree.
+unaccounted when it's removed from radix-tree. Even if RSS pages are fully
+unmapped (by kswapd), they may exist as SwapCache in the system until they
+are really freed. Such SwapCaches also also accounted.
+A swapped-in page is not accounted until it's mapped.
+
+Note: The kernel does swapin-readahead and read multiple swaps at once.
+This means swapped-in pages may contain pages for other tasks than a task
+causing page fault. So, we avoid accounting at swap-in I/O.
 
 At page migration, accounting information is kept.
 
-Note: we just account pages-on-lru because our purpose is to control amount
-of used pages. not-on-lru pages are tend to be out-of-control from vm view.
+Note: we just account pages-on-LRU because our purpose is to control amount
+of used pages; not-on-LRU pages tend to be out-of-control from VM view.
 
 2.3 Shared Page Accounting
 
@@ -143,6 +186,7 @@ caller of swapoff rather than the users 
 
 
 2.4 Swap Extension (CONFIG_CGROUP_MEM_RES_CTLR_SWAP)
+
 Swap Extension allows you to record charge for swap. A swapped-in page is
 charged back to original page allocator if possible.
 
@@ -150,13 +194,20 @@ When swap is accounted, following files 
  - memory.memsw.usage_in_bytes.
  - memory.memsw.limit_in_bytes.
 
-usage of mem+swap is limited by memsw.limit_in_bytes.
+memsw means memory+swap. Usage of memory+swap is limited by
+memsw.limit_in_bytes.
 
-* why 'mem+swap' rather than swap.
+Example: Assume a system with 4G of swap. A task which allocates 6G of memory
+(by mistake) under 2G memory limitation will use all swap.
+In this case, setting memsw.limit_in_bytes=3G will prevent bad use of swap.
+By using memsw limit, you can avoid system OOM which can be caused by swap
+shortage.
+
+* why 'memory+swap' rather than swap.
 The global LRU(kswapd) can swap out arbitrary pages. Swap-out means
 to move account from memory to swap...there is no change in usage of
-mem+swap. In other words, when we want to limit the usage of swap without
-affecting global LRU, mem+swap limit is better than just limiting swap from
+memory+swap. In other words, when we want to limit the usage of swap without
+affecting global LRU, memory+swap limit is better than just limiting swap from
 OS point of view.
 
 * What happens when a cgroup hits memory.memsw.limit_in_bytes
@@ -168,12 +219,12 @@ it by cgroup.
 
 2.5 Reclaim
 
-Each cgroup maintains a per cgroup LRU that consists of an active
-and inactive list. When a cgroup goes over its limit, we first try
+Each cgroup maintains a per cgroup LRU which has the same structure as
+global VM. When a cgroup goes over its limit, we first try
 to reclaim memory from the cgroup so as to make space for the new
 pages that the cgroup has touched. If the reclaim is unsuccessful,
 an OOM routine is invoked to select and kill the bulkiest task in the
-cgroup.
+cgroup. (See 10. OOM Control below.)
 
 The reclaim algorithm has not been modified for cgroups, except that
 pages that are selected for reclaiming come from the per cgroup LRU
@@ -187,13 +238,19 @@ Note2: When panic_on_oom is set to "2", 
 When oom event notifier is registered, event will be delivered.
 (See oom_control section)
 
-2. Locking
+2.6 Locking
 
-The memory controller uses the following hierarchy
+   lock_page_cgroup()/unlock_page_cgroup() should not be called under
+   mapping->tree_lock.
 
-1. zone->lru_lock is used for selecting pages to be isolated
-2. mem->per_zone->lru_lock protects the per cgroup LRU (per zone)
-3. lock_page_cgroup() is used to protect page->page_cgroup
+   Other lock order is following:
+   PG_locked.
+   mm->page_table_lock
+       zone->lru_lock
+	  lock_page_cgroup.
+  In many cases, just lock_page_cgroup() is called.
+  per-zone-per-cgroup LRU (cgroup's private LRU) is just guarded by
+  zone->lru_lock, it has no lock of its own.
 
 3. User Interface
 
@@ -202,6 +259,7 @@ The memory controller uses the following
 a. Enable CONFIG_CGROUPS
 b. Enable CONFIG_RESOURCE_COUNTERS
 c. Enable CONFIG_CGROUP_MEM_RES_CTLR
+d. Enable CONFIG_CGROUP_MEM_RES_CTLR_SWAP (to use swap extension)
 
 1. Prepare the cgroups
 # mkdir -p /cgroups
@@ -209,31 +267,28 @@ c. Enable CONFIG_CGROUP_MEM_RES_CTLR
 
 2. Make the new group and move bash into it
 # mkdir /cgroups/0
-# echo $$ >  /cgroups/0/tasks
+# echo $$ > /cgroups/0/tasks
 
-Since now we're in the 0 cgroup,
-We can alter the memory limit:
+Since now we're in the 0 cgroup, we can alter the memory limit:
 # echo 4M > /cgroups/0/memory.limit_in_bytes
 
 NOTE: We can use a suffix (k, K, m, M, g or G) to indicate values in kilo,
-mega or gigabytes.
+mega or gigabytes. (Here, Kilo, Mega, Giga are Kibibytes, Mebibytes, Gibibytes.)
+
 NOTE: We can write "-1" to reset the *.limit_in_bytes(unlimited).
 NOTE: We cannot set limits on the root cgroup any more.
 
 # cat /cgroups/0/memory.limit_in_bytes
 4194304
 
-NOTE: The interface has now changed to display the usage in bytes
-instead of pages
-
 We can check the usage:
 # cat /cgroups/0/memory.usage_in_bytes
 1216512
 
 A successful write to this file does not guarantee a successful set of
-this limit to the value written into the file.  This can be due to a
+this limit to the value written into the file. This can be due to a
 number of factors, such as rounding up to page boundaries or the total
-availability of memory on the system.  The user is required to re-read
+availability of memory on the system. The user is required to re-read
 this file after a write to guarantee the value committed by the kernel.
 
 # echo 1 > memory.limit_in_bytes
@@ -248,15 +303,23 @@ caches, RSS and Active pages/Inactive pa
 
 4. Testing
 
-Balbir posted lmbench, AIM9, LTP and vmmstress results [10] and [11].
-Apart from that v6 has been tested with several applications and regular
-daily use. The controller has also been tested on the PPC64, x86_64 and
-UML platforms.
+For testing features and implementation, see memcg_test.txt.
+
+Performance test is also important. To see pure memory controller's overhead,
+testing on tmpfs will give you good numbers of small overheads.
+Example: do kernel make on tmpfs.
+
+Page-fault scalability is also important. At measuring parallel
+page fault test, multi-process test may be better than multi-thread
+test because it has noise of shared objects/status.
+
+But the above two are testing extreme situations.
+Trying usual test under memory controller is always helpful.
 
 4.1 Troubleshooting
 
 Sometimes a user might find that the application under a cgroup is
-terminated. There are several causes for this:
+terminated by OOM killer. There are several causes for this:
 
 1. The cgroup limit is too low (just too low to do anything useful)
 2. The user is using anonymous memory and swap is turned off or too low
@@ -264,6 +327,9 @@ terminated. There are several causes for
 A sync followed by echo 1 > /proc/sys/vm/drop_caches will help get rid of
 some of the pages cached in the cgroup (page cache pages).
 
+To know what happens, disable OOM_Kill by 10. OOM Control(see below) and
+seeing what happens will be helpful.
+
 4.2 Task migration
 
 When a task migrates from one cgroup to another, it's charge is not
@@ -271,16 +337,19 @@ carried forward by default. The pages al
 remain charged to it, the charge is dropped when the page is freed or
 reclaimed.
 
-Note: You can move charges of a task along with task migration. See 8.
+You can move charges of a task along with task migration.
+See 8. "Move charges at task migration"
 
 4.3 Removing a cgroup
 
 A cgroup can be removed by rmdir, but as discussed in sections 4.1 and 4.2, a
 cgroup might have some charge associated with it, even though all
-tasks have migrated away from it.
-Such charges are freed(at default) or moved to its parent. When moved,
-both of RSS and CACHES are moved to parent.
-If both of them are busy, rmdir() returns -EBUSY. See 5.1 Also.
+tasks have migrated away from it. (because we charge against pages, not
+against tasks.)
+
+Such charges are freed or moved to their parent. At moving, both of RSS
+and CACHES are moved to parent.
+rmdir() may return -EBUSY if freeing/moving fails. See 5.1 also.
 
 Charges recorded in swap information is not updated at removal of cgroup.
 Recorded information is discarded and a cgroup which uses swap (swapcache)
@@ -296,10 +365,10 @@ will be charged as a new owner of it.
 
   # echo 0 > memory.force_empty
 
-  Almost all pages tracked by this memcg will be unmapped and freed. Some of
-  pages cannot be freed because it's locked or in-use. Such pages are moved
-  to parent and this cgroup will be empty. But this may return -EBUSY in
-  some too busy case.
+  Almost all pages tracked by this memory cgroup will be unmapped and freed.
+  Some pages cannot be freed because they are locked or in-use. Such pages are
+  moved to parent and this cgroup will be empty. This may return -EBUSY if
+  VM is too busy to free/move all pages immediately.
 
   Typical use case of this interface is that calling this before rmdir().
   Because rmdir() moves all pages to parent, some out-of-use page caches can be
@@ -309,19 +378,41 @@ will be charged as a new owner of it.
 
 memory.stat file includes following statistics
 
+# per-memory cgroup local status
 cache		- # of bytes of page cache memory.
 rss		- # of bytes of anonymous and swap cache memory.
+mapped_file	- # of bytes of mapped file (includes tmpfs/shmem)
 pgpgin		- # of pages paged in (equivalent to # of charging events).
 pgpgout		- # of pages paged out (equivalent to # of uncharging events).
-active_anon	- # of bytes of anonymous and  swap cache memory on active
-		  lru list.
+swap		- # of bytes of swap usage
 inactive_anon	- # of bytes of anonymous memory and swap cache memory on
-		  inactive lru list.
-active_file	- # of bytes of file-backed memory on active lru list.
-inactive_file	- # of bytes of file-backed memory on inactive lru list.
+		LRU list.
+active_anon	- # of bytes of anonymous and swap cache memory on active
+		inactive LRU list.
+inactive_file	- # of bytes of file-backed memory on inactive LRU list.
+active_file	- # of bytes of file-backed memory on active LRU list.
 unevictable	- # of bytes of memory that cannot be reclaimed (mlocked etc).
 
-The following additional stats are dependent on CONFIG_DEBUG_VM.
+# status considering hierarchy (see memory.use_hierarchy settings)
+
+hierarchical_memory_limit - # of bytes of memory limit with regard to hierarchy
+			under which the memory cgroup is
+hierarchical_memsw_limit - # of bytes of memory+swap limit with regard to
+			hierarchy under which memory cgroup is.
+
+total_cache		- sum of all children's "cache"
+total_rss		- sum of all children's "rss"
+total_mapped_file	- sum of all children's "cache"
+total_pgpgin		- sum of all children's "pgpgin"
+total_pgpgout		- sum of all children's "pgpgout"
+total_swap		- sum of all children's "swap"
+total_inactive_anon	- sum of all children's "inactive_anon"
+total_active_anon	- sum of all children's "active_anon"
+total_inactive_file	- sum of all children's "inactive_file"
+total_active_file	- sum of all children's "active_file"
+total_unevictable	- sum of all children's "unevictable"
+
+# The following additional stats are dependent on CONFIG_DEBUG_VM.
 
 inactive_ratio		- VM internal parameter. (see mm/page_alloc.c)
 recent_rotated_anon	- VM internal parameter. (see mm/vmscan.c)
@@ -330,24 +421,37 @@ recent_scanned_anon	- VM internal parame
 recent_scanned_file	- VM internal parameter. (see mm/vmscan.c)
 
 Memo:
-	recent_rotated means recent frequency of lru rotation.
-	recent_scanned means recent # of scans to lru.
+	recent_rotated means recent frequency of LRU rotation.
+	recent_scanned means recent # of scans to LRU.
 	showing for better debug please see the code for meanings.
 
 Note:
 	Only anonymous and swap cache memory is listed as part of 'rss' stat.
 	This should not be confused with the true 'resident set size' or the
-	amount of physical memory used by the cgroup. Per-cgroup rss
-	accounting is not done yet.
+	amount of physical memory used by the cgroup.
+	'rss + file_mapped" will give you resident set size of cgroup.
+	(Note: file and shmem may be shared among other cgroups. In that case,
+	 file_mapped is accounted only when the memory cgroup is owner of page
+	 cache.)
 
 5.3 swappiness
-  Similar to /proc/sys/vm/swappiness, but affecting a hierarchy of groups only.
 
-  Following cgroups' swappiness can't be changed.
-  - root cgroup (uses /proc/sys/vm/swappiness).
-  - a cgroup which uses hierarchy and it has child cgroup.
-  - a cgroup which uses hierarchy and not the root of hierarchy.
+Similar to /proc/sys/vm/swappiness, but affecting a hierarchy of groups only.
+
+Following cgroups' swappiness can't be changed.
+- root cgroup (uses /proc/sys/vm/swappiness).
+- a cgroup which uses hierarchy and it has other cgroup(s) below it.
+- a cgroup which uses hierarchy and not the root of hierarchy.
+
+5.4 failcnt
+
+A memory cgroup provides memory.failcnt and memory.memsw.failcnt files.
+This failcnt(== failure count) shows the number of times that a usage counter
+hit its limit. When a memory cgroup hits a limit, failcnt increases and
+memory under it will be reclaimed.
 
+You can reset failcnt by writing 0 to failcnt file.
+# echo 0 > .../memory.failcnt
 
 6. Hierarchy support
 
@@ -366,13 +470,13 @@ hierarchy
 
 In the diagram above, with hierarchical accounting enabled, all memory
 usage of e, is accounted to its ancestors up until the root (i.e, c and root),
-that has memory.use_hierarchy enabled.  If one of the ancestors goes over its
+that has memory.use_hierarchy enabled. If one of the ancestors goes over its
 limit, the reclaim algorithm reclaims from the tasks in the ancestor and the
 children of the ancestor.
 
 6.1 Enabling hierarchical accounting and reclaim
 
-The memory controller by default disables the hierarchy feature. Support
+A memory cgroup by default disables the hierarchy feature. Support
 can be enabled by writing 1 to memory.use_hierarchy file of the root cgroup
 
 # echo 1 > memory.use_hierarchy
@@ -382,10 +486,10 @@ The feature can be disabled by
 # echo 0 > memory.use_hierarchy
 
 NOTE1: Enabling/disabling will fail if the cgroup already has other
-cgroups created below it.
+       cgroups created below it.
 
 NOTE2: When panic_on_oom is set to "2", the whole system will panic in
-case of an oom event in any cgroup.
+       case of an OOM event in any cgroup.
 
 7. Soft limits
 
@@ -395,7 +499,7 @@ is to allow control groups to use as muc
 a. There is no memory contention
 b. They do not exceed their hard limit
 
-When the system detects memory contention or low memory control groups
+When the system detects memory contention or low memory, control groups
 are pushed back to their soft limits. If the soft limit of each control
 group is very high, they are pushed back as much as possible to make
 sure that one control group does not starve the others of memory.
@@ -409,7 +513,7 @@ it gets invoked from balance_pgdat (kswa
 7.1 Interface
 
 Soft limits can be setup by using the following commands (in this example we
-assume a soft limit of 256 megabytes)
+assume a soft limit of 256 MiB)
 
 # echo 256M > memory.soft_limit_in_bytes
 
@@ -445,7 +549,7 @@ Note: Charges are moved only when you mo
 Note: If we cannot find enough space for the task in the destination cgroup, we
       try to make space by reclaiming memory. Task migration may fail if we
       cannot make enough space.
-Note: It can take several seconds if you move charges in giga bytes order.
+Note: It can take several seconds if you move charges much.
 
 And if you want disable it again:
 
@@ -465,7 +569,7 @@ memory cgroup.
       | enable Swap Extension(see 2.4) to enable move of swap charges.
  -----+------------------------------------------------------------------------
    1  | A charge of file pages(normal file, tmpfs file(e.g. ipc shared memory)
-      | and swaps of tmpfs file) mmaped by the target task. Unlike the case of
+      | and swaps of tmpfs file) mmapped by the target task. Unlike the case of
       | anonymous pages, file pages(and swaps) in the range mmapped by the task
       | will be moved even if the task hasn't done page fault, i.e. they might
       | not be the task's "RSS", but other task's "RSS" that maps the same file.
@@ -482,15 +586,15 @@ memory cgroup.
 
 9. Memory thresholds
 
-Memory controler implements memory thresholds using cgroups notification
+Memory cgroup implements memory thresholds using cgroups notification
 API (see cgroups.txt). It allows to register multiple memory and memsw
 thresholds and gets notifications when it crosses.
 
 To register a threshold application need:
- - create an eventfd using eventfd(2);
- - open memory.usage_in_bytes or memory.memsw.usage_in_bytes;
- - write string like "<event_fd> <memory.usage_in_bytes> <threshold>" to
-   cgroup.event_control.
+- create an eventfd using eventfd(2);
+- open memory.usage_in_bytes or memory.memsw.usage_in_bytes;
+- write string like "<event_fd> <fd of memory.usage_in_bytes> <threshold>" to
+  cgroup.event_control.
 
 Application will be notified through eventfd when memory usage crosses
 threshold in any direction.
@@ -501,27 +605,28 @@ It's applicable for root and non-root cg
 
 memory.oom_control file is for OOM notification and other controls.
 
-Memory controler implements oom notifier using cgroup notification
-API (See cgroups.txt). It allows to register multiple oom notification
-delivery and gets notification when oom happens.
+Memory cgroup implements OOM notifier using cgroup notification
+API (See cgroups.txt). It allows to register multiple OOM notification
+delivery and gets notification when OOM happens.
 
 To register a notifier, application need:
  - create an eventfd using eventfd(2)
  - open memory.oom_control file
- - write string like "<event_fd> <memory.oom_control>" to cgroup.event_control
+ - write string like "<event_fd> <fd of memory.oom_control>" to
+   cgroup.event_control
 
-Application will be notifier through eventfd when oom happens.
+Application will be notified through eventfd when OOM happens.
 OOM notification doesn't work for root cgroup.
 
-You can disable oom-killer by writing "1" to memory.oom_control file.
+You can disable OOM-killer by writing "1" to memory.oom_control file.
 As.
 	#echo 1 > memory.oom_control
 
-This operation is only allowed to the top cgroup of subhierarchy.
-If oom-killer is disabled, tasks under cgroup will hang/sleep
-in memcg's oom-waitq when they request accountable memory.
+This operation is only allowed to the top cgroup of sub-hierarchy.
+If OOM-killer is disabled, tasks under cgroup will hang/sleep
+in memory cgroup's OOM-waitqueue when they request accountable memory.
 
-For running them, you have to relax the memcg's oom sitaution by
+For running them, you have to relax the memory cgroup's OOM status by
 	* enlarge limit or reduce usage.
 To reduce usage,
 	* kill some tasks.
@@ -532,7 +637,7 @@ Then, stopped tasks will work again.
 
 At reading, current status of OOM is shown.
 	oom_kill_disable 0 or 1 (if 1, oom-killer is disabled)
-	under_oom	 0 or 1 (if 1, the memcg is under OOM,tasks may
+	under_oom	 0 or 1 (if 1, the memory cgroup is under OOM, tasks may
 				 be stopped.)
 
 11. TODO


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
