Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8A6C56B0036
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 04:47:44 -0400 (EDT)
Received: by mail-qg0-f46.google.com with SMTP id q108so12200197qgd.5
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 01:47:44 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id lc5si20978117qcb.23.2014.06.03.01.47.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jun 2014 01:47:43 -0700 (PDT)
Date: Tue, 3 Jun 2014 10:47:35 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: mm,console: circular dependency between console_sem and zone lock
Message-ID: <20140603084735.GO11096@twins.programming.kicks-ass.net>
References: <536AE5DC.6070307@oracle.com>
 <20140512162811.GD3685@quack.suse.cz>
 <538B33D5.8070002@oracle.com>
 <20140602215529.0c13f91b@gandalf.local.home>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="AXVeTwB1tCcD1nEH"
Content-Disposition: inline
In-Reply-To: <20140602215529.0c13f91b@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Jan Kara <jack@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>, Ingo Molnar <mingo@kernel.org>


--AXVeTwB1tCcD1nEH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 02, 2014 at 09:55:29PM -0400, Steven Rostedt wrote:
> Hmm, it failed on a try lock, but on the spinlock within the trylock. I
> wonder if we should add this.
>=20
> Peter?
>=20
> -- Steve
>=20
> diff --git a/kernel/locking/semaphore.c b/kernel/locking/semaphore.c
> index 6815171..6579f84 100644
> --- a/kernel/locking/semaphore.c
> +++ b/kernel/locking/semaphore.c
> @@ -132,7 +132,9 @@ int down_trylock(struct semaphore *sem)
>  	unsigned long flags;
>  	int count;
> =20
> -	raw_spin_lock_irqsave(&sem->lock, flags);
> +	if (!raw_spin_trylock_irqsave(&sem->lock, flags))
> +		return 1;
> +
>  	count =3D sem->count - 1;
>  	if (likely(count >=3D 0))
>  		sem->count =3D count;

I prefer not to, there is no reason the down_trylock() will fail if that
spinlock is contended. We might have just hit the release in progress.

But let me stare at the original problem..

--AXVeTwB1tCcD1nEH
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJTjYumAAoJEHZH4aRLwOS6T/kP/RbtlCdesCyjgceJgf75Pgz+
DV75gfHHjh2fvJ9opE5sdSvkHHsWwpiqACZ0jWq/2X1ZO49WfJAl/G/7VoX7Xn4G
FjVdUHV7/U0KvNwdlo9BYU7yUHTlEuPtYbRmdA19YdoCOCRwq9FQrqRLBvS+vbGA
F06YnVIg4jwIFWVf8ZOWinNWvZCgQg95+xg6dgjfbzbW8BwdLXC+JrNvAcmU4ISJ
OL8iWBkq4XpREAh41GdHXkkd4GaPAibOKxd/1lj3oaXrbMfWZ2h8nKPzkFhF9zaR
SaENdcOBUjj4TcuI0/Oe2XzJRZzNjL7nXZULFaO5YmhqM0Agoli/M0kyra2T2IT2
Orxn5OLenAm8tgmqpWga356/KwbDY1HjDcg8UcztARt388YZ/87IIk3yTECrSVM4
SEjguvyzOL0v04ps554JhqLB8JFojMTPd16hmkFqlcKS2ympBT/mAy1JF5zodmcp
zyMW3fnShWWdea+3d76/OmWkCa12PqIkd826nZep/SS+1cRojr+mtxI0xckM0CvH
Mdru8mepK/Vgty0/fY0dRr//W6fcUlbsdgBGubjpF54EHC7HcMKrw1nriuK9rfMW
7inBKcX5EVZEbLAm1119pBq0KVbMZ2OOd/rzg3YbmEWIw+kmPvi6GYks0z2i+gLp
7GeVBZElJUHzybHW1Leb
=pf/j
-----END PGP SIGNATURE-----

--AXVeTwB1tCcD1nEH--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
