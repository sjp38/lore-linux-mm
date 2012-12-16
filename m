Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id F414E6B002B
	for <linux-mm@kvack.org>; Sun, 16 Dec 2012 14:53:59 -0500 (EST)
Date: Sun, 16 Dec 2012 19:53:56 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] mm: Downgrade mmap_sem before locking or populating on
 mmap
Message-ID: <20121216195355.GE4939@ZenIV.linux.org.uk>
References: <3b624af48f4ba4affd78466b73b6afe0e2f66549.1355463438.git.luto@amacapital.net>
 <20121214072755.GR4939@ZenIV.linux.org.uk>
 <CALCETrVw9Pc1sUZBL=wtLvsnBnkW5LAO5iu-i=T2oMOdwQfjHg@mail.gmail.com>
 <20121214144927.GS4939@ZenIV.linux.org.uk>
 <CALCETrUS7baKF7cdbrqX-o2qdeo1Uk=7Z4MHcxHMA3Luh+Obdw@mail.gmail.com>
 <20121216170403.GC4939@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121216170403.GC4939@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, J??rn Engel <joern@logfs.org>

On Sun, Dec 16, 2012 at 05:04:03PM +0000, Al Viro wrote:

> FWIW, I've done some checking of ->mmap_sem uses yesterday.  Got further than
> the last time; catch so far, just from find_vma() audit:
> * arm swp_emulate.c - missing ->mmap_sem around find_vma().  Fix sent to
> rmk.
> * blackfin ptrace - find_vma() without any protection, definitely broken
> * m68k sys_cacheflush() - ditto
> * mips process_fpemu_return() - ditto
> * mips octeon_flush_cache_sigtramp() - ditto
> * omap_vout_uservirt_to_phys() - ditto, patch sent
> * vb2_get_contig_userptr() - probaly a bug, unless I've misread the (very
> twisty maze of) v4l2 code leading to it
> * vb2_get_contig_userptr() - ditto
> * gntdev_ioctl_get_offset_for_vaddr() - definitely broken
> and there's a couple of dubious places in arch/* I hadn't finished with,
> plus a lot in mm/* proper.
> 
> That's just from a couple of days of RTFS.  The locking in there is far too
> convoluted as it is; worse, it's not localized code-wise, so rechecking
> correctness is going to remain a big time-sink ;-/
> 
> Making it *more* complex doesn't look like a good idea, TBH...

While we are at it: fs/proc/task_nommu.c:m_stop() is fucked.  It assumes
that the process in question hadn't done execve() since m_start().  And
it doesn't hold anywhere near enough locks to guarantee that.  task_mmu.c
counterpart avoids that fun by using ->vm_mm to get to mm_struct in question.
Completely untested patch follows; if it works, that's -stable fodder.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
diff --git a/fs/proc/task_nommu.c b/fs/proc/task_nommu.c
index 1ccfa53..dc26605 100644
--- a/fs/proc/task_nommu.c
+++ b/fs/proc/task_nommu.c
@@ -211,6 +211,14 @@ static int show_tid_map(struct seq_file *m, void *_p)
 	return show_map(m, _p, 0);
 }
 
+static void stop_it(void *_p)
+{
+	struct vm_area_struct *vma = rb_entry(_p, struct vm_area_struct, vm_rb);
+	struct mm_struct *mm = vma->vm_mm;
+	up_read(&mm->mmap_sem);
+	mmput(mm);
+}
+
 static void *m_start(struct seq_file *m, loff_t *pos)
 {
 	struct proc_maps_private *priv = m->private;
@@ -235,6 +243,8 @@ static void *m_start(struct seq_file *m, loff_t *pos)
 	for (p = rb_first(&mm->mm_rb); p; p = rb_next(p))
 		if (n-- == 0)
 			return p;
+	up_read(&mm->mmap_sem);
+	mmput(mm);
 	return NULL;
 }
 
@@ -243,9 +253,8 @@ static void m_stop(struct seq_file *m, void *_vml)
 	struct proc_maps_private *priv = m->private;
 
 	if (priv->task) {
-		struct mm_struct *mm = priv->task->mm;
-		up_read(&mm->mmap_sem);
-		mmput(mm);
+		if (_vml)
+			stop_it(_vml);
 		put_task_struct(priv->task);
 	}
 }
@@ -255,7 +264,12 @@ static void *m_next(struct seq_file *m, void *_p, loff_t *pos)
 	struct rb_node *p = _p;
 
 	(*pos)++;
-	return p ? rb_next(p) : NULL;
+	if (!p)
+		return NULL;
+	p = rb_next(p);
+	if (!p)
+		stop_it(_p);
+	return p;
 }
 
 static const struct seq_operations proc_pid_maps_ops = {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
