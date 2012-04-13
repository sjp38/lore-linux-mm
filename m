Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 6CA376B00FB
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 05:59:04 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so3014568bkw.14
        for <linux-mm@kvack.org>; Fri, 13 Apr 2012 02:59:02 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH 1/2] mm: fix NULL ptr dereference in migrate_pages
Date: Fri, 13 Apr 2012 08:58:21 -0400
Message-Id: <1334321902-7143-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, akpm@linux-foundation.org
Cc: hughd@google.com, dave@linux.vnet.ibm.com, ebiederm@xmission.com, davej@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Commit 3268c63 ("mm: fix move/migrate_pages() race on task struct") has added
an odd construct where 'mm' is checked for being NULL, and if it is, it would
get dereferenced anyways by mput()ing it.

This would lead to the following NULL ptr deref and BUG() when calling
migrate_pages() with a pid that has no mm struct:

[25904.193704] BUG: unable to handle kernel NULL pointer dereference at 0000000000000050
[25904.194235] IP: [<ffffffff810b0de7>] mmput+0x27/0xf0
[25904.194235] PGD 773e6067 PUD 77da0067 PMD 0
[25904.194235] Oops: 0002 [#1] PREEMPT SMP
[25904.194235] CPU 2
[25904.194235] Pid: 31608, comm: trinity Tainted: G        W    3.4.0-rc2-next-20120412-sasha #69
[25904.194235] RIP: 0010:[<ffffffff810b0de7>]  [<ffffffff810b0de7>] mmput+0x27/0xf0
[25904.194235] RSP: 0018:ffff880077d49e08  EFLAGS: 00010202
[25904.194235] RAX: 0000000000000286 RBX: 0000000000000000 RCX: 0000000000000000
[25904.194235] RDX: ffff880075ef8000 RSI: 000000000000023d RDI: 0000000000000286
[25904.194235] RBP: ffff880077d49e18 R08: 0000000000000001 R09: 0000000000000001
[25904.194235] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
[25904.194235] R13: 00000000ffffffea R14: ffff880034287740 R15: ffff8800218d3010
[25904.194235] FS:  00007fc8b244c700(0000) GS:ffff880029800000(0000) knlGS:0000000000000000
[25904.194235] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[25904.194235] CR2: 0000000000000050 CR3: 00000000767c6000 CR4: 00000000000406e0
[25904.194235] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[25904.194235] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[25904.194235] Process trinity (pid: 31608, threadinfo ffff880077d48000, task ffff880075ef8000)
[25904.194235] Stack:
[25904.194235]  ffff8800342876c0 0000000000000000 ffff880077d49f78 ffffffff811b8020
[25904.194235]  ffffffff811b7d91 ffff880075ef8000 ffff88002256d200 0000000000000000
[25904.194235]  00000000000003ff 0000000000000000 0000000000000000 0000000000000000
[25904.194235] Call Trace:
[25904.194235]  [<ffffffff811b8020>] sys_migrate_pages+0x340/0x3a0
[25904.194235]  [<ffffffff811b7d91>] ? sys_migrate_pages+0xb1/0x3a0
[25904.194235]  [<ffffffff8266cbb9>] system_call_fastpath+0x16/0x1b
[25904.194235] Code: c9 c3 66 90 55 31 d2 48 89 e5 be 3d 02 00 00 48 83 ec 10 48 89 1c 24 4c 89 64 24 08 48 89 fb 48 c7 c7 cf 0e e1 82 e8 69 18 03 00 <f0> ff 4b 50 0f 94 c0 84 c0 0f 84 aa 00 00 00 48 89 df e8 72 f1
[25904.194235] RIP  [<ffffffff810b0de7>] mmput+0x27/0xf0
[25904.194235]  RSP <ffff880077d49e08>
[25904.194235] CR2: 0000000000000050
[25904.348999] ---[ end trace a307b3ed40206b4b ]---

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 mm/mempolicy.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 4c0b8d5..417c363 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1361,11 +1361,14 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned long, maxnode,
 
 	mm = get_task_mm(task);
 	put_task_struct(task);
-	if (mm)
-		err = do_migrate_pages(mm, old, new,
-			capable(CAP_SYS_NICE) ? MPOL_MF_MOVE_ALL : MPOL_MF_MOVE);
-	else
+
+	if (!mm) {
 		err = -EINVAL;
+		goto out;
+	}
+
+	err = do_migrate_pages(mm, old, new,
+		capable(CAP_SYS_NICE) ? MPOL_MF_MOVE_ALL : MPOL_MF_MOVE);
 
 	mmput(mm);
 out:
-- 
1.7.8.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
