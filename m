Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E099B8D003A
	for <linux-mm@kvack.org>; Sat, 12 Mar 2011 08:53:35 -0500 (EST)
Date: Sat, 12 Mar 2011 14:44:53 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 3/3] oom: select_bad_process: use same_thread_group()
Message-ID: <20110312134453.GD27275@redhat.com>
References: <alpine.DEB.2.00.1103011108400.28110@chino.kir.corp.google.com> <20110303100030.B936.A69D9226@jp.fujitsu.com> <20110308134233.GA26884@redhat.com> <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com> <20110309151946.dea51cde.akpm@linux-foundation.org> <alpine.DEB.2.00.1103111142260.30699@chino.kir.corp.google.com> <20110312123413.GA18351@redhat.com> <20110312134341.GA27275@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110312134341.GA27275@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrey Vagin <avagin@openvz.org>, David Rientjes <rientjes@google.com>

select_bad_process() checks if the exiting process is current. This
condition can never be true if the caller is not the main thread.
Use same_thread_group() instead.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 mm/oom_kill.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 38/mm/oom_kill.c~fix_ck_current	2011-03-12 14:22:19.000000000 +0100
+++ 38/mm/oom_kill.c	2011-03-12 14:27:14.000000000 +0100
@@ -341,7 +341,7 @@ static struct task_struct *select_bad_pr
 		 * Otherwise we could get an easy OOM deadlock.
 		 */
 		if (mm_is_exiting(p)) {
-			if (p != current)
+			if (!same_thread_group(p, current))
 				return ERR_PTR(-1UL);
 
 			chosen = p;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
