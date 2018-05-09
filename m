Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F0786B0572
	for <linux-mm@kvack.org>; Wed,  9 May 2018 15:38:47 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k16-v6so24460964wrh.6
        for <linux-mm@kvack.org>; Wed, 09 May 2018 12:38:47 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id y186-v6si8558240wmg.11.2018.05.09.12.38.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 09 May 2018 12:38:45 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 5/8] bdi: Use irqsave variant of refcount_dec_and_lock()
Date: Wed,  9 May 2018 21:36:42 +0200
Message-Id: <20180509193645.830-6-bigeasy@linutronix.de>
In-Reply-To: <20180509193645.830-1-bigeasy@linutronix.de>
References: <20180509193645.830-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: tglx@linutronix.de, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, Anna-Maria Gleixner <anna-maria@linutronix.de>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

From: Anna-Maria Gleixner <anna-maria@linutronix.de>

The irqsave variant of refcount_dec_and_lock handles irqsave/restore when
taking/releasing the spin lock. With this variant the call of
local_irq_save/restore is no longer required.

Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>
[bigeasy: s@atomic_dec_and_lock@refcount_dec_and_lock@g ]
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/backing-dev.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 7984a872073e..520aa092f7b2 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -485,11 +485,8 @@ void wb_congested_put(struct bdi_writeback_congested *=
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
2.17.0
