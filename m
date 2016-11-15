Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 17FC56B0275
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 06:18:15 -0500 (EST)
Received: by mail-yb0-f198.google.com with SMTP id d128so174261961ybh.6
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 03:18:15 -0800 (PST)
Received: from g9t5009.houston.hpe.com (g9t5009.houston.hpe.com. [15.241.48.73])
        by mx.google.com with ESMTPS id a83si11553626oif.108.2016.11.15.03.18.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 03:18:14 -0800 (PST)
Subject: Re: [RFC PATCH v3 1/2] Add support for eXclusive Page Frame Ownership
 (XPFO)
References: <20160914071901.8127-1-juerg.haefliger@hpe.com>
 <20161104144534.14790-1-juerg.haefliger@hpe.com>
 <20161104144534.14790-2-juerg.haefliger@hpe.com>
 <CAGXu5jKvWZ6=YLkFkA2wEE0gTdESTEifeL5KVXUd+EjKjJm9WQ@mail.gmail.com>
From: Juerg Haefliger <juerg.haefliger@hpe.com>
Message-ID: <9c558dfc-112a-bb52-88c5-206f5ca4fc42@hpe.com>
Date: Tue, 15 Nov 2016 12:18:10 +0100
MIME-Version: 1.0
In-Reply-To: <CAGXu5jKvWZ6=YLkFkA2wEE0gTdESTEifeL5KVXUd+EjKjJm9WQ@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="tIVC2OL3od72E71xQ07EDiAJ4OLahkkKF"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, linux-x86_64@vger.kernel.org, vpk@cs.columbia.edu

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--tIVC2OL3od72E71xQ07EDiAJ4OLahkkKF
Content-Type: multipart/mixed; boundary="rclb8TCNqwCQ5eCEnVAGCpLPAekUixeEA";
 protected-headers="v1"
From: Juerg Haefliger <juerg.haefliger@hpe.com>
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
 "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
 linux-x86_64@vger.kernel.org, vpk@cs.columbia.edu
Message-ID: <9c558dfc-112a-bb52-88c5-206f5ca4fc42@hpe.com>
Subject: Re: [RFC PATCH v3 1/2] Add support for eXclusive Page Frame Ownership
 (XPFO)
References: <20160914071901.8127-1-juerg.haefliger@hpe.com>
 <20161104144534.14790-1-juerg.haefliger@hpe.com>
 <20161104144534.14790-2-juerg.haefliger@hpe.com>
 <CAGXu5jKvWZ6=YLkFkA2wEE0gTdESTEifeL5KVXUd+EjKjJm9WQ@mail.gmail.com>
In-Reply-To: <CAGXu5jKvWZ6=YLkFkA2wEE0gTdESTEifeL5KVXUd+EjKjJm9WQ@mail.gmail.com>

--rclb8TCNqwCQ5eCEnVAGCpLPAekUixeEA
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 11/10/2016 08:24 PM, Kees Cook wrote:
> On Fri, Nov 4, 2016 at 7:45 AM, Juerg Haefliger <juerg.haefliger@hpe.co=
m> wrote:
>> This patch adds support for XPFO which protects against 'ret2dir' kern=
el
>> attacks. The basic idea is to enforce exclusive ownership of page fram=
es
>> by either the kernel or userspace, unless explicitly requested by the
>> kernel. Whenever a page destined for userspace is allocated, it is
>> unmapped from physmap (the kernel's page table). When such a page is
>> reclaimed from userspace, it is mapped back to physmap.
>>
>> Additional fields in the page_ext struct are used for XPFO housekeepin=
g.
>> Specifically two flags to distinguish user vs. kernel pages and to tag=

>> unmapped pages and a reference counter to balance kmap/kunmap operatio=
ns
>> and a lock to serialize access to the XPFO fields.
>>
>> Known issues/limitations:
>>   - Only supports x86-64 (for now)
>>   - Only supports 4k pages (for now)
>>   - There are most likely some legitimate uses cases where the kernel =
needs
>>     to access userspace which need to be made XPFO-aware
>>   - Performance penalty
>>
>> Reference paper by the original patch authors:
>>   http://www.cs.columbia.edu/~vpk/papers/ret2dir.sec14.pdf
>=20
> Would it be possible to create an lkdtm test that can exercise this pro=
tection?

I'll look into it.


>> diff --git a/security/Kconfig b/security/Kconfig
>> index 118f4549404e..4502e15c8419 100644
>> --- a/security/Kconfig
>> +++ b/security/Kconfig
>> @@ -6,6 +6,25 @@ menu "Security options"
>>
>>  source security/keys/Kconfig
>>
>> +config ARCH_SUPPORTS_XPFO
>> +       bool
>=20
> Can you include a "help" section here to describe what requirements an
> architecture needs to support XPFO? See HAVE_ARCH_SECCOMP_FILTER and
> HAVE_ARCH_VMAP_STACK or some examples.

Will do.


>> +config XPFO
>> +       bool "Enable eXclusive Page Frame Ownership (XPFO)"
>> +       default n
>> +       depends on ARCH_SUPPORTS_XPFO
>> +       select PAGE_EXTENSION
>> +       help
>> +         This option offers protection against 'ret2dir' kernel attac=
ks.
>> +         When enabled, every time a page frame is allocated to user s=
pace, it
>> +         is unmapped from the direct mapped RAM region in kernel spac=
e
>> +         (physmap). Similarly, when a page frame is freed/reclaimed, =
it is
>> +         mapped back to physmap.
>> +
>> +         There is a slight performance impact when this option is ena=
bled.
>> +
>> +         If in doubt, say "N".
>> +
>>  config SECURITY_DMESG_RESTRICT
>>         bool "Restrict unprivileged access to the kernel syslog"
>>         default n
>=20
> I've added these patches to my kspp tree on kernel.org, so it should
> get some 0-day testing now...

Very good. Thanks!


> Thanks!

Appreciate the feedback.

=2E..Juerg


> -Kees
>=20



--rclb8TCNqwCQ5eCEnVAGCpLPAekUixeEA--

--tIVC2OL3od72E71xQ07EDiAJ4OLahkkKF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYKu7zAAoJEHVMOpb5+LSMThkP/1ZSAODxbIB2ebdrvax2absi
nJwtgo56pBL7g7OJu/OrxUXvMHi9LGfahZOUTUmRCiQIL60EdjCJvQB9wcASVr3i
7AO1ztMGZxmGl/UlobukQs0xTlFU9FcYJFxTqKQPHA8PFnzQZe5jqG1JwTjhw4Z7
ANULiFZGG0G0vSXAagWwiwdzZJyt4HCSamfoESBKSBTK8TywvIFDqy/qsHHlmpjd
EExwax4E/VB+Yl8Tg2RvgHHI1kQpTB1dPBfAQvXOTjujdHVGxVZSZBss+3HXL5vi
BbNA0Gez+aNvVp2tTTeyWce9y11nIAZgU4rcjxkBqGoU73S+I2ltlIN7MCbKOYR3
/wGxXpCeOCWRVcFxm4yxnQcWOXWMa7aIVHMf7uHU53oKOqGtglFQcMR6V4bcmNG9
n+jLQZr/ADR9PJ2Rsb1vVyOlNiy+uQ+JCA5lBfEe+ckPW2MSc5GedzeETGYQgdUS
u9ZzGrbtW9++PXXjgm6YBoaij0vjhVH2/Q1WU3wwdzBDGIaRpy1Bh0zShDdQ7S8y
G83c8dHH4Yc1CIljCA0+Ipur3nvuoJKdc6Kxy+j1JK86t6dK8sktXS/1SnBIGM7T
L30CH60pgfyvpDEWbSXoQXjdyuYMaQALBYX258KXuH8e9+vjPrO/UC8prgJqK/C1
rbWnk9S8v1HGxMfThiYi
=Vrrl
-----END PGP SIGNATURE-----

--tIVC2OL3od72E71xQ07EDiAJ4OLahkkKF--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
