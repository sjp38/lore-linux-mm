Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id D3B776B005D
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 00:34:39 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6812C3EE0C1
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 13:34:38 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E52645DEBA
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 13:34:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 332FF45DEB7
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 13:34:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FFDD1DB803E
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 13:34:38 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BFC741DB803B
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 13:34:37 +0900 (JST)
Message-ID: <507F86BD.7070201@jp.fujitsu.com>
Date: Thu, 18 Oct 2012 13:34:05 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch for-3.7 v2] mm, mempolicy: avoid taking mutex inside spinlock
 when reading numa_maps
References: <alpine.DEB.2.00.1210152306320.9480@chino.kir.corp.google.com> <CAHGf_=pemT6rcbu=dBVSJE7GuGWwVFP+Wn-mwkcsZ_gBGfaOsg@mail.gmail.com> <alpine.DEB.2.00.1210161657220.14014@chino.kir.corp.google.com> <alpine.DEB.2.00.1210161714110.17278@chino.kir.corp.google.com> <20121017040515.GA13505@redhat.com> <alpine.DEB.2.00.1210162222100.26279@chino.kir.corp.google.com> <20121017181413.GA16805@redhat.com> <alpine.DEB.2.00.1210171219010.28214@chino.kir.corp.google.com> <20121017193229.GC16805@redhat.com> <alpine.DEB.2.00.1210171237130.28214@chino.kir.corp.google.com> <20121017194501.GA24400@redhat.com> <alpine.DEB.2.00.1210171318400.28214@chino.kir.corp.google.com> <alpine.DEB.2.00.1210171428540.20712@chino.kir.corp.google.com> <507F803A.8000900@jp.fujitsu.com>
In-Reply-To: <507F803A.8000900@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, bhutchings@solarflare.com, Konstantin Khlebnikov <khlebnikov@openvz.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

(2012/10/18 13:06), Kamezawa Hiroyuki wrote:
> (2012/10/18 6:31), David Rientjes wrote:
>> As a result of commit 32f8516a8c73 ("mm, mempolicy: fix printing stack
>> contents in numa_maps"), the mutex protecting a shared policy can be
>> inadvertently taken while holding task_lock(task).
>>
>> Recently, commit b22d127a39dd ("mempolicy: fix a race in
>> shared_policy_replace()") switched the spinlock within a shared policy to
>> a mutex so sp_alloc() could block.  Thus, a refcount must be grabbed on
>> all mempolicies returned by get_vma_policy() so it isn't freed while being
>> passed to mpol_to_str() when reading /proc/pid/numa_maps.
>>
>> This patch only takes task_lock() while dereferencing task->mempolicy in
>> get_vma_policy() if it's non-NULL in the lockess check to increment its
>> refcount.  This ensures it will remain in memory until dropped by
>> __mpol_put() after mpol_to_str() is called.
>>
>> Refcounts of shared policies are grabbed by the ->get_policy() function of
>> the vma, all others will be grabbed directly in get_vma_policy().  Now
>> that this is done, all callers now unconditionally drop the refcount.
>>
>
> please add original problem description....
>
> from your 1st patch.
>> When reading /proc/pid/numa_maps, it's possible to return the contents of
>> the stack where the mempolicy string should be printed if the policy gets
>> freed from beneath us.
>>
>> This happens because mpol_to_str() may return an error the
>> stack-allocated buffer is then printed without ever being stored.
> .....
>
> Hmm, I've read the whole thread again...and, I'm sorry if I misunderstand something.
>
> I think Kosaki mentioned the commit 52cd3b0740. It avoids refcounting in get_vma_policy()
> because it's called every time alloc_pages_vma() is called, at every page fault.
> So, it seems he doesn't agree this fix because of performance concern on big NUMA,
>
>
> Can't we have another way to fix ? like this ? too ugly ?
> Again, I'm sorry if I misunderstand the points.
>
Sorry this patch itself may be buggy. please don't test..
I missed that kernel/exit.c sets task->mempolicy to be NULL.
fixed one here.

--
 From 5581c71e68a7f50e52fd67cca00148911023f9f5 Mon Sep 17 00:00:00 2001
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 18 Oct 2012 13:50:29 +0900
Subject: [PATCH] hold task->mempolicy while numa_maps scans.

  /proc/<pid>/numa_maps scans vma and show mempolicy under
  mmap_sem. It sometimes accesses task->mempolicy which can
  be freed without mmap_sem and numa_maps can show some
  garbage while scanning.

This patch tries to take reference count of task->mempolicy at reading
numa_maps before calling get_vma_policy(). By this, task->mempolicy
will not be freed until numa_maps reaches its end.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

V1->V2
  -  access task->mempolicy only once and remember it.  Becase kernel/exit.c
     can overwrite it.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
  fs/proc/internal.h |    4 ++++
  fs/proc/task_mmu.c |   33 ++++++++++++++++++++++++++++++++-
  2 files changed, 36 insertions(+), 1 deletion(-)

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
index 14df880..624927d 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -89,11 +89,41 @@ static void pad_len_spaces(struct seq_file *m, int len)
  		len = 1;
  	seq_printf(m, "%*c", len, ' ');
  }
+#ifdef CONFIG_NUMA
+/*
+ * numa_maps scans all vmas under mmap_sem and checks their mempolicy.
+ * But task->mempolicy is not guarded by mmap_sem, it can be cleared/freed
+ * under task_lock() (see kernel/exit.c) replacement of it is guarded by
+ * mmap_sem. So, take referenceount under task_lock() before we start
+ * scanning and drop it when numa_maps reaches the end.
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
@@ -132,7 +162,7 @@ static void *m_start(struct seq_file *m, loff_t *pos)
  
  	tail_vma = get_gate_vma(priv->task->mm);
  	priv->tail_vma = tail_vma;
-
+	hold_task_mempolicy(priv);
  	/* Start with last addr hint */
  	vma = find_vma(mm, last_addr);
  	if (last_addr && vma) {
@@ -159,6 +189,7 @@ out:
  	if (vma)
  		return vma;
  
+	release_task_mempolicy(priv);
  	/* End of vmas has been reached */
  	m->version = (tail_vma != NULL)? 0: -1UL;
  	up_read(&mm->mmap_sem);
-- 
1.7.10.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
