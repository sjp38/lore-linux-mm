Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 936266B0003
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 06:26:07 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p9-v6so14947552wrm.22
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 03:26:07 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id z14-v6si11573836wrn.199.2018.06.04.03.26.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 04 Jun 2018 03:26:06 -0700 (PDT)
Date: Mon, 4 Jun 2018 12:25:59 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 1/5 v2] spinlock: atomic_dec_and_lock: Add an irqsave variant
Message-ID: <20180604102559.2ynbassthjzva62l@linutronix.de>
References: <20180504154533.8833-1-bigeasy@linutronix.de>
 <20180504154533.8833-2-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20180504154533.8833-2-bigeasy@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: tglx@linutronix.de, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, Anna-Maria Gleixner <anna-maria@linutronix.de>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, linux-alpha@vger.kernel.org

There are in-tree users of atomic_dec_and_lock() which must acquire the
spin lock with interrupts disabled. To workaround the lack of an irqsave
variant of atomic_dec_and_lock() they use local_irq_save() at the call
site. This causes extra code and creates in some places unneeded long
interrupt disabled times. These places need also extra treatment for
PREEMPT_RT due to the disconnect of the irq disabling and the lock
function.

Implement the missing irqsave variant of the function.
Add a stub for Alpha which should work without the assmebly optimisation
for the fastpath.

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org> [not the Alpha bits]
Cc: Richard Henderson <rth@twiddle.net>
Cc: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Cc: Matt Turner <mattst88@gmail.com>
Cc: linux-alpha@vger.kernel.org
Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>
[bigeasy: adding Alpha bits]
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
v1=E2=80=A6v2: Add Alpha bits (kbuild reported build failure on Alpha)

 arch/alpha/lib/dec_and_lock.c | 16 ++++++++++++++++
 include/linux/spinlock.h      |  5 +++++
 lib/dec_and_lock.c            | 16 ++++++++++++++++
 3 files changed, 37 insertions(+)

diff --git a/arch/alpha/lib/dec_and_lock.c b/arch/alpha/lib/dec_and_lock.c
index a117707f57fe..069fef7372dc 100644
--- a/arch/alpha/lib/dec_and_lock.c
+++ b/arch/alpha/lib/dec_and_lock.c
@@ -42,3 +42,19 @@ static int __used atomic_dec_and_lock_1(atomic_t *atomic=
, spinlock_t *lock)
 	return 0;
 }
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
2.17.1
