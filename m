Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 756376B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 10:39:28 -0500 (EST)
Subject: [PATCH] mm: export mmu notifier invalidates
Message-Id: <E1Tr9P7-0001AN-S4@eag09.americas.sgi.com>
From: Cliff Wickman <cpw@sgi.com>
Date: Fri, 04 Jan 2013 09:41:53 -0600
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com, akpm@linux-foundation.org, avi@redhat.com, hughd@google.com, mgorman@suse.de
Cc: linux-mm@kvack.org

From: Cliff Wickman <cpw@sgi.com>

Avi, Andrea, Andrew, Hugh, Mel,

We at SGI have a need to address some very high physical address ranges with
our GRU (global reference unit), sometimes across partitioned machine boundaries
and sometimes with larger addresses than the cpu supports.
We do this with the aid of our own 'extended vma' module which mimics the vma.
When something (either unmap or exit) frees an 'extended vma' we use the mmu
notifiers to clean them up.

We had been able to mimic the functions __mmu_notifier_invalidate_range_start()
and __mmu_notifier_invalidate_range_end() by locking the per-mm lock and 
walking the per-mm notifier list.  But with the change to a global srcu
lock (static in mmu_notifier.c) we can no longer do that.  Our module has
no access to that lock.

So we request that these two functions be exported.

Signed-off-by: Cliff Wickman <cpw@sgi.com>
Acked-by: Robin Holt <holt@sgi.com>

---
 mm/mmu_notifier.c |    2 ++
 1 file changed, 2 insertions(+)

Index: linux/mm/mmu_notifier.c
===================================================================
--- linux.orig/mm/mmu_notifier.c
+++ linux/mm/mmu_notifier.c
@@ -170,6 +170,7 @@ void __mmu_notifier_invalidate_range_sta
 	}
 	srcu_read_unlock(&srcu, id);
 }
+EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start);
 
 void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 				  unsigned long start, unsigned long end)
@@ -185,6 +186,7 @@ void __mmu_notifier_invalidate_range_end
 	}
 	srcu_read_unlock(&srcu, id);
 }
+EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_end);
 
 static int do_mmu_notifier_register(struct mmu_notifier *mn,
 				    struct mm_struct *mm,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
