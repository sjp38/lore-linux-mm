Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 045506B059B
	for <linux-mm@kvack.org>; Sat, 29 Jul 2017 19:25:05 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 24so61152719pfk.5
        for <linux-mm@kvack.org>; Sat, 29 Jul 2017 16:25:04 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y5si14456116pgs.486.2017.07.29.16.25.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Jul 2017 16:25:03 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6TNNtSg053786
	for <linux-mm@kvack.org>; Sat, 29 Jul 2017 19:25:03 -0400
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2c0k8rbgg5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 29 Jul 2017 19:25:03 -0400
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Sat, 29 Jul 2017 17:25:02 -0600
Date: Sat, 29 Jul 2017 16:24:46 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [RFC v6 19/62] powerpc: ability to create execute-disabled pkeys
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
 <1500177424-13695-20-git-send-email-linuxram@us.ibm.com>
 <87bmo63p7c.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87bmo63p7c.fsf@linux.vnet.ibm.com>
Message-Id: <20170729232446.GG5664@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, arnd@arndb.de, corbet@lwn.net, mhocko@kernel.org, dave.hansen@intel.com, mingo@redhat.com, paulus@samba.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com

On Thu, Jul 27, 2017 at 11:54:31AM -0300, Thiago Jung Bauermann wrote:
> 
> Ram Pai <linuxram@us.ibm.com> writes:
> 
> > --- a/arch/powerpc/include/asm/pkeys.h
> > +++ b/arch/powerpc/include/asm/pkeys.h
> > @@ -2,6 +2,18 @@
> >  #define _ASM_PPC64_PKEYS_H
> >
> >  extern bool pkey_inited;
> > +/* override any generic PKEY Permission defines */
> > +#undef  PKEY_DISABLE_ACCESS
> > +#define PKEY_DISABLE_ACCESS    0x1
> > +#undef  PKEY_DISABLE_WRITE
> > +#define PKEY_DISABLE_WRITE     0x2
> > +#undef  PKEY_DISABLE_EXECUTE
> > +#define PKEY_DISABLE_EXECUTE   0x4
> > +#undef  PKEY_ACCESS_MASK
> > +#define PKEY_ACCESS_MASK       (PKEY_DISABLE_ACCESS |\
> > +				PKEY_DISABLE_WRITE  |\
> > +				PKEY_DISABLE_EXECUTE)
> > +
> 
> Is it ok to #undef macros from another header? Especially since said
> header is in uapi (include/uapi/asm-generic/mman-common.h).
> 
> Also, it's unnecessary to undef the _ACCESS and _WRITE macros since they
> are identical to the original definition. And since these macros are
> originally defined in an uapi header, the powerpc-specific ones should
> be in an uapi header as well, if I understand it correctly.

The architectural neutral code allows the implementation to define the
macros to its taste. powerpc headers due to legacy reason includes the
include/uapi/asm-generic/mman-common.h header. That header includes the
generic definitions of only PKEY_DISABLE_ACCESS and PKEY_DISABLE_WRITE.
Unfortunately we end up importing them. I dont want to depend on them.
Any changes there could effect us. Example if the generic uapi header
changed PKEY_DISABLE_ACCESS to 0x4, we will have a conflict with
PKEY_DISABLE_EXECUTE.  Hence I undef them and define the it my way.

> 
> An alternative solution is to define only PKEY_DISABLE_EXECUTE in
> arch/powerpc/include/uapi/asm/mman.h and then test for its existence to
> properly define PKEY_ACCESS_MASK in
> include/uapi/asm-generic/mman-common.h. What do you think of the code
> below?
> 
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

I suppose we can do it this way aswell. but dont like the way it is
spreading the defines accross multiple files.

> 
> 
> > diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
> > index 98d0391..b9ad98d 100644
> > --- a/arch/powerpc/mm/pkeys.c
> > +++ b/arch/powerpc/mm/pkeys.c
> > @@ -73,6 +73,7 @@ int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
> >  		unsigned long init_val)
> >  {
> >  	u64 new_amr_bits = 0x0ul;
> > +	u64 new_iamr_bits = 0x0ul;
> >
> >  	if (!is_pkey_enabled(pkey))
> >  		return -1;
> > @@ -85,5 +86,14 @@ int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
> >
> >  	init_amr(pkey, new_amr_bits);
> >
> > +	/*
> > +	 * By default execute is disabled.
> > +	 * To enable execute, PKEY_ENABLE_EXECUTE
> > +	 * needs to be specified.
> > +	 */
> > +	if ((init_val & PKEY_DISABLE_EXECUTE))
> > +		new_iamr_bits |= IAMR_EX_BIT;
> > +
> > +	init_iamr(pkey, new_iamr_bits);
> >  	return 0;
> >  }
> 
> The comment seems to be from an earlier version which has the logic
> inverted, and there is no PKEY_ENABLE_EXECUTE. Should the comment be
> updated to the following?
> 
>     By default execute is enabled.
>     To disable execute, PKEY_DISABLE_EXECUTE needs to be specified.

yes. the comment is misleading. I just took it out.

RP

> 
> -- 
> Thiago Jung Bauermann
> IBM Linux Technology Center

-- 
Ram Pai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
