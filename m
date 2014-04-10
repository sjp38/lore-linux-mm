Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 85B6F6B0035
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 13:10:17 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id fp1so4140872pdb.0
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 10:10:17 -0700 (PDT)
Received: from smtp.gentoo.org (smtp.gentoo.org. [140.211.166.183])
        by mx.google.com with ESMTPS id l4si2563738pbn.207.2014.04.10.10.10.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Apr 2014 10:10:16 -0700 (PDT)
Message-ID: <5346D05E.2020201@gentoo.org>
Date: Thu, 10 Apr 2014 13:09:50 -0400
From: Richard Yao <ryao@gentoo.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/vmalloc: Introduce DEBUG_VMALLOCINFO to reduce spinlock
 contention
References: <1397148058-8737-1-git-send-email-ryao@gentoo.org> <87txa1i0uq.fsf@tassilo.jf.intel.com>
In-Reply-To: <87txa1i0uq.fsf@tassilo.jf.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="9XQMfpVkEgXa76K4rLfhnGcqM2kGo6A3M"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel@gentoo.org, Matthew Thode <mthode@mthode.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--9XQMfpVkEgXa76K4rLfhnGcqM2kGo6A3M
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 04/10/2014 12:51 PM, Andi Kleen wrote:
> Richard Yao <ryao@gentoo.org> writes:
>=20
>> Performance analysis of software compilation by Gentoo portage on an
>> Intel E5-2620 with 64GB of RAM revealed that a sizeable amount of time=
,
>> anywhere from 5% to 15%, was spent in get_vmalloc_info(), with at leas=
t
>> 40% of that time spent in the _raw_spin_lock() invoked by it.
>=20
> I don't think that's the right fix. We want to be able=20
> to debug kernels without having to recompile them.

There are plenty of other features for debugging the VM subsystem that
are disabled in production kernels because they are too expensive. I see
no reason why this should not be one of them.

If someone reading this has a use for this functionality in production
systems, I would love to hear about it. I am having trouble finding uses
for this in production.

That being said, we are clearly spending plenty of time blocked on list
traversal. I imagine that we could use an extent tree to track free
space for even bigger gains, but I have difficulty seeing why
/proc/vmallocinfo should be available on non-debug kernels. Allowing
userland to hold a critical lock indefinitely on production systems is a
deadlock waiting to happen.

> And switching locking around dynamically like this is very
> ugly and hard to maintain.

I welcome suggestions on how to make the changes I have made in this
patch more maintainable.

> Besides are you sure the spin lock is not needed elsewhere?
>=20
> How are writers to the list protected?

The spinlock is needed elsewhere, but not to protect this list.
Modifications to this list are done under RCU. The only thing stopping
RCU from being enough to avoid a spinlock is /proc/vmallocinfo, which
does locking to prevent modification while userland is reading the list.


--9XQMfpVkEgXa76K4rLfhnGcqM2kGo6A3M
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBAgAGBQJTRtBkAAoJECDuEZm+6Exkxd4P/3qGawWH/z110KPTadfUbUo5
7aojuucZXCcEUZHGsnr433Vo7+WUyH/k0Cg3cvmCglEJNdWzy7vZbdQ3h963Wg1f
1ShOTqv1WW1EmuVGRuwpHQhm+V29w7E9eMEQ2N+d2/VXB2MiTu0gijejcQ85enTu
0skbA0WvAp0Oy3yzXL6NgUTUcBr9UfBB/zxOf80Sm9U7uck8RCbft3Viy9oi0Pgu
ixqXEWopGZXMCj/pJHnhptj7/E+rYclJvbkg++7HTA9gUkXo7Cs4BhppVgw9YyxW
aFHvyWtEAuJUusSQ0uEp6iYyhtZ3gZyTouXUsucmdBzmIJfXVji3cjhrJsoAsJ2m
0b/Lmzb3wn0bFUzKHQikdhbMBHbHPiQ9Kc6QuJMJ1oLMnwvf4fOiOrYYQJP+/4N7
HJZQD9yizo1bntANFgCcbh9YOt2jEzrauGOHpLW4IMJzaOritacBvnRiuo5eDaRM
1UN5dfZ+b/IBy1V6NrlbDqcMWroT0hh3fzCYvyPAnADi5iENUiU582P7+402UCjw
DIKezgdGD2mKsJnVfzy5BKw5a7uf7vLA8qg+kZyygIsWLBzvg0BwFiXtUvViVp+C
xSSd7aHuOfm9H9F8pxxNBD2aSFZPrbl5QiHP8KatNTsZKn4JSF89HQ8UdMVNBnDu
tPzpwJp7yEnvWTx1N4Hs
=nBmN
-----END PGP SIGNATURE-----

--9XQMfpVkEgXa76K4rLfhnGcqM2kGo6A3M--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
