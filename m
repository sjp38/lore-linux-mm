From: Christoph Lameter <cl@linux.com>
Subject: [thisops uV3 08/18] Taskstats: Use this_cpu_ops
Date: Tue, 30 Nov 2010 13:07:15 -0600
Message-ID: <20101130190845.819605614@linux.com>
References: <20101130190707.457099608@linux.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PNVZW-0000Li-IC
	for glkm-linux-mm-2@m.gmane.org; Tue, 30 Nov 2010 20:09:02 +0100
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 767466B0092
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 14:08:48 -0500 (EST)
Content-Disposition: inline; filename=this_cpu_taskstats
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Michael Holzheu <holzheu@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Use this_cpu_inc_return in one place and avoid ugly __raw_get_cpu in another.

Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 kernel/taskstats.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

Index: linux-2.6/kernel/taskstats.c
===================================================================
--- linux-2.6.orig/kernel/taskstats.c	2010-11-30 10:06:35.000000000 -0600
+++ linux-2.6/kernel/taskstats.c	2010-11-30 10:10:14.000000000 -0600
@@ -89,8 +89,7 @@ static int prepare_reply(struct genl_inf
 		return -ENOMEM;
 
 	if (!info) {
-		int seq = get_cpu_var(taskstats_seqnum)++;
-		put_cpu_var(taskstats_seqnum);
+		int seq = this_cpu_inc_return(taskstats_seqnum);
 
 		reply = genlmsg_put(skb, 0, seq, &family, 0, cmd);
 	} else
@@ -581,7 +580,7 @@ void taskstats_exit(struct task_struct *
 		fill_tgid_exit(tsk);
 	}
 
-	listeners = &__raw_get_cpu_var(listener_array);
+	listeners = __this_cpu_ptr(listener_array);
 	if (list_empty(&listeners->list))
 		return;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
