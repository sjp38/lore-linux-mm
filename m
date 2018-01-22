Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id CE830800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 03:25:25 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id c14so2017809wrd.6
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 00:25:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f5sor1600768wmc.3.2018.01.22.00.25.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jan 2018 00:25:24 -0800 (PST)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH] kcov: detect double association with a single task
Date: Mon, 22 Jan 2018 09:25:20 +0100
Message-Id: <20180122082520.15716-1-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: sp3485@columbia.edu, andrew.aday@columbia.edu, Dmitry Vyukov <dvyukov@google.com>, syzkaller@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently KCOV_ENABLE does not check if the current task is already
associated with another kcov descriptor. As the result it is possible
to associate a single task with more than one kcov descriptor, which
later leads to a memory leak of the old descriptor. This relation is
really meant to be one-to-one (task has only one back link).

Extend validation to detect such misuse.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Reported-by: Shankara Pailoor <sp3485@columbia.edu>
Fixes: 5c9a8750a640 ("kernel: add kcov code coverage")
Cc: syzkaller@googlegroups.com
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 kernel/kcov.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/kcov.c b/kernel/kcov.c
index 7594c033d98a..2c16f1ab5e10 100644
--- a/kernel/kcov.c
+++ b/kernel/kcov.c
@@ -358,7 +358,8 @@ static int kcov_ioctl_locked(struct kcov *kcov, unsigned int cmd,
 		 */
 		if (kcov->mode != KCOV_MODE_INIT || !kcov->area)
 			return -EINVAL;
-		if (kcov->t != NULL)
+		t = current;
+		if (kcov->t != NULL || t->kcov != NULL)
 			return -EBUSY;
 		if (arg == KCOV_TRACE_PC)
 			kcov->mode = KCOV_MODE_TRACE_PC;
@@ -370,7 +371,6 @@ static int kcov_ioctl_locked(struct kcov *kcov, unsigned int cmd,
 #endif
 		else
 			return -EINVAL;
-		t = current;
 		/* Cache in task struct for performance. */
 		t->kcov_size = kcov->size;
 		t->kcov_area = kcov->area;
-- 
2.16.0.rc1.238.g530d649a79-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
