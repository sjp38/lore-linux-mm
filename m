Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBA1L2WE016530
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 10 Dec 2008 10:21:02 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5659545DE53
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 10:21:02 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 20DDA45DE50
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 10:21:02 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E4261DB803C
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 10:21:01 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 294A21DB8038
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 10:21:01 +0900 (JST)
Date: Wed, 10 Dec 2008 10:20:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH mmotm] memcg: update document for memcg details.
Message-Id: <20081210102008.65a49831.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

An update for memcg-explain-details-and-test-document.patch
better file name is welcome....

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Update/Fix document about implementation details of memcg.

Changelog:
  - Fixed typo and bad texts.
  - removed changes to memcontrol.c

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/controllers/memcg_test.txt |  240 ++++++++++++++++++++++++++-----
 1 file changed, 203 insertions(+), 37 deletions(-)

Index: mmotm-2.6.28-Dec09/Documentation/controllers/memcg_test.txt
===================================================================
--- mmotm-2.6.28-Dec09.orig/Documentation/controllers/memcg_test.txt
+++ mmotm-2.6.28-Dec09/Documentation/controllers/memcg_test.txt
@@ -1,59 +1,76 @@
 Memory Resource Controller(Memcg)  Implementation Memo.
-Last Updated: 2009/12/03
+Last Updated: 2008/12/10
+Base Kernel Version: based on 2.6.28-rc7-mm.
 
 Because VM is getting complex (one of reasons is memcg...), memcg's behavior
-is complex. This is a document for memcg's internal behavior and some test
-patterns tend to be racy.
+is complex. This is a document for memcg's internal behavior.
+Please note that implementation details can be changed.
 
-1. charges
+(*) Topics on API should be in Documentation/controllers/memory.txt)
+
+0. How to record usage ?
+   2 objects are used.
+
+   page_cgroup ....an object per page.
+	Allocated at boot or memory hotplug. Freed at memory hot removal.
+
+   swap_cgroup ... an entry per swp_entry.
+	Allocated at swapon(). Freed at swapoff().
+
+   The page_cgroup has USED bit and double count against a page_cgroup never
+   occurs. swap_cgroup is used only when a charged page is swapped-out.
+
+1. Charge
 
    a page/swp_entry may be charged (usage += PAGE_SIZE) at
 
-	mem_cgroup_newpage_newpage()
-	  called at new page fault and COW.
+	mem_cgroup_newpage_charge()
+	  Called at new page fault and Copy-On-Write.
 
 	mem_cgroup_try_charge_swapin()
-	  called at do_swap_page() and swapoff.
-	  followed by charge-commit-cancel protocol.
-	  (With swap accounting) at commit, charges recorded in swap is removed.
+	  Called at do_swap_page() (page fault on swap entry) and swapoff.
+	  Followed by charge-commit-cancel protocol. (With swap accounting)
+	  At commit, a charge recorded in swap_cgroup is removed.
 
 	mem_cgroup_cache_charge()
-	  called at add_to_page_cache()
+	  Called at add_to_page_cache()
 
-	mem_cgroup_cache_charge_swapin)()
-	  called by shmem's swapin processing.
+	mem_cgroup_cache_charge_swapin()
+	  Called at shmem's swapin.
 
 	mem_cgroup_prepare_migration()
-	  called before migration. "extra" charge is done
-	  followed by charge-commit-cancel protocol.
+	  Called before migration. "extra" charge is done and followed by
+	  charge-commit-cancel protocol.
 	  At commit, charge against oldpage or newpage will be committed.
 
-2. uncharge
+2. Uncharge
   a page/swp_entry may be uncharged (usage -= PAGE_SIZE) by
 
 	mem_cgroup_uncharge_page()
-	  called when an anonymous page is unmapped. If the page is SwapCache
-	  uncharge is delayed until mem_cgroup_uncharge_swapcache().
+	  Called when an anonymous page is fully unmapped. I.e., mapcount goes
+	  to 0. If the page is SwapCache, uncharge is delayed until
+	  mem_cgroup_uncharge_swapcache().
 
 	mem_cgroup_uncharge_cache_page()
-	  called when a page-cache is deleted from radix-tree. If the page is
-	  SwapCache, uncharge is delayed until mem_cgroup_uncharge_swapcache()
+	  Called when a page-cache is deleted from radix-tree. If the page is
+	  SwapCache, uncharge is delayed until mem_cgroup_uncharge_swapcache().
 
 	mem_cgroup_uncharge_swapcache()
-	  called when SwapCache is removed from radix-tree. the charge itself
+	  Called when SwapCache is removed from radix-tree. The charge itself
 	  is moved to swap_cgroup. (If mem+swap controller is disabled, no
-	  charge to swap.)
+	  charge to swap occurs.)
 
 	mem_cgroup_uncharge_swap()
-	  called when swp_entry's refcnt goes down to be 0. charge against swap
+	  Called when swp_entry's refcnt goes down to 0. A charge against swap
 	  disappears.
 
 	mem_cgroup_end_migration(old, new)
-	at success of migration -> old is uncharged (if necessary), charge
-	to new is committed. at failure, charge to old is committed.
+	At success of migration old is uncharged (if necessary), a charge
+	to new page is committed. At failure, charge to old page is committed.
 
 3. charge-commit-cancel
-	In some case, we can't know this "charge" is valid or not at charge.
+	In some case, we can't know this "charge" is valid or not at charging
+	(because of races).
 	To handle such case, there are charge-commit-cancel functions.
 		mem_cgroup_try_charge_XXX
 		mem_cgroup_commit_charge_XXX
@@ -68,24 +85,164 @@ patterns tend to be racy.
 
 	At cancel(), simply usage -= PAGE_SIZE.
 
-4. Typical Tests.
+Under below explanation, we assume CONFIG_MEM_RES_CTRL_SWAP=y.
 
-  Tests for racy cases.
+4. Anonymous
+	Anonymous page is newly allocated at
+		  - page fault into MAP_ANONYMOUS mapping.
+		  - Copy-On-Write.
+ 	It is charged right after it's allocated before doing any page table
+	related operations. Of course, it's uncharged when another page is used
+	for the fault address.
 
-  4.1 small limit to memcg.
+	At freeing anonymous page (by exit() or munmap()), zap_pte() is called
+	and pages for ptes are freed one by one.(see mm/memory.c). Uncharges
+	are done at page_remove_rmap() when page_mapcount() goes down to 0.
+
+	Another page freeing is by page-reclaim (vmscan.c) and anonymous
+	pages are swapped out. In this case, the page is marked as
+	PageSwapCache(). uncharge() routine doesn't uncharge the page marked
+	as SwapCache(). It's delayed until __delete_from_swap_cache().
+
+	4.1 Swap-in.
+	At swap-in, the page is taken from swap-cache. There are 2 cases.
+
+	(a) If the SwapCache is newly allocated and read, it has no charges.
+	(b) If the SwapCache has been mapped by processes, it has been
+	    charged already.
+
+	In case (a), we charge it. In case (b), we don't charge it.
+	(But racy state between (a) and (b) exists. We do check it.)
+	At charging, a charge recorded in swap_cgroup is moved to page_cgroup.
+
+	4.2 Swap-out.
+	At swap-out, typical state transition is below.
+
+	(a) add to swap cache. (marked as SwapCache)
+	    swp_entry's refcnt += 1.
+	(b) fully unmapped.
+	    swp_entry's refcnt += # of ptes.
+	(c) write back to swap.
+	(d) delete from swap cache. (remove from SwapCache)
+	    swp_entry's refcnt -= 1.
+
+
+	At (b), the page is marked as SwapCache and not uncharged.
+	At (d), the page is removed from SwapCache and a charge in page_cgroup
+	is moved to swap_cgroup.
+
+	Finally, at task exit,
+	(e) zap_pte() is called and swp_entry's refcnt -=1 -> 0.
+	Here, a charge in swap_cgroup disappears.
+
+5. Page Cache
+   	Page Cache is charged at
+	- add_to_page_cache_locked().
+
+	uncharged at
+	- __remove_from_page_cache().
+
+	The logic is very clear. (About migration, see below)
+	Note: __remove_from_page_cache() is called by remove_from_page_cache()
+	and __remove_mapping().
+
+6. Shmem(tmpfs) Page Cache
+	Memcg's charge/uncharge have special handlers of shmem. The best way
+	to understand shmem's page state transition is to read mm/shmem.c.
+	But brief explanation of the behavior of memcg around shmem will be
+	helpful to understand the logic.
+
+	Shmem's page (just leaf page, not direct/indirect block) can be on
+		- radix-tree of shmem's inode.
+		- SwapCache.
+		- Both on radix-tree and SwapCache. This happens at swap-in
+		  and swap-out,
+
+	It's charged when...
+	- A new page is added to shmem's radix-tree.
+	- A swp page is read. (move a charge from swap_cgroup to page_cgroup)
+	It's uncharged when
+	- A page is removed from radix-tree and not SwapCache.
+	- When SwapCache is removed, a charge is moved to swap_cgroup.
+	- When swp_entry's refcnt goes down to 0, a charge in swap_cgroup
+	  disappears.
+
+7. Page Migration
+   	One of the most complicated functions is page-migration-handler.
+	Memcg has 2 routines. Assume that we are migrating a page's contents
+	from OLDPAGE to NEWPAGE.
+
+	Usual migration logic is..
+	(a) remove the page from LRU.
+	(b) allocate NEWPAGE (migration target)
+	(c) lock by lock_page().
+	(d) unmap all mappings.
+	(e-1) If necessary, replace entry in radix-tree.
+	(e-2) move contents of a page.
+	(f) map all mappings again.
+	(g) pushback the page to LRU.
+	(-) OLDPAGE will be freed.
+
+	Before (g), memcg should complete all necessary charge/uncharge to
+	NEWPAGE/OLDPAGE.
+
+	The point is....
+	- If OLDPAGE is anonymous, all charges will be dropped at (d) because
+          try_to_unmap() drops all mapcount and the page will not be
+	  SwapCache.
+
+	- If OLDPAGE is SwapCache, charges will be kept at (g) because
+	  __delete_from_swap_cache() isn't called at (e-1)
+
+	- If OLDPAGE is page-cache, charges will be kept at (g) because
+	  remove_from_swap_cache() isn't called at (e-1)
+
+	memcg provides following hooks.
+
+	- mem_cgroup_prepare_migration(OLDPAGE)
+	  Called after (b) to account a charge (usage += PAGE_SIZE) against
+	  memcg which OLDPAGE belongs to.
+
+        - mem_cgroup_end_migration(OLDPAGE, NEWPAGE)
+	  Called after (f) before (g).
+	  If OLDPAGE is used, commit OLDPAGE again. If OLDPAGE is already
+	  charged, a charge by prepare_migration() is automatically canceled.
+	  If NEWPAGE is used, commit NEWPAGE and uncharge OLDPAGE.
+
+	  But zap_pte() (by exit or munmap) can be called while migration,
+	  we have to check if OLDPAGE/NEWPAGE is a valid page after commit().
+
+8. LRU
+        Each memcg has its own private LRU. Now, it's handling is under global
+	VM's control (means that it's handled under global zone->lru_lock).
+	Almost all routines around memcg's LRU is called by global LRU's
+	list management functions under zone->lru_lock().
+
+	A special function is mem_cgroup_isolate_pages(). This scans
+	memcg's private LRU and call __isolate_lru_page() to extract a page
+	from LRU.
+	(By __isolate_lru_page(), the page is removed from both of global and
+	 private LRU.)
+
+
+9. Typical Tests.
+
+ Tests for racy cases.
+
+ 9.1 Small limit to memcg.
 	When you do test to do racy case, it's good test to set memcg's limit
 	to be very small rather than GB. Many races found in the test under
 	xKB or xxMB limits.
 	(Memory behavior under GB and Memory behavior under MB shows very
 	 different situation.)
 
-  4.2 shmem
+ 9.2 Shmem
 	Historically, memcg's shmem handling was poor and we saw some amount
 	of troubles here. This is because shmem is page-cache but can be
 	SwapCache. Test with shmem/tmpfs is always good test.
 
-  4.3 migration
-	For NUMA, migration is an another special. To do easy test, cpuset
+ 9.3 Migration
+	For NUMA, migration is an another special case. To do easy test, cpuset
 	is useful. Following is a sample script to do migration.
 
 	mount -t cgroup -o cpuset none /opt/cpuset
@@ -118,20 +275,20 @@ patterns tend to be racy.
 	G2_TASK=`cat ${G2}/tasks`
 	move_task "${G1_TASK}" ${G2} &
 	--
-  4.4 memory hotplug.
+ 9.4 Memory hotplug.
 	memory hotplug test is one of good test.
 	to offline memory, do following.
 	# echo offline > /sys/devices/system/memory/memoryXXX/state
 	(XXX is the place of memory)
 	This is an easy way to test page migration, too.
 
- 4.5 mkdir/rmdir
+ 9.5 mkdir/rmdir
 	When using hierarchy, mkdir/rmdir test should be done.
-	tests like following.
+	Use tests like the following.
 
-	#echo 1 >/opt/cgroup/01/memory/use_hierarchy
-	#mkdir /opt/cgroup/01/child_a
-	#mkdir /opt/cgroup/01/child_b
+	echo 1 >/opt/cgroup/01/memory/use_hierarchy
+	mkdir /opt/cgroup/01/child_a
+	mkdir /opt/cgroup/01/child_b
 
 	set limit to 01.
 	add limit to 01/child_b
@@ -143,3 +300,12 @@ patterns tend to be racy.
 	/opt/cgroup/01/child_c
 
 	running new jobs in new group is also good.
+
+ 9.6 Mount with other subsystems.
+	Mounting with other subsystems is a good test because there is a
+	race and lock dependency with other cgroup subsystems.
+
+	example)
+	# mount -t cgroup none /cgroup -t cpuset,memory,cpu,devices
+
+	and do task move, mkdir, rmdir etc...under this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
