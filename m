Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C42346B02EE
	for <linux-mm@kvack.org>; Wed, 17 May 2017 02:55:16 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y22so456489wry.1
        for <linux-mm@kvack.org>; Tue, 16 May 2017 23:55:16 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id t206si1610834wmt.55.2017.05.16.23.55.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 23:55:15 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id v4so1206716wmb.2
        for <linux-mm@kvack.org>; Tue, 16 May 2017 23:55:15 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] drm: replace drm_[cm]alloc* by kvmalloc alternatives
Date: Wed, 17 May 2017 08:55:08 +0200
Message-Id: <20170517065509.18659-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dri-devel@lists.freedesktop.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daniel Vetter <daniel.vetter@intel.com>, Jani Nikula <jani.nikula@linux.intel.com>, Sean Paul <seanpaul@chromium.org>, David Airlie <airlied@linux.ie>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

drm_[cm]alloc* has grown their own kvmalloc with vmalloc fallback
implementations. MM has grown kvmalloc* helpers in the meantime. Let's
use those because it a) reduces the code and b) MM has a better idea
how to implement fallbacks (e.g. do not vmalloc before kmalloc is tried
with __GFP_NORETRY).

drm_calloc_large needs to get __GFP_ZERO explicitly but it is the same
thing as kvmalloc_array in principle.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
I didn't add Reviewed-by from Chris because the original patch [1]
didn't change drm_calloc_large which I have missed in that posting.
This patch is the same otherwwise.

[1] http://lkml.kernel.org/r/20170516090606.5891-1-mhocko@kernel.org

 include/drm/drm_mem_util.h | 31 +++----------------------------
 1 file changed, 3 insertions(+), 28 deletions(-)

diff --git a/include/drm/drm_mem_util.h b/include/drm/drm_mem_util.h
index d0f6cf2e5324..a1ddf55fda67 100644
--- a/include/drm/drm_mem_util.h
+++ b/include/drm/drm_mem_util.h
@@ -31,43 +31,18 @@
 
 static __inline__ void *drm_calloc_large(size_t nmemb, size_t size)
 {
-	if (size != 0 && nmemb > SIZE_MAX / size)
-		return NULL;
-
-	if (size * nmemb <= PAGE_SIZE)
-	    return kcalloc(nmemb, size, GFP_KERNEL);
-
-	return vzalloc(size * nmemb);
+	return kvmalloc_array(nmemb, size, GFP_KERNEL | __GFP_ZERO);
 }
 
 /* Modeled after cairo's malloc_ab, it's like calloc but without the zeroing. */
 static __inline__ void *drm_malloc_ab(size_t nmemb, size_t size)
 {
-	if (size != 0 && nmemb > SIZE_MAX / size)
-		return NULL;
-
-	if (size * nmemb <= PAGE_SIZE)
-	    return kmalloc(nmemb * size, GFP_KERNEL);
-
-	return vmalloc(size * nmemb);
+	return kvmalloc_array(nmemb, size, GFP_KERNEL);
 }
 
 static __inline__ void *drm_malloc_gfp(size_t nmemb, size_t size, gfp_t gfp)
 {
-	if (size != 0 && nmemb > SIZE_MAX / size)
-		return NULL;
-
-	if (size * nmemb <= PAGE_SIZE)
-		return kmalloc(nmemb * size, gfp);
-
-	if (gfp & __GFP_RECLAIMABLE) {
-		void *ptr = kmalloc(nmemb * size,
-				    gfp | __GFP_NOWARN | __GFP_NORETRY);
-		if (ptr)
-			return ptr;
-	}
-
-	return __vmalloc(size * nmemb, gfp, PAGE_KERNEL);
+	return kvmalloc_array(nmemb, size, gfp);
 }
 
 static __inline void drm_free_large(void *ptr)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
