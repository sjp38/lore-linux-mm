Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 04EA26B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 09:14:51 -0400 (EDT)
Date: Tue, 7 Jul 2009 16:17:25 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Subject: Re: kmemleak not tainted
Message-ID: <20090707131725.GB3238@localdomain.by>
References: <20090707115128.GA3238@localdomain.by>
 <1246970859.9451.34.camel@pc1117.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="rJwd6BRFiFCcLxzm"
Content-Disposition: inline
In-Reply-To: <1246970859.9451.34.camel@pc1117.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--rJwd6BRFiFCcLxzm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

> On Tue, 2009-07-07 at 14:51 +0300, Sergey Senozhatsky wrote:
> > kernel: [ 1917.133154] INFO: RCU detected CPU 0 stall (t=3D485140/3000 =
jiffies)
>=20
> That's the relevant message. With CONFIG_RCU_CPU_STALL_DETECTOR you may
> get these messages.
>=20
> > static struct kmemleak_object *find_and_get_object(unsigned long ptr, i=
nt alias)
> > {
> > 	unsigned long flags;
> > 	struct kmemleak_object *object =3D NULL;
> >=20
> > 	rcu_read_lock();
> > 	read_lock_irqsave(&kmemleak_lock, flags);
> > 	if (ptr >=3D min_addr && ptr < max_addr)
> > 		object =3D lookup_object(ptr, alias);
> > >>	read_unlock_irqrestore(&kmemleak_lock, flags);
> >=20
> > 	/* check whether the object is still available */
> > 	if (object && !get_object(object))
> > 		object =3D NULL;
> > 	rcu_read_unlock();
> >=20
> > 	return object;
> > }
>=20
> It just happened here because that's where the interrupts were enabled
> and the timer routine invoked. The rcu-locked region above should be
> pretty short (just a tree look-up).
>=20
> What I think happens is that the kmemleak thread runs for several
> seconds for scanning the memory and there may not be any context
> switches. I have a patch to add more cond_resched() calls throughout the
> kmemleak_scan() function which I hope will get merged.=20

Cc me please.
Thanks.


> I don't get any  of these messages with CONFIG_PREEMPT enabled.
>=20

It started with rc2-git1 (may be). Almost every scan ends with RCU pending.

[ 1917.133154] INFO: RCU detected CPU 0 stall (t=3D485140/3000 jiffies)
[ 1917.133154] Pid: 511, comm: kmemleak Not tainted 2.6.31-rc2-nv-git1-0025=
4-ga4e2f0a-dirty #2
[ 1917.133154] Call Trace:
[ 1917.133154]  [<c141784d>] ? printk+0x23/0x36
[ 1917.133154]  [<c10a81e0>] __rcu_pending+0x140/0x210
[ 1917.133154]  [<c10a82da>] rcu_pending+0x2a/0x70
[ 1917.133154]  [<c1051b8f>] update_process_times+0x3f/0x80
[ 1917.133154]  [<c107148f>] tick_sched_timer+0x6f/0xf0
[ 1917.133154]  [<c10640a6>] __run_hrtimer+0x56/0xe0
[ 1917.133154]  [<c1071420>] ? tick_sched_timer+0x0/0xf0
[ 1917.133154]  [<c1071420>] ? tick_sched_timer+0x0/0xf0
[ 1917.133154]  [<c1064aa5>] hrtimer_interrupt+0x145/0x270
[ 1917.133154]  [<c101c48c>] smp_apic_timer_interrupt+0x5c/0xb0
[ 1917.133154]  [<c12582b8>] ? trace_hardirqs_off_thunk+0xc/0x14
[ 1917.133154]  [<c1003e36>] apic_timer_interrupt+0x36/0x3c
[ 1917.133154]  [<c141ad61>] ? _read_unlock_irqrestore+0x41/0x70
[ 1917.133154]  [<c10f7415>] find_and_get_object+0x75/0xe0
[ 1917.133154]  [<c10f73a0>] ? find_and_get_object+0x0/0xe0
[ 1917.133154]  [<c10f7577>] scan_block+0x87/0x110
[ 1917.133154]  [<c10f7880>] kmemleak_scan+0x280/0x420
[ 1917.133154]  [<c10f7600>] ? kmemleak_scan+0x0/0x420
[ 1917.133154]  [<c10f80b0>] ? kmemleak_scan_thread+0x0/0xc0
[ 1917.133154]  [<c10f8100>] kmemleak_scan_thread+0x50/0xc0
[ 1917.133154]  [<c105ff54>] kthread+0x84/0x90
[ 1917.133154]  [<c105fed0>] ? kthread+0x0/0x90
[ 1917.133154]  [<c100401b>] kernel_thread_helper+0x7/0x1c
[ 1979.742347] kmemleak: 1 new suspected memory leaks (see /sys/kernel/debu=
g/kmemleak)
[ 2589.860586] INFO: RCU detected CPU 1 stall (t=3D686958/3000 jiffies)
[ 2589.860586] Pid: 511, comm: kmemleak Not tainted 2.6.31-rc2-nv-git1-0025=
4-ga4e2f0a-dirty #2
[ 2589.860586] Call Trace:
[ 2589.860586]  [<c141784d>] ? printk+0x23/0x36
[ 2589.860586]  [<c10a81e0>] __rcu_pending+0x140/0x210
[ 2589.860586]  [<c10a82da>] rcu_pending+0x2a/0x70
[ 2589.860586]  [<c1051b8f>] update_process_times+0x3f/0x80
[ 2589.860586]  [<c107148f>] tick_sched_timer+0x6f/0xf0
[ 2589.860586]  [<c10640a6>] __run_hrtimer+0x56/0xe0
[ 2589.860586]  [<c1071420>] ? tick_sched_timer+0x0/0xf0
[ 2589.860586]  [<c1071420>] ? tick_sched_timer+0x0/0xf0
[ 2589.860586]  [<c1064aa5>] hrtimer_interrupt+0x145/0x270
[ 2589.860586]  [<c104b6c8>] ? _local_bh_enable+0x68/0xd0
[ 2589.860586]  [<c101c48c>] smp_apic_timer_interrupt+0x5c/0xb0
[ 2589.860586]  [<c12582b8>] ? trace_hardirqs_off_thunk+0xc/0x14
[ 2589.860586]  [<c1003e36>] apic_timer_interrupt+0x36/0x3c
[ 2589.860586]  [<c10795d5>] ? lock_acquire+0xb5/0x120
[ 2589.860586]  [<c10f73a0>] ? find_and_get_object+0x0/0xe0
[ 2589.860586]  [<c10f73a0>] ? find_and_get_object+0x0/0xe0
[ 2589.860586]  [<c10f73eb>] find_and_get_object+0x4b/0xe0
[ 2589.860586]  [<c10f73a0>] ? find_and_get_object+0x0/0xe0
[ 2589.860586]  [<c10f7577>] scan_block+0x87/0x110
[ 2589.860586]  [<c10f7880>] kmemleak_scan+0x280/0x420
[ 2589.860586]  [<c10f7600>] ? kmemleak_scan+0x0/0x420
[ 2589.860586]  [<c10f80b0>] ? kmemleak_scan_thread+0x0/0xc0
[ 2589.860586]  [<c10f8100>] kmemleak_scan_thread+0x50/0xc0
[ 2589.860586]  [<c105ff54>] kthread+0x84/0x90
[ 2589.860586]  [<c105fed0>] ? kthread+0x0/0x90
[ 2589.860586]  [<c100401b>] kernel_thread_helper+0x7/0x1c
[ 3089.007168] r8169: eth1: link down
[ 3245.897188] INFO: RCU detected CPU 1 stall (t=3D883769/3000 jiffies)
[ 3245.897188] Pid: 511, comm: kmemleak Not tainted 2.6.31-rc2-nv-git1-0025=
4-ga4e2f0a-dirty #2
[ 3245.897188] Call Trace:
[ 3245.897188]  [<c141784d>] ? printk+0x23/0x36
[ 3245.897188]  [<c10a81e0>] __rcu_pending+0x140/0x210
[ 3245.897188]  [<c10a82da>] rcu_pending+0x2a/0x70
[ 3245.897188]  [<c1051b8f>] update_process_times+0x3f/0x80
[ 3245.897188]  [<c107148f>] tick_sched_timer+0x6f/0xf0
[ 3245.897188]  [<c10640a6>] __run_hrtimer+0x56/0xe0
[ 3245.897188]  [<c1071420>] ? tick_sched_timer+0x0/0xf0
[ 3245.897188]  [<c1071420>] ? tick_sched_timer+0x0/0xf0
[ 3245.897188]  [<c1064aa5>] hrtimer_interrupt+0x145/0x270
[ 3245.897188]  [<c101c48c>] smp_apic_timer_interrupt+0x5c/0xb0
[ 3245.897188]  [<c12582b8>] ? trace_hardirqs_off_thunk+0xc/0x14
[ 3245.897188]  [<c1003e36>] apic_timer_interrupt+0x36/0x3c
[ 3245.897188]  [<c141ad61>] ? _read_unlock_irqrestore+0x41/0x70
[ 3245.897188]  [<c10f745f>] find_and_get_object+0xbf/0xe0
[ 3245.897188]  [<c10f73a0>] ? find_and_get_object+0x0/0xe0
[ 3245.897188]  [<c10f7577>] scan_block+0x87/0x110
[ 3245.897188]  [<c10f7880>] kmemleak_scan+0x280/0x420
[ 3245.897188]  [<c10f7600>] ? kmemleak_scan+0x0/0x420
[ 3245.897188]  [<c10f80b0>] ? kmemleak_scan_thread+0x0/0xc0
[ 3245.897188]  [<c10f8100>] kmemleak_scan_thread+0x50/0xc0
[ 3245.897188]  [<c105ff54>] kthread+0x84/0x90
[ 3245.897188]  [<c105fed0>] ? kthread+0x0/0x90
[ 3245.897188]  [<c100401b>] kernel_thread_helper+0x7/0x1c
[ 3290.435108] kmemleak: 5 new suspected memory leaks (see /sys/kernel/debu=
g/kmemleak)


Hm.. Something is broken...
cat /.../kmemleak
[ 7933.537868] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
[ 7933.537873] [ BUG: lock held when returning to user space! ]
[ 7933.537876] ------------------------------------------------
[ 7933.537880] cat/2897 is leaving the kernel with locks still held!
[ 7933.537884] 1 lock held by cat/2897:
[ 7933.537887]  #0:  (scan_mutex){+.+.+.}, at: [<c10f717c>] kmemleak_open+0=
x4c/0x80


> --=20
> Catalin
>=20
=09
	Sergey
--rJwd6BRFiFCcLxzm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iJwEAQECAAYFAkpTSuUACgkQfKHnntdSXjR0OQP/bVH8POBqSYXspc9XtNQ8b++s
hS5r1HpgiVYZiGRTBj7EbkJzVsgCYa/nWIIvUMHtOv+BbzDVACsC8U6BwO0iDvr8
PkbBx2n9px16+0Mu+9lGhC4ZBMFNtGl3lP4SKdiXYsQDbf1/327P8GXbAS0+SLhs
hEIS+aKjz8zznwoflEY=
=YTQW
-----END PGP SIGNATURE-----

--rJwd6BRFiFCcLxzm--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
