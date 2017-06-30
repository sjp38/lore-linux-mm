Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C89B86B02FA
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 21:45:00 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id p15so107511637pgs.7
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 18:45:00 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id l5si4691214pgu.532.2017.06.29.18.44.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 18:45:00 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v2 5/6] mm, swap: Add sysfs interface for VMA based swap readahead
Date: Fri, 30 Jun 2017 09:44:42 +0800
Message-Id: <20170630014443.23983-6-ying.huang@intel.com>
In-Reply-To: <20170630014443.23983-1-ying.huang@intel.com>
References: <20170630014443.23983-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

From: Huang Ying <ying.huang@intel.com>

The sysfs interface to control the VMA based swap readahead is added
as follow,

/sys/kernel/mm/swap/vma_ra_enabled

Enable the VMA based swap readahead algorithm, or use the original
global swap readahead algorithm.

/sys/kernel/mm/swap/vma_ra_max_order

Set the max order of the readahead window size for the VMA based swap
readahead algorithm.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>
Cc: Tim Chen <tim.c.chen@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
---
 mm/swap_state.c | 47 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 47 insertions(+)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index c88eda175ba7..bd483aff543a 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -812,6 +812,51 @@ static ssize_t swap_readahead_total_show(
 static struct kobj_attribute swap_readahead_total_attr =
 	__ATTR(ra_total, 0444, swap_readahead_total_show, NULL);
 
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
 static struct attribute *swap_attrs[] = {
 	&swap_cache_pages_attr.attr,
 	&swap_cache_add_attr.attr,
@@ -820,6 +865,8 @@ static struct attribute *swap_attrs[] = {
 	&swap_cache_find_total_attr.attr,
 	&swap_readahead_hits_attr.attr,
 	&swap_readahead_total_attr.attr,
+	&vma_ra_enabled_attr.attr,
+	&vma_ra_max_order_attr.attr,
 	NULL,
 };
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
