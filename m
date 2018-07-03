Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 238EE6B0010
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 16:04:08 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id t10-v6so1486502wre.19
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 13:04:08 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id i124-v6si1443822wmg.205.2018.07.03.13.04.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 03 Jul 2018 13:04:06 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 4/6] bdi: Use irqsave variant of refcount_dec_and_lock()
Date: Tue,  3 Jul 2018 22:01:39 +0200
Message-Id: <20180703200141.28415-5-bigeasy@linutronix.de>
In-Reply-To: <20180703200141.28415-1-bigeasy@linutronix.de>
References: <20180703200141.28415-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: tglx@linutronix.de, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Anna-Maria Gleixner <anna-maria@linutronix.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

From: Anna-Maria Gleixner <anna-maria@linutronix.de>

The irqsave variant of refcount_dec_and_lock handles irqsave/restore when
taking/releasing the spin lock. With this variant the call of
local_irq_save/restore is no longer required.

Cc: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>
[bigeasy: s@atomic_dec_and_lock@refcount_dec_and_lock@g ]
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/backing-dev.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 55a233d75f39..f5981e9d6ae2 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -473,11 +473,8 @@ void wb_congested_put(struct bdi_writeback_congested *=
congested)
 {
 	unsigned long flags;
=20
-	local_irq_save(flags);
-	if (!refcount_dec_and_lock(&congested->refcnt, &cgwb_lock)) {
-		local_irq_restore(flags);
+	if (!refcount_dec_and_lock_irqsave(&congested->refcnt, &cgwb_lock, &flags=
))
 		return;
-	}
=20
 	/* bdi might already have been destroyed leaving @congested unlinked */
 	if (congested->__bdi) {
--=20
2.18.0
