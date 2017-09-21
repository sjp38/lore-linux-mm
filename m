Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 29B786B0038
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 11:26:09 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id d8so12219851pgt.1
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 08:26:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g14sor852738pln.56.2017.09.21.08.26.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Sep 2017 08:26:07 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH v4] mm: introduce validity check on vm dirtiness settings
Date: Fri, 22 Sep 2017 07:12:32 +0800
Message-Id: <1506035552-13010-1-git-send-email-laoar.shao@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Yafang Shao <laoar.shao@gmail.com>

we can find the logic in domain_dirty_limits() that
when dirty bg_thresh is bigger than dirty thresh,
bg_thresh will be set as thresh * 1 / 2.
	if (bg_thresh >= thresh)
		bg_thresh = thresh / 2;

But actually we can set vm background dirtiness bigger than
vm dirtiness successfully. This behavior may mislead us.
We'd better do this validity check at the beginning.

Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 Documentation/sysctl/vm.txt |  6 ++++
 kernel/sysctl.c             |  4 +--
 mm/page-writeback.c         | 78 ++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 78 insertions(+), 10 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 9baf66a..0bab85d 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -156,6 +156,9 @@ read.
 Note: the minimum value allowed for dirty_bytes is two pages (in bytes); any
 value lower than this limit will be ignored and the old configuration will be
 retained.
+Note: the value of dirty_bytes also cannot be set lower than
+dirty_background_bytes or the amount of memory corresponding to
+dirty_background_ratio.
 
 ==============================================================
 
@@ -176,6 +179,9 @@ generating disk writes will itself start writing out dirty data.
 
 The total available memory is not equal to total system memory.
 
+Note: dirty_ratio cannot be set lower than dirty_background_ratio or
+ratio corresponding to dirty_background_bytes.
+
 ==============================================================
 
 dirty_writeback_centisecs
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 6648fbb..7b525cf 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1293,7 +1293,7 @@ static int sysrq_sysctl_handler(struct ctl_table *table, int write,
 		.maxlen		= sizeof(dirty_background_ratio),
 		.mode		= 0644,
 		.proc_handler	= dirty_background_ratio_handler,
-		.extra1		= &zero,
+		.extra1		= &one,
 		.extra2		= &one_hundred,
 	},
 	{
@@ -1310,7 +1310,7 @@ static int sysrq_sysctl_handler(struct ctl_table *table, int write,
 		.maxlen		= sizeof(vm_dirty_ratio),
 		.mode		= 0644,
 		.proc_handler	= dirty_ratio_handler,
-		.extra1		= &zero,
+		.extra1		= &one,
 		.extra2		= &one_hundred,
 	},
 	{
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0b9c5cb..a0dad7b 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -511,15 +511,59 @@ bool node_dirty_ok(struct pglist_data *pgdat)
 	return nr_pages <= limit;
 }
 
+static bool vm_dirty_settings_valid(void)
+{
+	bool ret = true;
+	unsigned long bytes;
+
+	if (vm_dirty_ratio > 0) {
+		if (dirty_background_ratio >= vm_dirty_ratio) {
+			ret = false;
+			goto out;
+		}
+
+		bytes = global_dirtyable_memory() * PAGE_SIZE / 100 *
+				vm_dirty_ratio;
+		if (dirty_background_bytes >= bytes) {
+			ret = false;
+			goto out;
+		}
+	}
+
+	if (vm_dirty_bytes > 0) {
+		if (dirty_background_bytes >= vm_dirty_bytes) {
+			ret = false;
+			goto out;
+		}
+
+		bytes = global_dirtyable_memory() * PAGE_SIZE / 100 *
+				dirty_background_ratio;
+
+		if (bytes >= vm_dirty_bytes)
+			ret = false;
+	}
+
+out:
+	return ret;
+}
+
 int dirty_background_ratio_handler(struct ctl_table *table, int write,
 		void __user *buffer, size_t *lenp,
 		loff_t *ppos)
 {
 	int ret;
+	int old_ratio = dirty_background_ratio;
 
 	ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
-	if (ret == 0 && write)
-		dirty_background_bytes = 0;
+	if (ret == 0 && write && dirty_background_ratio != old_ratio) {
+		if (vm_dirty_settings_valid())
+			dirty_background_bytes = 0;
+		else {
+			dirty_background_ratio = old_ratio;
+			ret = -EINVAL;
+		}
+	}
+
 	return ret;
 }
 
@@ -528,10 +572,18 @@ int dirty_background_bytes_handler(struct ctl_table *table, int write,
 		loff_t *ppos)
 {
 	int ret;
+	unsigned long old_bytes = dirty_background_bytes;
 
 	ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
-	if (ret == 0 && write)
-		dirty_background_ratio = 0;
+	if (ret == 0 && write && dirty_background_bytes != old_bytes) {
+		if (vm_dirty_settings_valid())
+			dirty_background_ratio = 0;
+		else {
+			dirty_background_bytes = old_bytes;
+			ret = -EINVAL;
+		}
+	}
+
 	return ret;
 }
 
@@ -544,8 +596,13 @@ int dirty_ratio_handler(struct ctl_table *table, int write,
 
 	ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
 	if (ret == 0 && write && vm_dirty_ratio != old_ratio) {
-		writeback_set_ratelimit();
-		vm_dirty_bytes = 0;
+		if (vm_dirty_settings_valid()) {
+			writeback_set_ratelimit();
+			vm_dirty_bytes = 0;
+		} else {
+			vm_dirty_ratio = old_ratio;
+			ret = -EINVAL;
+		}
 	}
 	return ret;
 }
@@ -559,8 +616,13 @@ int dirty_bytes_handler(struct ctl_table *table, int write,
 
 	ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
 	if (ret == 0 && write && vm_dirty_bytes != old_bytes) {
-		writeback_set_ratelimit();
-		vm_dirty_ratio = 0;
+		if (vm_dirty_settings_valid()) {
+			writeback_set_ratelimit();
+			vm_dirty_ratio = 0;
+		} else {
+			vm_dirty_bytes = old_bytes;
+			ret = -EINVAL;
+		}
 	}
 	return ret;
 }
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
