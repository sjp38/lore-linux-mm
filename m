Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB4696B47BF
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 06:57:26 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id n45so19905278qta.5
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 03:57:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 188si2759742qki.258.2018.11.27.03.57.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 03:57:25 -0800 (PST)
From: Florian Weimer <fweimer@redhat.com>
Subject: Re: pkeys: Reserve PKEY_DISABLE_READ
References: <877ehnbwqy.fsf@oldenburg.str.redhat.com>
	<2d62c9e2-375b-2791-32ce-fdaa7e7664fd@intel.com>
	<87bm6zaa04.fsf@oldenburg.str.redhat.com>
	<6f9c65fb-ea7e-8217-a4cc-f93e766ed9bb@intel.com>
	<87k1ln8o7u.fsf@oldenburg.str.redhat.com>
	<20181108201231.GE5481@ram.oc3035372033.ibm.com>
	<87bm6z71yw.fsf@oldenburg.str.redhat.com>
	<20181109180947.GF5481@ram.oc3035372033.ibm.com>
	<87efbqqze4.fsf@oldenburg.str.redhat.com>
	<20181127102350.GA5795@ram.oc3035372033.ibm.com>
Date: Tue, 27 Nov 2018 12:57:15 +0100
In-Reply-To: <20181127102350.GA5795@ram.oc3035372033.ibm.com> (Ram Pai's
	message of "Tue, 27 Nov 2018 02:23:50 -0800")
Message-ID: <87zhtuhgx0.fsf@oldenburg.str.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: linux-mm@kvack.org, linux-api@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Dave Hansen <dave.hansen@intel.com>

* Ram Pai:

> diff --git a/arch/x86/include/uapi/asm/mman.h b/arch/x86/include/uapi/asm/mman.h
> index d4a8d04..e9b121b 100644
> --- a/arch/x86/include/uapi/asm/mman.h
> +++ b/arch/x86/include/uapi/asm/mman.h
> @@ -24,6 +24,11 @@
>  		((key) & 0x2 ? VM_PKEY_BIT1 : 0) |      \
>  		((key) & 0x4 ? VM_PKEY_BIT2 : 0) |      \
>  		((key) & 0x8 ? VM_PKEY_BIT3 : 0))
> +
> +/* Override any generic PKEY permission defines */
> +#undef PKEY_ACCESS_MASK
> +#define PKEY_ACCESS_MASK       (PKEY_DISABLE_ACCESS |\
> +				PKEY_DISABLE_WRITE)
>  #endif

I would have expected something that translates PKEY_DISABLE_WRITE |
PKEY_DISABLE_READ into PKEY_DISABLE_ACCESS, and also accepts
PKEY_DISABLE_ACCESS | PKEY_DISABLE_READ, for consistency with POWER.

(My understanding is that PKEY_DISABLE_ACCESS does not disable all
access, but produces execute-only memory.)

> diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
> index e7ee328..61168e4 100644
> --- a/include/uapi/asm-generic/mman-common.h
> +++ b/include/uapi/asm-generic/mman-common.h
> @@ -71,7 +71,8 @@
>  
>  #define PKEY_DISABLE_ACCESS	0x1
>  #define PKEY_DISABLE_WRITE	0x2
> -#define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
> -				 PKEY_DISABLE_WRITE)
> -
> +#define PKEY_DISABLE_EXECUTE	0x4
> +#define PKEY_DISABLE_READ	0x8
> +#define PKEY_ACCESS_MASK	0x0	/* arch can override and define its own
> +					   mask bits */
>  #endif /* __ASM_GENERIC_MMAN_COMMON_H */

I think Dave requested a value for PKEY_DISABLE_READ which is further
away from the existing bits.

Thanks,
Florian
