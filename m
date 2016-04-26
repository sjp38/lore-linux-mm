Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5BED46B0268
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 08:56:55 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r12so11679686wme.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:55 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id p141si23416123wmb.69.2016.04.26.05.56.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 05:56:40 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id r12so4234100wme.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:39 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 11/18] coredump: make coredump_wait wait for mmap_sem for write killable
Date: Tue, 26 Apr 2016 14:56:18 +0200
Message-Id: <1461675385-5934-12-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
References: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

From: Michal Hocko <mhocko@suse.com>

coredump_wait waits for mmap_sem for write currently which can
prevent oom_reaper to reclaim the oom victims address space
asynchronously because that requires mmap_sem for read. This might
happen if the oom victim is multi threaded and some thread(s) is
holding mmap_sem for read (e.g. page fault) and it is stuck in
the page allocator while other thread(s) reached coredump_wait
already.

This patch simply uses down_write_killable and bails out with EINTR
if the lock got interrupted by the fatal signal. do_coredump will
return right away and do_group_exit will take care to zap the whole
thread group.

Acked-by: Oleg Nesterov <oleg@redhat.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/coredump.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/coredump.c b/fs/coredump.c
index 47c32c3bfa1d..f2cef927789b 100644
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -413,7 +413,9 @@ static int coredump_wait(int exit_code, struct core_state *core_state)
 	core_state->dumper.task = tsk;
 	core_state->dumper.next = NULL;
 
-	down_write(&mm->mmap_sem);
+	if (down_write_killable(&mm->mmap_sem))
+		return -EINTR;
+
 	if (!mm->core_state)
 		core_waiters = zap_threads(tsk, mm, core_state, exit_code);
 	up_write(&mm->mmap_sem);
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
