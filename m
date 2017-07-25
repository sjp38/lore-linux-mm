Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C8F866B02B4
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 21:52:00 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 83so87486087pgb.14
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 18:52:00 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id s10si7722046pgc.281.2017.07.24.18.51.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 18:51:59 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v3 1/6] mm, swap: Add swap cache statistics sysfs interface
Date: Tue, 25 Jul 2017 09:51:46 +0800
Message-Id: <20170725015151.19502-2-ying.huang@intel.com>
In-Reply-To: <20170725015151.19502-1-ying.huang@intel.com>
References: <20170725015151.19502-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

From: Huang Ying <ying.huang@intel.com>

The swap cache stats could be gotten only via sysrq, which isn't
convenient in some situation.  So the sysfs interface of swap cache
stats is added for that.  The added sysfs directories/files are as
follow,

/sys/kernel/mm/swap
/sys/kernel/mm/swap/cache_find_total
/sys/kernel/mm/swap/cache_find_success
/sys/kernel/mm/swap/cache_add
/sys/kernel/mm/swap/cache_del
/sys/kernel/mm/swap/cache_pages

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
 mm/swap_state.c | 78 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 78 insertions(+)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index b68c93014f50..a13bbf504e93 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -561,3 +561,81 @@ void exit_swap_address_space(unsigned int type)
 	synchronize_rcu();
 	kvfree(spaces);
 }
+
+#ifdef CONFIG_SYSFS
+static ssize_t swap_cache_pages_show(
+	struct kobject *kobj, struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%lu\n", total_swapcache_pages());
+}
+static struct kobj_attribute swap_cache_pages_attr =
+	__ATTR(cache_pages, 0444, swap_cache_pages_show, NULL);
+
+static ssize_t swap_cache_add_show(
+	struct kobject *kobj, struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%lu\n", swap_cache_info.add_total);
+}
+static struct kobj_attribute swap_cache_add_attr =
+	__ATTR(cache_add, 0444, swap_cache_add_show, NULL);
+
+static ssize_t swap_cache_del_show(
+	struct kobject *kobj, struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%lu\n", swap_cache_info.del_total);
+}
+static struct kobj_attribute swap_cache_del_attr =
+	__ATTR(cache_del, 0444, swap_cache_del_show, NULL);
+
+static ssize_t swap_cache_find_success_show(
+	struct kobject *kobj, struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%lu\n", swap_cache_info.find_success);
+}
+static struct kobj_attribute swap_cache_find_success_attr =
+	__ATTR(cache_find_success, 0444, swap_cache_find_success_show, NULL);
+
+static ssize_t swap_cache_find_total_show(
+	struct kobject *kobj, struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%lu\n", swap_cache_info.find_total);
+}
+static struct kobj_attribute swap_cache_find_total_attr =
+	__ATTR(cache_find_total, 0444, swap_cache_find_total_show, NULL);
+
+static struct attribute *swap_attrs[] = {
+	&swap_cache_pages_attr.attr,
+	&swap_cache_add_attr.attr,
+	&swap_cache_del_attr.attr,
+	&swap_cache_find_success_attr.attr,
+	&swap_cache_find_total_attr.attr,
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
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
