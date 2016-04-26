Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0FD5F6B026B
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 08:57:04 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e201so11209886wme.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:57:04 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id t65si24785421wmd.90.2016.04.26.05.56.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 05:56:43 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id r12so4234551wme.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:43 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 15/18] uprobes: wait for mmap_sem for write killable
Date: Tue, 26 Apr 2016 14:56:22 +0200
Message-Id: <1461675385-5934-16-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
References: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

From: Michal Hocko <mhocko@suse.com>

xol_add_vma needs mmap_sem for write. If the waiting task gets killed by
the oom killer it would block oom_reaper from asynchronous address space
reclaim and reduce the chances of timely OOM resolving. Wait for the
lock in the killable mode and return with EINTR if the task got killed
while waiting.

Do not warn in dup_xol_work if __create_xol_area failed due to fatal
signal pending because this is usually considered a kernel issue.

Acked-by: Oleg Nesterov <oleg@redhat.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 kernel/events/uprobes.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 7edc95edfaee..7bed7f63336d 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -1130,7 +1130,9 @@ static int xol_add_vma(struct mm_struct *mm, struct xol_area *area)
 	struct vm_area_struct *vma;
 	int ret;
 
-	down_write(&mm->mmap_sem);
+	if (down_write_killable(&mm->mmap_sem))
+		return -EINTR;
+
 	if (mm->uprobes_state.xol_area) {
 		ret = -EALREADY;
 		goto fail;
@@ -1469,7 +1471,8 @@ static void dup_xol_work(struct callback_head *work)
 	if (current->flags & PF_EXITING)
 		return;
 
-	if (!__create_xol_area(current->utask->dup_xol_addr))
+	if (!__create_xol_area(current->utask->dup_xol_addr) &&
+			!fatal_signal_pending(current))
 		uprobe_warn(current, "dup xol area");
 }
 
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
