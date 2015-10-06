Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 783F882F6F
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 05:25:03 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so150068568wic.1
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 02:25:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pm7si36818376wjb.185.2015.10.06.02.24.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Oct 2015 02:24:52 -0700 (PDT)
From: Jan Kara <jack@suse.com>
Subject: [PATCH 6/7] drm/i915: Convert to use get_user_page_unlocked()
Date: Tue,  6 Oct 2015 11:24:29 +0200
Message-Id: <1444123470-4932-7-git-send-email-jack@suse.com>
In-Reply-To: <1444123470-4932-1-git-send-email-jack@suse.com>
References: <1444123470-4932-1-git-send-email-jack@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Jan Kara <jack@suse.cz>, Daniel Vetter <daniel.vetter@intel.com>, David Airlie <airlied@linux.ie>, dri-devel@lists.freedesktop.org

From: Jan Kara <jack@suse.cz>

Convert __i915_gem_userptr_get_pages_worker() to use
get_user_page_unlocked() so that we don't unnecessarily leak knowledge of
mm locking into driver code.

CC: Daniel Vetter <daniel.vetter@intel.com>
CC: David Airlie <airlied@linux.ie>
CC: dri-devel@lists.freedesktop.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/gpu/drm/i915/i915_gem_userptr.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index 8fd431bcdfd3..5138fe61d2fa 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -585,19 +585,18 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
 	if (pvec != NULL) {
 		struct mm_struct *mm = obj->userptr.mm->mm;
 
-		down_read(&mm->mmap_sem);
 		while (pinned < num_pages) {
-			ret = get_user_pages(work->task, mm,
-					     obj->userptr.ptr + pinned * PAGE_SIZE,
-					     num_pages - pinned,
-					     !obj->userptr.read_only, 0,
-					     pvec + pinned, NULL);
+			ret = get_user_pages_unlocked(
+					work->task, mm,
+					obj->userptr.ptr + pinned * PAGE_SIZE,
+					num_pages - pinned,
+					!obj->userptr.read_only, 0,
+					pvec + pinned);
 			if (ret < 0)
 				break;
 
 			pinned += ret;
 		}
-		up_read(&mm->mmap_sem);
 	}
 
 	mutex_lock(&dev->struct_mutex);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
