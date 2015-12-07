Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5033C6B0257
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 05:26:26 -0500 (EST)
Received: by pfdd184 with SMTP id d184so63026599pfd.3
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 02:26:26 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id eo16si8218719pab.209.2015.12.07.02.26.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 07 Dec 2015 02:26:25 -0800 (PST)
Subject: Re: [PATCH v5 3/4] arm64: mm: support ARCH_MMAP_RND_BITS.
References: <1449000658-11475-1-git-send-email-dcashman@android.com>
 <1449000658-11475-2-git-send-email-dcashman@android.com>
 <1449000658-11475-3-git-send-email-dcashman@android.com>
 <1449000658-11475-4-git-send-email-dcashman@android.com>
From: Jon Hunter <jonathanh@nvidia.com>
Message-ID: <56655EC8.6030905@nvidia.com>
Date: Mon, 7 Dec 2015 10:26:16 +0000
MIME-Version: 1.0
In-Reply-To: <1449000658-11475-4-git-send-email-dcashman@android.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Cashman <dcashman@android.com>, linux-kernel@vger.kernel.org
Cc: dcashman@google.com, linux-doc@vger.kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, linux-mm@kvack.org, hpa@zytor.com, mingo@kernel.org, aarcange@redhat.com, linux@arm.linux.org.uk, corbet@lwn.net, xypron.glpk@gmx.de, x86@kernel.org, hecmargi@upv.es, mgorman@suse.de, rientjes@google.com, bp@suse.de, nnk@google.com, dzickus@redhat.com, keescook@chromium.org, arnd@arndb.de, jpoimboe@redhat.com, tglx@linutronix.de, n-horiguchi@ah.jp.nec.com, linux-arm-kernel@lists.infradead.org, salyzyn@android.com, ebiederm@xmission.com, jeffv@google.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com


On 01/12/15 20:10, Daniel Cashman wrote:
> From: dcashman <dcashman@google.com>
>=20
> arm64: arch_mmap_rnd() uses STACK_RND_MASK to generate the
> random offset for the mmap base address.  This value represents a
> compromise between increased ASLR effectiveness and avoiding
> address-space fragmentation. Replace it with a Kconfig option, which
> is sensibly bounded, so that platform developers may choose where to
> place this compromise. Keep default values as new minimums.
>=20
> Signed-off-by: Daniel Cashman <dcashman@android.com>
> ---
>  arch/arm64/Kconfig   | 31 +++++++++++++++++++++++++++++++
>  arch/arm64/mm/mmap.c |  8 ++++++--
>  2 files changed, 37 insertions(+), 2 deletions(-)

[snip]

> diff --git a/arch/arm64/mm/mmap.c b/arch/arm64/mm/mmap.c
> index ed17747..af461b9 100644
> --- a/arch/arm64/mm/mmap.c
> +++ b/arch/arm64/mm/mmap.c
> @@ -51,8 +51,12 @@ unsigned long arch_mmap_rnd(void)
>  {
>  	unsigned long rnd;
> =20
> -	rnd =3D (unsigned long)get_random_int() & STACK_RND_MASK;
> -
> +ifdef CONFIG_COMPAT
> +	if (test_thread_flag(TIF_32BIT))
> +		rnd =3D (unsigned long)get_random_int() % (1 << mmap_rnd_compat_bits);
> +	else
> +#endif
> +		rnd =3D (unsigned long)get_random_int() % (1 << mmap_rnd_bits);
>  	return rnd << PAGE_SHIFT;
>  }

The above is causing a build failure on -next today.

commit 42a6c8953112a9856dd09148c3d6a2cc106b6003
Author: Jon Hunter <jonathanh@nvidia.com>
Date:   Mon Dec 7 10:15:47 2015 +0000

    ARM64: mm: Fix build failure caused by invalid ifdef statement
   =20
    Commit 2e4614190421 ("arm64-mm-support-arch_mmap_rnd_bits-v4") caused t=
he
    following build failure due to a missing "#". Fix this.
   =20
    arch/arm64/mm/mmap.c: In function =91arch_mmap_rnd=92:
    arch/arm64/mm/mmap.c:54:1: error: =91ifdef=92 undeclared (first use in =
this function)
     ifdef CONFIG_COMPAT
      ^
    Signed-off-by: Jon Hunter <jonathanh@nvidia.com>

diff --git a/arch/arm64/mm/mmap.c b/arch/arm64/mm/mmap.c
index af461b935137..e59a75a308bc 100644
--- a/arch/arm64/mm/mmap.c
+++ b/arch/arm64/mm/mmap.c
@@ -51,7 +51,7 @@ unsigned long arch_mmap_rnd(void)
 {
        unsigned long rnd;
=20
-ifdef CONFIG_COMPAT
+#ifdef CONFIG_COMPAT
        if (test_thread_flag(TIF_32BIT))
                rnd =3D (unsigned long)get_random_int() % (1 << mmap_rnd_co=
mpat_bits);
        else

Cheers
Jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
