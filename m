Date: Tue, 12 Aug 2003 12:40:46 +0200
From: Roger Luethi <rl@hellgate.ch>
Subject: [PATCH] Deprecate /proc/#/statm
Message-ID: <20030812104046.GA6606@k3.hellgate.ch>
References: <20030811090213.GA11939@k3.hellgate.ch> <20030811160222.GE3170@holomorphy.com> <20030811215235.GB13180@k3.hellgate.ch> <20030811221646.GF3170@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030811221646.GF3170@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Mon, 11 Aug 2003 15:16:46 -0700, William Lee Irwin III wrote:
> > has actually more values that seem correct as it is now. Since statm has
> > been broken in 2.4, fixing it for 2.6 means basically _introducing_ a file
> > full of redundant information with unclear semantics, a file which nobody
> > missed in 2.4. I still think the file should die.
> 
> Not entirely unreasonable.

Alright. We have established that /proc/#/statm has been useless at least
since 2.4. Procps doesn't even bother reading it.

I propose this very non-invasive patch for 2.6. It replaces all values
printed in statm (all of which are either redundant or bogus) with 0s (for
kblockd and others statm is a line of zeroes already). IMO the real surgery
should happen in 2.7.

Comments? Andrew?

Roger

--- fs/proc/array.c.orig	2003-08-12 11:21:54.599717655 +0200
+++ fs/proc/array.c	2003-08-12 12:09:28.912397328 +0200
@@ -392,6 +392,8 @@
 int proc_pid_statm(struct task_struct *task, char *buffer)
 {
 	int size = 0, resident = 0, shared = 0, text = 0, lib = 0, data = 0;
+	/* TODO Rip out /proc/#/statm in 2.7 */
+#if 0
 	struct mm_struct *mm = get_task_mm(task);
 	
 	if (mm) {
@@ -401,6 +403,7 @@
 
 		mmput(mm);
 	}
+#endif
 
 	return sprintf(buffer,"%d %d %d %d %d %d %d\n",
 		       size, resident, shared, text, lib, data, 0);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
