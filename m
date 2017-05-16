Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id F27776B0038
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:06:15 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id o25so131814908pgc.1
        for <linux-mm@kvack.org>; Tue, 16 May 2017 02:06:15 -0700 (PDT)
Received: from mail-pg0-f66.google.com (mail-pg0-f66.google.com. [74.125.83.66])
        by mx.google.com with ESMTPS id 9si13137812pfo.181.2017.05.16.02.06.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 02:06:15 -0700 (PDT)
Received: by mail-pg0-f66.google.com with SMTP id s62so20691350pgc.0
        for <linux-mm@kvack.org>; Tue, 16 May 2017 02:06:15 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] drm: use kvmalloc_array for drm_malloc*
Date: Tue, 16 May 2017 11:06:06 +0200
Message-Id: <20170516090606.5891-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dri-devel@lists.freedesktop.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daniel Vetter <daniel.vetter@intel.com>, Jani Nikula <jani.nikula@linux.intel.com>, Sean Paul <seanpaul@chromium.org>, David Airlie <airlied@linux.ie>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

drm_malloc* has grown their own kmalloc with vmalloc fallback
implementations. MM has grown kvmalloc* helpers in the meantime. Let's
use those because it a) reduces the code and b) MM has a better idea
how to implement fallbacks (e.g. do not vmalloc before kmalloc is tried
with __GFP_NORETRY).

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/drm/drm_mem_util.h | 23 ++---------------------
 1 file changed, 2 insertions(+), 21 deletions(-)

diff --git a/include/drm/drm_mem_util.h b/include/drm/drm_mem_util.h
index d0f6cf2e5324..b461e4e4e6db 100644
--- a/include/drm/drm_mem_util.h
+++ b/include/drm/drm_mem_util.h
@@ -43,31 +43,12 @@ static __inline__ void *drm_calloc_large(size_t nmemb, size_t size)
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
