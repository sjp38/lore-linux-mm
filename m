Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 61F5C6B0261
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 08:27:39 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id l68so58413832wml.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 05:27:39 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 17/18] drm/radeon: make radeon_mn_get wait for mmap_sem killable
Date: Mon, 29 Feb 2016 14:26:56 +0100
Message-Id: <1456752417-9626-18-git-send-email-mhocko@kernel.org>
In-Reply-To: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

radeon_mn_get which is called during ioct path relies on mmap_sem for
write. If the waiting task gets killed by the oom killer it would block
oom_reaper from asynchronous address space reclaim and reduce the
chances of timely OOM resolving. Wait for the lock in the killable mode
and return with EINTR if the task got killed while waiting.

Cc: Alex Deucher <alexander.deucher@amd.com>
Cc: "Christian KA?nig" <christian.koenig@amd.com>
Cc: David Airlie <airlied@linux.ie>
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
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
