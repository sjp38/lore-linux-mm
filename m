Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id E39716B056F
	for <linux-mm@kvack.org>; Wed,  9 May 2018 15:38:46 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id q67-v6so11661217wrb.12
        for <linux-mm@kvack.org>; Wed, 09 May 2018 12:38:46 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id k4si8401814wmb.24.2018.05.09.12.38.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 09 May 2018 12:38:45 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 4/8] locking/refcount: implement refcount_dec_and_lock_irqsave()
Date: Wed,  9 May 2018 21:36:41 +0200
Message-Id: <20180509193645.830-5-bigeasy@linutronix.de>
In-Reply-To: <20180509193645.830-1-bigeasy@linutronix.de>
References: <20180509193645.830-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: tglx@linutronix.de, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, Anna-Maria Gleixner <anna-maria@linutronix.de>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

From: Anna-Maria Gleixner <anna-maria@linutronix.de>

There are in-tree users of refcount_dec_and_lock() which must acquire the
spin lock with interrupts disabled. To workaround the lack of an irqsave
variant of refcount_dec_and_lock() they use local_irq_save() at the call
site. This causes extra code and creates in some places unneeded long
interrupt disabled times. These places need also extra treatment for
PREEMPT_RT due to the disconnect of the irq disabling and the lock
function.

Implement the missing irqsave variant of the function.

Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>
[bigeasy: s@atomic_dec_and_lock@refcount_dec_and_lock@g]
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 include/linux/refcount.h |  4 +++-
 lib/refcount.c           | 28 ++++++++++++++++++++++++++++
 2 files changed, 31 insertions(+), 1 deletion(-)

diff --git a/include/linux/refcount.h b/include/linux/refcount.h
index 4193c41e383a..a685da2c4522 100644
--- a/include/linux/refcount.h
+++ b/include/linux/refcount.h
@@ -98,5 +98,7 @@ extern __must_check bool refcount_dec_if_one(refcount_t *=
r);
 extern __must_check bool refcount_dec_not_one(refcount_t *r);
 extern __must_check bool refcount_dec_and_mutex_lock(refcount_t *r, struct=
 mutex *lock);
 extern __must_check bool refcount_dec_and_lock(refcount_t *r, spinlock_t *=
lock);
-
+extern __must_check bool refcount_dec_and_lock_irqsave(refcount_t *r,
+						       spinlock_t *lock,
+						       unsigned long *flags);
 #endif /* _LINUX_REFCOUNT_H */
diff --git a/lib/refcount.c b/lib/refcount.c
index 0eb48353abe3..d3b81cefce91 100644
--- a/lib/refcount.c
+++ b/lib/refcount.c
@@ -350,3 +350,31 @@ bool refcount_dec_and_lock(refcount_t *r, spinlock_t *=
lock)
 }
 EXPORT_SYMBOL(refcount_dec_and_lock);
=20
+/**
+ * refcount_dec_and_lock_irqsave - return holding spinlock with disabled
+ *                                 interrupts if able to decrement refcoun=
t to 0
+ * @r: the refcount
+ * @lock: the spinlock to be locked
+ * @flags: saved IRQ-flags if the is acquired
+ *
+ * Same as refcount_dec_and_lock() above except that the spinlock is acqui=
red
+ * with disabled interupts.
+ *
+ * Return: true and hold spinlock if able to decrement refcount to 0, false
+ *         otherwise
+ */
+bool refcount_dec_and_lock_irqsave(refcount_t *r, spinlock_t *lock,
+				   unsigned long *flags)
+{
+	if (refcount_dec_not_one(r))
+		return false;
+
+	spin_lock_irqsave(lock, *flags);
+	if (!refcount_dec_and_test(r)) {
+		spin_unlock_irqrestore(lock, *flags);
+		return false;
+	}
+
+	return true;
+}
+EXPORT_SYMBOL(refcount_dec_and_lock_irqsave);
--=20
2.17.0
