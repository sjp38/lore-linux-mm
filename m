Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A43CB6B0005
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 03:43:37 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u83so721669wmb.3
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 00:43:37 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p19sor249279wrb.42.2018.03.09.00.43.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Mar 2018 00:43:36 -0800 (PST)
Date: Fri, 9 Mar 2018 09:43:32 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] x86, powerpc : pkey-mprotect must allow pkey-0
Message-ID: <20180309084332.hk6xt6obghoqokbc@gmail.com>
References: <1520583161-11741-1-git-send-email-linuxram@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1520583161-11741-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com, Ulrich.Weigand@de.ibm.com


* Ram Pai <linuxram@us.ibm.com> wrote:

> Once an address range is associated with an allocated pkey, it cannot be
> reverted back to key-0. There is no valid reason for the above behavior.  On
> the contrary applications need the ability to do so.
> 
> The patch relaxes the restriction.
> 
> Tested on powerpc and x86_64.
> 
> cc: Dave Hansen <dave.hansen@intel.com>
> cc: Michael Ellermen <mpe@ellerman.id.au>
> cc: Ingo Molnar <mingo@kernel.org>
> Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> ---
>  arch/powerpc/include/asm/pkeys.h | 19 ++++++++++++++-----
>  arch/x86/include/asm/pkeys.h     |  5 +++--
>  2 files changed, 17 insertions(+), 7 deletions(-)
> 
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

Please capitalize in comments consistently, i.e.:

	/* Reserved keys are never allocated: */

> +
> +	return(__mm_pkey_is_allocated(mm, pkey));

'return' is not a function.

Thanks,

	Ingo
