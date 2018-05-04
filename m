Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3D3F86B026C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 11:45:58 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l6-v6so14376371wrn.17
        for <linux-mm@kvack.org>; Fri, 04 May 2018 08:45:58 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id f8-v6si14785534wra.156.2018.05.04.08.45.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 04 May 2018 08:45:57 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 5/5] drivers/md/raid5: Do not disable irq on release_inactive_stripe_list() call
Date: Fri,  4 May 2018 17:45:33 +0200
Message-Id: <20180504154533.8833-6-bigeasy@linutronix.de>
In-Reply-To: <20180504154533.8833-1-bigeasy@linutronix.de>
References: <20180504154533.8833-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: tglx@linutronix.de, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, Anna-Maria Gleixner <anna-maria@linutronix.de>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

From: Anna-Maria Gleixner <anna-maria@linutronix.de>

There is no need to invoke release_inactive_stripe_list() with interrupts
disabled. All call sites, except raid5_release_stripe(), unlock
->device_lock and enable interrupts before invoking the function.

Make it consistent.

Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/md/raid5.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/md/raid5.c b/drivers/md/raid5.c
index 0a5e6f5d271d..5ee974fcd42e 100644
--- a/drivers/md/raid5.c
+++ b/drivers/md/raid5.c
@@ -414,9 +414,8 @@ void raid5_release_stripe(struct stripe_head *sh)
 		INIT_LIST_HEAD(&list);
 		hash =3D sh->hash_lock_index;
 		do_release_stripe(conf, sh, &list);
-		spin_unlock(&conf->device_lock);
+		spin_unlock_irqrestore(&conf->device_lock, flags);
 		release_inactive_stripe_list(conf, &list, hash);
-		local_irq_restore(flags);
 	}
 }
=20
--=20
2.17.0
