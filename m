Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id D8A8B6B0035
	for <linux-mm@kvack.org>; Tue,  5 Aug 2014 09:07:00 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id z12so988433wgg.0
        for <linux-mm@kvack.org>; Tue, 05 Aug 2014 06:07:00 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id je7si4626124wic.5.2014.08.05.06.06.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Aug 2014 06:06:59 -0700 (PDT)
Date: Tue, 5 Aug 2014 15:06:46 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 0/7] nested sleeps, fixes and debug infra
Message-ID: <20140805130646.GZ19379@twins.programming.kicks-ass.net>
References: <20140804103025.478913141@infradead.org>
 <CALFYKtBo2p5uNtkJZOy_rN7JbdFs1RbB1OfcF7TR+qDaMU0Kvg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DnA9obu+/I5ICgZN"
Content-Disposition: inline
In-Reply-To: <CALFYKtBo2p5uNtkJZOy_rN7JbdFs1RbB1OfcF7TR+qDaMU0Kvg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ilya Dryomov <ilya.dryomov@inktank.com>
Cc: Ingo Molnar <mingo@kernel.org>, oleg@redhat.com, Linus Torvalds <torvalds@linux-foundation.org>, tglx@linutronix.de, Mike Galbraith <umgwanakikbuti@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org


--DnA9obu+/I5ICgZN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 05, 2014 at 12:33:16PM +0400, Ilya Dryomov wrote:
> On Mon, Aug 4, 2014 at 2:30 PM, Peter Zijlstra <peterz@infradead.org> wro=
te:
> > Hi,
> >
> > Ilya recently tripped over a nested sleep which made Ingo suggest we sh=
ould
> > have debug checks for that. So I did some, see patch 7. Of course that
> > triggered a whole bunch of fail the instant I tried to boot my machine.
> >
> > With this series I can boot my test box and build a kernel on it, I'm f=
airly
> > sure that's far too limited a test to have found all, but its a start.
>=20
> FWIW, I'm getting a lot of these during light rbd testing.  CC'ed
> netdev and linux-mm.

Both are cond_resched() calls, and that's not blocking as such, just a
preemption point, so lets exclude those.

=46rom the school of '_' are free:

---
 include/linux/kernel.h |    3 +++
 include/linux/sched.h  |    6 +++---
 kernel/sched/core.c    |   12 +++++++++---
 3 files changed, 15 insertions(+), 6 deletions(-)

--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -162,6 +162,7 @@ extern int _cond_resched(void);
 #endif
=20
 #ifdef CONFIG_DEBUG_ATOMIC_SLEEP
+  void ___might_sleep(const char *file, int line, int preempt_offset);
   void __might_sleep(const char *file, int line, int preempt_offset);
 /**
  * might_sleep - annotation for functions that can sleep
@@ -176,6 +177,8 @@ extern int _cond_resched(void);
 # define might_sleep() \
 	do { __might_sleep(__FILE__, __LINE__, 0); might_resched(); } while (0)
 #else
+  static inline void ___might_sleep(const char *file, int line,
+				   int preempt_offset) { }
   static inline void __might_sleep(const char *file, int line,
 				   int preempt_offset) { }
 # define might_sleep() do { might_resched(); } while (0)
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2754,7 +2754,7 @@ static inline int signal_pending_state(l
 extern int _cond_resched(void);
=20
 #define cond_resched() ({			\
-	__might_sleep(__FILE__, __LINE__, 0);	\
+	___might_sleep(__FILE__, __LINE__, 0);	\
 	_cond_resched();			\
 })
=20
@@ -2767,14 +2767,14 @@ extern int __cond_resched_lock(spinlock_
 #endif
=20
 #define cond_resched_lock(lock) ({				\
-	__might_sleep(__FILE__, __LINE__, PREEMPT_LOCK_OFFSET);	\
+	___might_sleep(__FILE__, __LINE__, PREEMPT_LOCK_OFFSET);\
 	__cond_resched_lock(lock);				\
 })
=20
 extern int __cond_resched_softirq(void);
=20
 #define cond_resched_softirq() ({					\
-	__might_sleep(__FILE__, __LINE__, SOFTIRQ_DISABLE_OFFSET);	\
+	___might_sleep(__FILE__, __LINE__, SOFTIRQ_DISABLE_OFFSET);	\
 	__cond_resched_softirq();					\
 })
=20
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -7078,8 +7078,6 @@ static inline int preempt_count_equals(i
=20
 void __might_sleep(const char *file, int line, int preempt_offset)
 {
-	static unsigned long prev_jiffy;	/* ratelimiting */
-
 	/*
 	 * Blocking primitives will set (and therefore destroy) current->state,
 	 * since we will exit with TASK_RUNNING make sure we enter with it,
@@ -7093,6 +7091,14 @@ void __might_sleep(const char *file, int
 			(void *)current->task_state_change))
 		__set_current_state(TASK_RUNNING);
=20
+	___might_sleep(file, line, preempt_offset);
+}
+EXPORT_SYMBOL(__might_sleep);
+
+void ___might_sleep(const char *file, int line, int preempt_offset)
+{
+	static unsigned long prev_jiffy;	/* ratelimiting */
+
 	rcu_sleep_check(); /* WARN_ON_ONCE() by default, no rate limit reqd. */
 	if ((preempt_count_equals(preempt_offset) && !irqs_disabled() &&
 	     !is_idle_task(current)) ||
@@ -7122,7 +7128,7 @@ void __might_sleep(const char *file, int
 #endif
 	dump_stack();
 }
-EXPORT_SYMBOL(__might_sleep);
+EXPORT_SYMBOL(___might_sleep);
 #endif
=20
 #ifdef CONFIG_MAGIC_SYSRQ

--DnA9obu+/I5ICgZN
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJT4NbmAAoJEHZH4aRLwOS6PbwP/jnw7oRWl+vglQdWDV6TkeV4
Rj2EE/EZl9ftFUgi1XbdD7qfNpCpN+jjo82P8r66Qz0hsZr9XEsNsvlv7Q+dUd0j
Y9U8WxUzcdu9rnnmN4Be9HrKgPA6TkDN8Pu5+6fSAsv0TvYBFFIlm2t/bemBHZMq
9dw1uE6dLGomf9l2k9vtPO8vWWFvT2+CIiRjAp7RRdx20hqJGJoQwuDaZ6Ol+VxU
f+IbFqltv0Q0Gnaw+7jW6j/C3wBTHIvSuzpf9OBOqlBZmZAxuaeTj+P8UkC6K1gp
6BhBaIQ+jUrOpjfE3om0uQ45ry8ELeKt7k1zm3iwBQR1Sscpz+CDsrDwRiVNC6QD
SqY6MZYl6QrOdTDZLw0CK06D3HzkeWxwARWjQqB7TgxlQql1EQPQy4XN1xPOcOXJ
x94CFlP90oWj+/5Iqi+b7quzUQ9fZ1f8HKZZs5vF1hHj+puaRaBlVLiADJHvNOra
k5zTODEFW4BdFoiQCXAHrDEGAR1z2KnyE1nuhzC1HQZ3xQWip68dz+IJGJUT+RLI
+Cwd40bdrPySRoz10uSaDWQzBIxFwnLFG8wKrzM38Ug9rmoxjoYh9qum8mDGnzz+
gqadS84VWTCLZuMIwdfv8yrWBsyZBR5SOm5G1k7ztOjwonErModZLb9F+kcdj47t
LdHabG3soJJ/pTbKm2UN
=vRLc
-----END PGP SIGNATURE-----

--DnA9obu+/I5ICgZN--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
