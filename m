Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4BCC06B0055
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 07:49:53 -0400 (EDT)
Date: Tue, 7 Jul 2009 14:51:28 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Subject: kmemleak not tainted
Message-ID: <20090707115128.GA3238@localdomain.by>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="WIyZ46R2i8wDzkSu"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--WIyZ46R2i8wDzkSu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello,

Just noticed:
kernel: [ 1917.133154] INFO: RCU detected CPU 0 stall (t=485140/3000 jiffies)
kernel: [ 1917.133154] Pid: 511, comm: kmemleak Not tainted 2.6.31-rc2-nv-git1-00254-ga4e2f0a-dirty #2
kernel: [ 1917.133154] Call Trace:
kernel: [ 1917.133154]  [<c141784d>] ? printk+0x23/0x36
kernel: [ 1917.133154]  [<c10a81e0>] __rcu_pending+0x140/0x210
kernel: [ 1917.133154]  [<c10a82da>] rcu_pending+0x2a/0x70
kernel: [ 1917.133154]  [<c1051b8f>] update_process_times+0x3f/0x80
kernel: [ 1917.133154]  [<c107148f>] tick_sched_timer+0x6f/0xf0
kernel: [ 1917.133154]  [<c10640a6>] __run_hrtimer+0x56/0xe0
kernel: [ 1917.133154]  [<c1071420>] ? tick_sched_timer+0x0/0xf0
kernel: [ 1917.133154]  [<c1071420>] ? tick_sched_timer+0x0/0xf0
kernel: [ 1917.133154]  [<c1064aa5>] hrtimer_interrupt+0x145/0x270
kernel: [ 1917.133154]  [<c101c48c>] smp_apic_timer_interrupt+0x5c/0xb0
kernel: [ 1917.133154]  [<c12582b8>] ? trace_hardirqs_off_thunk+0xc/0x14
kernel: [ 1917.133154]  [<c1003e36>] apic_timer_interrupt+0x36/0x3c
kernel: [ 1917.133154]  [<c141ad61>] ? _read_unlock_irqrestore+0x41/0x70
kernel: [ 1917.133154]  [<c10f7415>] find_and_get_object+0x75/0xe0
kernel: [ 1917.133154]  [<c10f73a0>] ? find_and_get_object+0x0/0xe0
kernel: [ 1917.133154]  [<c10f7577>] scan_block+0x87/0x110
kernel: [ 1917.133154]  [<c10f7880>] kmemleak_scan+0x280/0x420
kernel: [ 1917.133154]  [<c10f7600>] ? kmemleak_scan+0x0/0x420
kernel: [ 1917.133154]  [<c10f80b0>] ? kmemleak_scan_thread+0x0/0xc0
kernel: [ 1917.133154]  [<c10f8100>] kmemleak_scan_thread+0x50/0xc0
kernel: [ 1917.133154]  [<c105ff54>] kthread+0x84/0x90
kernel: [ 1917.133154]  [<c105fed0>] ? kthread+0x0/0x90
kernel: [ 1917.133154]  [<c100401b>] kernel_thread_helper+0x7/0x1c


static struct kmemleak_object *find_and_get_object(unsigned long ptr, int alias)
{
	unsigned long flags;
	struct kmemleak_object *object = NULL;

	rcu_read_lock();
	read_lock_irqsave(&kmemleak_lock, flags);
	if (ptr >= min_addr && ptr < max_addr)
		object = lookup_object(ptr, alias);
>>	read_unlock_irqrestore(&kmemleak_lock, flags);

	/* check whether the object is still available */
	if (object && !get_object(object))
		object = NULL;
	rcu_read_unlock();

	return object;
}

I'm not sure where this is kmemleak's problem, since with 31 I see lots of 'not tainted' reports on my laptop.

	Sergey
--WIyZ46R2i8wDzkSu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iJwEAQECAAYFAkpTNsAACgkQfKHnntdSXjTZLgQA2R+5PQ+FCKIcAWzVal/1mruU
FjzAPFqS8362WTh2le2XuPDuC5t8Ws68nBSZEtmfX0GW+Es7YAaRW/ZinLrBdQy+
6H4UgndJljHYLtq0IN3cQajFgGQQoqkY/8Ni+wEp2SRdFjTMf3jy+FM9CSa9XUUg
cyiOtWNKkUCEefrBo/Q=
=jNY6
-----END PGP SIGNATURE-----

--WIyZ46R2i8wDzkSu--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
