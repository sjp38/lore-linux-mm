Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4BF2A6B004F
	for <linux-mm@kvack.org>; Sun, 14 Jun 2009 13:42:13 -0400 (EDT)
Date: Sun, 14 Jun 2009 13:43:30 -0400
From: Bart Trojanowski <bart@jukie.net>
Subject: Re: [v2.6.30 nfs+fscache] swapper: possible circular locking
	dependency detected
Message-ID: <20090614174329.GA4721@jukie.net>
References: <20090613182721.GA24072@jukie.net> <20090614141459.GA5543@jukie.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20090614141459.GA5543@jukie.net>
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org
Cc: linux-cachefs@redhat.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It's me again.

I am tyring to decipher the lockdep report...

* Bart Trojanowski <bart@jukie.net> [090614 10:15]:
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
> [ INFO: possible circular locking dependency detected ]
> 2.6.30-kvm3-dirty #4
> -------------------------------------------------------
> swapper/0 is trying to acquire lock:
>  (&cwq->lock){..-...}, at: [<ffffffff80256c37>] __queue_work+0x1d/0x43
>=20
> but task is already holding lock:
>  (&q->lock){-.-.-.}, at: [<ffffffff80235b6a>] __wake_up+0x27/0x55
>=20
> which lock already depends on the new lock.
>=20
>=20
> the existing dependency chain (in reverse order) is:
>=20
> -> #1 (&q->lock){-.-.-.}:
>        [<ffffffff8026b7f6>] __lock_acquire+0x1350/0x16b4
>        [<ffffffff8026bc21>] lock_acquire+0xc7/0xf3
>        [<ffffffff805a22e1>] _spin_lock_irqsave+0x4f/0x86
>        [<ffffffff80235b6a>] __wake_up+0x27/0x55
>        [<ffffffff8025620b>] insert_work+0x9a/0xa6
>        [<ffffffff80256c49>] __queue_work+0x2f/0x43
>        [<ffffffff80256cec>] queue_work_on+0x4a/0x53
>        [<ffffffff80256e49>] queue_work+0x1f/0x21
<snip>

So, here I can see that we take the cwq->lock first, when __queue_work
does:

        spin_lock_irqsave(&cwq->lock, flags);
        insert_work(cwq, work, &cwq->worklist);
        spin_unlock_irqrestore(&cwq->lock, flags);

and later take the q->lock when insert_work calls to __wake_up:

        spin_lock_irqsave(&q->lock, flags);
        __wake_up_common(q, mode, nr_exclusive, 0, key);
        spin_unlock_irqrestore(&q->lock, flags);

But previously the order was reversed:

> stack backtrace:
> Pid: 0, comm: swapper Not tainted 2.6.30-kvm3-dirty #4
> Call Trace:
>  <IRQ>  [<ffffffff80269ffe>] print_circular_bug_tail+0xc1/0xcc
>  [<ffffffff8026b52b>] __lock_acquire+0x1085/0x16b4
>  [<ffffffff802685b4>] ? save_trace+0x3f/0xa6
>  [<ffffffff8026ba78>] ? __lock_acquire+0x15d2/0x16b4
>  [<ffffffff8026bc21>] lock_acquire+0xc7/0xf3
>  [<ffffffff80256c37>] ? __queue_work+0x1d/0x43
>  [<ffffffff805a22e1>] _spin_lock_irqsave+0x4f/0x86
>  [<ffffffff80256c37>] ? __queue_work+0x1d/0x43
>  [<ffffffff80256c37>] __queue_work+0x1d/0x43
>  [<ffffffff80256cec>] queue_work_on+0x4a/0x53
>  [<ffffffff80256e49>] queue_work+0x1f/0x21
>  [<ffffffff80256e66>] schedule_work+0x1b/0x1d
>  [<ffffffffa00e9268>] fscache_enqueue_operation+0xec/0x11e [fscache]
>  [<ffffffffa00fd662>] cachefiles_read_waiter+0xee/0x102 [cachefiles]
>  [<ffffffff80233a55>] __wake_up_common+0x4b/0x7a
>  [<ffffffff80235b80>] __wake_up+0x3d/0x55
>  [<ffffffff8025a2f1>] __wake_up_bit+0x31/0x33
>  [<ffffffff802a52af>] unlock_page+0x27/0x2b

Here the __wake_up happens first, which takes the q->lock, and later the
__queue_work would take the cwq->lock.

I am guessing that it's not safe for fscache to call out to queue_work
=66rom this cachefiles_read_waiter() context (more specifically
fscache_enqueue_operation calls schedule_work).  I don't have much
experience with lockdep...  does that make any sense?

-Bart

--=20
				WebSig: http://www.jukie.net/~bart/sig/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
