Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8AB136B0005
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 16:20:13 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 33so120581415lfw.1
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 13:20:13 -0700 (PDT)
Received: from laurent.telenet-ops.be (laurent.telenet-ops.be. [2a02:1800:110:4::f00:19])
        by mx.google.com with ESMTPS id p1si105483wmd.53.2016.08.03.13.20.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Aug 2016 13:20:12 -0700 (PDT)
From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH/RFC] mm, oom: Fix uninitialized ret in task_will_free_mem()
Date: Wed,  3 Aug 2016 22:19:59 +0200
Message-Id: <1470255599-24841-1-git-send-email-geert@linux-m68k.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>

    mm/oom_kill.c: In function a??task_will_free_mema??:
    mm/oom_kill.c:767: warning: a??reta?? may be used uninitialized in this function

If __task_will_free_mem() is never called inside the for_each_process()
loop, ret will not be initialized.

Fixes: 1af8bb43269563e4 ("mm, oom: fortify task_will_free_mem()")
Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
Untested. I'm not familiar with the code, hence the default value of
true was deducted from the logic in the loop (return false as soon as
__task_will_free_mem() has returned false).
---
 mm/oom_kill.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 7d0a275df822e9e1..d53a9aa00977cbd0 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -764,7 +764,7 @@ bool task_will_free_mem(struct task_struct *task)
 {
 	struct mm_struct *mm = task->mm;
 	struct task_struct *p;
-	bool ret;
+	bool ret = true;
 
 	/*
 	 * Skip tasks without mm because it might have passed its exit_mm and
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
