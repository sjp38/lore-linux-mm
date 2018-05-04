Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 083736B026B
	for <linux-mm@kvack.org>; Fri,  4 May 2018 11:45:57 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f21-v6so1099690wmh.5
        for <linux-mm@kvack.org>; Fri, 04 May 2018 08:45:56 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 197si1500095wma.98.2018.05.04.08.45.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 04 May 2018 08:45:55 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 4/5] drivers/md/raid5: Use irqsave variant of atomic_dec_and_lock()
Date: Fri,  4 May 2018 17:45:32 +0200
Message-Id: <20180504154533.8833-5-bigeasy@linutronix.de>
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
local_irq_save is no longer required.

Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/md/raid5.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/md/raid5.c b/drivers/md/raid5.c
index be117d0a65a8..0a5e6f5d271d 100644
--- a/drivers/md/raid5.c
+++ b/drivers/md/raid5.c
@@ -409,16 +409,15 @@ void raid5_release_stripe(struct stripe_head *sh)
 		md_wakeup_thread(conf->mddev->thread);
 	return;
 slow_path:
-	local_irq_save(flags);
 	/* we are ok here if STRIPE_ON_RELEASE_LIST is set or not */
-	if (atomic_dec_and_lock(&sh->count, &conf->device_lock)) {
+	if (atomic_dec_and_lock_irqsave(&sh->count, &conf->device_lock, flags)) {
 		INIT_LIST_HEAD(&list);
 		hash =3D sh->hash_lock_index;
 		do_release_stripe(conf, sh, &list);
 		spin_unlock(&conf->device_lock);
 		release_inactive_stripe_list(conf, &list, hash);
+		local_irq_restore(flags);
 	}
-	local_irq_restore(flags);
 }
=20
 static inline void remove_hash(struct stripe_head *sh)
--=20
2.17.0
