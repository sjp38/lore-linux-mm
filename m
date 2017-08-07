Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 026DA6B02F3
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 01:42:14 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v77so88260233pgb.15
        for <linux-mm@kvack.org>; Sun, 06 Aug 2017 22:42:13 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id n16si942416pll.676.2017.08.06.22.42.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Aug 2017 22:42:12 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v4 4/5] mm, swap: Add sysfs interface for VMA based swap readahead
Date: Mon,  7 Aug 2017 13:40:37 +0800
Message-Id: <20170807054038.1843-5-ying.huang@intel.com>
In-Reply-To: <20170807054038.1843-1-ying.huang@intel.com>
References: <20170807054038.1843-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

From: Huang Ying <ying.huang@intel.com>

The sysfs interface to control the VMA based swap readahead is added
as follow,

/sys/kernel/mm/swap/vma_ra_enabled

Enable the VMA based swap readahead algorithm, or use the original
global swap readahead algorithm.

/sys/kernel/mm/swap/vma_ra_max_order

Set the max order of the readahead window size for the VMA based swap
readahead algorithm.

The corresponding ABI documentation is added too.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>
Cc: Tim Chen <tim.c.chen@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
---
 Documentation/ABI/testing/sysfs-kernel-mm-swap | 26 +++++++++
 mm/swap_state.c                                | 80 ++++++++++++++++++++++++++
 2 files changed, 106 insertions(+)
 create mode 100644 Documentation/ABI/testing/sysfs-kernel-mm-swap

diff --git a/Documentation/ABI/testing/sysfs-kernel-mm-swap b/Documentation/ABI/testing/sysfs-kernel-mm-swap
new file mode 100644
index 000000000000..587db52084c7
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-kernel-mm-swap
@@ -0,0 +1,26 @@
+What:		/sys/kernel/mm/swap/
+Date:		August 2017
+Contact:	Linux memory management mailing list <linux-mm@kvack.org>
+Description:	Interface for swapping
+
+What:		/sys/kernel/mm/swap/vma_ra_enabled
+Date:		August 2017
+Contact:	Linux memory management mailing list <linux-mm@kvack.org>
+Description:	Enable/disable VMA based swap readahead.
+
+		If set to true, the VMA based swap readahead algorithm
+		will be used for swappable anonymous pages mapped in a
+		VMA, and the global swap readahead algorithm will be
+		still used for tmpfs etc. other users.  If set to
+		false, the global swap readahead algorithm will be
+		used for all swappable pages.
+
+What:		/sys/kernel/mm/swap/vma_ra_max_order
+Date:		August 2017
+Contact:	Linux memory management mailing list <linux-mm@kvack.org>
+Description:	The max readahead size in order for VMA based swap readahead
+
+		VMA based swap readahead algorithm will readahead at
+		most 1 << max_order pages for each readahead.  The
+		real readahead size for each readahead will be scaled
+		according to the estimation algorithm.
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 3885fef7bdf5..71ce2d1ccbf7 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -751,3 +751,83 @@ struct page *do_swap_page_readahead(swp_entry_t fentry, gfp_t gfp_mask,
 	return read_swap_cache_async(fentry, gfp_mask, vma, vmf->address,
 				     swap_ra->win == 1);
 }
+
+#ifdef CONFIG_SYSFS
+static ssize_t vma_ra_enabled_show(struct kobject *kobj,
+				     struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%s\n", swap_vma_readahead ? "true" : "false");
+}
+static ssize_t vma_ra_enabled_store(struct kobject *kobj,
+				      struct kobj_attribute *attr,
+				      const char *buf, size_t count)
+{
+	if (!strncmp(buf, "true", 4) || !strncmp(buf, "1", 1))
+		swap_vma_readahead = true;
+	else if (!strncmp(buf, "false", 5) || !strncmp(buf, "0", 1))
+		swap_vma_readahead = false;
+	else
+		return -EINVAL;
+
+	return count;
+}
+static struct kobj_attribute vma_ra_enabled_attr =
+	__ATTR(vma_ra_enabled, 0644, vma_ra_enabled_show,
+	       vma_ra_enabled_store);
+
+static ssize_t vma_ra_max_order_show(struct kobject *kobj,
+				     struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%d\n", swap_ra_max_order);
+}
+static ssize_t vma_ra_max_order_store(struct kobject *kobj,
+				      struct kobj_attribute *attr,
+				      const char *buf, size_t count)
+{
+	int err, v;
+
+	err = kstrtoint(buf, 10, &v);
+	if (err || v > SWAP_RA_ORDER_CEILING || v <= 0)
+		return -EINVAL;
+
+	swap_ra_max_order = v;
+
+	return count;
+}
+static struct kobj_attribute vma_ra_max_order_attr =
+	__ATTR(vma_ra_max_order, 0644, vma_ra_max_order_show,
+	       vma_ra_max_order_store);
+
+static struct attribute *swap_attrs[] = {
+	&vma_ra_enabled_attr.attr,
+	&vma_ra_max_order_attr.attr,
+	NULL,
+};
+
+static struct attribute_group swap_attr_group = {
+	.attrs = swap_attrs,
+};
+
+static int __init swap_init_sysfs(void)
+{
+	int err;
+	struct kobject *swap_kobj;
+
+	swap_kobj = kobject_create_and_add("swap", mm_kobj);
+	if (!swap_kobj) {
+		pr_err("failed to create swap kobject\n");
+		return -ENOMEM;
+	}
+	err = sysfs_create_group(swap_kobj, &swap_attr_group);
+	if (err) {
+		pr_err("failed to register swap group\n");
+		goto delete_obj;
+	}
+	return 0;
+
+delete_obj:
+	kobject_put(swap_kobj);
+	return err;
+}
+subsys_initcall(swap_init_sysfs);
+#endif
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
