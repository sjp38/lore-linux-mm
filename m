From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [RFC][PATCH 4/4] HWPOISON: memory cgroup based hwpoison injection filtering
Date: Mon, 31 Aug 2009 18:26:44 +0800
Message-ID: <20090831104217.039999677@intel.com>
References: <20090831102640.092092954@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5D2146B005D
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 06:43:32 -0400 (EDT)
Content-Disposition: inline; filename=hwpoison-filter-cgroup-pages.patch
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, lizf@cn.fujitsu.com, nishimura@mxp.nes.nec.co.jp, menage@google.com, linux-mm <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/hwpoison-inject.c |   37 +++++++++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

--- linux-mm.orig/mm/hwpoison-inject.c	2009-08-30 18:18:41.000000000 +0800
+++ linux-mm/mm/hwpoison-inject.c	2009-08-30 18:24:33.000000000 +0800
@@ -5,10 +5,13 @@
 #include <linux/mm.h>
 #include <linux/bootmem.h>
 #include <linux/pagemap.h>
+#include <linux/page_cgroup.h>
+#include <linux/cgroup.h>
 #include "internal.h"
 
 static struct dentry *hwpoison_dir;
 
+static u32 hwpoison_filter_memcg;
 static u32 hwpoison_filter_dev_major = ~0U;
 static u32 hwpoison_filter_dev_minor = ~0U;
 static u64 hwpoison_filter_flags_mask;
@@ -53,8 +56,37 @@ static int hwpoison_filter_dev(struct pa
 	return 0;
 }
 
+static int hwpoison_filter_cg(struct page *p)
+{
+	struct mem_cgroup *mem;
+	struct cgroup_subsys_state *css;
+	int ret;
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
+	if (css_id(css) != hwpoison_filter_memcg)
+		ret = -EINVAL;
+	else
+		ret = 0;
+
+	css_put(css);
+	return ret;
+}
+
 static int hwpoison_filter(struct page *p)
 {
+	if (hwpoison_filter_cg(p))
+		return 1;
+
 	if (hwpoison_filter_dev(p))
 		return -EINVAL;
 
@@ -119,6 +151,11 @@ static int pfn_inject_init(void)
 	if (!dentry)
 		goto fail;
 
+	dentry = debugfs_create_u32("corrupt-filter-memcg", 0600,
+				    hwpoison_dir, &hwpoison_filter_memcg);
+	if (!dentry)
+		goto fail;
+
 	dentry = debugfs_create_u32("corrupt-filter-dev-major", 0600,
 				    hwpoison_dir, &hwpoison_filter_dev_major);
 	if (!dentry)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
