Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id F389E6B01FA
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 06:59:46 -0400 (EDT)
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate7.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o3QAxbk9015231
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 10:59:37 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3QAxbY21597462
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 11:59:37 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o3QAxaGX017433
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 11:59:36 +0100
Message-ID: <4BD57213.7060207@linux.vnet.ibm.com>
Date: Mon, 26 Apr 2010 12:59:31 +0200
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Subject: [PATCH][RFC] mm: make working set portion that is protected
 tunable v2
References: <20100322235053.GD9590@csn.ul.ie> <4BA940E7.2030308@redhat.com> <20100324145028.GD2024@csn.ul.ie> <4BCC4B0C.8000602@linux.vnet.ibm.com> <20100419214412.GB5336@cmpxchg.org> <4BCD55DA.2020000@linux.vnet.ibm.com> <20100420153202.GC5336@cmpxchg.org> <4BCDE2F0.3010009@redhat.com> <4BCE7DD1.70900@linux.vnet.ibm.com> <4BCEAAC6.7070602@linux.vnet.ibm.com> <4BCEFB4C.1070206@redhat.com> <4BCFEAD0.4010708@linux.vnet.ibm.com>
In-Reply-To: <4BCFEAD0.4010708@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, gregkh@novell.com
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, Corrado Zoccolo <czoccolo@gmail.com>
List-ID: <linux-mm.kvack.org>

Subject: [PATCH][RFC] mm: make working set portion that is protected tunable v2

From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>

*updates in v2*
- use do_div

This patch creates a knob to help users that have workloads suffering from the
fix 1:1 active inactive ratio brought into the kernel by "56e49d21 vmscan:
evict use-once pages first".
It also provides the tuning mechanisms for other users that want an even bigger
working set to be protected.

To be honest the best solution would be to allow a system not using the working
set to regain that memory *somewhen*, and therefore without drawbacks to the
scenarios it was implemented for e.g. UI interactivity while copying a lot of
data. But up to now there was no idea how to get that behaviour implemented.

In the old thread started by Elladan that finally led to 56e49d21 Wu Fengguang
wrote:
 "In the worse scenario, it could waste half the memory that could
 otherwise be used for readahead buffer and to prevent thrashing, in a
 server serving large datasets that are hardly reused, but still slowly
 builds up its active list during the long uptime (think about a slowly
 performance downgrade that can be fixed by a crude dropcache action).

 That said, the actual performance degradation could be much smaller -
 say 15% - all memories are not equal."

We now identified a case with up to -60% Throughput, therefore this patch tries
to provide a more gentle interface than drop_caches to help a system stuck in
this.

In discussion with Rik van Riel and Joannes Weiner we came up that there are
cases that want the current "save 50%" for the working set all the time and
others that would benefit from protectig only a smaller amount.

Eventually no "carved in stone" in kernel ratio will match all use cases,
therefore this patch makes the value tunable via a /proc/sys/vm/ interface
named active_inactive_ratio.

Example configurations might be:
- 50% - like the current kernel
- 0%  - like a kernel pre 56e49d21
- x%  - allow customizing the system to someones needs

Due to our experiments the suggested default in this patch is 25%, but if
preferred I'm fine keeping 50% and letting admins/distros adapt as needed.

Signed-off-by: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
---

[diffstat]
 Documentation/sysctl/vm.txt |   10 ++++++++++
 include/linux/mm.h          |    2 ++
 kernel/sysctl.c             |    9 +++++++++
 mm/memcontrol.c             |    9 ++++++---
 mm/vmscan.c                 |   17 ++++++++++++++---
 5 files changed, 41 insertions(+), 6 deletions(-)

[diff]
Index: linux-2.6/Documentation/sysctl/vm.txt
===================================================================
--- linux-2.6.orig/Documentation/sysctl/vm.txt	2010-04-21 06:32:23.000000000 +0200
+++ linux-2.6/Documentation/sysctl/vm.txt	2010-04-21 07:24:35.000000000 +0200
@@ -18,6 +18,7 @@
 
 Currently, these files are in /proc/sys/vm:
 
+- active_inactive_ratio
 - block_dump
 - dirty_background_bytes
 - dirty_background_ratio
@@ -57,6 +58,15 @@
 
 ==============================================================
 
+active_inactive_ratio
+
+The kernel tries to protect the active working set. Therefore a portion of the
+file pages is protected, meaning they are omitted when eviting pages until this
+ratio is reached.
+This tunable represents that ratio in percent and specifies the protected part
+
+==============================================================
+
 block_dump
 
 block_dump enables block I/O debugging when set to a nonzero value. More
Index: linux-2.6/kernel/sysctl.c
===================================================================
--- linux-2.6.orig/kernel/sysctl.c	2010-04-21 06:33:43.000000000 +0200
+++ linux-2.6/kernel/sysctl.c	2010-04-21 07:26:35.000000000 +0200
@@ -1271,6 +1271,15 @@
 		.extra2		= &one,
 	},
 #endif
+	{
+		.procname	= "active_inactive_ratio",
+		.data		= &sysctl_active_inactive_ratio,
+		.maxlen		= sizeof(sysctl_active_inactive_ratio),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &one_hundred,
+	},
 
 /*
  * NOTE: do not add new entries to this table unless you have read
Index: linux-2.6/mm/memcontrol.c
===================================================================
--- linux-2.6.orig/mm/memcontrol.c	2010-04-21 06:31:29.000000000 +0200
+++ linux-2.6/mm/memcontrol.c	2010-04-26 12:45:46.000000000 +0200
@@ -893,12 +893,15 @@
 int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg)
 {
 	unsigned long active;
-	unsigned long inactive;
+	unsigned long activetoprotect;
 
-	inactive = mem_cgroup_get_local_zonestat(memcg, LRU_INACTIVE_FILE);
 	active = mem_cgroup_get_local_zonestat(memcg, LRU_ACTIVE_FILE);
+	activetoprotect = active
+		+ mem_cgroup_get_local_zonestat(memcg, LRU_INACTIVE_FILE)
+		* sysctl_active_inactive_ratio;
+	activetoprotect = do_div(activetoprotect, 100);
 
-	return (active > inactive);
+	return (active > activetoprotect);
 }
 
 unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2010-04-21 06:31:29.000000000 +0200
+++ linux-2.6/mm/vmscan.c	2010-04-26 12:50:47.000000000 +0200
@@ -1459,14 +1459,25 @@
 	return low;
 }
 
+/*
+ * sysctl_active_inactive_ratio
+ *
+ * Defines the portion of file pages within the active working set is going to
+ * be protected. The value represents the percentage that will be protected.
+ */
+int sysctl_active_inactive_ratio __read_mostly = 25;
+
 static int inactive_file_is_low_global(struct zone *zone)
 {
-	unsigned long active, inactive;
+	unsigned long active, activetoprotect;
 
 	active = zone_page_state(zone, NR_ACTIVE_FILE);
-	inactive = zone_page_state(zone, NR_INACTIVE_FILE);
+	activetoprotect = zone_page_state(zone, NR_FILE)
+			* sysctl_active_inactive_ratio;
+	activetoprotect = do_div(activetoprotect, 100);
+
+	return (active > activetoprotect);
 
-	return (active > inactive);
 }
 
 /**
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2010-04-21 09:02:37.000000000 +0200
+++ linux-2.6/include/linux/mm.h	2010-04-21 09:02:51.000000000 +0200
@@ -1467,5 +1467,7 @@
 
 extern void dump_page(struct page *page);
 
+extern int sysctl_active_inactive_ratio;
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
