Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 14B6C6B0036
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 05:00:30 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id z12so6423799wgg.12
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 02:00:30 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id j4si27025440wix.45.2014.06.03.02.00.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jun 2014 02:00:23 -0700 (PDT)
Date: Tue, 3 Jun 2014 11:00:10 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: mm,console: circular dependency between console_sem and zone lock
Message-ID: <20140603090010.GP11096@twins.programming.kicks-ass.net>
References: <536AE5DC.6070307@oracle.com>
 <20140512162811.GD3685@quack.suse.cz>
 <538B33D5.8070002@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="YXsbNr0GD8juqqEr"
Content-Disposition: inline
In-Reply-To: <538B33D5.8070002@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Jan Kara <jack@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>


--YXsbNr0GD8juqqEr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Jun 01, 2014 at 10:08:21AM -0400, Sasha Levin wrote:
> On 05/12/2014 12:28 PM, Jan Kara wrote:
> > On Wed 07-05-14 22:03:08, Sasha Levin wrote:
> >> > Hi all,
> >> >=20
> >> > While fuzzing with trinity inside a KVM tools guest running the late=
st -next
> >> > kernel I've stumbled on the following spew:
> >   Thanks for report. So the problem seems to be maginally valid but I'm=
 not
> > 100% sure whom to blame :). So printk() code calls up() which calls
> > try_to_wake_up() under console_sem.lock spinlock. That function can take
> > rq->lock which is all expected.
> >=20
> > The next part of the chain is that during CPU initialization we call
> > __sched_fork() with rq->lock which calls into hrtimer_init() which can
> > allocate memory which creates a dependency rq->lock =3D> zone.lock.rloc=
k.
> >=20
> > And memory management code calls printk() which zone.lock.rlock held wh=
ich
> > closes the loop. Now I suspect the second link in the chain can happen =
only
> > while CPU is booting and might even happen only if some debug options a=
re
> > enabled. But I don't really know scheduler code well enough. Steven?
>=20
> I've cc'ed Peter and Ingo who may be able to answer that, as it still hap=
pens
> on -next.

Ah, cute.

So the second paragraph seems to miss the detail that this is the
__sched_fork() call from init_idle(), all other callers don't actually
hold the rq->lock.

Now init_idle() is called from:

	sched_init()
	fork_idle()
	idle_thread_get()

Now fork_idle() is called from:

	smp_init() -> idle_threads_init() -> idle_init()

and idle_thread_get is called from:

	_cpu_up()


So while it looks we're calling __sched_fork() twice for every !boot
idle thread (urgh) we do appear to call it before anything is running on
that cpu, so I don't see any particular problem with removing the call
=66rom under that lock.

Something like so should do I suppose.

---
 kernel/sched/core.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 240aa83e73f5..99609c33482b 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -4505,9 +4505,10 @@ void init_idle(struct task_struct *idle, int cpu)
 	struct rq *rq =3D cpu_rq(cpu);
 	unsigned long flags;
=20
+	__sched_fork(0, idle);
+
 	raw_spin_lock_irqsave(&rq->lock, flags);
=20
-	__sched_fork(0, idle);
 	idle->state =3D TASK_RUNNING;
 	idle->se.exec_start =3D sched_clock();
=20

--YXsbNr0GD8juqqEr
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJTjY6aAAoJEHZH4aRLwOS6aHMQAJ1fgUkLkqtjPyLISXWxEcfW
y/7hByALJfq174BHqmO1nBxMNLtXr6LiSboMnLVpIl1vZFbmzw60hm85Qa/iYo8G
r5GiE3V2rU/Esk1y4MbOEeWbCbfB9g86h1vCK3AWA/XOlaqnGvd3qfhT5zr/r8hM
SIQJnM8aquv2KIj9WirmjxZ5MEyd52HpKxt3WlW0SqSaqBKtcjJRT/SjozPCKepf
qVXq+ekPgHwO8qlYVm2D2AB81ENWNj8cJqFfSefyEpSYnZfit6nTeafNU0UatJ4N
GLQ7cx3dXROG0jthWjmtFCu2wZe6WC66kZtBJWhTt+5hwaTASOrzKH9WaMx6SLlX
BixmOxccivgwIOYtYaG1oo9A+0C/DR0ZsbYd9JAx+39oBBR38BFJcqxmv+T6In46
aDIwnSf1aooH1MMwQyZyFQrP9au8R2DUoGiSXy4srp1KWXNo4FfOjNOuDt6ZcMIY
v+sKE8z7uW7lDo/KpKXrOjmfIBySjjGgRQw9q5mV8nr9rPZKecD4zMJnjhqDycZh
8vzEUo57N6F/qr2Zaq9RNQmO2GCDVitB1t1EIzVHM5Cn+6zFna95AQ1OEIalyrgF
d9HDCVa+HzPkCSyHjdGCCIjfbi6Qa39fZ1kiWw2ljdUsxetN0hUjMRsKwIvaBVtK
CUh3xMj3KyxTOZKOcd0A
=I76p
-----END PGP SIGNATURE-----

--YXsbNr0GD8juqqEr--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
