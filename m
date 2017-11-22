Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3CD3C6B02E0
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:16:17 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id q45so13819204qtq.21
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:16:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f96sor3753480qtb.110.2017.11.22.13.16.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Nov 2017 13:16:16 -0800 (PST)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH v2 05/11] writeback: convert the flexible prop stuff to bytes
Date: Wed, 22 Nov 2017 16:16:00 -0500
Message-Id: <1511385366-20329-6-git-send-email-josef@toxicpanda.com>
In-Reply-To: <1511385366-20329-1-git-send-email-josef@toxicpanda.com>
References: <1511385366-20329-1-git-send-email-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org
Cc: Josef Bacik <jbacik@fb.com>

From: Josef Bacik <jbacik@fb.com>

The flexible proportions were all page based, but now that we are doing
metadata writeout that can be smaller or larger than page size we need
to account for this in bytes instead of number of pages.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 mm/page-writeback.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index e4563645749a..2a1994194cc1 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -574,11 +574,11 @@ static unsigned long wp_next_time(unsigned long cur_time)
 	return cur_time;
 }
 
-static void wb_domain_writeout_inc(struct wb_domain *dom,
+static void wb_domain_writeout_add(struct wb_domain *dom,
 				   struct fprop_local_percpu *completions,
-				   unsigned int max_prop_frac)
+				   long bytes, unsigned int max_prop_frac)
 {
-	__fprop_inc_percpu_max(&dom->completions, completions,
+	__fprop_add_percpu_max(&dom->completions, completions, bytes,
 			       max_prop_frac);
 	/* First event after period switching was turned off? */
 	if (unlikely(!dom->period_time)) {
@@ -602,12 +602,12 @@ static inline void __wb_writeout_add(struct bdi_writeback *wb, long bytes)
 	struct wb_domain *cgdom;
 
 	__add_wb_stat(wb, WB_WRITTEN_BYTES, bytes);
-	wb_domain_writeout_inc(&global_wb_domain, &wb->completions,
+	wb_domain_writeout_add(&global_wb_domain, &wb->completions, bytes,
 			       wb->bdi->max_prop_frac);
 
 	cgdom = mem_cgroup_wb_domain(wb);
 	if (cgdom)
-		wb_domain_writeout_inc(cgdom, wb_memcg_completions(wb),
+		wb_domain_writeout_add(cgdom, wb_memcg_completions(wb), bytes,
 				       wb->bdi->max_prop_frac);
 }
 
-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
