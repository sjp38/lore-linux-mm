Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 46CAB6B0033
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 08:54:52 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id o80so2947519lfg.20
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 05:54:52 -0700 (PDT)
Received: from mail.free-electrons.com (mail.free-electrons.com. [62.4.15.54])
        by mx.google.com with ESMTP id i17si852084wmb.177.2017.10.04.05.54.50
        for <linux-mm@kvack.org>;
        Wed, 04 Oct 2017 05:54:50 -0700 (PDT)
From: Boris Brezillon <boris.brezillon@free-electrons.com>
Subject: [PATCH] cma: Take __GFP_NOWARN into account in cma_alloc()
Date: Wed,  4 Oct 2017 14:54:47 +0200
Message-Id: <20171004125447.15195-1-boris.brezillon@free-electrons.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <labbott@redhat.com>
Cc: Jaewon Kim <jaewon31.kim@samsung.com>, David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>, dri-devel@lists.freedesktop.org, Eric Anholt <eric@anholt.net>, Boris Brezillon <boris.brezillon@free-electrons.com>

cma_alloc() unconditionally prints an INFO message when the CMA
allocation fails. Make this message conditional on the non-presence of
__GFP_NOWARN in gfp_mask.

Signed-off-by: Boris Brezillon <boris.brezillon@free-electrons.com>
---
Hello,

This patch aims at removing INFO messages that are displayed when the
VC4 driver tries to allocate buffer objects. From the driver perspective
an allocation failure is acceptable, and the driver can possibly do
something to make following allocation succeed (like flushing the VC4
internal cache).

Also, I don't understand why this message is only an INFO message, and
not a WARN (pr_warn()). Please let me know if you have good reasons to
keep it as an unconditional pr_info().

Thanks,

Boris
---
 mm/cma.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/cma.c b/mm/cma.c
index c0da318c020e..022e52bd8370 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -460,7 +460,7 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align,
 
 	trace_cma_alloc(pfn, page, count, align);
 
-	if (ret) {
+	if (ret && !(gfp_mask & __GFP_NOWARN)) {
 		pr_info("%s: alloc failed, req-size: %zu pages, ret: %d\n",
 			__func__, count, ret);
 		cma_debug_show_areas(cma);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
