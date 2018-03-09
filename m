Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 611956B0005
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 05:20:02 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id 62-v6so4324016ply.4
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 02:20:02 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id v10-v6si583919ply.700.2018.03.09.02.20.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 09 Mar 2018 02:20:00 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH] x86, powerpc : pkey-mprotect must allow pkey-0
In-Reply-To: <1520583161-11741-1-git-send-email-linuxram@us.ibm.com>
References: <1520583161-11741-1-git-send-email-linuxram@us.ibm.com>
Date: Fri, 09 Mar 2018 21:19:53 +1100
Message-ID: <87lgf1v9di.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, mingo@redhat.com, akpm@linux-foundation.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com, Ulrich.Weigand@de.ibm.com

Ram Pai <linuxram@us.ibm.com> writes:

> Once an address range is associated with an allocated pkey, it cannot be
> reverted back to key-0. There is no valid reason for the above behavior.  On
> the contrary applications need the ability to do so.

Please explain this in much more detail. Is it an ABI change?

And why did we just notice this?

> The patch relaxes the restriction.
>
> Tested on powerpc and x86_64.

Thanks, but please split the patch, one for each arch.

cheers

> diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
> index 0409c80..3e8abe4 100644
> --- a/arch/powerpc/include/asm/pkeys.h
> +++ b/arch/powerpc/include/asm/pkeys.h
> @@ -101,10 +101,18 @@ static inline u16 pte_to_pkey_bits(u64 pteflags)
>  
>  static inline bool mm_pkey_is_allocated(struct mm_struct *mm, int pkey)
>  {
> -	/* A reserved key is never considered as 'explicitly allocated' */
> -	return ((pkey < arch_max_pkey()) &&
> -		!__mm_pkey_is_reserved(pkey) &&
> -		__mm_pkey_is_allocated(mm, pkey));
> +	/* pkey 0 is allocated by default. */
> +	if (!pkey)
> +	       return true;
> +
> +	if (pkey < 0 || pkey >= arch_max_pkey())
> +	       return false;
> +
> +	/* reserved keys are never allocated. */
> +	if (__mm_pkey_is_reserved(pkey))
> +	       return false;
> +
> +	return(__mm_pkey_is_allocated(mm, pkey));
>  }
>  
>  extern void __arch_activate_pkey(int pkey);
> @@ -150,7 +158,8 @@ static inline int mm_pkey_free(struct mm_struct *mm, int pkey)
>  	if (static_branch_likely(&pkey_disabled))
>  		return -1;
>  
> -	if (!mm_pkey_is_allocated(mm, pkey))
> +	/* pkey 0 cannot be freed */
> +	if (!pkey || !mm_pkey_is_allocated(mm, pkey))
>  		return -EINVAL;
>  
>  	/*
> diff --git a/arch/x86/include/asm/pkeys.h b/arch/x86/include/asm/pkeys.h
> index a0ba1ff..6ea7486 100644
> --- a/arch/x86/include/asm/pkeys.h
> +++ b/arch/x86/include/asm/pkeys.h
> @@ -52,7 +52,7 @@ bool mm_pkey_is_allocated(struct mm_struct *mm, int pkey)
>  	 * from pkey_alloc().  pkey 0 is special, and never
>  	 * returned from pkey_alloc().
>  	 */
> -	if (pkey <= 0)
> +	if (pkey < 0)
>  		return false;
>  	if (pkey >= arch_max_pkey())
>  		return false;
> @@ -92,7 +92,8 @@ int mm_pkey_alloc(struct mm_struct *mm)
>  static inline
>  int mm_pkey_free(struct mm_struct *mm, int pkey)
>  {
> -	if (!mm_pkey_is_allocated(mm, pkey))
> +	/* pkey 0 is special and can never be freed */
> +	if (!pkey || !mm_pkey_is_allocated(mm, pkey))
>  		return -EINVAL;
>  
>  	mm_set_pkey_free(mm, pkey);
> -- 
> 1.8.3.1
