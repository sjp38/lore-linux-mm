Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1D8D46B0389
	for <linux-mm@kvack.org>; Sat, 25 Feb 2017 16:00:27 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id b2so103572885pgc.6
        for <linux-mm@kvack.org>; Sat, 25 Feb 2017 13:00:27 -0800 (PST)
Received: from mail-pg0-x234.google.com (mail-pg0-x234.google.com. [2607:f8b0:400e:c05::234])
        by mx.google.com with ESMTPS id n59si10976776plb.191.2017.02.25.13.00.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 Feb 2017 13:00:26 -0800 (PST)
Received: by mail-pg0-x234.google.com with SMTP id p5so2667943pga.1
        for <linux-mm@kvack.org>; Sat, 25 Feb 2017 13:00:26 -0800 (PST)
From: Tahsin Erdogan <tahsin@google.com>
Subject: [PATCH 2/3] percpu: acquire pcpu_lock when updating pcpu_nr_empty_pop_pages
Date: Sat, 25 Feb 2017 13:00:19 -0800
Message-Id: <20170225210019.23610-1-tahsin@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wilson <chris@chris-wilson.co.uk>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Roman Pen <r.peniaev@gmail.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tahsin Erdogan <tahsin@google.com>

Update to pcpu_nr_empty_pop_pages in pcpu_alloc() is currently done
without holding pcpu_lock. This can lead to bad updates to the variable.
Add missing lock calls.

Fixes: b539b87fed37 ("percpu: implmeent pcpu_nr_empty_pop_pages and chunk->nr_populated")
Signed-off-by: Tahsin Erdogan <tahsin@google.com>
---
 mm/percpu.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 0686f566d347..232356a2d914 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1011,8 +1011,11 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 		mutex_unlock(&pcpu_alloc_mutex);
 	}
 
-	if (chunk != pcpu_reserved_chunk)
+	if (chunk != pcpu_reserved_chunk) {
+		spin_lock_irqsave(&pcpu_lock, flags);
 		pcpu_nr_empty_pop_pages -= occ_pages;
+		spin_unlock_irqrestore(&pcpu_lock, flags);
+	}
 
 	if (pcpu_nr_empty_pop_pages < PCPU_EMPTY_POP_PAGES_LOW)
 		pcpu_schedule_balance_work();
-- 
2.11.0.483.g087da7b7c-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
