Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id C984A6B0035
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 20:42:58 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id fp1so10089854pdb.19
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 17:42:58 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id 1si7927438pdf.411.2014.07.21.17.42.57
        for <linux-mm@kvack.org>;
        Mon, 21 Jul 2014 17:42:57 -0700 (PDT)
From: "Zhang, Tianfei" <tianfei.zhang@intel.com>
Subject: RE: [PATCH v7 05/10] x86, mpx: extend siginfo structure to include
 bound violation information
Date: Tue, 22 Jul 2014 00:42:53 +0000
Message-ID: <BA6F50564D52C24884F9840E07E32DEC17D5E258@CDSMSX102.ccr.corp.intel.com>
References: <1405921124-4230-1-git-send-email-qiaowei.ren@intel.com>
 <1405921124-4230-6-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1405921124-4230-6-git-send-email-qiaowei.ren@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Ren, Qiaowei" <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>
Cc: "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>



> -----Original Message-----
> From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
> Behalf Of Qiaowei Ren
> Sent: Monday, July 21, 2014 1:39 PM
> To: H. Peter Anvin; Thomas Gleixner; Ingo Molnar; Hansen, Dave
> Cc: x86@kernel.org; linux-kernel@vger.kernel.org; linux-mm@kvack.org; Ren=
,
> Qiaowei
> Subject: [PATCH v7 05/10] x86, mpx: extend siginfo structure to include b=
ound
> violation information
>=20
> This patch adds new fields about bound violation into siginfo structure.
> si_lower and si_upper are respectively lower bound and upper bound when
> bound violation is caused.
>=20
> Signed-off-by: Qiaowei Ren <qiaowei.ren@intel.com>
> ---
>  include/uapi/asm-generic/siginfo.h |    9 ++++++++-
>  kernel/signal.c                    |    4 ++++
>  2 files changed, 12 insertions(+), 1 deletions(-)
>=20
> diff --git a/include/uapi/asm-generic/siginfo.h
> b/include/uapi/asm-generic/siginfo.h
> index ba5be7f..1e35520 100644
> --- a/include/uapi/asm-generic/siginfo.h
> +++ b/include/uapi/asm-generic/siginfo.h
> @@ -91,6 +91,10 @@ typedef struct siginfo {
>  			int _trapno;	/* TRAP # which caused the signal */
>  #endif
>  			short _addr_lsb; /* LSB of the reported address */
> +			struct {
> +				void __user *_lower;
> +				void __user *_upper;
> +			} _addr_bnd;
>  		} _sigfault;
>=20
>  		/* SIGPOLL */
> @@ -131,6 +135,8 @@ typedef struct siginfo {
>  #define si_trapno	_sifields._sigfault._trapno
>  #endif
>  #define si_addr_lsb	_sifields._sigfault._addr_lsb
> +#define si_lower	_sifields._sigfault._addr_bnd._lower
> +#define si_upper	_sifields._sigfault._addr_bnd._upper
>  #define si_band		_sifields._sigpoll._band
>  #define si_fd		_sifields._sigpoll._fd
>  #ifdef __ARCH_SIGSYS
> @@ -199,7 +205,8 @@ typedef struct siginfo {
>   */
>  #define SEGV_MAPERR	(__SI_FAULT|1)	/* address not mapped to object
> */
>  #define SEGV_ACCERR	(__SI_FAULT|2)	/* invalid permissions for mapped
> object */
> -#define NSIGSEGV	2
> +#define SEGV_BNDERR	(__SI_FAULT|3)  /* failed address bound checks */
> +#define NSIGSEGV	3
>=20
>  /*
>   * SIGBUS si_codes
> diff --git a/kernel/signal.c b/kernel/signal.c index a4077e9..2131636 100=
644
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -2748,6 +2748,10 @@ int copy_siginfo_to_user(siginfo_t __user *to,
> const siginfo_t *from)
>  		if (from->si_code =3D=3D BUS_MCEERR_AR || from->si_code =3D=3D
> BUS_MCEERR_AO)
>  			err |=3D __put_user(from->si_addr_lsb, &to->si_addr_lsb);  #endif
> +#ifdef SEGV_BNDERR
> +		err |=3D __put_user(from->si_lower, &to->si_lower);
> +		err |=3D __put_user(from->si_upper, &to->si_upper); #endif

"#endif" should be in a new line.

>  		break;
>  	case __SI_CHLD:
>  		err |=3D __put_user(from->si_pid, &to->si_pid);
> --
> 1.7.1
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in the body to
> majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
