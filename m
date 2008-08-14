From: Jiri Slaby <jirislaby@gmail.com>
Subject: [PATCH 1/1] mm_owner: fix cgroup null dereference
Date: Thu, 14 Aug 2008 22:16:53 +0200
Message-Id: <1218745013-9537-1-git-send-email-jirislaby@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi,

found this in mmotm, a fix for
mm-owner-fix-race-between-swap-and-exit.patch

--

mm->owner is set to NULL prior to calling cgroup_mm_owner_callbacks,
but it should be set after that to not pass NULL pointer as the old
owner which otherwise results in an oops (shortened):

BUG: unable to handle kernel NULL pointer dereference at 0000000000000580
Oops: 0000 [1] SMP
Pid: 3396, comm: nscd Tainted: G        W 2.6.27-rc3-mm1_64 #439
RIP: 0010:[<ffffffff8027035a>]  [<ffffffff8027035a>] cgroup_mm_owner_callbacks+0x3a/0x90
RAX: 0000000000000000 RBX: ffffffff80589720 RCX: ffff880079f503e8
RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffffff806c36e0
RBP: ffff880078291bd8 R08: ffff880078290000 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000000 R12: 0000000000000000
R13: 0000000000000000 R14: 0000000000000000 R15: ffff8800787f8e20
Call Trace:
 [<ffffffff8023d42a>] mm_update_next_owner+0x1ca/0x240
 [<ffffffff8023d5aa>] exit_mm+0x10a/0x150
 [<ffffffff8023f1fc>] do_exit+0x1dc/0x940
Code: 89 fe 41 55 49 89 f5 41 54 53 74 68 48 c7 c3 20 97 58 80 45 31 e4 0f 1f 00 48 8b 3b 4d 85 ed 48 63 47 58 48 8d 14 c5 00 00 00 00 <49> 8b 86 80 05 00 00 48 8d 44 10 38 48 8b 00 48 8b 30 74 12 49

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
---
 kernel/exit.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/kernel/exit.c b/kernel/exit.c
index 3f47470..3a2a42a 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -637,8 +637,8 @@ retry:
 	 * the callback and take action
 	 */
 	down_write(&mm->mmap_sem);
-	mm->owner = NULL;
 	cgroup_mm_owner_callbacks(mm->owner, NULL);
+	mm->owner = NULL;
 	up_write(&mm->mmap_sem);
 	return;
 
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
