Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9C3C76B0256
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 09:31:22 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id bj10so13803268pad.2
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 06:31:22 -0800 (PST)
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id hq1si5111768pac.56.2016.03.08.06.31.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 06:31:21 -0800 (PST)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH] mm: slub: Ensure that slab_unlock() is atomic
Date: Tue, 8 Mar 2016 20:00:57 +0530
Message-ID: <1457447457-25878-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Vineet Gupta <Vineet.Gupta1@synopsys.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Noam Camus <noamc@ezchip.com>, stable@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org

We observed livelocks on ARC SMP setup when running hackbench with SLUB.
This hardware configuration lacks atomic instructions (LLOCK/SCOND) thus
kernel resorts to a central @smp_bitops_lock to protect any R-M-W ops
suh as test_and_set_bit()

The spinlock itself is implemented using Atomic [EX]change instruction
which is always available.

The race happened when both cores tried to slab_lock() the same page.

   c1		    c0
-----------	-----------
slab_lock
		slab_lock
slab_unlock
		Not observing the unlock

This in turn happened because slab_unlock() doesn't serialize properly
(doesn't use atomic clear) with a concurrent running
slab_lock()->test_and_set_bit()

Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Noam Camus <noamc@ezchip.com>
Cc: <stable@vger.kernel.org>
Cc: <linux-mm@kvack.org>
Cc: <linux-kernel@vger.kernel.org>
Cc: <linux-snps-arc@lists.infradead.org>
Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 mm/slub.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index d8fbd4a6ed59..b7d345a508dc 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -345,7 +345,7 @@ static __always_inline void slab_lock(struct page *page)
 static __always_inline void slab_unlock(struct page *page)
 {
 	VM_BUG_ON_PAGE(PageTail(page), page);
-	__bit_spin_unlock(PG_locked, &page->flags);
+	bit_spin_unlock(PG_locked, &page->flags);
 }
 
 static inline void set_page_slub_counters(struct page *page, unsigned long counters_new)
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
