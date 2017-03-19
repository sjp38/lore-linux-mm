Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8483E6B038B
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 12:03:36 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id x125so73675605pgb.5
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 09:03:36 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id q17si14591694pgh.300.2017.03.19.09.03.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Mar 2017 09:03:35 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id o126so14113261pfb.1
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 09:03:35 -0700 (PDT)
Date: Mon, 20 Mar 2017 00:03:33 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH tip] x86/mm: Correct fixmap header usage on adaptable
 MODULES_END
Message-ID: <20170319160333.GA1187@WeideMBP.lan>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170317175034.4701-1-thgarnie@google.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="liOOAslEiF7prFVr"
Content-Disposition: inline
In-Reply-To: <20170317175034.4701-1-thgarnie@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


--liOOAslEiF7prFVr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Mar 17, 2017 at 10:50:34AM -0700, Thomas Garnier wrote:
>This patch remove fixmap header usage on non-x86 code that was
>introduced by the adaptable MODULE_END change.

Hi, Thomas

In this patch, it looks you are trying to do two things for my understandin=
g:
1. To include <asm/fixmap.h> in asm/pagetable_64.h and remove the include in
some of the x86 files
2. Remove <asm/fixmap.h> in mm/vmalloc.c

I think your change log covers the second task in the patch, but not not ta=
lk
about the first task you did in the patch. If you could mention it in commit
log, it would be good for maintain.

BTW, I have little knowledge about MODULE_END. By searching the code
MODULE_END is not used in arch/x86. If you would like to mention the commit
which introduce the problem, it would be more helpful to review the code.

>
>Signed-off-by: Thomas Garnier <thgarnie@google.com>
>---
>Based on tip:x86/mm
>---
> arch/x86/include/asm/pgtable_64.h | 1 +
> arch/x86/kernel/module.c          | 1 -
> arch/x86/mm/dump_pagetables.c     | 1 -
> arch/x86/mm/kasan_init_64.c       | 1 -
> mm/vmalloc.c                      | 4 ----
> 5 files changed, 1 insertion(+), 7 deletions(-)
>
>diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgta=
ble_64.h
>index 73c7ccc38912..67608d4abc2c 100644
>--- a/arch/x86/include/asm/pgtable_64.h
>+++ b/arch/x86/include/asm/pgtable_64.h
>@@ -13,6 +13,7 @@
> #include <asm/processor.h>
> #include <linux/bitops.h>
> #include <linux/threads.h>
>+#include <asm/fixmap.h>
>=20

Hmm... I see in both pgtable_32.h and pgtable_64.h will include <asm/fixmap=
=2Eh>
after this change. And pgtable_32.h and pgtable_64.h will be included only =
in
pgtable.h. So is it possible to include <asm/fixmap.h> in pgtable.h for once
instead of include it in both files? Any concerns you would have?

> extern pud_t level3_kernel_pgt[512];
> extern pud_t level3_ident_pgt[512];
>diff --git a/arch/x86/kernel/module.c b/arch/x86/kernel/module.c
>index fad61caac75e..477ae806c2fa 100644
>--- a/arch/x86/kernel/module.c
>+++ b/arch/x86/kernel/module.c
>@@ -35,7 +35,6 @@
> #include <asm/page.h>
> #include <asm/pgtable.h>
> #include <asm/setup.h>
>-#include <asm/fixmap.h>
>=20
> #if 0
> #define DEBUGP(fmt, ...)				\
>diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
>index 75efeecc85eb..58b5bee7ea27 100644
>--- a/arch/x86/mm/dump_pagetables.c
>+++ b/arch/x86/mm/dump_pagetables.c
>@@ -20,7 +20,6 @@
>=20
> #include <asm/kasan.h>
> #include <asm/pgtable.h>
>-#include <asm/fixmap.h>
>=20
> /*
>  * The dumper groups pagetable entries of the same type into one, and for
>diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
>index 1bde19ef86bd..8d63d7a104c3 100644
>--- a/arch/x86/mm/kasan_init_64.c
>+++ b/arch/x86/mm/kasan_init_64.c
>@@ -9,7 +9,6 @@
>=20
> #include <asm/tlbflush.h>
> #include <asm/sections.h>
>-#include <asm/fixmap.h>
>=20
> extern pgd_t early_level4_pgt[PTRS_PER_PGD];
> extern struct range pfn_mapped[E820_X_MAX];
>diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>index b7d2a23349f4..0dd80222b20b 100644
>--- a/mm/vmalloc.c
>+++ b/mm/vmalloc.c
>@@ -36,10 +36,6 @@
> #include <asm/tlbflush.h>
> #include <asm/shmparam.h>
>=20
>-#ifdef CONFIG_X86
>-# include <asm/fixmap.h>
>-#endif
>-
> #include "internal.h"
>=20
> struct vfree_deferred {
>--=20
>2.12.0.367.g23dc2f6d3c-goog

--=20
Wei Yang
Help you, Help me

--liOOAslEiF7prFVr
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJYzqvVAAoJEKcLNpZP5cTdI/cP/1MDqQVkInT9EcrfNQbFWrny
s9h7AyoFviNOX+lpQg5s+4dNehVRXTbFg2s+wTjermPl4fu4eT4XnHcyS8e5s2Ay
7102YuRJ4IjXhbCzAkxkKnx6McF3fOhFDpkiaX+nPKBvWJKsZNBwkRmgsa89RJ0C
y9QK4Q3kMxVGohQ9spCKH4A8D0PM1akEnDUBG1ac3r3HDiIAdn7f8bNxtiITHMCY
od2SbYuv36FlNQ3CBHgdXZ/6ppdXTW97zDMgDcbocWlg7UzBkrKjoSPJYZYHOYHi
Ob5JO/BdRGZFFZEV+uRuZE9SO4MiSG3o0CRAGhGd+b3yGwIVVyq/I0uj13vXYSRu
TcompDvNoYOht/kLkaB61IAxWfQsKl4gKgOG7/sLULVvaiwJN1oPi97SSqsfB3dc
hAv6lo8nrf9N56YrIdH5qpKIAOSGo0uyqg3/t7LlhtCl8tWgF3wH7enaX+YKN0nv
Ii0Xy7LvlkccmZJCjIu4TKMc4oPUzgpXUO+hncHGh169txqjg2QQRpeFeOCsP1hX
6GZ8+XoKqR/BAzDgRW1srjz9khfHZQgGv0xqnmrOkA9B79hRXm1TiYlX3mYY8yW7
8DF0zLaow5FJNb6fhICvQSpUmAW9djA7M3T87zqH76qQhRDvdLgHO8UmsKxPi20X
Z4XwGkg3us5QR1RM+OGT
=df8w
-----END PGP SIGNATURE-----

--liOOAslEiF7prFVr--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
