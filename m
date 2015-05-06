Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id E836B6B0070
	for <linux-mm@kvack.org>; Wed,  6 May 2015 13:50:55 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so19848495wgy.2
        for <linux-mm@kvack.org>; Wed, 06 May 2015 10:50:55 -0700 (PDT)
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com. [195.75.94.113])
        by mx.google.com with ESMTPS id x1si3398384wif.27.2015.05.06.10.50.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 06 May 2015 10:50:50 -0700 (PDT)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dahi@linux.vnet.ibm.com>;
	Wed, 6 May 2015 18:50:48 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id AFEB2219004D
	for <linux-mm@kvack.org>; Wed,  6 May 2015 18:50:26 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t46Hoifj4784624
	for <linux-mm@kvack.org>; Wed, 6 May 2015 17:50:44 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t46HohGE027458
	for <linux-mm@kvack.org>; Wed, 6 May 2015 11:50:44 -0600
From: David Hildenbrand <dahi@linux.vnet.ibm.com>
Subject: [PATCH RFC 02/15] mm, uaccess: trigger might_sleep() in might_fault() with disabled pagefaults
Date: Wed,  6 May 2015 19:50:26 +0200
Message-Id: <1430934639-2131-3-git-send-email-dahi@linux.vnet.ibm.com>
In-Reply-To: <1430934639-2131-1-git-send-email-dahi@linux.vnet.ibm.com>
References: <1430934639-2131-1-git-send-email-dahi@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: dahi@linux.vnet.ibm.com, mingo@redhat.com, peterz@infradead.org, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org

Commit 662bbcb2747c ("mm, sched: Allow uaccess in atomic with
pagefault_disable()") removed might_sleep() checks for all user access
code (that uses might_fault()).

The reason was to disable wrong "sleep in atomic" warnings in the
following scenario:
    pagefault_disable()
    rc = copy_to_user(...)
    pagefault_enable()

Which is valid, as pagefault_disable() increments the preempt counter
and therefore disables the pagefault handler. copy_to_user() will not
sleep and return an error code if a page is not available.

However, as all might_sleep() checks are removed,
CONFIG_DEBUG_ATOMIC_SLEEP would no longer detect the following scenario:
    spin_lock(&lock);
    rc = copy_to_user(...)
    spin_unlock(&lock)

If the kernel is compiled with preemption turned on, preempt_disable()
will make in_atomic() detect disabled preemption. The fault handler would
correctly never sleep on user access.
However, with preemption turned off, preempt_disable() is usually a NOP
(with !CONFIG_PREEMPT_COUNT), therefore in_atomic() will not be able to
detect disabled preemption nor disabled pagefaults. The fault handler
could sleep.
We really want to enable CONFIG_DEBUG_ATOMIC_SLEEP checks for user access
functions again, otherwise we can end up with horrible deadlocks.

Root of all evil is that pagefault_disable() acts almost as
preempt_disable(), depending on preemption being turned on/off.

As we now have pagefault_disabled(), we can use it to distinguish
whether user acces functions might sleep.

Convert might_fault() into a makro that calls __might_fault(), to
allow proper file + line messages in case of a might_sleep() warning.

Signed-off-by: David Hildenbrand <dahi@linux.vnet.ibm.com>
---
 include/linux/kernel.h |  3 ++-
 mm/memory.c            | 18 ++++++------------
 2 files changed, 8 insertions(+), 13 deletions(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 3a5b48e..060dd7b 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -244,7 +244,8 @@ static inline u32 reciprocal_scale(u32 val, u32 ep_ro)
 
 #if defined(CONFIG_MMU) && \
 	(defined(CONFIG_PROVE_LOCKING) || defined(CONFIG_DEBUG_ATOMIC_SLEEP))
-void might_fault(void);
+#define might_fault() __might_fault(__FILE__, __LINE__)
+void __might_fault(const char *file, int line);
 #else
 static inline void might_fault(void) { }
 #endif
diff --git a/mm/memory.c b/mm/memory.c
index d1fa0c1..2ddd80a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3737,7 +3737,7 @@ void print_vma_addr(char *prefix, unsigned long ip)
 }
 
 #if defined(CONFIG_PROVE_LOCKING) || defined(CONFIG_DEBUG_ATOMIC_SLEEP)
-void might_fault(void)
+void __might_fault(const char *file, int line)
 {
 	/*
 	 * Some code (nfs/sunrpc) uses socket ops on kernel memory while
@@ -3747,21 +3747,15 @@ void might_fault(void)
 	 */
 	if (segment_eq(get_fs(), KERNEL_DS))
 		return;
-
-	/*
-	 * it would be nicer only to annotate paths which are not under
-	 * pagefault_disable, however that requires a larger audit and
-	 * providing helpers like get_user_atomic.
-	 */
-	if (in_atomic())
+	if (pagefault_disabled())
 		return;
-
-	__might_sleep(__FILE__, __LINE__, 0);
-
+	__might_sleep(file, line, 0);
+#if defined(CONFIG_DEBUG_ATOMIC_SLEEP)
 	if (current->mm)
 		might_lock_read(&current->mm->mmap_sem);
+#endif
 }
-EXPORT_SYMBOL(might_fault);
+EXPORT_SYMBOL(__might_fault);
 #endif
 
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
