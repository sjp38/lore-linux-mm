Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8FFD46B0259
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 08:27:25 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id n186so49199110wmn.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 05:27:25 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 09/18] ipc, shm: make shmem attach/detach wait for mmap_sem killable
Date: Mon, 29 Feb 2016 14:26:48 +0100
Message-Id: <1456752417-9626-10-git-send-email-mhocko@kernel.org>
In-Reply-To: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

shmat and shmdt rely on mmap_sem for write. If the waiting task
gets killed by the oom killer it would block oom_reaper from
asynchronous address space reclaim and reduce the chances of timely
OOM resolving. Wait for the lock in the killable mode and return with
EINTR if the task got killed while waiting.

Cc: Davidlohr Bueso <dave@stgolabs.net>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 ipc/shm.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/ipc/shm.c b/ipc/shm.c
index 331fc1b0b3c7..b8cfa05940d2 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -1200,7 +1200,11 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
 	if (err)
 		goto out_fput;
 
-	down_write(&current->mm->mmap_sem);
+	if (down_write_killable(&current->mm->mmap_sem)) {
+		err = -EINVAL;
+		goto out_fput;
+	}
+
 	if (addr && !(shmflg & SHM_REMAP)) {
 		err = -EINVAL;
 		if (addr + size < addr)
@@ -1271,7 +1275,8 @@ SYSCALL_DEFINE1(shmdt, char __user *, shmaddr)
 	if (addr & ~PAGE_MASK)
 		return retval;
 
-	down_write(&mm->mmap_sem);
+	if (down_write_killable(&mm->mmap_sem))
+		return -EINTR;
 
 	/*
 	 * This function tries to be smart and unmap shm segments that
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
