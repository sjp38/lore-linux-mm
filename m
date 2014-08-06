Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 971D16B0083
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 04:31:50 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id l18so2163058wgh.26
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 01:31:49 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id q14si9703248wie.61.2014.08.06.01.31.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Aug 2014 01:31:49 -0700 (PDT)
Date: Wed, 6 Aug 2014 10:31:34 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 0/7] nested sleeps, fixes and debug infra
Message-ID: <20140806083134.GQ9918@twins.programming.kicks-ass.net>
References: <20140804103025.478913141@infradead.org>
 <CALFYKtBo2p5uNtkJZOy_rN7JbdFs1RbB1OfcF7TR+qDaMU0Kvg@mail.gmail.com>
 <20140805130646.GZ19379@twins.programming.kicks-ass.net>
 <CALFYKtAVQ9Rgu_QWCqUkNHk4-wbiVK0FeiwLDttaxZC5bnnG5w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="drkdbItNQN0oJM6x"
Content-Disposition: inline
In-Reply-To: <CALFYKtAVQ9Rgu_QWCqUkNHk4-wbiVK0FeiwLDttaxZC5bnnG5w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ilya Dryomov <ilya.dryomov@inktank.com>
Cc: Ingo Molnar <mingo@kernel.org>, oleg@redhat.com, Linus Torvalds <torvalds@linux-foundation.org>, tglx@linutronix.de, Mike Galbraith <umgwanakikbuti@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org


--drkdbItNQN0oJM6x
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 06, 2014 at 11:51:29AM +0400, Ilya Dryomov wrote:

> OK, this one is a bit different.
>=20
> WARNING: CPU: 1 PID: 1744 at kernel/sched/core.c:7104 __might_sleep+0x58/=
0x90()
> do not call blocking ops when !TASK_RUNNING; state=3D1 set at [<ffffffff8=
1070e10>] prepare_to_wait+0x50 /0xa0

>  [<ffffffff8105bc38>] __might_sleep+0x58/0x90
>  [<ffffffff8148c671>] lock_sock_nested+0x31/0xb0
>  [<ffffffff81498aaa>] sk_stream_wait_memory+0x18a/0x2d0

Urgh, tedious. Its not an actual bug as is. Due to the condition check
in sk_wait_event() we can call lock_sock() with ->state !=3D TASK_RUNNING.

I'm not entirely sure what the cleanest way is to make this go away.
Possibly something like so:

---
 include/net/sock.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index 156350745700..37902176c5ab 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -886,6 +886,7 @@ static inline void sock_rps_reset_rxhash(struct sock *s=
k)
 		if (!__rc) {						\
 			*(__timeo) =3D schedule_timeout(*(__timeo));	\
 		}							\
+		__set_current_state(TASK_RUNNING);			\
 		lock_sock(__sk);					\
 		__rc =3D __condition;					\
 		__rc;							\

--drkdbItNQN0oJM6x
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJT4efmAAoJEHZH4aRLwOS6I34P/1M9kv4XWsJQ1212C7VdvPNQ
r1MiM7bAVrtPv7MWje2rwEna+VF1AqSKbr/zCFQsh/84aJuxr1VFyZP/GJVd68y2
NDJeCv8E7fc8SsOOJTr765Y59R+ATVgLhqSldPJf1/vA+iCwtGa6qfIAsoebQpvL
iFOIHAz05uy1zULn4QkOuSFVyC3o1QRls/xl/sPAd/7TaCrdp+rNKPzTYpwf5nZ2
GBuxXo1QN8yw/OOjpI5kCd2f6cThxA+x4T7W4eB1Y0I8FzCLyRQSdIgvPYUw++q+
oE1o847OigYu3ZXpf0Y1M0Di2K0KbZGAqqQD1KYJlgJ5F9Mvh9Smhlv9rhuMX+LW
n5AyVbGqO3FOhv2qYbh8pu8HUGH2EkGJ5LXHs0HXsy0mugYPvECqExdDfc3CsCrc
A3z0va5V3GnXxWwlyql0wyNafV2wt8V4uS5+IMOlM93iqIUKjkeXnfoI/bY81zNP
/R/ZCo5Cxhw3lxuAD9Z7h3hdFerEamXzv9OwTHnRhIFaiUpgf80oJDYspjltzTQ0
FhbQnwnrQrv5c6qAzgWbVquxsICVD1JGMgxHHKzo4RbAiUpeRuXhuyQulNsTW6iJ
6CJXBzGddI+0GVOmoKL5LZ7x0ElXfpZK4VurUrMDhZzM/uo7T2G1jsvuRk0nCp/j
0sAXGcA7RBRxqLig5KOc
=FPkg
-----END PGP SIGNATURE-----

--drkdbItNQN0oJM6x--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
