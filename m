Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3BB816B02C4
	for <linux-mm@kvack.org>; Wed, 17 May 2017 05:03:55 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id l9so886931wre.12
        for <linux-mm@kvack.org>; Wed, 17 May 2017 02:03:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q1si15540307wmd.38.2017.05.17.02.03.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 May 2017 02:03:53 -0700 (PDT)
Date: Wed, 17 May 2017 11:03:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] drm: replace drm_[cm]alloc* by kvmalloc alternatives
Message-ID: <20170517090350.GG18247@dhcp22.suse.cz>
References: <20170517065509.18659-1-mhocko@kernel.org>
 <20170517073809.GJ26693@nuc-i3427.alporthouse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170517073809.GJ26693@nuc-i3427.alporthouse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daniel Vetter <daniel.vetter@intel.com>, Jani Nikula <jani.nikula@linux.intel.com>, Sean Paul <seanpaul@chromium.org>, David Airlie <airlied@linux.ie>

On Wed 17-05-17 08:38:09, Chris Wilson wrote:
> On Wed, May 17, 2017 at 08:55:08AM +0200, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > drm_[cm]alloc* has grown their own kvmalloc with vmalloc fallback
> > implementations. MM has grown kvmalloc* helpers in the meantime. Let's
> > use those because it a) reduces the code and b) MM has a better idea
> > how to implement fallbacks (e.g. do not vmalloc before kmalloc is tried
> > with __GFP_NORETRY).
> > 
> > drm_calloc_large needs to get __GFP_ZERO explicitly but it is the same
> > thing as kvmalloc_array in principle.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Just a little surprised that calloc_large users still exist.
> 
> Reviewed-by: Chris Wilson <chris@chris-wilson.co.uk>

Thanks!

> One more feature request from mm, can we have the 
> 	if (size != 0 && n > SIZE_MAX / size)
> check exported by itself.

What do you exactly mean by exporting? Something like the following?
I haven't compile tested it outside of mm with different config options.
Sticking alloc_array_check into mm_types.h is kind of gross but I do not
have a great idea where to put it. A new header doesn't seem nice.
---
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7cb17c6b97de..f908b14ffc4c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -534,7 +534,7 @@ static inline void *kvzalloc(size_t size, gfp_t flags)
 
 static inline void *kvmalloc_array(size_t n, size_t size, gfp_t flags)
 {
-	if (size != 0 && n > SIZE_MAX / size)
+	if (!alloc_array_check(n, size))
 		return NULL;
 
 	return kvmalloc(n * size, flags);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 45cdb27791a3..d7154b43a0d1 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -601,4 +601,10 @@ typedef struct {
 	unsigned long val;
 } swp_entry_t;
 
+static inline bool alloc_array_check(size_t n, size_t size)
+{
+	if (size != 0 && n > SIZE_MAX / size)
+		return false;
+	return true;
+}
 #endif /* _LINUX_MM_TYPES_H */
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 3c37a8c51921..e936ca7c55a1 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -602,7 +602,7 @@ int memcg_update_all_caches(int num_memcgs);
  */
 static inline void *kmalloc_array(size_t n, size_t size, gfp_t flags)
 {
-	if (size != 0 && n > SIZE_MAX / size)
+	if (!alloc_array_check(n, size))
 		return NULL;
 	if (__builtin_constant_p(n) && __builtin_constant_p(size))
 		return kmalloc(n * size, flags);

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
