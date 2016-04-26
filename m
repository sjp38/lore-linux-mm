Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1B3976B0253
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 09:04:25 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r12so11870528wme.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 06:04:25 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id wa2si17159054wjc.62.2016.04.26.05.56.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 05:56:45 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id r12so4234860wme.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:45 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 18/18] drm/amdgpu: make amdgpu_mn_get wait for mmap_sem killable
Date: Tue, 26 Apr 2016 14:56:25 +0200
Message-Id: <1461675385-5934-19-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
References: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, David Airlie <airlied@linux.ie>, Alex Deucher <alexander.deucher@amd.com>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, Vlastimil Babka <vbabka@suse.cz>

From: Michal Hocko <mhocko@suse.com>

amdgpu_mn_get which is called during ioct path relies on mmap_sem for
write. If the waiting task gets killed by the oom killer it would block
oom_reaper from asynchronous address space reclaim and reduce the
chances of timely OOM resolving. Wait for the lock in the killable mode
and return with EINTR if the task got killed while waiting.

Cc: David Airlie <airlied@linux.ie>
Cc: Alex Deucher <alexander.deucher@amd.com>
Reviewed-by: Christian KA?nig <christian.koenig@amd.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
index 9f4a45cd2aab..cf90686a50d1 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
@@ -232,7 +232,10 @@ static struct amdgpu_mn *amdgpu_mn_get(struct amdgpu_device *adev)
 	int r;
 
 	mutex_lock(&adev->mn_lock);
-	down_write(&mm->mmap_sem);
+	if (down_write_killable(&mm->mmap_sem)) {
+		mutex_unlock(&adev->mn_lock);
+		return -EINTR;
+	}
 
 	hash_for_each_possible(adev->mn_hash, rmn, node, (unsigned long)mm)
 		if (rmn->mm == mm)
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
