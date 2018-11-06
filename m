Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id CB0766B0005
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 08:47:32 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id j9-v6so12464580pfn.20
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 05:47:32 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id g8-v6si49046849pli.338.2018.11.06.05.47.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 05:47:31 -0800 (PST)
From: Sean Christopherson <sean.j.christopherson@intel.com>
Subject: [PATCH v2] mm/mmu_notifier: remove mmu_notifier_synchronize()
Date: Tue,  6 Nov 2018 05:47:05 -0800
Message-Id: <20181106134705.14197-1-sean.j.christopherson@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

Contrary to its name, mmu_notifier_synchronize() does not synchronize
the notifier's SRCU instance, but rather waits for RCU callbacks to
finished, i.e. it invokes rcu_barrier().  The RCU documentation is
quite clear on this matter, explicitly calling out that rcu_barrier()
does not imply synchronize_rcu().

As there are no callers of mmu_notifier_synchronize() and it's unclear
whether any user of mmu_notifier_call_srcu() will ever want to barrier
on their callbacks, simply remove the function.

Signed-off-by: Sean Christopherson <sean.j.christopherson@intel.com>
---
 include/linux/mmu_notifier.h | 1 -
 mm/mmu_notifier.c            | 7 -------
 2 files changed, 8 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 9893a6432adf..913c3c13e36e 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -420,7 +420,6 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 
 extern void mmu_notifier_call_srcu(struct rcu_head *rcu,
 				   void (*func)(struct rcu_head *rcu));
-extern void mmu_notifier_synchronize(void);
 
 #else /* CONFIG_MMU_NOTIFIER */
 
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 5119ff846769..755466cd289a 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -35,13 +35,6 @@ void mmu_notifier_call_srcu(struct rcu_head *rcu,
 }
 EXPORT_SYMBOL_GPL(mmu_notifier_call_srcu);
 
-void mmu_notifier_synchronize(void)
-{
-	/* Wait for any running method to finish. */
-	srcu_barrier(&srcu);
-}
-EXPORT_SYMBOL_GPL(mmu_notifier_synchronize);
-
 /*
  * This function can't run concurrently against mmu_notifier_register
  * because mm->mm_users > 0 during mmu_notifier_register and exit_mmap
-- 
2.19.1
