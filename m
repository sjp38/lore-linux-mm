Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 500046B0388
	for <linux-mm@kvack.org>; Mon, 20 Mar 2017 21:52:58 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t143so75776814pgb.1
        for <linux-mm@kvack.org>; Mon, 20 Mar 2017 18:52:58 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id p6si19446581pgd.368.2017.03.20.18.52.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Mar 2017 18:52:57 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id 79so14044011pgf.0
        for <linux-mm@kvack.org>; Mon, 20 Mar 2017 18:52:57 -0700 (PDT)
Date: Tue, 21 Mar 2017 09:52:54 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH tip v2] x86/mm: Correct fixmap header usage on adaptable
 MODULES_END
Message-ID: <20170321015254.GA12487@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170320194024.60749-1-thgarnie@google.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="KsGdsel6WgEHnImy"
Content-Disposition: inline
In-Reply-To: <20170320194024.60749-1-thgarnie@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Borislav Petkov <bp@suse.de>, Hugh Dickins <hughd@google.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Andy Lutomirski <luto@kernel.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, Chris Wilson <chris@chris-wilson.co.uk>, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, richard.weiyang@gmail.com


--KsGdsel6WgEHnImy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Mar 20, 2017 at 12:40:24PM -0700, Thomas Garnier wrote:
>This patch removes fixmap headers on non-x86 code introduced by the
>adaptable MODULE_END change. It is also removed in the 32-bit pgtable
>header. Instead, it is added  by default in the pgtable generic header
>for both architectures.
>
>Signed-off-by: Thomas Garnier <thgarnie@google.com>
>---
> arch/x86/include/asm/pgtable.h    | 1 +
> arch/x86/include/asm/pgtable_32.h | 1 -
> arch/x86/kernel/module.c          | 1 -
> arch/x86/mm/dump_pagetables.c     | 1 -
> arch/x86/mm/kasan_init_64.c       | 1 -
> mm/vmalloc.c                      | 4 ----
> 6 files changed, 1 insertion(+), 8 deletions(-)
>
>diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable=
=2Eh
>index 6f6f351e0a81..78d1fc32e947 100644
>--- a/arch/x86/include/asm/pgtable.h
>+++ b/arch/x86/include/asm/pgtable.h
>@@ -598,6 +598,7 @@ pte_t *populate_extra_pte(unsigned long vaddr);
> #include <linux/mm_types.h>
> #include <linux/mmdebug.h>
> #include <linux/log2.h>
>+#include <asm/fixmap.h>
>=20
> static inline int pte_none(pte_t pte)
> {
>diff --git a/arch/x86/include/asm/pgtable_32.h b/arch/x86/include/asm/pgta=
ble_32.h
>index fbc73360aea0..bfab55675c16 100644
>--- a/arch/x86/include/asm/pgtable_32.h
>+++ b/arch/x86/include/asm/pgtable_32.h
>@@ -14,7 +14,6 @@
>  */
> #ifndef __ASSEMBLY__
> #include <asm/processor.h>
>-#include <asm/fixmap.h>
> #include <linux/threads.h>
> #include <asm/paravirt.h>
>=20

Yep, I thinks the above two is what I mean.

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

Hmm... your code is already merged in upstream?

When I look into current Torvalds tree, it looks not include the <asm/fixma=
p.h>

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arc=
h/x86/kernel/module.c

Which tree your change is based on? Do I miss something?

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

The same as this one.

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


At last, you have tested both on x86-32 and x86-64 platform?

--=20
Wei Yang
Help you, Help me

--KsGdsel6WgEHnImy
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJY0Id2AAoJEKcLNpZP5cTd2rEP/RyN6hmEwBnJtu4RSRUlJzmq
hiIbBmIYMKTfClUbIkbs07NCofl9Bi4/j6v2vVoyfWqgUaBxMdbF6D8QFSfeSnT3
isbQ0T0k/eU1QQ2zP+Yy6v/iEaYspxcSKhFMYRFQ5eGK6vZ6f0nSXsVWKJQTZ4qp
ZLSfakmutQiGa3xmpaRTupFUPz/TzSrINgyXxLCslVuo16wLSzJ/l5hp5Og21GzQ
wDSXPsRiH5cOZyq1ixKPIz/d24m9GrxmV5+AMkzbvtayP7Gi02O6/G9kB8hOmJ9m
ie/UOpx9LeAM8971l8clZVN1UTdmJJFNiUpSZgsTdQ8yG12XhE4QN4nZu0klTdsF
JYS8Yoa9Sfh8o6Xm9mAAUPuHDFuI24tcDQMDyz9nqDeSYNm86j8tB1XAJEoIPj8t
Q4ZtPLHZrHKVzHgEdrUvWm2cCyb0qHZj7YlwUFYiO+cyPodm08u1gzgM8fai86lu
yO14C1zvEQwGRkxypye10lbwekT1hSxOscsWxD+etyRhRCDqmgksw9M2g72Gb7zX
KngiaUrNaQfQGdY8PRhZxP2cpRE3aI7ACyFo9NtPdy9moEU+pUFDoiqvx3j9X9ZR
rLNk0ZLmsHcdULxr2lAVVW9L+979hX5MUU6bSkmUxnxsSz8GSqXQEzXdYFE1xPV5
ITiPglZ3aHjycWj/MvOc
=BOIn
-----END PGP SIGNATURE-----

--KsGdsel6WgEHnImy--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
