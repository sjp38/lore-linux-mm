Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A3C3C6B0028
	for <linux-mm@kvack.org>; Thu, 12 May 2011 02:18:28 -0400 (EDT)
From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH v2 2/3] coredump: use task comm instead of (unknown)
Date: Thu, 12 May 2011 08:18:12 +0200
Message-Id: <1305181093-20871-2-git-send-email-jslaby@suse.cz>
In-Reply-To: <1305181093-20871-1-git-send-email-jslaby@suse.cz>
References: <1305181093-20871-1-git-send-email-jslaby@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, jirislaby@gmail.com, Alan Cox <alan@lxorguk.ukuu.org.uk>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>

If we don't know the file corresponding to the binary (i.e. exe_file
is unknown), use "task->comm (path unknown)" instead of simple
"(unknown)" as suggested by ak.

The fallback is the same as %e except it will append "(path unknown)".

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Oleg Nesterov <oleg@redhat.com>
---
 fs/exec.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 155c6d4..8900f61 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1554,8 +1554,11 @@ static int cn_print_exe_file(struct core_name *cn)
 	int ret;
 
 	exe_file = get_mm_exe_file(current->mm);
-	if (!exe_file)
-		return cn_printf(cn, "(unknown)");
+	if (!exe_file) {
+		char comm[TASK_COMM_LEN];
+		return cn_printf(cn, "%s (path unknown)", get_task_comm(comm,
+					current));
+	}
 
 	pathbuf = kmalloc(PATH_MAX, GFP_TEMPORARY);
 	if (!pathbuf) {
-- 
1.7.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
