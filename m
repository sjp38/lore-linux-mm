Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id E6FD46B0258
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 08:27:23 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id n186so49197973wmn.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 05:27:23 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 08/18] mm, fork: make dup_mmap wait for mmap_sem for write killable
Date: Mon, 29 Feb 2016 14:26:47 +0100
Message-Id: <1456752417-9626-9-git-send-email-mhocko@kernel.org>
In-Reply-To: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

dup_mmap needs to lock current's mm mmap_sem for write. If the waiting
task gets killed by the oom killer it would block oom_reaper from
asynchronous address space reclaim and reduce the chances of timely OOM
resolving. Wait for the lock in the killable mode and return with EINTR
if the task got killed while waiting.

Cc: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 kernel/fork.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index d277e83ed3e0..e064bc8453dc 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -413,7 +413,10 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 	unsigned long charge;
 
 	uprobe_start_dup_mmap();
-	down_write(&oldmm->mmap_sem);
+	if (down_write_killable(&oldmm->mmap_sem)) {
+		uprobe_end_dup_mmap();
+		return -EINTR;
+	}
 	flush_cache_dup_mm(oldmm);
 	uprobe_dup_mmap(oldmm, mm);
 	/*
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
