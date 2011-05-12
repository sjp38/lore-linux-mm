Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 77C416B0026
	for <linux-mm@kvack.org>; Thu, 12 May 2011 02:18:28 -0400 (EDT)
From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH v2 1/3] coredump: use get_task_comm for %e filename format
Date: Thu, 12 May 2011 08:18:11 +0200
Message-Id: <1305181093-20871-1-git-send-email-jslaby@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, jirislaby@gmail.com, Alan Cox <alan@lxorguk.ukuu.org.uk>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>

We currently access current->comm directly. As we have
prctl(PR_SET_NAME), we need the access be protected by task_lock. This
is exactly what get_task_comm does, so use it.

I'm not 100% convinced prctl(PR_SET_NAME) may be called at the time of
core dump, but the locking won't hurt. Note that siglock is not held
in format_corename.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Oleg Nesterov <oleg@redhat.com>
---
 fs/exec.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 5ee7562..155c6d4 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1656,9 +1656,12 @@ static int format_corename(struct core_name *cn, long signr)
 				up_read(&uts_sem);
 				break;
 			/* executable */
-			case 'e':
-				err = cn_printf(cn, "%s", current->comm);
+			case 'e': {
+				char comm[TASK_COMM_LEN];
+				err = cn_printf(cn, "%s",
+						get_task_comm(comm, current));
 				break;
+			}
 			case 'E':
 				err = cn_print_exe_file(cn);
 				break;
-- 
1.7.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
