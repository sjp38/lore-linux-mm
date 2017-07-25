Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5B0076B02FA
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 21:52:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u17so145024045pfa.6
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 18:52:11 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id d3si7512619pgc.726.2017.07.24.18.52.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 18:52:10 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v3 5/6] mm, swap: Add sysfs interface for VMA based swap readahead
Date: Tue, 25 Jul 2017 09:51:50 +0800
Message-Id: <20170725015151.19502-6-ying.huang@intel.com>
In-Reply-To: <20170725015151.19502-1-ying.huang@intel.com>
References: <20170725015151.19502-1-ying.huang@intel.com>
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
 mm/swap_state.c | 47 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 47 insertions(+)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index 730477d86f15..46717088bd9f 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -820,6 +820,51 @@ static ssize_t swap_readahead_total_show(
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
@@ -828,6 +873,8 @@ static struct attribute *swap_attrs[] = {
 	&swap_cache_find_total_attr.attr,
 	&swap_readahead_hits_attr.attr,
 	&swap_readahead_total_attr.attr,
+	&vma_ra_enabled_attr.attr,
+	&vma_ra_max_order_attr.attr,
 	NULL,
 };
 
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
