Date: Tue, 11 Dec 2007 12:03:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [DOC][for -mm] update Documentation/controller/memory.txt
Message-Id: <20071211120349.3ae9c55c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "riel@redhat.com" <riel@redhat.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Balbir-san, could you review this update ?

--
Documentation updates for memory controller.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: linux-2.6.24-rc4-mm1/Documentation/controllers/memory.txt
===================================================================
--- linux-2.6.24-rc4-mm1.orig/Documentation/controllers/memory.txt
+++ linux-2.6.24-rc4-mm1/Documentation/controllers/memory.txt
@@ -9,8 +9,7 @@ d. Provides a double LRU: global memory 
    global LRU; a cgroup on hitting a limit, reclaims from the per
    cgroup LRU
 
-NOTE: Page Cache (unmapped) also includes Swap Cache pages as a subset
-and will not be referred to explicitly in the rest of the documentation.
+NOTE: Swap Cache (unmapped) is not accounted now.
 
 Benefits and Purpose of the memory controller
 
@@ -144,7 +143,7 @@ list.
 The memory controller uses the following hierarchy
 
 1. zone->lru_lock is used for selecting pages to be isolated
-2. mem->lru_lock protects the per cgroup LRU
+2. mem->per_zone->lru_lock protects the per cgroup LRU (per zone)
 3. lock_page_cgroup() is used to protect page->page_cgroup
 
 3. User Interface
@@ -193,6 +192,15 @@ this file after a write to guarantee the
 The memory.failcnt field gives the number of times that the cgroup limit was
 exceeded.
 
+The memory.stat file gives accounting information. Now, the number of
+caches, RSS and Active pages/Inactive pages are shown.
+
+The memory.force_empty gives an interface to drop *all* charges by force.
+
+# echo -n 1 > memory.force_empty
+
+will drop all charges in cgroup. Currently, this is maintained for test.
+
 4. Testing
 
 Balbir posted lmbench, AIM9, LTP and vmmstress results [10] and [11].
@@ -222,11 +230,8 @@ reclaimed.
 
 A cgroup can be removed by rmdir, but as discussed in sections 4.1 and 4.2, a
 cgroup might have some charge associated with it, even though all
-tasks have migrated away from it. If some pages are still left, after following
-the steps listed in sections 4.1 and 4.2, check the Swap Cache usage in
-/proc/meminfo to see if the Swap Cache usage is showing up in the
-cgroups memory.usage_in_bytes counter. A simple test of swapoff -a and
-swapon -a should free any pending Swap Cache usage.
+tasks have migrated away from it. Such charges are automatically dropped at
+rmdir() if there are no tasks.
 
 4.4 Choosing what to account  -- Page Cache (unmapped) vs RSS (mapped)?
 
@@ -238,15 +243,11 @@ echo -n 1 > memory.control_type
 5. TODO
 
 1. Add support for accounting huge pages (as a separate controller)
-2. Improve the user interface to accept/display memory limits in KB or MB
-   rather than pages (since page sizes can differ across platforms/machines).
-3. Make cgroup lists per-zone
-4. Make per-cgroup scanner reclaim not-shared pages first
-5. Teach controller to account for shared-pages
-6. Start reclamation when the limit is lowered
-7. Start reclamation in the background when the limit is
+2. Make per-cgroup scanner reclaim not-shared pages first
+3. Teach controller to account for shared-pages
+4. Start reclamation when the limit is lowered
+5. Start reclamation in the background when the limit is
    not yet hit but the usage is getting closer
-8. Create per zone LRU lists per cgroup
 
 Summary
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
