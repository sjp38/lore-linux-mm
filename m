Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 521FB600762
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:16:53 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [23/31] HWPOISON: add memory cgroup filter
Message-Id: <20091208211639.8499FB151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:39 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: kosaki.motohiro@jp.fujitsu.com, hugh.dickins@tiscali.co.uk, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, lizf@cn.fujitsu.com, menage@google.com, npiggin@suse.de, andi@firstfloor.org, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


The hwpoison test suite need to inject hwpoison to a collection of
selected task pages, and must not touch pages not owned by them and
thus kill important system processes such as init. (But it's OK to
mis-hwpoison free/unowned pages as well as shared clean pages.
Mis-hwpoison of shared dirty pages will kill all tasks, so the test
suite will target all or non of such tasks in the first place.)

The memory cgroup serves this purpose well. We can put the target
processes under the control of a memory cgroup, and tell the hwpoison
injection code to only kill pages associated with some active memory
cgroup.

The prerequisite for doing hwpoison stress tests with mem_cgroup is,
the mem_cgroup code tracks task pages _accurately_ (unless page is
locked).  Which we believe is/should be true.

The benefits are simplification of hwpoison injector code. Also the
mem_cgroup code will automatically be tested by hwpoison test cases.

The alternative interfaces pin-pfn/unpin-pfn can also delegate the
(process and page flags) filtering functions reliably to user space.
However prototype implementation shows that this scheme adds more
complexity than we wanted.

Example test case:

	mkdir /cgroup/hwpoison

	usemem -m 100 -s 1000 &
	echo `jobs -p` > /cgroup/hwpoison/tasks

	memcg_ino=$(ls -id /cgroup/hwpoison | cut -f1 -d' ')
	echo $memcg_ino > /debug/hwpoison/corrupt-filter-memcg

	page-types -p `pidof init`   --hwpoison  # shall do nothing
	page-types -p `pidof usemem` --hwpoison  # poison its pages

AK: Fix documentation

CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Hugh Dickins <hugh.dickins@tiscali.co.uk>
CC: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
CC: Balbir Singh <balbir@linux.vnet.ibm.com>
CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Li Zefan <lizf@cn.fujitsu.com>
CC: Paul Menage <menage@google.com>
CC: Nick Piggin <npiggin@suse.de> 
CC: Andi Kleen <andi@firstfloor.org> 
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 Documentation/vm/hwpoison.txt |   16 ++++++++++++++++
 mm/hwpoison-inject.c          |    7 +++++++
 mm/internal.h                 |    1 +
 mm/memory-failure.c           |   42 ++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 66 insertions(+)

Index: linux/mm/memory-failure.c
===================================================================
--- linux.orig/mm/memory-failure.c
+++ linux/mm/memory-failure.c
@@ -100,6 +100,45 @@ static int hwpoison_filter_flags(struct
 		return -EINVAL;
 }
 
+/*
+ * This allows stress tests to limit test scope to a collection of tasks
+ * by putting them under some memcg. This prevents killing unrelated/important
+ * processes such as /sbin/init. Note that the target task may share clean
+ * pages with init (eg. libc text), which is harmless. If the target task
+ * share _dirty_ pages with another task B, the test scheme must make sure B
+ * is also included in the memcg. At last, due to race conditions this filter
+ * can only guarantee that the page either belongs to the memcg tasks, or is
+ * a freed page.
+ */
+#ifdef	CONFIG_CGROUP_MEM_RES_CTLR_SWAP
+u64 hwpoison_filter_memcg;
+EXPORT_SYMBOL_GPL(hwpoison_filter_memcg);
+static int hwpoison_filter_task(struct page *p)
+{
+	struct mem_cgroup *mem;
+	struct cgroup_subsys_state *css;
+	unsigned long ino;
+
+	if (!hwpoison_filter_memcg)
+		return 0;
+
+	mem = try_get_mem_cgroup_from_page(p);
+	if (!mem)
+		return -EINVAL;
+
+	css = mem_cgroup_css(mem);
+	ino = css->cgroup->dentry->d_inode->i_ino;
+	css_put(css);
+
+	if (ino != hwpoison_filter_memcg)
+		return -EINVAL;
+
+	return 0;
+}
+#else
+static int hwpoison_filter_task(struct page *p) { return 0; }
+#endif
+
 int hwpoison_filter(struct page *p)
 {
 	if (hwpoison_filter_dev(p))
@@ -108,6 +147,9 @@ int hwpoison_filter(struct page *p)
 	if (hwpoison_filter_flags(p))
 		return -EINVAL;
 
+	if (hwpoison_filter_task(p))
+		return -EINVAL;
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(hwpoison_filter);
Index: linux/mm/internal.h
===================================================================
--- linux.orig/mm/internal.h
+++ linux/mm/internal.h
@@ -270,3 +270,4 @@ extern u32 hwpoison_filter_dev_major;
 extern u32 hwpoison_filter_dev_minor;
 extern u64 hwpoison_filter_flags_mask;
 extern u64 hwpoison_filter_flags_value;
+extern u64 hwpoison_filter_memcg;
Index: linux/mm/hwpoison-inject.c
===================================================================
--- linux.orig/mm/hwpoison-inject.c
+++ linux/mm/hwpoison-inject.c
@@ -112,6 +112,13 @@ static int pfn_inject_init(void)
 	if (!dentry)
 		goto fail;
 
+#ifdef	CONFIG_CGROUP_MEM_RES_CTLR_SWAP
+	dentry = debugfs_create_u64("corrupt-filter-memcg", 0600,
+				    hwpoison_dir, &hwpoison_filter_memcg);
+	if (!dentry)
+		goto fail;
+#endif
+
 	return 0;
 fail:
 	pfn_inject_exit();
Index: linux/Documentation/vm/hwpoison.txt
===================================================================
--- linux.orig/Documentation/vm/hwpoison.txt
+++ linux/Documentation/vm/hwpoison.txt
@@ -123,6 +123,22 @@ Only handle memory failures to pages ass
 by block device major/minor.  -1U is the wildcard value.
 This should be only used for testing with artificial injection.
 
+corrupt-filter-memcg
+
+Limit injection to pages owned by memgroup. Specified by inode number
+of the memcg.
+
+Example:
+        mkdir /cgroup/hwpoison
+
+        usemem -m 100 -s 1000 &
+        echo `jobs -p` > /cgroup/hwpoison/tasks
+
+        memcg_ino=$(ls -id /cgroup/hwpoison | cut -f1 -d' ')
+        echo $memcg_ino > /debug/hwpoison/corrupt-filter-memcg
+
+        page-types -p `pidof init`   --hwpoison  # shall do nothing
+        page-types -p `pidof usemem` --hwpoison  # poison its pages
 
 corrupt-filter-flags-mask
 corrupt-filter-flags-value

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
