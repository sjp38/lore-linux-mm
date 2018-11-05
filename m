Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7E2436B0003
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 14:30:57 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id b15-v6so5577036pfo.3
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 11:30:57 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id u34si988293pgk.24.2018.11.05.11.30.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 11:30:56 -0800 (PST)
From: Sean Christopherson <sean.j.christopherson@intel.com>
Subject: [PATCH] mm/mmu_notifier: rename mmu_notifier_synchronize() to <...>_barrier()
Date: Mon,  5 Nov 2018 11:29:55 -0800
Message-Id: <20181105192955.26305-1-sean.j.christopherson@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Oded Gabbay <oded.gabbay@amd.com>

...and update its comment to explicitly reference its association with
mmu_notifier_call_srcu().

Contrary to its name, mmu_notifier_synchronize() does not synchronize
the notifier's SRCU instance, but rather waits for RCU callbacks to
finished, i.e. it invokes rcu_barrier().  The RCU documentation is
quite clear on this matter, explicitly calling out that rcu_barrier()
does not imply synchronize_rcu().  The misnomer could lean an unwary
developer to incorrectly assume that mmu_notifier_synchronize() can
be used in conjunction with mmu_notifier_unregister_no_release() to
implement a variation of mmu_notifier_unregister() that synchronizes
SRCU without invoking ->release.  A Documentation-allergic and hasty
developer could be further confused by the fact that rcu_barrier() is
indeed a pass-through to synchronize_rcu()... in tiny SRCU.

Signed-off-by: Sean Christopherson <sean.j.christopherson@intel.com>
---
 mm/mmu_notifier.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 5119ff846769..46ebea6483bf 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -35,12 +35,12 @@ void mmu_notifier_call_srcu(struct rcu_head *rcu,
 }
 EXPORT_SYMBOL_GPL(mmu_notifier_call_srcu);
 
-void mmu_notifier_synchronize(void)
+void mmu_notifier_barrier(void)
 {
-	/* Wait for any running method to finish. */
+	/* Wait for any running RCU callbacks (see above) to finish. */
 	srcu_barrier(&srcu);
 }
-EXPORT_SYMBOL_GPL(mmu_notifier_synchronize);
+EXPORT_SYMBOL_GPL(mmu_notifier_barrier);
 
 /*
  * This function can't run concurrently against mmu_notifier_register
-- 
2.19.1
