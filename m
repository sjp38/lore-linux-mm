Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id AF3326B0169
	for <linux-mm@kvack.org>; Fri,  5 Aug 2011 08:36:32 -0400 (EDT)
Subject: Re: select_task_rq_fair: WARNING: at kernel/lockdep.c
 match_held_lock
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Fri, 05 Aug 2011 14:36:20 +0200
In-Reply-To: <20110804155347.GB3562@swordfish.minsk.epam.com>
References: <20110804141306.GA3536@swordfish.minsk.epam.com>
	 <1312470358.16729.25.camel@twins>
	 <20110804153752.GA3562@swordfish.minsk.epam.com>
	 <1312472867.16729.38.camel@twins>
	 <20110804155347.GB3562@swordfish.minsk.epam.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1312547780.28695.1.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Thu, 2011-08-04 at 18:53 +0300, Sergey Senozhatsky wrote:
>=20
> Nope, that's `if (DEBUG_LOCKS_WARN_ON(!class))'
>=20
The below is what I've come up with.

---
Subject: lockdep: Fix wrong assumption in match_held_lock
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Fri Aug 05 14:26:17 CEST 2011

match_held_lock() was assuming it was being called on a lock class
that had already seen usage.=20

This condition was true for bug-free code using lockdep_assert_held(),
since you're in fact holding the lock when calling it. However the
assumption fails the moment you assume the assertion can fail, which
is the whole point of having the assertion in the first place.

Anyway, now that there's more lockdep_is_held() users, notably
__rcu_dereference_check(), its much easier to trigger this since we
test for a number of locks and we only need to hold any one of them to
be good.

Reported-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 kernel/lockdep.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

Index: linux-2.6/kernel/lockdep.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/kernel/lockdep.c
+++ linux-2.6/kernel/lockdep.c
@@ -3111,7 +3111,13 @@ static int match_held_lock(struct held_l
 		if (!class)
 			class =3D look_up_lock_class(lock, 0);
=20
-		if (DEBUG_LOCKS_WARN_ON(!class))
+		/*
+		 * If look_up_lock_class() failed to find a class, we're trying
+		 * to test if we hold a lock that has never yet been acquired.
+		 * Clearly if the lock hasn't been acquired _ever_, we're not
+		 * holding it either, so report failure.
+		 */
+		if (!class)
 			return 0;
=20
 		if (DEBUG_LOCKS_WARN_ON(!hlock->nest_lock))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
