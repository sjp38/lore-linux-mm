Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 9B35B6B0062
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 04:36:01 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CB46F3EE0C1
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 17:35:59 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AD27045DE51
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 17:35:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 93B8945DE4E
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 17:35:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8204A1DB803E
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 17:35:59 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DFC9E38003
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 17:35:59 +0900 (JST)
Message-ID: <508110C4.6030805@jp.fujitsu.com>
Date: Fri, 19 Oct 2012 17:35:16 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [patch for-3.7 v3] mm, mempolicy: hold task->mempolicy refcount while
 reading numa_maps.
References: <alpine.DEB.2.00.1210152306320.9480@chino.kir.corp.google.com> <CAHGf_=pemT6rcbu=dBVSJE7GuGWwVFP+Wn-mwkcsZ_gBGfaOsg@mail.gmail.com> <alpine.DEB.2.00.1210161657220.14014@chino.kir.corp.google.com> <alpine.DEB.2.00.1210161714110.17278@chino.kir.corp.google.com> <20121017040515.GA13505@redhat.com> <alpine.DEB.2.00.1210162222100.26279@chino.kir.corp.google.com> <20121017181413.GA16805@redhat.com> <alpine.DEB.2.00.1210171219010.28214@chino.kir.corp.google.com> <20121017193229.GC16805@redhat.com> <alpine.DEB.2.00.1210171237130.28214@chino.kir.corp.google.com> <20121017194501.GA24400@redhat.com> <alpine.DEB.2.00.1210171318400.28214@chino.kir.corp.google.com> <alpine.DEB.2.00.1210171428540.20712@chino.kir.corp.google.com> <507F803A.8000900@jp.fujitsu.com> <507F86BD.7070201@jp.fujitsu.com> <alpine.DEB.2.00.1210181255470.26994@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1210181255470.26994@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, bhutchings@solarflare.com, Konstantin Khlebnikov <khlebnikov@openvz.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

(2012/10/19 5:03), David Rientjes wrote:
> On Thu, 18 Oct 2012, Kamezawa Hiroyuki wrote:
>> @@ -132,7 +162,7 @@ static void *m_start(struct seq_file *m, loff_t *pos)
>>    	tail_vma = get_gate_vma(priv->task->mm);
>>   	priv->tail_vma = tail_vma;
>> -
>> +	hold_task_mempolicy(priv);
>>   	/* Start with last addr hint */
>>   	vma = find_vma(mm, last_addr);
>>   	if (last_addr && vma) {
>> @@ -159,6 +189,7 @@ out:
>>   	if (vma)
>>   		return vma;
>>   +	release_task_mempolicy(priv);
>>   	/* End of vmas has been reached */
>>   	m->version = (tail_vma != NULL)? 0: -1UL;
>>   	up_read(&mm->mmap_sem);
>
> Otherwise looks good, but please remove the two task_lock()'s in
> show_numa_map() that I added as part of this since you're replacing the
> need for locking.
>
Thank you for your review.
How about this ?

==
 From c5849c9034abeec3f26bf30dadccd393b0c5c25e Mon Sep 17 00:00:00 2001
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 19 Oct 2012 17:00:55 +0900
Subject: [PATCH] hold task->mempolicy while numa_maps scans.

  /proc/<pid>/numa_maps scans vma and show mempolicy under
  mmap_sem. It sometimes accesses task->mempolicy which can
  be freed without mmap_sem and numa_maps can show some
  garbage while scanning.

This patch tries to take reference count of task->mempolicy at reading
numa_maps before calling get_vma_policy(). By this, task->mempolicy
will not be freed until numa_maps reaches its end.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

V2->v3
  -  updated comments to be more verbose.
  -  removed task_lock() in numa_maps code.
V1->V2
  -  access task->mempolicy only once and remember it.  Becase kernel/exit.c
     can overwrite it.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
  fs/proc/internal.h |    4 ++++
  fs/proc/task_mmu.c |   49 ++++++++++++++++++++++++++++++++++++++++++++++---
  2 files changed, 50 insertions(+), 3 deletions(-)

diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index cceaab0..43973b0 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -12,6 +12,7 @@
  #include <linux/sched.h>
  #include <linux/proc_fs.h>
  struct  ctl_table_header;
+struct  mempolicy;
  
  extern struct proc_dir_entry proc_root;
  #ifdef CONFIG_PROC_SYSCTL
@@ -74,6 +75,9 @@ struct proc_maps_private {
  #ifdef CONFIG_MMU
  	struct vm_area_struct *tail_vma;
  #endif
+#ifdef CONFIG_NUMA
+	struct mempolicy *task_mempolicy;
+#endif
  };
  
  void proc_init_inodecache(void);
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 14df880..2371fea 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -89,11 +89,55 @@ static void pad_len_spaces(struct seq_file *m, int len)
  		len = 1;
  	seq_printf(m, "%*c", len, ' ');
  }
+#ifdef CONFIG_NUMA
+/*
+ * These functions are for numa_maps but called in generic **maps seq_file
+ * ->start(), ->stop() ops.
+ *
+ * numa_maps scans all vmas under mmap_sem and checks their mempolicy.
+ * Each mempolicy object is controlled by reference counting. The problem here
+ * is how to avoid accessing dead mempolicy object.
+ *
+ * Because we're holding mmap_sem while reading seq_file, it's safe to access
+ * each vma's mempolicy, no vma objects will never drop refs to mempolicy.
+ *
+ * A task's mempolicy (task->mempolicy) has different behavior. task->mempolicy
+ * is set and replaced under mmap_sem but unrefed and cleared under task_lock().
+ * So, without task_lock(), we cannot trust get_vma_policy() because we cannot
+ * gurantee the task never exits under us. But taking task_lock() around
+ * get_vma_plicy() causes lock order problem.
+ *
+ * To access task->mempolicy without lock, we hold a reference count of an
+ * object pointed by task->mempolicy and remember it. This will guarantee
+ * that task->mempolicy points to an alive object or NULL in numa_maps accesses.
+ */
+static void hold_task_mempolicy(struct proc_maps_private *priv)
+{
+	struct task_struct *task = priv->task;
+
+	task_lock(task);
+	priv->task_mempolicy = task->mempolicy;
+	mpol_get(priv->task_mempolicy);
+	task_unlock(task);
+}
+static void release_task_mempolicy(struct proc_maps_private *priv)
+{
+	mpol_put(priv->task_mempolicy);
+}
+#else
+static void hold_task_mempolicy(struct proc_maps_private *priv)
+{
+}
+static void release_task_mempolicy(struct proc_maps_private *priv)
+{
+}
+#endif
  
  static void vma_stop(struct proc_maps_private *priv, struct vm_area_struct *vma)
  {
  	if (vma && vma != priv->tail_vma) {
  		struct mm_struct *mm = vma->vm_mm;
+		release_task_mempolicy(priv);
  		up_read(&mm->mmap_sem);
  		mmput(mm);
  	}
@@ -132,7 +176,7 @@ static void *m_start(struct seq_file *m, loff_t *pos)
  
  	tail_vma = get_gate_vma(priv->task->mm);
  	priv->tail_vma = tail_vma;
-
+	hold_task_mempolicy(priv);
  	/* Start with last addr hint */
  	vma = find_vma(mm, last_addr);
  	if (last_addr && vma) {
@@ -159,6 +203,7 @@ out:
  	if (vma)
  		return vma;
  
+	release_task_mempolicy(priv);
  	/* End of vmas has been reached */
  	m->version = (tail_vma != NULL)? 0: -1UL;
  	up_read(&mm->mmap_sem);
@@ -1178,11 +1223,9 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
  	walk.private = md;
  	walk.mm = mm;
  
-	task_lock(task);
  	pol = get_vma_policy(task, vma, vma->vm_start);
  	mpol_to_str(buffer, sizeof(buffer), pol, 0);
  	mpol_cond_put(pol);
-	task_unlock(task);
  
  	seq_printf(m, "%08lx %s", vma->vm_start, buffer);
  
-- 
1.7.10.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
