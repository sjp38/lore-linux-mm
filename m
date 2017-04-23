Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id B46B66B0297
	for <linux-mm@kvack.org>; Sun, 23 Apr 2017 05:57:42 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id h186so33420231ith.10
        for <linux-mm@kvack.org>; Sun, 23 Apr 2017 02:57:42 -0700 (PDT)
Received: from terminus.zytor.com (terminus.zytor.com. [65.50.211.136])
        by mx.google.com with ESMTPS id a26si15412687pgd.72.2017.04.23.02.57.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Apr 2017 02:57:42 -0700 (PDT)
Date: Sun, 23 Apr 2017 02:53:15 -0700
From: "tip-bot for Paul E. McKenney" <tipbot@zytor.com>
Message-ID: <tip-dde8da6cffe73dab81aca3855e717e40db35178c@git.kernel.org>
Reply-To: linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com,
        mhocko@suse.com, vegard.nossum@oracle.com, akpm@linux-foundation.org,
        tglx@linutronix.de, hpa@zytor.com, mingo@kernel.org,
        linux-mm@kvack.org, peterz@infradead.org
Subject: [tip:core/rcu] mm: Use static initialization for "srcu"
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: linux-mm@kvack.org, peterz@infradead.org, hpa@zytor.com, mingo@kernel.org, vegard.nossum@oracle.com, akpm@linux-foundation.org, tglx@linutronix.de, mhocko@suse.com, paulmck@linux.vnet.ibm.com

Commit-ID:  dde8da6cffe73dab81aca3855e717e40db35178c
Gitweb:     http://git.kernel.org/tip/dde8da6cffe73dab81aca3855e717e40db35178c
Author:     Paul E. McKenney <paulmck@linux.vnet.ibm.com>
AuthorDate: Sat, 25 Mar 2017 10:42:07 -0700
Committer:  Paul E. McKenney <paulmck@linux.vnet.ibm.com>
CommitDate: Tue, 18 Apr 2017 11:38:22 -0700

mm: Use static initialization for "srcu"

The MM-notifier code currently dynamically initializes the srcu_struct
named "srcu" at subsys_initcall() time, and includes a BUG_ON() to check
this initialization in do_mmu_notifier_register().  Unfortunately, there
is no foolproof way to verify that an srcu_struct has been initialized,
given the possibility of an srcu_struct being allocated on the stack or
on the heap.  This means that creating an srcu_struct_is_initialized()
function is not a reasonable course of action.  Nor is peppering
do_mmu_notifier_register() with SRCU-specific #ifdefs an attractive
alternative.

This commit therefore uses DEFINE_STATIC_SRCU() to initialize
this srcu_struct at compile time, thus eliminating both the
subsys_initcall()-time initialization and the runtime BUG_ON().

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "Peter Zijlstra (Intel)" <peterz@infradead.org>
Cc: Vegard Nossum <vegard.nossum@oracle.com>
---
 mm/mmu_notifier.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index a7652ac..54ca545 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -21,7 +21,7 @@
 #include <linux/slab.h>
 
 /* global SRCU for all MMs */
-static struct srcu_struct srcu;
+DEFINE_STATIC_SRCU(srcu);
 
 /*
  * This function allows mmu_notifier::release callback to delay a call to
@@ -252,12 +252,6 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 
 	BUG_ON(atomic_read(&mm->mm_users) <= 0);
 
-	/*
-	 * Verify that mmu_notifier_init() already run and the global srcu is
-	 * initialized.
-	 */
-	BUG_ON(!srcu.per_cpu_ref);
-
 	ret = -ENOMEM;
 	mmu_notifier_mm = kmalloc(sizeof(struct mmu_notifier_mm), GFP_KERNEL);
 	if (unlikely(!mmu_notifier_mm))
@@ -406,9 +400,3 @@ void mmu_notifier_unregister_no_release(struct mmu_notifier *mn,
 	mmdrop(mm);
 }
 EXPORT_SYMBOL_GPL(mmu_notifier_unregister_no_release);
-
-static int __init mmu_notifier_init(void)
-{
-	return init_srcu_struct(&srcu);
-}
-subsys_initcall(mmu_notifier_init);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
