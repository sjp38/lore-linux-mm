Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9V2tgxx007440
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 31 Oct 2008 11:55:43 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D80E45DD87
	for <linux-mm@kvack.org>; Fri, 31 Oct 2008 11:55:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4EC9A45DD7F
	for <linux-mm@kvack.org>; Fri, 31 Oct 2008 11:55:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 53E421DB804B
	for <linux-mm@kvack.org>; Fri, 31 Oct 2008 11:55:41 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E9B241DB803E
	for <linux-mm@kvack.org>; Fri, 31 Oct 2008 11:55:40 +0900 (JST)
Date: Fri, 31 Oct 2008 11:55:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 3/5] memcg : mem+swap controller kconfig
Message-Id: <20081031115510.3ba13f3b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081031115057.6da3dafd.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081031115057.6da3dafd.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, hugh@veritas.com, taka@valinux.co.jp
List-ID: <linux-mm.kvack.org>

Experimental.

Config and control variable for mem+swap controller.

This patch adds CONFIG_CGROUP_MEM_RES_CTLR_SWAP
(memory resource controller swap extension.)

For accounting swap, it's obvious that we have to use additional memory
to remember "who uses swap". This adds more overhead.
So, it's better to offer "choice" to users. This patch adds 2 choices.

This patch adds 2 parameters to enable swap extension or not.
  - CONFIG
  - boot option

Changelog: v1 -> v2
 - fixed typo.
 - make default value of "do_swap_account" to be 0 and turned on 1
   later if configured.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


 Documentation/kernel-parameters.txt |    3 +++
 include/linux/memcontrol.h          |    3 +++
 init/Kconfig                        |   17 +++++++++++++++++
 mm/memcontrol.c                     |   32 ++++++++++++++++++++++++++++++++
 4 files changed, 55 insertions(+)

Index: mmotm-2.6.28-rc2+/init/Kconfig
===================================================================
--- mmotm-2.6.28-rc2+.orig/init/Kconfig
+++ mmotm-2.6.28-rc2+/init/Kconfig
@@ -428,6 +428,23 @@ config CGROUP_MEM_RES_CTLR
 config MM_OWNER
 	bool
 
+config CGROUP_MEM_RES_CTLR_SWAP
+	bool "Memory Resource Controller Swap Extension(EXPERIMENTAL)"
+	depends on CGROUP_MEM_RES_CTLR && SWAP && EXPERIMENTAL
+	help
+	  Add swap management feature to memory resource controller. When you
+	  enable this, you can limit mem+swap usage per cgroup. In other words,
+	  when you disable this, memory resource controller has no cares to
+	  usage of swap...a process can exhaust all of the swap. This extension
+	  is useful when you want to avoid exhaustion swap but this itself
+	  adds more overheads and consumes memory for remembering information.
+	  Especially if you use 32bit system or small memory system, please
+	  be careful about enabling this. When memory resource controller
+	  is disabled by boot option, this will be automatically disabled and
+	  there will be no overhead from this. Even when you set this config=y,
+	  if boot option "noswapaccount" is set, swap will not be accounted.
+
+
 endmenu
 
 config SYSFS_DEPRECATED
Index: mmotm-2.6.28-rc2+/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-rc2+.orig/mm/memcontrol.c
+++ mmotm-2.6.28-rc2+/mm/memcontrol.c
@@ -41,6 +41,15 @@
 struct cgroup_subsys mem_cgroup_subsys __read_mostly;
 #define MEM_CGROUP_RECLAIM_RETRIES	5
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
+/* Turned on only when memory cgroup is enabled && reallY_do_swap_account = 0 */
+int do_swap_account __read_mostly;
+static int really_do_swap_account __initdata = 1; /* for remember boot option*/
+#else
+#define do_swap_account		(0)
+#endif
+
+
 /*
  * Statistics for memory cgroup.
  */
@@ -1369,6 +1378,18 @@ static void mem_cgroup_free(struct mem_c
 }
 
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
+static void __init enable_swap_cgroup(void)
+{
+	if (really_do_swap_account)
+		do_swap_account = 1;
+}
+#else
+static void __init enable_swap_cgroup(void)
+{
+}
+#endif
+
 static struct cgroup_subsys_state *
 mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 {
@@ -1377,6 +1398,7 @@ mem_cgroup_create(struct cgroup_subsys *
 
 	if (unlikely((cont->parent) == NULL)) {
 		mem = &init_mem_cgroup;
+		enable_swap_cgroup();
 	} else {
 		mem = mem_cgroup_alloc();
 		if (!mem)
@@ -1460,3 +1482,13 @@ struct cgroup_subsys mem_cgroup_subsys =
 	.attach = mem_cgroup_move_task,
 	.early_init = 0,
 };
+
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
+
+static int __init disable_swap_account(char *s)
+{
+	really_do_swap_account = 0;
+	return 1;
+}
+__setup("noswapaccount", disable_swap_account);
+#endif
Index: mmotm-2.6.28-rc2+/Documentation/kernel-parameters.txt
===================================================================
--- mmotm-2.6.28-rc2+.orig/Documentation/kernel-parameters.txt
+++ mmotm-2.6.28-rc2+/Documentation/kernel-parameters.txt
@@ -1543,6 +1543,9 @@ and is between 256 and 4096 characters. 
 
 	nosoftlockup	[KNL] Disable the soft-lockup detector.
 
+	noswapaccount	[KNL] Disable accounting of swap in memory resource
+			controller. (See Documentation/controllers/memory.txt)
+
 	nosync		[HW,M68K] Disables sync negotiation for all devices.
 
 	notsc		[BUGS=X86-32] Disable Time Stamp Counter
Index: mmotm-2.6.28-rc2+/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.28-rc2+.orig/include/linux/memcontrol.h
+++ mmotm-2.6.28-rc2+/include/linux/memcontrol.h
@@ -77,6 +77,9 @@ extern void mem_cgroup_record_reclaim_pr
 extern long mem_cgroup_calc_reclaim(struct mem_cgroup *mem, struct zone *zone,
 					int priority, enum lru_list lru);
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
+extern int do_swap_account;
+#endif
 
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
