Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C97A16B02B9
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 23:10:11 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 68so22475345wmz.5
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 20:10:11 -0700 (PDT)
Received: from thejh.net (thejh.net. [2a03:4000:2:1b9::1])
        by mx.google.com with ESMTPS id uq10si6493680wjb.198.2016.11.02.20.10.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 20:10:10 -0700 (PDT)
Date: Thu, 3 Nov 2016 04:10:08 +0100
From: Jann Horn <jann@thejh.net>
Subject: Re: [PATCH v3 2/3] mm: add LSM hook for writes to readonly memory
Message-ID: <20161103031008.GC13748@pc.thejh.net>
References: <1478142286-18427-1-git-send-email-jann@thejh.net>
 <1478142286-18427-5-git-send-email-jann@thejh.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="V88s5gaDVPzZ0KCq"
Content-Disposition: inline
In-Reply-To: <1478142286-18427-5-git-send-email-jann@thejh.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: security@kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, Eric Paris <eparis@parisplace.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, mchong@google.com, Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Nick Kralevich <nnk@google.com>, Janis Danisevskis <jdanis@google.com>
Cc: linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--V88s5gaDVPzZ0KCq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 03, 2016 at 04:04:45AM +0100, Jann Horn wrote:
> SELinux attempts to make it possible to whitelist trustworthy sources of
> code that may be mapped into memory, and Android makes use of this featur=
e.
> To prevent an attacker from bypassing this by modifying R+X memory through
> /proc/$pid/mem, PTRACE_POKETEXT or DMA, it is necessary to call a security
> hook in check_vma_flags().
>=20
> PTRACE_POKETEXT can also be mitigated by blocking ptrace access, and
> /proc/$pid/mem can also be blocked at the VFS layer, but DMA is harder to
> deal with: Some driver functions (e.g. videobuf_dma_init_user_locked)
> write to user-specified DMA mappings even if those mappings are readonly
> or R+X.

Whoops, sorry for sending that twice. :/

A comment regarding the whole series: I'm not entirely sure whether this is
the best way to fix this after all. It's quite a bit of code churn, but it
has the benefit of having a single check in a central place.

As an alternative to this patch, it might be possible to break the ABIs
of the drivers that access DMA buffers with FOLL_FORCE by simply removing
FOLL_FORCE from those drivers. However, I'm not sure how much that would
break existing userspace code.

--V88s5gaDVPzZ0KCq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJYGqqQAAoJED4KNFJOeCOo49sQANukv1CdzzfURE8CTP4rMdlU
0PFqwSlfUB5hirr/aWQBICiUFxrJzVd15j08p7i2lxFoiDF8lIyXwcwlFXlgcl4+
GDDvq7em4bNf1OHkATxOj7Nm4mkq/FRqcAWuOtHUx4rnwV2V1a3FU7asfdUqjZIY
xWth51afy8klJHfsa01WGAjNi7AxZm+xOLicZHpubEAkhHB4TVDZjb7mMHciuKRj
GhYAryJPhgbIzoZSuDfLWQf3lQyGMKLPnutYo4rYHI7FlTyf9BFbnlg8TGowjYV2
6a4aSNLyzVszGQLSGkSMv6BQQGnzJLwjUnkWY5S1Mk2F5HjpuMh6BRqtNBw6i8Wa
nlEpp42329i0iRA13hI0MR3h+dvUjaBlAyi8Y4bl9SEAzVzTMTZ1XG9r4WowLCps
+47numDQkBs3DI8s0RRix2aKDqVh26nkj/mSYYtI+aeH6dtG4SrUhUFmiVIFnWIs
wggJJ0XBUlwnOrUK1LyM9SfJ2yCkW7bTKh/aZ0ltwF3Sp/EwaxQD+KwcLYVPOyUM
N2mQL/rzAt77/mh4vAQiVxQvEHc7EMFEIOej2MjDJHJ+ybep7y+Hu+VISv+KNzq4
8Pkx+UAgBVnNgOcoAkK6DGl3+bxBeW0Gu5PltIFnz7uIpO35KmohXxKwuko/JWnh
t3scv478HeeMtN+vlQ1M
=Onc6
-----END PGP SIGNATURE-----

--V88s5gaDVPzZ0KCq--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
