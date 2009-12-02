From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 22/24] HWPOISON: add memory cgroup filter
Date: Wed, 02 Dec 2009 11:12:53 +0800
Message-ID: <20091202043046.519053333@intel.com>
References: <20091202031231.735876003@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 18CDD6007C1
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 23:37:39 -0500 (EST)
Content-Disposition: inline; filename=hwpoison-filter-memcg.patch
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Nick Piggin <npiggin@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

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

The benifits are simplification of hwpoison injector code. Also the
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
 mm/Kconfig           |    3 ++-
 mm/hwpoison-inject.c |    5 +++++
 mm/internal.h        |    1 +
 mm/memory-failure.c  |   24 ++++++++++++++++++++++++
 4 files changed, 32 insertions(+), 1 deletion(-)

--- linux-mm.orig/mm/memory-failure.c	2009-12-01 09:56:06.000000000 +0800
+++ linux-mm/mm/memory-failure.c	2009-12-01 09:56:18.000000000 +0800
@@ -53,6 +53,7 @@ u32 hwpoison_filter_dev_major = ~0U;
 u32 hwpoison_filter_dev_minor = ~0U;
 u64 hwpoison_filter_flags_mask;
 u64 hwpoison_filter_flags_value;
+u32 hwpoison_filter_memcg;
 
 static int hwpoison_filter_dev(struct page *p)
 {
@@ -96,6 +97,26 @@ static int hwpoison_filter_flags(struct 
 		return -EINVAL;
 }
 
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
+	if (!css)
+		return -EINVAL;
+
+	css_put(css);
+	return 0;
+}
+
 int hwpoison_filter(struct page *p)
 {
 	if (hwpoison_filter_dev(p))
@@ -104,6 +125,9 @@ int hwpoison_filter(struct page *p)
 	if (hwpoison_filter_flags(p))
 		return -EINVAL;
 
+	if (hwpoison_filter_task(p))
+		return -EINVAL;
+
 	return 0;
 }
 
--- linux-mm.orig/mm/internal.h	2009-12-01 09:56:06.000000000 +0800
+++ linux-mm/mm/internal.h	2009-12-01 09:56:18.000000000 +0800
@@ -270,3 +270,4 @@ extern u32 hwpoison_filter_dev_major;
 extern u32 hwpoison_filter_dev_minor;
 extern u64 hwpoison_filter_flags_mask;
 extern u64 hwpoison_filter_flags_value;
+extern u32 hwpoison_filter_memcg;
--- linux-mm.orig/mm/hwpoison-inject.c	2009-12-01 09:56:06.000000000 +0800
+++ linux-mm/mm/hwpoison-inject.c	2009-12-01 09:56:18.000000000 +0800
@@ -95,6 +95,11 @@ static int pfn_inject_init(void)
 	if (!dentry)
 		goto fail;
 
+	dentry = debugfs_create_u32("corrupt-filter-memcg", 0600,
+				    hwpoison_dir, &hwpoison_filter_memcg);
+	if (!dentry)
+		goto fail;
+
 	return 0;
 fail:
 	pfn_inject_exit();
--- linux-mm.orig/mm/Kconfig	2009-11-30 11:08:30.000000000 +0800
+++ linux-mm/mm/Kconfig	2009-12-01 09:56:18.000000000 +0800
@@ -257,8 +257,9 @@ config MEMORY_FAILURE
 	  special hardware support and typically ECC memory.
 
 config HWPOISON_INJECT
-	tristate "Poison pages injector"
+	tristate "HWPoison pages injector"
 	depends on MEMORY_FAILURE && DEBUG_KERNEL
+	depends on CGROUP_MEM_RES_CTLR_SWAP
 
 config NOMMU_INITIAL_TRIM_EXCESS
 	int "Turn on mmap() excess space trimming before booting"


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
