Date: Fri, 22 Aug 2008 20:41:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 12/14] memcg: mem+swap controller Kconfig
Message-Id: <20080822204106.8bc40ce6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Add config for mem+swap controller and defines a helper macro

For stacking several readable size of patches, this marks config
as Broken....later patch will remove this word.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 init/Kconfig    |   10 ++++++++++
 mm/memcontrol.c |    7 +++++++
 2 files changed, 17 insertions(+)

Index: mmtom-2.6.27-rc3+/init/Kconfig
===================================================================
--- mmtom-2.6.27-rc3+.orig/init/Kconfig
+++ mmtom-2.6.27-rc3+/init/Kconfig
@@ -415,6 +415,16 @@ config CGROUP_MEM_RES_CTLR
 	  This config option also selects MM_OWNER config option, which
 	  could in turn add some fork/exit overhead.
 
+config CGROUP_MEM_RES_CTLR_SWAP
+	bool "Memory Resource Controller Swap Extension (Broken)"
+	depends on CGROUP_MEM_RES_CTLR && SWAP && EXPERIMENTAL
+	help
+	 Add swap management feature to memory resource controller. By this,
+	 you can control swap consumption per cgroup by limiting the total
+	 amount of memory+swap. Because this records additional informaton
+	 at swap-out, this consumes extra memory. If you use 32bit system or
+	 small memory system, please be careful to enable this.
+
 config CGROUP_MEMRLIMIT_CTLR
 	bool "Memory resource limit controls for cgroups"
 	depends on CGROUPS && RESOURCE_COUNTERS && MMU
Index: mmtom-2.6.27-rc3+/mm/memcontrol.c
===================================================================
--- mmtom-2.6.27-rc3+.orig/mm/memcontrol.c
+++ mmtom-2.6.27-rc3+/mm/memcontrol.c
@@ -42,6 +42,13 @@ static struct kmem_cache *page_cgroup_ca
 #define MEM_CGROUP_RECLAIM_RETRIES	5
 #define NR_MEMCGRP_ID			(32767)
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
+#define do_swap_account	(1)
+#else
+#define do_swap_account	(0)
+#endif
+
+
 /*
  * Statistics for memory cgroup.
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
