Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 416FF6B02DC
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:16:14 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id j58so13800490qtj.18
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:16:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f27sor5849524qkf.72.2017.11.22.13.16.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Nov 2017 13:16:13 -0800 (PST)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH v2 03/11] lib: make the fprop batch size a multiple of PAGE_SIZE
Date: Wed, 22 Nov 2017 16:15:58 -0500
Message-Id: <1511385366-20329-4-git-send-email-josef@toxicpanda.com>
In-Reply-To: <1511385366-20329-1-git-send-email-josef@toxicpanda.com>
References: <1511385366-20329-1-git-send-email-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org
Cc: Josef Bacik <jbacik@fb.com>

From: Josef Bacik <jbacik@fb.com>

We are converting the writeback counters to use bytes instead of pages,
so we need to make the batch size for the percpu modifications align
properly with the new units.  Since we used pages before, just multiply
by PAGE_SIZE to get the equivalent bytes for the batch size.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 lib/flex_proportions.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/flex_proportions.c b/lib/flex_proportions.c
index 2cc1f94e03a1..b0343ae71f5e 100644
--- a/lib/flex_proportions.c
+++ b/lib/flex_proportions.c
@@ -166,7 +166,7 @@ void fprop_fraction_single(struct fprop_global *p,
 /*
  * ---- PERCPU ----
  */
-#define PROP_BATCH (8*(1+ilog2(nr_cpu_ids)))
+#define PROP_BATCH (8*PAGE_SIZE*(1+ilog2(nr_cpu_ids)))
 
 int fprop_local_init_percpu(struct fprop_local_percpu *pl, gfp_t gfp)
 {
-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
