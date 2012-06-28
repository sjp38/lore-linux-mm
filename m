Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 482F66B0070
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 08:57:06 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 20/40] autonuma: alloc/free/init mm_autonuma
Date: Thu, 28 Jun 2012 14:56:00 +0200
Message-Id: <1340888180-15355-21-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

This is where the mm_autonuma structure is being handled. Just like
sched_autonuma, this is only allocated at runtime if the hardware the
kernel is running on has been detected as NUMA. On not NUMA hardware
the memory cost is reduced to one pointer per mm.

To get rid of the pointer in the each mm, the kernel can be compiled
with CONFIG_AUTONUMA=n.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 kernel/fork.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 0adbe09..3e5a0d9 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -527,6 +527,8 @@ static void mm_init_aio(struct mm_struct *mm)
 
 static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 {
+	if (unlikely(alloc_mm_autonuma(mm)))
+		goto out_free_mm;
 	atomic_set(&mm->mm_users, 1);
 	atomic_set(&mm->mm_count, 1);
 	init_rwsem(&mm->mmap_sem);
@@ -549,6 +551,8 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 		return mm;
 	}
 
+	free_mm_autonuma(mm);
+out_free_mm:
 	free_mm(mm);
 	return NULL;
 }
@@ -598,6 +602,7 @@ void __mmdrop(struct mm_struct *mm)
 	destroy_context(mm);
 	mmu_notifier_mm_destroy(mm);
 	check_mm(mm);
+	free_mm_autonuma(mm);
 	free_mm(mm);
 }
 EXPORT_SYMBOL_GPL(__mmdrop);
@@ -880,6 +885,7 @@ fail_nocontext:
 	 * If init_new_context() failed, we cannot use mmput() to free the mm
 	 * because it calls destroy_context()
 	 */
+	free_mm_autonuma(mm);
 	mm_free_pgd(mm);
 	free_mm(mm);
 	return NULL;
@@ -1702,6 +1708,7 @@ void __init proc_caches_init(void)
 	mm_cachep = kmem_cache_create("mm_struct",
 			sizeof(struct mm_struct), ARCH_MIN_MMSTRUCT_ALIGN,
 			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_NOTRACK, NULL);
+	mm_autonuma_init();
 	vm_area_cachep = KMEM_CACHE(vm_area_struct, SLAB_PANIC);
 	mmap_init();
 	nsproxy_cache_init();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
