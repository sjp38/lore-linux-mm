Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2496C6B0253
	for <linux-mm@kvack.org>; Sun, 17 Sep 2017 05:53:02 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id d8so12733983pgt.1
        for <linux-mm@kvack.org>; Sun, 17 Sep 2017 02:53:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b35sor2440700plh.57.2017.09.17.02.53.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Sep 2017 02:53:00 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm: introduce sanity check on dirty ratio sysctl value
Date: Mon, 18 Sep 2017 01:39:28 +0800
Message-Id: <1505669968-12593-1-git-send-email-laoar.shao@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, jack@suse.cz, hannes@cmpxchg.org, mhocko@suse.com, vdavydov.dev@gmail.com, jlayton@redhat.com, nborisov@suse.com, tytso@mit.edu, mawilcox@microsoft.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, laoar.shao@gmail.com

we can find the logic in domain_dirty_limits() that
when dirty bg_thresh is bigger than dirty thresh,
bg_thresh will be set as thresh * 1 / 2.
	if (bg_thresh >= thresh)
		bg_thresh = thresh / 2;

But actually we can set dirty_background_raio bigger than
dirty_ratio successfully. This behavior may mislead us.
So we should do this sanity check at the beginning.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 Documentation/sysctl/vm.txt |  5 +++
 mm/page-writeback.c         | 84 ++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 81 insertions(+), 8 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 9baf66a..b87e238 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -156,6 +156,8 @@ read.
 Note: the minimum value allowed for dirty_bytes is two pages (in bytes); any
 value lower than this limit will be ignored and the old configuration will be
 retained.
+dirty_bytes can't less than dirty_background_bytes or
+dirty_ratio * available_memory / 100.
 
 ==============================================================
 
@@ -176,6 +178,9 @@ generating disk writes will itself start writing out dirty data.
 
 The total available memory is not equal to total system memory.
 
+Note: dirty_ratio can't less than dirty_background_ratio or
+dirty_background_bytes / available_memory * 100.
+
 ==============================================================
 
 dirty_writeback_centisecs
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0b9c5cb..1dcb8f7 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -515,11 +515,29 @@ int dirty_background_ratio_handler(struct ctl_table *table, int write,
 		void __user *buffer, size_t *lenp,
 		loff_t *ppos)
 {
+	int old_ratio = dirty_background_ratio;
+	unsigned long bytes;
 	int ret;
 
 	ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
-	if (ret == 0 && write)
-		dirty_background_bytes = 0;
+
+	if (ret == 0 && write) {
+		if (vm_dirty_ratio > 0) {
+			if (dirty_background_ratio >= vm_dirty_ratio)
+				ret = -EINVAL;
+		} else if (vm_dirty_bytes > 0) {
+			bytes = global_dirtyable_memory() * PAGE_SIZE *
+					dirty_background_ratio / 100;
+			if (bytes >= vm_dirty_bytes)
+				ret = -EINVAL;
+		}
+
+		if (ret == 0)
+			dirty_background_bytes = 0;
+		else
+			dirty_background_ratio = old_ratio;
+	}
+
 	return ret;
 }
 
@@ -527,11 +545,29 @@ int dirty_background_bytes_handler(struct ctl_table *table, int write,
 		void __user *buffer, size_t *lenp,
 		loff_t *ppos)
 {
+	unsigned long old_bytes = dirty_background_bytes;
+	unsigned long bytes;
 	int ret;
 
 	ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
-	if (ret == 0 && write)
-		dirty_background_ratio = 0;
+
+	if (ret == 0 && write) {
+		if (vm_dirty_bytes > 0) {
+			if (dirty_background_bytes >= vm_dirty_bytes)
+				ret = -EINVAL;
+		} else if (vm_dirty_ratio > 0) {
+			bytes = global_dirtyable_memory() * PAGE_SIZE *
+					vm_dirty_ratio / 100;
+			if (dirty_background_bytes >= bytes)
+				ret = -EINVAL;
+		}
+
+		if (ret == 0)
+			dirty_background_ratio = 0;
+		else
+			dirty_background_bytes = old_bytes;
+	}
+
 	return ret;
 }
 
@@ -540,13 +576,29 @@ int dirty_ratio_handler(struct ctl_table *table, int write,
 		loff_t *ppos)
 {
 	int old_ratio = vm_dirty_ratio;
+	unsigned long bytes;
 	int ret;
 
 	ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
+
 	if (ret == 0 && write && vm_dirty_ratio != old_ratio) {
-		writeback_set_ratelimit();
-		vm_dirty_bytes = 0;
+		if (dirty_background_ratio > 0) {
+			if (vm_dirty_ratio <= dirty_background_ratio)
+				ret = -EINVAL;
+		} else if (dirty_background_bytes > 0) {
+			bytes = global_dirtyable_memory() * PAGE_SIZE *
+					vm_dirty_ratio / 100;
+			if (bytes <= dirty_background_bytes)
+				ret = -EINVAL;
+		}
+
+		if (ret == 0) {
+			writeback_set_ratelimit();
+			vm_dirty_bytes = 0;
+		} else
+			vm_dirty_ratio = old_ratio;
 	}
+
 	return ret;
 }
 
@@ -555,13 +607,29 @@ int dirty_bytes_handler(struct ctl_table *table, int write,
 		loff_t *ppos)
 {
 	unsigned long old_bytes = vm_dirty_bytes;
+	unsigned long bytes;
 	int ret;
 
 	ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
+
 	if (ret == 0 && write && vm_dirty_bytes != old_bytes) {
-		writeback_set_ratelimit();
-		vm_dirty_ratio = 0;
+		if (dirty_background_ratio > 0) {
+			bytes = global_dirtyable_memory() * PAGE_SIZE *
+					dirty_background_ratio / 100;
+			if (vm_dirty_bytes <= bytes)
+				ret = -EINVAL;
+		} else if (dirty_background_bytes > 0) {
+			if (vm_dirty_bytes <= dirty_background_bytes)
+				ret = -EINVAL;
+		}
+
+		if (ret == 0) {
+			writeback_set_ratelimit();
+			vm_dirty_ratio = 0;
+		} else
+			vm_dirty_bytes = old_bytes;
 	}
+
 	return ret;
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
