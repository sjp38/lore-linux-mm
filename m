Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6E7DC6B025E
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 16:57:03 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id q45so7571187qtq.21
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 13:57:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t184sor14045101qkc.163.2017.11.14.13.57.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 Nov 2017 13:57:02 -0800 (PST)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 04/10] lib: add a __fprop_add_percpu_max
Date: Tue, 14 Nov 2017 16:56:50 -0500
Message-Id: <1510696616-8489-4-git-send-email-josef@toxicpanda.com>
In-Reply-To: <1510696616-8489-1-git-send-email-josef@toxicpanda.com>
References: <1510696616-8489-1-git-send-email-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org
Cc: Josef Bacik <jbacik@fb.com>

From: Josef Bacik <jbacik@fb.com>

This helper allows us to add an arbitrary amount to the fprop
structures.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 include/linux/flex_proportions.h | 11 +++++++++--
 lib/flex_proportions.c           |  9 +++++----
 2 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/include/linux/flex_proportions.h b/include/linux/flex_proportions.h
index 853f4305d1b2..2d1a87331e5d 100644
--- a/include/linux/flex_proportions.h
+++ b/include/linux/flex_proportions.h
@@ -85,8 +85,8 @@ struct fprop_local_percpu {
 int fprop_local_init_percpu(struct fprop_local_percpu *pl, gfp_t gfp);
 void fprop_local_destroy_percpu(struct fprop_local_percpu *pl);
 void __fprop_inc_percpu(struct fprop_global *p, struct fprop_local_percpu *pl);
-void __fprop_inc_percpu_max(struct fprop_global *p, struct fprop_local_percpu *pl,
-			    int max_frac);
+void __fprop_add_percpu_max(struct fprop_global *p, struct fprop_local_percpu *pl,
+			    unsigned long nr, int max_frac);
 void fprop_fraction_percpu(struct fprop_global *p,
 	struct fprop_local_percpu *pl, unsigned long *numerator,
 	unsigned long *denominator);
@@ -101,4 +101,11 @@ void fprop_inc_percpu(struct fprop_global *p, struct fprop_local_percpu *pl)
 	local_irq_restore(flags);
 }
 
+static inline
+void __fprop_inc_percpu_max(struct fprop_global *p,
+			    struct fprop_local_percpu *pl, int max_frac)
+{
+	__fprop_add_percpu_max(p, pl, 1, max_frac);
+}
+
 #endif
diff --git a/lib/flex_proportions.c b/lib/flex_proportions.c
index 5552523b663a..2190180a81fe 100644
--- a/lib/flex_proportions.c
+++ b/lib/flex_proportions.c
@@ -254,8 +254,9 @@ void fprop_fraction_percpu(struct fprop_global *p,
  * Like __fprop_inc_percpu() except that event is counted only if the given
  * type has fraction smaller than @max_frac/FPROP_FRAC_BASE
  */
-void __fprop_inc_percpu_max(struct fprop_global *p,
-			    struct fprop_local_percpu *pl, int max_frac)
+void __fprop_add_percpu_max(struct fprop_global *p,
+			    struct fprop_local_percpu *pl, unsigned long nr,
+			    int max_frac)
 {
 	if (unlikely(max_frac < FPROP_FRAC_BASE)) {
 		unsigned long numerator, denominator;
@@ -266,6 +267,6 @@ void __fprop_inc_percpu_max(struct fprop_global *p,
 			return;
 	} else
 		fprop_reflect_period_percpu(p, pl);
-	percpu_counter_add_batch(&pl->events, 1, p->batch_size);
-	percpu_counter_add(&p->events, 1);
+	percpu_counter_add_batch(&pl->events, nr, p->batch_size);
+	percpu_counter_add(&p->events, nr);
 }
-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
