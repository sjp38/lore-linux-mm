Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C556C6B026A
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 08:57:01 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r12so11682051wme.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:57:01 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id db10si15449978wjb.194.2016.04.26.05.56.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 05:56:42 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id w143so4195049wmw.3
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:42 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 14/18] prctl: make PR_SET_THP_DISABLE wait for mmap_sem killable
Date: Tue, 26 Apr 2016 14:56:21 +0200
Message-Id: <1461675385-5934-15-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
References: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Alex Thorlton <athorlton@sgi.com>, Vlastimil Babka <vbabka@suse.cz>

From: Michal Hocko <mhocko@suse.com>

PR_SET_THP_DISABLE requires mmap_sem for write. If the waiting
task gets killed by the oom killer it would block oom_reaper from
asynchronous address space reclaim and reduce the chances of timely OOM
resolving. Wait for the lock in the killable mode and return with EINTR
if the task got killed while waiting.

Cc: Alex Thorlton <athorlton@sgi.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 kernel/sys.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/kernel/sys.c b/kernel/sys.c
index cf8ba545c7d3..89d5be418157 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -2246,7 +2246,8 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 	case PR_SET_THP_DISABLE:
 		if (arg3 || arg4 || arg5)
 			return -EINVAL;
-		down_write(&me->mm->mmap_sem);
+		if (down_write_killable(&me->mm->mmap_sem))
+			return -EINTR;
 		if (arg2)
 			me->mm->def_flags |= VM_NOHUGEPAGE;
 		else
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
