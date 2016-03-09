Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id DD8BC6B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 05:19:50 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id p65so64041231wmp.0
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 02:19:50 -0800 (PST)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id h83si9805900wmi.37.2016.03.09.02.19.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 02:19:49 -0800 (PST)
Received: by mail-wm0-f45.google.com with SMTP id p65so185538830wmp.1
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 02:19:49 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] ipc, shm: make shmem attach/detach wait for mmap_sem killable
Date: Wed,  9 Mar 2016 11:19:38 +0100
Message-Id: <1457518778-32235-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1456752417-9626-10-git-send-email-mhocko@kernel.org>
References: <1456752417-9626-10-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>

From: Michal Hocko <mhocko@suse.com>

shmat and shmdt rely on mmap_sem for write. If the waiting task
gets killed by the oom killer it would block oom_reaper from
asynchronous address space reclaim and reduce the chances of timely
OOM resolving. Wait for the lock in the killable mode and return with
EINTR if the task got killed while waiting.

Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
Acked-by: Davidlohr Bueso <dave@stgolabs.net>
---
 ipc/shm.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/ipc/shm.c b/ipc/shm.c
index 331fc1b0b3c7..13282510bc0d 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -1200,7 +1200,11 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
 	if (err)
 		goto out_fput;
 
-	down_write(&current->mm->mmap_sem);
+	if (down_write_killable(&current->mm->mmap_sem)) {
+		err = -EINTR;
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
