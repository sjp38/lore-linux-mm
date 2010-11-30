From: Christoph Lameter <cl@linux.com>
Subject: [thisops uV3 17/18] Connector: Use this_cpu operations
Date: Tue, 30 Nov 2010 13:07:24 -0600
Message-ID: <20101130190851.156410048@linux.com>
References: <20101130190707.457099608@linux.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PNVZu-0000fQ-R3
	for glkm-linux-mm-2@m.gmane.org; Tue, 30 Nov 2010 20:09:27 +0100
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 07ACC6B009C
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 14:08:53 -0500 (EST)
Content-Disposition: inline; filename=this_cpu_cn_proc
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Scott James Remnant <scott@ubuntu.com>, Mike Frysinger <vapier@gentoo.org>, linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

get_seq can benefit from this_cpu_operations. Address calculation is avoided
and the increment is done using an xadd.

Cc: Scott James Remnant <scott@ubuntu.com>
Cc: Mike Frysinger <vapier@gentoo.org>
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 drivers/connector/cn_proc.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux-2.6/drivers/connector/cn_proc.c
===================================================================
--- linux-2.6.orig/drivers/connector/cn_proc.c	2010-11-30 09:38:33.000000000 -0600
+++ linux-2.6/drivers/connector/cn_proc.c	2010-11-30 09:39:38.000000000 -0600
@@ -43,9 +43,10 @@ static DEFINE_PER_CPU(__u32, proc_event_
 
 static inline void get_seq(__u32 *ts, int *cpu)
 {
-	*ts = get_cpu_var(proc_event_counts)++;
+	preempt_disable();
+	*ts = __this_cpu_inc(proc_event_counts);
 	*cpu = smp_processor_id();
-	put_cpu_var(proc_event_counts);
+	preempt_enable();
 }
 
 void proc_fork_connector(struct task_struct *task)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
