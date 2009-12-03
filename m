Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 81AD06B003D
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 21:28:42 -0500 (EST)
Date: Thu, 3 Dec 2009 10:28:28 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 22/24] HWPOISON: add memory cgroup filter
Message-ID: <20091203022828.GA15527@localhost>
References: <20091202031231.735876003@intel.com> <20091202043046.519053333@intel.com> <20091202124446.GA18989@one.firstfloor.org> <20091202125842.GA13277@localhost> <4B171F35.1010908@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B171F35.1010908@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

After integrating Andi, Kame and Zefan's review comments:
---
HWPOISON: add memory cgroup filter

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
---
 mm/Kconfig           |    2 +-
 mm/hwpoison-inject.c |    7 +++++++
 mm/internal.h        |    1 +
 mm/memory-failure.c  |   35 +++++++++++++++++++++++++++++++++++
 4 files changed, 44 insertions(+), 1 deletion(-)

--- linux-mm.orig/mm/memory-failure.c	2009-12-03 09:51:46.000000000 +0800
+++ linux-mm/mm/memory-failure.c	2009-12-03 10:24:14.000000000 +0800
@@ -96,6 +96,38 @@ static int hwpoison_filter_flags(struct 
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
+u32 hwpoison_filter_memcg;
+static int hwpoison_filter_task(struct page *p)
+{
+	struct mem_cgroup *mem;
+	struct cgroup_subsys_state *css;
+
+	if (!hwpoison_filter_memcg)
+		return 0;
+
+	mem = try_get_mem_cgroup_from_page(p);
+	if (!mem)
+		return -EINVAL;
+
+	css = mem_cgroup_css(mem);
+	css_put(css);
+	return 0;
+}
+#else
+static int hwpoison_filter_task(struct page *p) { return 0; }
+#endif
+
 int hwpoison_filter(struct page *p)
 {
 	if (hwpoison_filter_dev(p))
@@ -104,6 +136,9 @@ int hwpoison_filter(struct page *p)
 	if (hwpoison_filter_flags(p))
 		return -EINVAL;
 
+	if (hwpoison_filter_task(p))
+		return -EINVAL;
+
 	return 0;
 }
 
--- linux-mm.orig/mm/internal.h	2009-12-03 09:51:46.000000000 +0800
+++ linux-mm/mm/internal.h	2009-12-03 09:51:54.000000000 +0800
@@ -270,3 +270,4 @@ extern u32 hwpoison_filter_dev_major;
 extern u32 hwpoison_filter_dev_minor;
 extern u64 hwpoison_filter_flags_mask;
 extern u64 hwpoison_filter_flags_value;
+extern u32 hwpoison_filter_memcg;
--- linux-mm.orig/mm/hwpoison-inject.c	2009-12-03 09:51:46.000000000 +0800
+++ linux-mm/mm/hwpoison-inject.c	2009-12-03 09:51:54.000000000 +0800
@@ -95,6 +95,13 @@ static int pfn_inject_init(void)
 	if (!dentry)
 		goto fail;
 
+#ifdef	CONFIG_CGROUP_MEM_RES_CTLR_SWAP
+	dentry = debugfs_create_u32("corrupt-filter-memcg", 0600,
+				    hwpoison_dir, &hwpoison_filter_memcg);
+	if (!dentry)
+		goto fail;
+#endif
+
 	return 0;
 fail:
 	pfn_inject_exit();
--- linux-mm.orig/mm/Kconfig	2009-12-03 09:51:46.000000000 +0800
+++ linux-mm/mm/Kconfig	2009-12-03 09:51:54.000000000 +0800
@@ -257,7 +257,7 @@ config MEMORY_FAILURE
 	  special hardware support and typically ECC memory.
 
 config HWPOISON_INJECT
-	tristate "Poison pages injector"
+	tristate "HWPoison pages injector"
 	depends on MEMORY_FAILURE && DEBUG_KERNEL
 
 config NOMMU_INITIAL_TRIM_EXCESS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
