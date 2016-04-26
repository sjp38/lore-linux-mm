Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E362A6B0265
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 08:56:50 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w143so11587814wmw.3
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:50 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id a7si29860766wjn.75.2016.04.26.05.56.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 05:56:38 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id r12so4233855wme.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:38 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 09/18] ipc, shm: make shmem attach/detach wait for mmap_sem killable
Date: Tue, 26 Apr 2016 14:56:16 +0200
Message-Id: <1461675385-5934-10-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
References: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Vlastimil Babka <vbabka@suse.cz>

From: Michal Hocko <mhocko@suse.com>

shmat and shmdt rely on mmap_sem for write. If the waiting task
gets killed by the oom killer it would block oom_reaper from
asynchronous address space reclaim and reduce the chances of timely
OOM resolving. Wait for the lock in the killable mode and return with
EINTR if the task got killed while waiting.

Cc: Hugh Dickins <hughd@google.com>
Acked-by: Davidlohr Bueso <dave@stgolabs.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
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
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
