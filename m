Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id B55B76B026B
	for <linux-mm@kvack.org>; Thu, 31 May 2018 20:43:50 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id i1-v6so14218206pld.11
        for <linux-mm@kvack.org>; Thu, 31 May 2018 17:43:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s65-v6sor12588588pfj.137.2018.05.31.17.43.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 May 2018 17:43:49 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 08/16] device: Use overflow helpers for devm_kmalloc()
Date: Thu, 31 May 2018 17:42:25 -0700
Message-Id: <20180601004233.37822-9-keescook@chromium.org>
In-Reply-To: <20180601004233.37822-1-keescook@chromium.org>
References: <20180601004233.37822-1-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Matthew Wilcox <willy@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

Use the overflow helpers both in existing multiplication-using inlines as
well as the addition-overflow case in the core allocation routine.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/base/devres.c  | 7 ++++++-
 include/linux/device.h | 8 ++++++--
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/base/devres.c b/drivers/base/devres.c
index 95b67281cd2a..f98a097e73f2 100644
--- a/drivers/base/devres.c
+++ b/drivers/base/devres.c
@@ -84,9 +84,14 @@ static struct devres_group * node_to_group(struct devres_node *node)
 static __always_inline struct devres * alloc_dr(dr_release_t release,
 						size_t size, gfp_t gfp, int nid)
 {
-	size_t tot_size = sizeof(struct devres) + size;
+	size_t tot_size;
 	struct devres *dr;
 
+	/* We must catch any near-SIZE_MAX cases that could overflow. */
+	if (unlikely(check_add_overflow(sizeof(struct devres), size,
+					&tot_size)))
+		return NULL;
+
 	dr = kmalloc_node_track_caller(tot_size, gfp, nid);
 	if (unlikely(!dr))
 		return NULL;
diff --git a/include/linux/device.h b/include/linux/device.h
index 477956990f5e..897efa647203 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -25,6 +25,7 @@
 #include <linux/ratelimit.h>
 #include <linux/uidgid.h>
 #include <linux/gfp.h>
+#include <linux/overflow.h>
 #include <asm/device.h>
 
 struct device;
@@ -668,9 +669,12 @@ static inline void *devm_kzalloc(struct device *dev, size_t size, gfp_t gfp)
 static inline void *devm_kmalloc_array(struct device *dev,
 				       size_t n, size_t size, gfp_t flags)
 {
-	if (size != 0 && n > SIZE_MAX / size)
+	size_t bytes;
+
+	if (unlikely(check_mul_overflow(n, size, &bytes)))
 		return NULL;
-	return devm_kmalloc(dev, n * size, flags);
+
+	return devm_kmalloc(dev, bytes, flags);
 }
 static inline void *devm_kcalloc(struct device *dev,
 				 size_t n, size_t size, gfp_t flags)
-- 
2.17.0
