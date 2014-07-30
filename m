Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 16C906B0038
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 05:28:35 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id w10so1159210pde.18
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 02:28:34 -0700 (PDT)
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com. [202.81.31.143])
        by mx.google.com with ESMTPS id 4si864983pdm.284.2014.07.30.02.28.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Jul 2014 02:28:33 -0700 (PDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aik@ozlabs.ru>;
	Wed, 30 Jul 2014 19:28:29 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 78B23357804F
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 19:28:22 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s6U95KmE62521492
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 19:05:22 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s6U9SJoX021411
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 19:28:20 +1000
From: Alexey Kardashevskiy <aik@ozlabs.ru>
Subject: [RFC PATCH] mm: Add helpers for locked_vm
Date: Wed, 30 Jul 2014 19:28:13 +1000
Message-Id: <1406712493-9284-1-git-send-email-aik@ozlabs.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Kardashevskiy <aik@ozlabs.ru>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, =?UTF-8?q?J=C3=B6rn=20Engel?= <joern@logfs.org>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Davidlohr Bueso <davidlohr@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alex Williamson <alex.williamson@redhat.com>, Alexander Graf <agraf@suse.de>, Michael Ellerman <michael@ellerman.id.au>

This adds 2 helpers to change the locked_vm counter:
- try_increase_locked_vm - may fail if new locked_vm value will be greater
than the RLIMIT_MEMLOCK limit;
- decrease_locked_vm.

These will be used by drivers capable of locking memory by userspace
request. For example, VFIO can use it to check if it can lock DMA memory
or PPC-KVM can use it to check if it can lock memory for TCE tables.

Signed-off-by: Alexey Kardashevskiy <aik@ozlabs.ru>
---
 include/linux/mm.h |  3 +++
 mm/mlock.c         | 49 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 52 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index e03dd29..1cb219d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2113,5 +2113,8 @@ void __init setup_nr_node_ids(void);
 static inline void setup_nr_node_ids(void) {}
 #endif
 
+extern long try_increment_locked_vm(long npages);
+extern void decrement_locked_vm(long npages);
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/mm/mlock.c b/mm/mlock.c
index b1eb536..39e4b55 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -864,3 +864,52 @@ void user_shm_unlock(size_t size, struct user_struct *user)
 	spin_unlock(&shmlock_user_lock);
 	free_uid(user);
 }
+
+/**
+ * try_increment_locked_vm() - checks if new locked_vm value is going to
+ * be less than RLIMIT_MEMLOCK and increments it by npages if it is.
+ *
+ * @npages: the number of pages to add to locked_vm.
+ *
+ * Returns 0 if succeeded or negative value if failed.
+ */
+long try_increment_locked_vm(long npages)
+{
+	long ret = 0, locked, lock_limit;
+
+	if (!current || !current->mm)
+		return -ESRCH; /* process exited */
+
+	down_write(&current->mm->mmap_sem);
+	locked = current->mm->locked_vm + npages;
+	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
+	if (locked > lock_limit && !capable(CAP_IPC_LOCK)) {
+		pr_warn("RLIMIT_MEMLOCK (%ld) exceeded\n",
+				rlimit(RLIMIT_MEMLOCK));
+		ret = -ENOMEM;
+	} else {
+		current->mm->locked_vm += npages;
+	}
+	up_write(&current->mm->mmap_sem);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(try_increment_locked_vm);
+
+/**
+ * decrement_locked_vm() - decrements the current task's locked_vm counter.
+ *
+ * @npages: the number to decrement by.
+ */
+void decrement_locked_vm(long npages)
+{
+	if (!current || !current->mm)
+		return; /* process exited */
+
+	down_write(&current->mm->mmap_sem);
+	if (npages > current->mm->locked_vm)
+		npages = current->mm->locked_vm;
+	current->mm->locked_vm -= npages;
+	up_write(&current->mm->mmap_sem);
+}
+EXPORT_SYMBOL_GPL(decrement_locked_vm);
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
