Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 64E166B0031
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 17:58:51 -0400 (EDT)
Date: Wed, 19 Oct 2011 23:54:02 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 14/X] uprobes: uprobe_deny_signal: check
	__fatal_signal_pending()
Message-ID: <20111019215402.GH16395@redhat.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20111015190007.GA30243@redhat.com> <20111019215139.GA16395@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111019215139.GA16395@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

Change uprobe_deny_signal() to check __fatal_signal_pending() along with
xol_was_trapped().

Normally this is not really needed but this is safer. And this makes more
clear the fact that even SIGKILL is handled via UTASK_SSTEP_TRAPPED. Once
again, SIGKILL can be pending because of the core-dumping, we should not
exit with regs->ip pointing to ->xol_vaddr.
---
 kernel/uprobes.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index aa5492a..9e9d4e4 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -1335,7 +1335,7 @@ bool uprobe_deny_signal(void)
 		clear_tsk_thread_flag(tsk, TIF_SIGPENDING);
 		spin_unlock_irq(&tsk->sighand->siglock);
 
-		if (xol_was_trapped(tsk)) {
+		if (__fatal_signal_pending(tsk) || xol_was_trapped(tsk)) {
 			utask->state = UTASK_SSTEP_TRAPPED;
 			set_tsk_thread_flag(tsk, TIF_UPROBE);
 			set_tsk_thread_flag(tsk, TIF_NOTIFY_RESUME);
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
