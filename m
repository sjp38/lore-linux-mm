Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9E9426B0263
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 08:56:46 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w143so11586478wmw.3
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:46 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id br5si29868709wjb.69.2016.04.26.05.56.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 05:56:36 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id e201so4193211wme.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:36 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 07/18] mm, proc: make clear_refs killable
Date: Tue, 26 Apr 2016 14:56:14 +0200
Message-Id: <1461675385-5934-8-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
References: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Petr Cermak <petrcermak@chromium.org>, Oleg Nesterov <oleg@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

From: Michal Hocko <mhocko@suse.com>

CLEAR_REFS_MM_HIWATER_RSS and CLEAR_REFS_SOFT_DIRTY are relying on
mmap_sem for write. If the waiting task gets killed by the oom killer
and it would operate on the current's mm it would block oom_reaper from
asynchronous address space reclaim and reduce the chances of timely OOM
resolving. Wait for the lock in the killable mode and return with EINTR
if the task got killed while waiting. This will also expedite the return
to the userspace and do_exit even if the mm is remote.

Cc: Petr Cermak <petrcermak@chromium.org>
Acked-by: Oleg Nesterov <oleg@redhat.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/proc/task_mmu.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 541583510cfb..4648c7f63ae2 100644
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
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
