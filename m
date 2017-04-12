Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8CD7A6B0397
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 12:56:19 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id m26so3617576wrm.5
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 09:56:19 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d7si8887800wme.99.2017.04.12.09.56.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Apr 2017 09:56:18 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3CGrlN1075003
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 12:56:17 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29spb3x6kr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 12:56:16 -0400
Received: from localhost
	by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 12 Apr 2017 12:56:16 -0400
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH tip/core/rcu 09/13] mm: Use static initialization for "srcu"
Date: Wed, 12 Apr 2017 09:55:45 -0700
In-Reply-To: <20170412165441.GA17149@linux.vnet.ibm.com>
References: <20170412165441.GA17149@linux.vnet.ibm.com>
Message-Id: <1492016149-18834-9-git-send-email-paulmck@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mingo@kernel.org, jiangshanlai@gmail.com, dipankar@in.ibm.com, akpm@linux-foundation.org, mathieu.desnoyers@efficios.com, josh@joshtriplett.org, tglx@linutronix.de, peterz@infradead.org, rostedt@goodmis.org, dhowells@redhat.com, edumazet@google.com, fweisbec@gmail.com, oleg@redhat.com, bobby.prani@gmail.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Vegard Nossum <vegard.nossum@oracle.com>

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
Cc: Andrew Morton <akpm@linux-foundation.org
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "Peter Zijlstra (Intel)" <peterz@infradead.org>
Cc: Vegard Nossum <vegard.nossum@oracle.com>
---
 mm/mmu_notifier.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index a7652acd2ab9..54ca54562928 100644
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
2.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
