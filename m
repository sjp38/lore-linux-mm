Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9FC8D828DF
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 13:01:35 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id l68so684974wml.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 10:01:35 -0800 (PST)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id r8si33312598wjq.3.2016.02.29.10.01.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 10:01:34 -0800 (PST)
Received: by mail-wm0-f41.google.com with SMTP id l68so2377068wml.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 10:01:34 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, proc: make clear_refs killable
Date: Mon, 29 Feb 2016 18:56:27 +0100
Message-Id: <1456768587-24893-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1456752417-9626-8-git-send-email-mhocko@kernel.org>
References: <1456752417-9626-8-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>, Petr Cermak <petrcermak@chromium.org>

From: Michal Hocko <mhocko@suse.com>

CLEAR_REFS_MM_HIWATER_RSS and CLEAR_REFS_SOFT_DIRTY are relying on
mmap_sem for write. If the waiting task gets killed by the oom killer
and it would operate on the current's mm it would block oom_reaper from
asynchronous address space reclaim and reduce the chances of timely OOM
resolving. Wait for the lock in the killable mode and return with EINTR
if the task got killed while waiting. This will also expedite the return
to the userspace and do_exit even if the mm is remote.

Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Petr Cermak <petrcermak@chromium.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/proc/task_mmu.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 9df431642042..bb117356a04e 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1027,11 +1027,15 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 		};
 
 		if (type == CLEAR_REFS_MM_HIWATER_RSS) {
+			if (down_write_killable(&mm->mmap_sem)) {
+				count = -EINTR;
+				goto out_mm;
+			}
+
 			/*
 			 * Writing 5 to /proc/pid/clear_refs resets the peak
 			 * resident set size to this mm's current rss value.
 			 */
-			down_write(&mm->mmap_sem);
 			reset_mm_hiwater_rss(mm);
 			up_write(&mm->mmap_sem);
 			goto out_mm;
@@ -1043,7 +1047,10 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 				if (!(vma->vm_flags & VM_SOFTDIRTY))
 					continue;
 				up_read(&mm->mmap_sem);
-				down_write(&mm->mmap_sem);
+				if (down_write_killable(&mm->mmap_sem)) {
+					count = -EINTR;
+					goto out_mm;
+				}
 				for (vma = mm->mmap; vma; vma = vma->vm_next) {
 					vma->vm_flags &= ~VM_SOFTDIRTY;
 					vma_set_page_prot(vma);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
