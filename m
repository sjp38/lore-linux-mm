Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4990D6B026D
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 08:57:08 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id s63so11701026wme.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:57:08 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id c10si29010679wjt.45.2016.04.26.05.56.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 05:56:44 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id w143so4195355wmw.3
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:44 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 17/18] drm/radeon: make radeon_mn_get wait for mmap_sem killable
Date: Tue, 26 Apr 2016 14:56:24 +0200
Message-Id: <1461675385-5934-18-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
References: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Alex Deucher <alexander.deucher@amd.com>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, David Airlie <airlied@linux.ie>, Vlastimil Babka <vbabka@suse.cz>

From: Michal Hocko <mhocko@suse.com>

radeon_mn_get which is called during ioct path relies on mmap_sem for
write. If the waiting task gets killed by the oom killer it would block
oom_reaper from asynchronous address space reclaim and reduce the
chances of timely OOM resolving. Wait for the lock in the killable mode
and return with EINTR if the task got killed while waiting.

Cc: Alex Deucher <alexander.deucher@amd.com>
Cc: "Christian KA?nig" <christian.koenig@amd.com>
Cc: David Airlie <airlied@linux.ie>
Reviewed-by: Christian KA?nig <christian.koenig@amd.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 drivers/gpu/drm/radeon/radeon_mn.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/radeon/radeon_mn.c b/drivers/gpu/drm/radeon/radeon_mn.c
index eef006c48584..896f2cf51e4e 100644
--- a/drivers/gpu/drm/radeon/radeon_mn.c
+++ b/drivers/gpu/drm/radeon/radeon_mn.c
@@ -186,7 +186,9 @@ static struct radeon_mn *radeon_mn_get(struct radeon_device *rdev)
 	struct radeon_mn *rmn;
 	int r;
 
-	down_write(&mm->mmap_sem);
+	if (down_write_killable(&mm->mmap_sem))
+		return ERR_PTR(-EINTR);
+
 	mutex_lock(&rdev->mn_lock);
 
 	hash_for_each_possible(rdev->mn_hash, rmn, node, (unsigned long)mm)
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
