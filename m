Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0487D6B0259
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 12:42:38 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id n186so61001298wmn.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 09:42:37 -0800 (PST)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id r76si21368406wmg.70.2016.02.29.09.42.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 09:42:33 -0800 (PST)
Received: by mail-wm0-f47.google.com with SMTP id n186so60996792wmn.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 09:42:33 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] uprobes: wait for mmap_sem for write killable
Date: Mon, 29 Feb 2016 18:42:23 +0100
Message-Id: <1456767743-18665-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1456752417-9626-16-git-send-email-mhocko@kernel.org>
References: <1456752417-9626-16-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

xol_add_vma needs mmap_sem for write. If the waiting task gets killed by
the oom killer it would block oom_reaper from asynchronous address space
reclaim and reduce the chances of timely OOM resolving. Wait for the
lock in the killable mode and return with EINTR if the task got killed
while waiting.

Do not warn in dup_xol_work if __create_xol_area failed due to fatal
signal pending because this is usually considered a kernel issue.

Cc: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 kernel/events/uprobes.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 8eef5f55d3f0..fb4a6bcc88ce 100644
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
@@ -1468,7 +1470,8 @@ static void dup_xol_work(struct callback_head *work)
 	if (current->flags & PF_EXITING)
 		return;
 
-	if (!__create_xol_area(current->utask->dup_xol_addr))
+	if (!__create_xol_area(current->utask->dup_xol_addr) &&
+			!fatal_signal_pending(current)
 		uprobe_warn(current, "dup xol area");
 }
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
