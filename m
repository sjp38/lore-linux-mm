Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 48DE96B026C
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 08:57:06 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k200so12573115lfg.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:57:06 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id v198si3192909wmv.34.2016.04.26.05.56.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 05:56:44 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id r12so4234669wme.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:43 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 16/18] drm/i915: make i915_gem_mmap_ioctl wait for mmap_sem killable
Date: Tue, 26 Apr 2016 14:56:23 +0200
Message-Id: <1461675385-5934-17-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
References: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Daniel Vetter <daniel.vetter@intel.com>, David Airlie <airlied@linux.ie>, Vlastimil Babka <vbabka@suse.cz>

From: Michal Hocko <mhocko@suse.com>

i915_gem_mmap_ioctl relies on mmap_sem for write. If the waiting
task gets killed by the oom killer it would block oom_reaper from
asynchronous address space reclaim and reduce the chances of timely OOM
resolving. Wait for the lock in the killable mode and return with EINTR
if the task got killed while waiting.

Cc: Daniel Vetter <daniel.vetter@intel.com>
Cc: David Airlie <airlied@linux.ie>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 drivers/gpu/drm/i915/i915_gem.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 761e28febddc..b99c761846ce 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -1721,7 +1721,10 @@ i915_gem_mmap_ioctl(struct drm_device *dev, void *data,
 		struct mm_struct *mm = current->mm;
 		struct vm_area_struct *vma;
 
-		down_write(&mm->mmap_sem);
+		if (down_write_killable(&mm->mmap_sem)) {
+			drm_gem_object_unreference_unlocked(obj);
+			return -EINTR;
+		}
 		vma = find_vma(mm, addr);
 		if (vma)
 			vma->vm_page_prot =
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
