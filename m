Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 0DA2C6B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 20:31:26 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so7319653pad.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 17:31:26 -0700 (PDT)
Date: Tue, 16 Oct 2012 17:31:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch for-3.7] mm, mempolicy: fix printing stack contents in
 numa_maps
In-Reply-To: <alpine.DEB.2.00.1210161657220.14014@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1210161714110.17278@chino.kir.corp.google.com>
References: <20121008150949.GA15130@redhat.com> <CAHGf_=pr1AYeWZhaC2MKN-XjiWB7=hs92V0sH-zVw3i00X-e=A@mail.gmail.com> <alpine.DEB.2.00.1210152055150.5400@chino.kir.corp.google.com> <CAHGf_=rLjQbtWQLDcbsaq5=zcZgjdveaOVdGtBgBwZFt78py4Q@mail.gmail.com>
 <alpine.DEB.2.00.1210152306320.9480@chino.kir.corp.google.com> <CAHGf_=pemT6rcbu=dBVSJE7GuGWwVFP+Wn-mwkcsZ_gBGfaOsg@mail.gmail.com> <alpine.DEB.2.00.1210161657220.14014@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Jones <davej@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, bhutchings@solarflare.com, Konstantin Khlebnikov <khlebnikov@openvz.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

When reading /proc/pid/numa_maps, it's possible to return the contents of 
the stack where the mempolicy string should be printed if the policy gets 
freed from beneath us.

This happens because mpol_to_str() may return an error the 
stack-allocated buffer is then printed without ever being stored.

There are two possible error conditions in mpol_to_str():

 - if the buffer allocated is insufficient for the string to be stored, 
   and

 - if the mempolicy has an invalid mode.

The first error condition is not triggered in any of the callers to 
mpol_to_str(): at least 50 bytes is always allocated on the stack and this 
is sufficient for the string to be written.  A future patch should convert 
this into BUILD_BUG_ON() since we know the maximum strlen possible, but 
that's not -rc material.

The second error condition is possible if a race occurs in dropping a 
reference to a task's mempolicy causing it to be freed during the read().  
The slab poison value is then used for the mode and mpol_to_str() returns 
-EINVAL.

This race is only possible because get_vma_policy() believes that 
mm->mmap_sem protects task->mempolicy, which isn't true.  The exit path 
does not hold mm->mmap_sem when dropping the reference or setting 
task->mempolicy to NULL: it uses task_lock(task) instead.

Thus, it's required for the caller of a task mempolicy to hold 
task_lock(task) while grabbing the mempolicy and reading it.  Callers with 
a vma policy store their mempolicy earlier and can simply increment the 
reference count so it's guaranteed not to be freed.

Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 fs/proc/task_mmu.c |    7 +++++--
 mm/mempolicy.c     |    5 ++---
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1158,6 +1158,7 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 	struct vm_area_struct *vma = v;
 	struct numa_maps *md = &numa_priv->md;
 	struct file *file = vma->vm_file;
+	struct task_struct *task = proc_priv->task;
 	struct mm_struct *mm = vma->vm_mm;
 	struct mm_walk walk = {};
 	struct mempolicy *pol;
@@ -1177,9 +1178,11 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 	walk.private = md;
 	walk.mm = mm;
 
-	pol = get_vma_policy(proc_priv->task, vma, vma->vm_start);
+	task_lock(task);
+	pol = get_vma_policy(task, vma, vma->vm_start);
 	mpol_to_str(buffer, sizeof(buffer), pol, 0);
 	mpol_cond_put(pol);
+	task_unlock(task);
 
 	seq_printf(m, "%08lx %s", vma->vm_start, buffer);
 
@@ -1189,7 +1192,7 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 	} else if (vma->vm_start <= mm->brk && vma->vm_end >= mm->start_brk) {
 		seq_printf(m, " heap");
 	} else {
-		pid_t tid = vm_is_stack(proc_priv->task, vma, is_pid);
+		pid_t tid = vm_is_stack(task, vma, is_pid);
 		if (tid != 0) {
 			/*
 			 * Thread stack in /proc/PID/task/TID/maps or
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 0b78fb9..d04a8a5 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1536,9 +1536,8 @@ asmlinkage long compat_sys_mbind(compat_ulong_t start, compat_ulong_t len,
  *
  * Returns effective policy for a VMA at specified address.
  * Falls back to @task or system default policy, as necessary.
- * Current or other task's task mempolicy and non-shared vma policies
- * are protected by the task's mmap_sem, which must be held for read by
- * the caller.
+ * Current or other task's task mempolicy and non-shared vma policies must be
+ * protected by task_lock(task) by the caller.
  * Shared policies [those marked as MPOL_F_SHARED] require an extra reference
  * count--added by the get_policy() vm_op, as appropriate--to protect against
  * freeing by another task.  It is the caller's responsibility to free the

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
