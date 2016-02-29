Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 27F5A6B025C
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 08:27:29 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id l68so58407648wml.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 05:27:29 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 11/18] coredump: make coredump_wait wait for mma_sem for write killable
Date: Mon, 29 Feb 2016 14:26:50 +0100
Message-Id: <1456752417-9626-12-git-send-email-mhocko@kernel.org>
In-Reply-To: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@suse.com>

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

Cc: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/coredump.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/coredump.c b/fs/coredump.c
index 9ea87e9fdccf..6b8aa1629891 100644
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -410,7 +410,9 @@ static int coredump_wait(int exit_code, struct core_state *core_state)
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
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
