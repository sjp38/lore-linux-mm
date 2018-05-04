Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7E8F46B0266
	for <linux-mm@kvack.org>; Fri,  4 May 2018 11:45:53 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e74so790147wmg.5
        for <linux-mm@kvack.org>; Fri, 04 May 2018 08:45:53 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id m79si1578218wmh.5.2018.05.04.08.45.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 04 May 2018 08:45:52 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 1/5] spinlock: atomic_dec_and_lock: Add an irqsave variant
Date: Fri,  4 May 2018 17:45:29 +0200
Message-Id: <20180504154533.8833-2-bigeasy@linutronix.de>
In-Reply-To: <20180504154533.8833-1-bigeasy@linutronix.de>
References: <20180504154533.8833-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: tglx@linutronix.de, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, Anna-Maria Gleixner <anna-maria@linutronix.de>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

From: Anna-Maria Gleixner <anna-maria@linutronix.de>

There are in-tree users of atomic_dec_and_lock() which must acquire the
spin lock with interrupts disabled. To workaround the lack of an irqsave
variant of atomic_dec_and_lock() they use local_irq_save() at the call
site. This causes extra code and creates in some places unneeded long
interrupt disabled times. These places need also extra treatment for
PREEMPT_RT due to the disconnect of the irq disabling and the lock
function.

Implement the missing irqsave variant of the function.

Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 include/linux/spinlock.h |  5 +++++
 lib/dec_and_lock.c       | 16 ++++++++++++++++
 2 files changed, 21 insertions(+)

diff --git a/include/linux/spinlock.h b/include/linux/spinlock.h
index 4894d322d258..803536c992f5 100644
--- a/include/linux/spinlock.h
+++ b/include/linux/spinlock.h
@@ -409,6 +409,11 @@ extern int _atomic_dec_and_lock(atomic_t *atomic, spin=
lock_t *lock);
 #define atomic_dec_and_lock(atomic, lock) \
 		__cond_lock(lock, _atomic_dec_and_lock(atomic, lock))
=20
+extern int _atomic_dec_and_lock_irqsave(atomic_t *atomic, spinlock_t *lock,
+					unsigned long *flags);
+#define atomic_dec_and_lock_irqsave(atomic, lock, flags) \
+		__cond_lock(lock, _atomic_dec_and_lock_irqsave(atomic, lock, &(flags)))
+
 int alloc_bucket_spinlocks(spinlock_t **locks, unsigned int *lock_mask,
 			   size_t max_size, unsigned int cpu_mult,
 			   gfp_t gfp);
diff --git a/lib/dec_and_lock.c b/lib/dec_and_lock.c
index 347fa7ac2e8a..9555b68bb774 100644
--- a/lib/dec_and_lock.c
+++ b/lib/dec_and_lock.c
@@ -33,3 +33,19 @@ int _atomic_dec_and_lock(atomic_t *atomic, spinlock_t *l=
ock)
 }
=20
 EXPORT_SYMBOL(_atomic_dec_and_lock);
+
+int _atomic_dec_and_lock_irqsave(atomic_t *atomic, spinlock_t *lock,
+				 unsigned long *flags)
+{
+	/* Subtract 1 from counter unless that drops it to 0 (ie. it was 1) */
+	if (atomic_add_unless(atomic, -1, 1))
+		return 0;
+
+	/* Otherwise do it the slow way */
+	spin_lock_irqsave(lock, *flags);
+	if (atomic_dec_and_test(atomic))
+		return 1;
+	spin_unlock_irqrestore(lock, *flags);
+	return 0;
+}
+EXPORT_SYMBOL(_atomic_dec_and_lock_irqsave);
--=20
2.17.0
