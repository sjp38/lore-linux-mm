Date: Fri, 14 Apr 2006 12:45:30 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 2/2] mm: fix mm_struct reference counting bugs in
 mm/oom_kill.c
Message-Id: <20060414124530.24a36d51.akpm@osdl.org>
In-Reply-To: <200604141214.35806.dsp@llnl.gov>
References: <200604131452.08292.dsp@llnl.gov>
	<200604131744.02114.dsp@llnl.gov>
	<20060414002654.76d1a6bc.akpm@osdl.org>
	<200604141214.35806.dsp@llnl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Peterson <dsp@llnl.gov>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com
List-ID: <linux-mm.kvack.org>

Dave Peterson <dsp@llnl.gov> wrote:
>
> On Friday 14 April 2006 00:26, Andrew Morton wrote:
> > task_lock() can be used to pin a task's ->mm.  To use task_lock() in
> > badness() we'd need to either
> >
> > a) nest task_lock()s.  I don't know if we're doing that anywhere else,
> >    but the parent->child ordering is a natural one.  or
> >
> > b) take a ref on the parent's mm_struct, drop the parent's task_lock()
> >    while we walk the children, then do mmput() on the parent's mm outside
> >    tasklist_lock.  This is probably better.
> 
> Looking a bit more closely at the code, I see that
> select_bad_process() iterates over all tasks, repeatedly calling
> badness().  This would complicate option 'b' since the iteration is
> done while holding tasklist_lock.  An alternative to option 'a' that
> avoids nesting task_lock()s would be to define a couple of new
> functions that might look something like this:
> 
>     void mmput_atomic(struct mm_struct *mm)
>     {
>             if (atomic_dec_and_test(&mm->mm_users)) {
>                     add mm to a global list of expired mm_structs
>             }
>     }
> 
>     void mmput_atomic_cleanup(void)
>     {
>             empty the global list of expired mm_structs and do
>             cleanup stuff for each one
>     }

I think that's way too elaborate.

What's wrong with this?


--- 25/mm/oom_kill.c~a	Fri Apr 14 12:37:51 2006
+++ 25-akpm/mm/oom_kill.c	Fri Apr 14 12:44:49 2006
@@ -47,15 +47,25 @@ int sysctl_panic_on_oom;
 unsigned long badness(struct task_struct *p, unsigned long uptime)
 {
 	unsigned long points, cpu_time, run_time, s;
-	struct list_head *tsk;
+	struct mm_struct *mm;
+	struct task_struct *child;
 
-	if (!p->mm)
+	task_lock(p);
+	mm = p->mm;
+	if (!mm) {
+		task_unlock(p);
 		return 0;
+	}
 
 	/*
 	 * The memory size of the process is the basis for the badness.
 	 */
-	points = p->mm->total_vm;
+	points = mm->total_vm;
+
+	/*
+	 * After this unlock we can no longer dereference local variable `mm'
+	 */
+	task_unlock(p);
 
 	/*
 	 * Processes which fork a lot of child processes are likely
@@ -65,11 +75,11 @@ unsigned long badness(struct task_struct
 	 * child is eating the vast majority of memory, adding only half
 	 * to the parents will make the child our kill candidate of choice.
 	 */
-	list_for_each(tsk, &p->children) {
-		struct task_struct *chld;
-		chld = list_entry(tsk, struct task_struct, sibling);
-		if (chld->mm != p->mm && chld->mm)
-			points += chld->mm->total_vm/2 + 1;
+	list_for_each_entry(child, &p->children, sibling) {
+		task_lock(child);
+		if (child->mm != mm && child->mm)
+			points += child->mm->total_vm/2 + 1;
+		task_unlock(child);
 	}
 
 	/*
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
