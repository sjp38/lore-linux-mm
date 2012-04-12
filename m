Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id A8DF26B0044
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 04:09:53 -0400 (EDT)
Received: by lagz14 with SMTP id z14so1796913lag.14
        for <linux-mm@kvack.org>; Thu, 12 Apr 2012 01:09:51 -0700 (PDT)
Subject: [PATCH 1/2] mm: set task exit code before complete_vfork_done()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 12 Apr 2012 12:09:48 +0400
Message-ID: <20120412080948.26401.23572.stgit@zurg>
In-Reply-To: <20120409200336.8368.63793.stgit@zurg>
References: <20120409200336.8368.63793.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Markus Trippelsdorf <markus@trippelsdorf.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

kthread_stop() uses task->vfork_done for synchronization. The exiting kthread
shouldn't do complete_vfork_done() until it sets ->exit_code.

fix for mm-correctly-synchronize-rss-counters-at-exit-exec.patch

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Oleg Nesterov <oleg@redhat.com>
---
 kernel/exit.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/kernel/exit.c b/kernel/exit.c
index eb12719..70875a6 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -960,6 +960,9 @@ void do_exit(long code)
 
 	acct_update_integrals(tsk);
 
+	/* Set exit_code before complete_vfork_done() in mm_release() */
+	tsk->exit_code = code;
+
 	/* Release mm and sync mm's RSS info before statistics gathering */
 	mm_release(tsk, tsk->mm);
 
@@ -975,7 +978,6 @@ void do_exit(long code)
 		tty_audit_exit();
 	audit_free(tsk);
 
-	tsk->exit_code = code;
 	taskstats_exit(tsk, group_dead);
 
 	exit_mm(tsk);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
