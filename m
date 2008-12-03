Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB35GOqC032202
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Dec 2008 14:16:24 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 91CBA45DE4F
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:16:24 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7538845DD72
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:16:24 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 59AFC1DB8040
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:16:24 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0EF3F1DB803A
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:16:24 +0900 (JST)
Date: Wed, 3 Dec 2008 14:15:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH  22/21] memcg-explain-details-and-test-document.patch
Message-Id: <20081203141534.39d1fc28.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

just passed spell check. sorry for 22/21.

==
Documentation for implementation details and how to test.

just an example. feel free to modify, add, remove lines.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 Documentation/controllers/memcg_test.txt |  145 +++++++++++++++++++++++++++++++
 1 file changed, 145 insertions(+)

Index: mmotm-2.6.28-Dec02/Documentation/controllers/memcg_test.txt
===================================================================
--- /dev/null
+++ mmotm-2.6.28-Dec02/Documentation/controllers/memcg_test.txt
@@ -0,0 +1,145 @@
+Memory Resource Controller(Memcg)  Implementation Memo.
+Last Updated: 2009/12/03
+
+Because VM is getting complex (one of reasons is memcg...), memcg's behavior
+is complex. This is a document for memcg's internal behavior and some test
+patterns tend to be racy.
+
+1. charges
+
+   a page/swp_entry may be charged (usage += PAGE_SIZE) at
+
+	mem_cgroup_newpage_newpage()
+	  called at new page fault and COW.
+
+	mem_cgroup_try_charge_swapin()
+	  called at do_swap_page() and swapoff.
+	  followed by charge-commit-cancel protocol.
+	  (With swap accounting) at commit, charges recorded in swap is removed.
+
+	mem_cgroup_cache_charge()
+	  called at add_to_page_cache()
+
+	mem_cgroup_cache_charge_swapin)()
+	  called by shmem's swapin processing.
+
+	mem_cgroup_prepare_migration()
+	  called before migration. "extra" charge is done
+	  followed by charge-commit-cancel protocol.
+	  At commit, charge against oldpage or newpage will be committed.
+
+2. uncharge
+  a page/swp_entry may be uncharged (usage -= PAGE_SIZE) by
+
+	mem_cgroup_uncharge_page()
+	  called when an anonymous page is unmapped. If the page is SwapCache
+	  uncharge is delayed until mem_cgroup_uncharge_swapcache().
+
+	mem_cgroup_uncharge_cache_page()
+	  called when a page-cache is deleted from radix-tree. If the page is
+	  SwapCache, uncharge is delayed until mem_cgroup_uncharge_swapcache()
+
+	mem_cgroup_uncharge_swapcache()
+	  called when SwapCache is removed from radix-tree. the charge itself
+	  is moved to swap_cgroup. (If mem+swap controller is disabled, no
+	  charge to swap.)
+
+	mem_cgroup_uncharge_swap()
+	  called when swp_entry's refcnt goes down to be 0. charge against swap
+	  disappears.
+
+	mem_cgroup_end_migration(old, new)
+	at success of migration -> old is uncharged (if necessary), charge
+	to new is committed. at failure, charge to old is committed.
+
+3. charge-commit-cancel
+	In some case, we can't know this "charge" is valid or not at charge.
+	To handle such case, there are charge-commit-cancel functions.
+		mem_cgroup_try_charge_XXX
+		mem_cgroup_commit_charge_XXX
+		mem_cgroup_cancel_charge_XXX
+	these are used in swap-in and migration.
+
+	At try_charge(), there are no flags to say "this page is charged".
+	at this point, usage += PAGE_SIZE.
+
+	At commit(), the function checks the page should be charged or not
+	and set flags or avoid charging.(usage -= PAGE_SIZE)
+
+	At cancel(), simply usage -= PAGE_SIZE.
+
+4. Typical Tests.
+
+  Tests for racy cases.
+
+  4.1 small limit to memcg.
+	When you do test to do racy case, it's good test to set memcg's limit
+	to be very small rather than GB. Many races found in the test under
+	xKB or xxMB limits.
+	(Memory behavior under GB and Memory behavior under MB shows very
+	 different situation.)
+
+  4.2 shmem
+	Historically, memcg's shmem handling was poor and we saw some amount
+	of troubles here. This is because shmem is page-cache but can be
+	SwapCache. Test with shmem/tmpfs is always good test.
+
+  4.3 migration
+	For NUMA, migration is an another special. To do easy test, cpuset
+	is useful. Following is a sample script to do migration.
+
+	mount -t cgroup -o cpuset none /opt/cpuset
+
+	mkdir /opt/cpuset/01
+	echo 1 > /opt/cpuset/01/cpuset.cpus
+	echo 0 > /opt/cpuset/01/cpuset.mems
+	echo 1 > /opt/cpuset/01/cpuset.memory_migrate
+	mkdir /opt/cpuset/02
+	echo 1 > /opt/cpuset/02/cpuset.cpus
+	echo 1 > /opt/cpuset/02/cpuset.mems
+	echo 1 > /opt/cpuset/02/cpuset.memory_migrate
+
+	In above set, when you moves a task from 01 to 02, page migration to
+	node 0 to node 1 will occur. Following is a script to migrate all
+	under cpuset.
+	--
+	move_task()
+	{
+	for pid in $1
+        do
+                /bin/echo $pid >$2/tasks 2>/dev/null
+		echo -n $pid
+		echo -n " "
+        done
+	echo END
+	}
+
+	G1_TASK=`cat ${G1}/tasks`
+	G2_TASK=`cat ${G2}/tasks`
+	move_task "${G1_TASK}" ${G2} &
+	--
+  4.4 memory hotplug.
+	memory hotplug test is one of good test.
+	to offline memory, do following.
+	# echo offline > /sys/devices/system/memory/memoryXXX/state
+	(XXX is the place of memory)
+	This is an easy way to test page migration, too.
+
+ 4.5 mkdir/rmdir
+	When using hierarchy, mkdir/rmdir test should be done.
+	tests like following.
+
+	#echo 1 >/opt/cgroup/01/memory/use_hierarchy
+	#mkdir /opt/cgroup/01/child_a
+	#mkdir /opt/cgroup/01/child_b
+
+	set limit to 01.
+	add limit to 01/child_b
+	run jobs under child_a and child_b
+
+	create/delete following groups at random while jobs are running.
+	/opt/cgroup/01/child_a/child_aa
+	/opt/cgroup/01/child_b/child_bb
+	/opt/cgroup/01/child_c
+
+	running new jobs in new group is also good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
