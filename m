Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 766098D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 15:13:32 -0400 (EDT)
Date: Mon, 14 Mar 2011 20:04:46 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 1/3 for 2.6.38] oom: oom_kill_process: don't set TIF_MEMDIE
	if !p->mm
Message-ID: <20110314190446.GB21845@redhat.com>
References: <20110303100030.B936.A69D9226@jp.fujitsu.com> <20110308134233.GA26884@redhat.com> <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com> <20110309151946.dea51cde.akpm@linux-foundation.org> <alpine.DEB.2.00.1103111142260.30699@chino.kir.corp.google.com> <20110312123413.GA18351@redhat.com> <20110312134341.GA27275@redhat.com> <AANLkTinHGSb2_jfkwx=Wjv96phzPCjBROfCTFCKi4Wey@mail.gmail.com> <20110313212726.GA24530@redhat.com> <20110314190419.GA21845@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110314190419.GA21845@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrey Vagin <avagin@openvz.org>, David Rientjes <rientjes@google.com>, Frantisek Hrbata <fhrbata@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

oom_kill_process() simply sets TIF_MEMDIE and returns if PF_EXITING.
This is very wrong by many reasons. In particular, this thread can
be the dead group leader. Check p->mm != NULL.

Note: this is _not_ enough. Just a minimal fix.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 mm/oom_kill.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 38/mm/oom_kill.c~1_kill_fix_pf_exiting	2011-03-14 17:53:05.000000000 +0100
+++ 38/mm/oom_kill.c	2011-03-14 18:51:49.000000000 +0100
@@ -470,7 +470,7 @@ static int oom_kill_process(struct task_
 	 * If the task is already exiting, don't alarm the sysadmin or kill
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
-	if (p->flags & PF_EXITING) {
+	if (p->flags & PF_EXITING && p->mm) {
 		set_tsk_thread_flag(p, TIF_MEMDIE);
 		boost_dying_task_prio(p, mem);
 		return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
