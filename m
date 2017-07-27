Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4D4676B04A9
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 11:35:21 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id k68so6551724wmd.14
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 08:35:21 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g46si14345250wrg.330.2017.07.27.08.35.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 08:35:20 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6RFZF42011531
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 11:35:18 -0400
Received: from e24smtp04.br.ibm.com (e24smtp04.br.ibm.com [32.104.18.25])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2byh1ppg9t-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 11:35:17 -0400
Received: from localhost
	by e24smtp04.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bauerman@linux.vnet.ibm.com>;
	Thu, 27 Jul 2017 12:35:12 -0300
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay03.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6RFZAxM40763430
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 12:35:10 -0300
Received: from d24av04.br.ibm.com (localhost [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6RFZAe9010394
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 12:35:11 -0300
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com> <1500177424-13695-20-git-send-email-linuxram@us.ibm.com> <87bmo63p7c.fsf@linux.vnet.ibm.com>
From: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
Subject: Re: [RFC v6 19/62] powerpc: ability to create execute-disabled pkeys
In-reply-to: <87bmo63p7c.fsf@linux.vnet.ibm.com>
Date: Thu, 27 Jul 2017 12:34:57 -0300
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87a83p51we.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, arnd@arndb.de, corbet@lwn.net, mhocko@kernel.org, dave.hansen@intel.com, mingo@redhat.com, paulus@samba.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com


Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com> writes:
> diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
> index e31f5ee8e81f..67e6a3a343ae 100644
> --- a/arch/powerpc/include/asm/pkeys.h
> +++ b/arch/powerpc/include/asm/pkeys.h
> @@ -4,17 +4,6 @@
>  #include <asm/firmware.h>
>  
>  extern bool pkey_inited;
> -/* override any generic PKEY Permission defines */
> -#undef  PKEY_DISABLE_ACCESS
> -#define PKEY_DISABLE_ACCESS    0x1
> -#undef  PKEY_DISABLE_WRITE
> -#define PKEY_DISABLE_WRITE     0x2
> -#undef  PKEY_DISABLE_EXECUTE
> -#define PKEY_DISABLE_EXECUTE   0x4
> -#undef  PKEY_ACCESS_MASK
> -#define PKEY_ACCESS_MASK       (PKEY_DISABLE_ACCESS |\
> -				PKEY_DISABLE_WRITE  |\
> -				PKEY_DISABLE_EXECUTE)
>  
>  #define ARCH_VM_PKEY_FLAGS (VM_PKEY_BIT0 | VM_PKEY_BIT1 | VM_PKEY_BIT2 | \
>  				VM_PKEY_BIT3 | VM_PKEY_BIT4)
> diff --git a/arch/powerpc/include/uapi/asm/mman.h b/arch/powerpc/include/uapi/asm/mman.h
> index ab45cc2f3101..dee43feb7c53 100644
> --- a/arch/powerpc/include/uapi/asm/mman.h
> +++ b/arch/powerpc/include/uapi/asm/mman.h
> @@ -45,4 +45,6 @@
>  #define MAP_HUGE_1GB	(30 << MAP_HUGE_SHIFT)	/* 1GB   HugeTLB Page */
>  #define MAP_HUGE_16GB	(34 << MAP_HUGE_SHIFT)	/* 16GB  HugeTLB Page */
>  
> +#define PKEY_DISABLE_EXECUTE   0x4
> +
>  #endif /* _UAPI_ASM_POWERPC_MMAN_H */
> diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
> index 72eb9a1bde79..777f8f8dff47 100644
> --- a/arch/powerpc/mm/pkeys.c
> +++ b/arch/powerpc/mm/pkeys.c
> @@ -12,7 +12,7 @@
>   * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
>   * more details.
>   */
> -#include <uapi/asm-generic/mman-common.h>
> +#include <asm/mman.h>
>  #include <linux/pkeys.h>                /* PKEY_*                       */
>  
>  bool pkey_inited;
> diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
> index 8c27db0c5c08..93e3841d9ada 100644
> --- a/include/uapi/asm-generic/mman-common.h
> +++ b/include/uapi/asm-generic/mman-common.h
> @@ -74,7 +74,15 @@
>  
>  #define PKEY_DISABLE_ACCESS	0x1
>  #define PKEY_DISABLE_WRITE	0x2
> +
> +/* The arch-specific code may define PKEY_DISABLE_EXECUTE */
> +#ifdef PKEY_DISABLE_EXECUTE
> +#define PKEY_ACCESS_MASK       (PKEY_DISABLE_ACCESS |	\
> +				PKEY_DISABLE_WRITE  |	\
> +				PKEY_DISABLE_EXECUTE)
> +#else
>  #define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
>  				 PKEY_DISABLE_WRITE)
> +#endif
>  
>  #endif /* __ASM_GENERIC_MMAN_COMMON_H */

Actually, I just noticed that arch/powerpc/include/uapi/asm/mman.h
includes <asm-generic/mman-common.h>, so for the #ifdef above to work
the former has to #define PKEY_DISABLE_EXECUTE before including the
latter.

-- 
Thiago Jung Bauermann
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
