Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A5EEE6B0038
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 22:08:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p87so358843pfj.4
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 19:08:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a70sor63689pge.134.2017.09.27.19.07.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Sep 2017 19:07:59 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm: print a warning once the vm dirtiness settings is illogical
Date: Thu, 28 Sep 2017 17:54:24 +0800
Message-Id: <1506592464-30962-1-git-send-email-laoar.shao@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: jack@suse.cz, mhocko@suse.com, linux-mm@kvack.org, Yafang Shao <laoar.shao@gmail.com>

The vm direct limit setting must be set greater than vm background
limit setting.
Otherwise we will print a warning to help the operator to figure
out that the vm dirtiness settings is in illogical state.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 Documentation/sysctl/vm.txt | 7 +++++++
 mm/page-writeback.c         | 5 ++++-
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 9baf66a..30fd16b 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -157,6 +157,10 @@ Note: the minimum value allowed for dirty_bytes is two pages (in bytes); any
 value lower than this limit will be ignored and the old configuration will be
 retained.
 
+Note: the value of dirty_bytes also must be set greater than
+dirty_background_bytes or the amount of memory corresponding to
+dirty_background_ratio.
+
 ==============================================================
 
 dirty_expire_centisecs
@@ -176,6 +180,9 @@ generating disk writes will itself start writing out dirty data.
 
 The total available memory is not equal to total system memory.
 
+Note: dirty_ratio must be set greater than dirty_background_ratio or
+ratio corresponding to dirty_background_bytes.
+
 ==============================================================
 
 dirty_writeback_centisecs
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0b9c5cb..8b747dd 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -433,8 +433,11 @@ static void domain_dirty_limits(struct dirty_throttle_control *dtc)
 	else
 		bg_thresh = (bg_ratio * available_memory) / PAGE_SIZE;
 
-	if (bg_thresh >= thresh)
+	if (unlikely(bg_thresh >= thresh)) {
+		pr_warn("vm direct limit must be set greater than background limit.\n");
 		bg_thresh = thresh / 2;
+	}
+
 	tsk = current;
 	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
 		bg_thresh += bg_thresh / 4 + global_wb_domain.dirty_limit / 32;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
