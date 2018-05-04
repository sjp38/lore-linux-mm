Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DF37B6B0269
	for <linux-mm@kvack.org>; Fri,  4 May 2018 11:45:54 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f188-v6so1105397wme.2
        for <linux-mm@kvack.org>; Fri, 04 May 2018 08:45:54 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id u55-v6si13169196wrf.181.2018.05.04.08.45.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 04 May 2018 08:45:53 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 2/5] mm/backing-dev: Use irqsave variant of atomic_dec_and_lock()
Date: Fri,  4 May 2018 17:45:30 +0200
Message-Id: <20180504154533.8833-3-bigeasy@linutronix.de>
In-Reply-To: <20180504154533.8833-1-bigeasy@linutronix.de>
References: <20180504154533.8833-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: tglx@linutronix.de, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, Anna-Maria Gleixner <anna-maria@linutronix.de>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

From: Anna-Maria Gleixner <anna-maria@linutronix.de>

The irqsave variant of atomic_dec_and_lock handles irqsave/restore when
taking/releasing the spin lock. With this variant the call of
local_irq_save/restore is no longer required.

Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/backing-dev.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 023190c69dce..c28418914591 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -484,11 +484,8 @@ void wb_congested_put(struct bdi_writeback_congested *=
congested)
 {
 	unsigned long flags;
=20
-	local_irq_save(flags);
-	if (!atomic_dec_and_lock(&congested->refcnt, &cgwb_lock)) {
-		local_irq_restore(flags);
+	if (!atomic_dec_and_lock_irqsave(&congested->refcnt, &cgwb_lock, flags))
 		return;
-	}
=20
 	/* bdi might already have been destroyed leaving @congested unlinked */
 	if (congested->__bdi) {
--=20
2.17.0
