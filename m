Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 09AD76B0035
	for <linux-mm@kvack.org>; Fri, 22 Aug 2014 12:32:47 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so16269508pdb.27
        for <linux-mm@kvack.org>; Fri, 22 Aug 2014 09:32:46 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ey9si41584789pab.138.2014.08.22.09.32.45
        for <linux-mm@kvack.org>;
        Fri, 22 Aug 2014 09:32:45 -0700 (PDT)
Subject: Re: [PATCH] [v3] warn on performance-impacting configs aka.
 TAINT_PERFORMANCE
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20140821202424.7ED66A50@viggo.jf.intel.com>
References: <20140821202424.7ED66A50@viggo.jf.intel.com>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-6R6ySw+ziY1zb5LP2SQA"
Date: Fri, 22 Aug 2014 09:32:37 -0700
Message-ID: <1408725157.4347.14.camel@schen9-DESK>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com, peterz@infradead.org, mingo@redhat.com, ak@linux.intel.com, akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, linux-mm@kvack.org, kirill@shutemov.name, lauraa@codeaurora.org


--=-6R6ySw+ziY1zb5LP2SQA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-08-21 at 13:24 -0700, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
>=20
> Changes from v2:
>  * remove tainting and stack track
>  * add debugfs file
>  * added a little text to guide folks who want to add more
>    options
>=20
> Changes from v1:
>  * remove schedstats
>  * add DEBUG_PAGEALLOC and SLUB_DEBUG_ON
>=20
> --
>=20
> I have more than once myself been the victim of an accidentally-
> enabled kernel config option being mistaken for a true
> performance problem.
>=20
> I'm sure I've also taken profiles or performance measurements
> and assumed they were real-world when really I was measuing the
> performance with an option that nobody turns on in production.
>=20
> A warning like this late in boot will help remind folks when
> these kinds of things are enabled.  We can also teach tooling to
> look for and capture /sys/kernel/debug/config_debug .
>=20
> As for the patch...
>=20
> I originally wanted this for CONFIG_DEBUG_VM, but I think it also
> applies to things like lockdep and slab debugging.  See the patch
> for the list of offending config options.  I'm open to adding
> more, but this seemed like a good list to start.
>=20
> The compiler is smart enough to really trim down the code when
> the array is empty.  An objdump -d looks like this:
>=20
> 	lib/perf-configs.o:     file format elf64-x86-64
>=20
> 	Disassembly of section .init.text:
>=20
> 	0000000000000000 <performance_taint>:
> 	   0:   55                      push   %rbp
> 	   1:   31 c0                   xor    %eax,%eax
> 	   3:   48 89 e5                mov    %rsp,%rbp
> 	   6:   5d                      pop    %rbp
> 	   7:   c3                      retq
>=20
> This could be done with Kconfig and an #ifdef to save us 8 bytes
> of text and the entry in the late_initcall() section.  Doing it
> this way lets us keep the list of these things in one spot, and
> also gives us a convenient way to dump out the name of the
> offending option.
>=20
> For anybody that *really* cares, I put the whole thing under
> CONFIG_DEBUG_KERNEL in the Makefile.
>=20
> The messages look like this:
>=20
> [    3.865297] WARNING: Do not use this kernel for performance measuremen=
t.
> [    3.868776] WARNING: Potentially performance-altering options:
> [    3.871558] 	CONFIG_LOCKDEP enabled
> [    3.873326] 	CONFIG_SLUB_DEBUG_ON enabled
>=20
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: ak@linux.intel.com
> Cc: tim.c.chen@linux.intel.com
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: kirill@shutemov.name
> Cc: lauraa@codeaurora.org
> ---
>=20
>  b/include/linux/kernel.h |    1=20
>  b/kernel/panic.c         |    1=20
>  b/lib/Makefile           |    1=20
>  b/lib/perf-configs.c     |  114 ++++++++++++++++++++++++++++++++++++++++=
+++++++
>  4 files changed, 117 insertions(+)
>=20
> diff -puN include/linux/kernel.h~taint-performance include/linux/kernel.h
> --- a/include/linux/kernel.h~taint-performance	2014-08-19 11:38:07.424005=
355 -0700
> +++ b/include/linux/kernel.h	2014-08-19 11:38:20.960615904 -0700
> @@ -471,6 +471,7 @@ extern enum system_states {
>  #define TAINT_OOT_MODULE		12
>  #define TAINT_UNSIGNED_MODULE		13
>  #define TAINT_SOFTLOCKUP		14
> +#define TAINT_PERFORMANCE		15
> =20
>  extern const char hex_asc[];
>  #define hex_asc_lo(x)	hex_asc[((x) & 0x0f)]
> diff -puN kernel/panic.c~taint-performance kernel/panic.c
> --- a/kernel/panic.c~taint-performance	2014-08-19 11:38:28.928975233 -070=
0
> +++ b/kernel/panic.c	2014-08-20 09:56:29.528471033 -0700
> @@ -225,6 +225,7 @@ static const struct tnt tnts[] =3D {
>  	{ TAINT_OOT_MODULE,		'O', ' ' },
>  	{ TAINT_UNSIGNED_MODULE,	'E', ' ' },
>  	{ TAINT_SOFTLOCKUP,		'L', ' ' },
> +	{ TAINT_PERFORMANCE,		'Q', ' ' },
>  };
> =20
>  /**
> diff -puN /dev/null lib/perf-configs.c
> --- /dev/null	2014-04-10 11:28:14.066815724 -0700
> +++ b/lib/perf-configs.c	2014-08-21 13:22:25.586598278 -0700
> @@ -0,0 +1,114 @@
> +#include <linux/bug.h>
> +#include <linux/debugfs.h>
> +#include <linux/gfp.h>
> +#include <linux/kernel.h>
> +#include <linux/slab.h>
> +
> +/*
> + * This should list any kernel options that can substantially
> + * affect performance.  This is intended to give a loud
> + * warning during bootup so that folks have a fighting chance
> + * of noticing these things.
> + *
> + * This is fairly subjective, but a good rule of thumb for these
> + * is: if it is enabled widely in production, then it does not
> + * belong here.  If a major enterprise kernel enables a feature
> + * for a non-debug kernel, it _really_ does not belong.
> + */
> +static const char * const perfomance_killing_configs[] =3D {
> +#ifdef CONFIG_LOCKDEP
> +	"LOCKDEP",
> +#endif
> +#ifdef CONFIG_LOCK_STAT
> +	"LOCK_STAT",
> +#endif
> +#ifdef CONFIG_DEBUG_VM
> +	"DEBUG_VM",
> +#endif
> +#ifdef CONFIG_DEBUG_VM_VMACACHE
> +	"DEBUG_VM_VMACACHE",
> +#endif
> +#ifdef CONFIG_DEBUG_VM_RB
> +	"DEBUG_VM_RB",
> +#endif
> +#ifdef CONFIG_DEBUG_SLAB
> +	"DEBUG_SLAB",
> +#endif
> +#ifdef CONFIG_SLUB_DEBUG_ON
> +	"SLUB_DEBUG_ON",
> +#endif
> +#ifdef CONFIG_DEBUG_OBJECTS_FREE
> +	"DEBUG_OBJECTS_FREE",
> +#endif
> +#ifdef CONFIG_DEBUG_KMEMLEAK
> +	"DEBUG_KMEMLEAK",
> +#endif
> +#ifdef CONFIG_DEBUG_PAGEALLOC
> +	"DEBUG_PAGEALLOC",

I think coverage profiling also impact performance.
So I sould also put CONFIG_GCOV_KERNEL in the list.

Tim


--=-6R6ySw+ziY1zb5LP2SQA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABAgAGBQJT93CcAAoJEKJntYqi1rhJIUgP/jiEXZzbUvCxr1e0t09hj/FR
EPy04BcqWYC4zdL8DVxlzb5GwCt552GeXTQ2cSAOys0Rntw8tSDn6OY6UaLaN6Ay
5aue6Iz6jInJtNIMhkHd7u+Db5TVuM0cL4JGstpQQWzj1+K3wMWW8BSKgMkLdgSL
hJObscsHIAbZ4jpTn3j3lcVC28NlP+lRopvK8U37C9ZRBHMUweLhiNyeymaAnztN
Uln/e05DmHnQv8JYpYJQ74E4sHsuiB3TFFFvzUaU09+cbLGJ8rNiLl4g9nfVBsk+
ESIETm4G00YR8GG/tFeLdKyeNzI+MU1uG1TerEernXgNKXdXPcNR+J3b8OPamk4R
LXrSmMcwAogLYPqIr+ixQ1O4jNCdmCAX7pCzpC0kftBZbEIz0+Bjgu4bNUgxkKQ5
feU9vQeBRMytxkq+0VL0JC9rt6/3E1gplT7MDwxAKf8sWwxIyUIi20zTGyoR9iAM
dahU/KbglnObORvgHcOU7h00/MLXcNTdAAkMD4K1RVz/uOl7Oksxd8sWjZVnje54
iEPy+qBrGw4P7X3BEm5rckfvDdxSheaX1qP2HSRuU0iN4ULqKEpFajr8kToNAjhA
9lqGkbz+rLtrqsR+QC3CroyXCLeaaZpAQTvh7Vy4aHNShnCiMkDcRXeAWaGxby1a
I/jofRRv2cyV5vPUlZHl
=8v0o
-----END PGP SIGNATURE-----

--=-6R6ySw+ziY1zb5LP2SQA--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
