Date: Fri, 17 Oct 2008 20:01:58 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mm 3/5] memcg: mem+swap controller Kconfig
Message-Id: <20081017200158.3ffa4312.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>
References: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

Add config for mem+swap controller and defines a helper macro

For stacking several readable size of patches, this marks config
as Broken....later patch will remove this word.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

diff --git a/init/Kconfig b/init/Kconfig
index a404869..14c8205 100644
--- a/init/Kconfig
+++ b/init/Kconfig
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
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5ef5a5c..023c7bc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -41,6 +41,13 @@ struct cgroup_subsys mem_cgroup_subsys __read_mostly;
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
