Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DDC006B0005
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 05:46:27 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id i64so2236498wmd.8
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 02:46:27 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id n23si3362753wrf.404.2018.03.15.02.46.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 15 Mar 2018 02:46:26 -0700 (PDT)
Date: Thu, 15 Mar 2018 10:46:05 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v3] x86: treat pkey-0 special
In-Reply-To: <1521061214-22385-1-git-send-email-linuxram@us.ibm.com>
Message-ID: <alpine.DEB.2.21.1803151039430.1525@nanos.tec.linutronix.de>
References: <1521061214-22385-1-git-send-email-linuxram@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: mingo@redhat.com, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com, Ulrich.Weigand@de.ibm.com

On Wed, 14 Mar 2018, Ram Pai wrote:
> Applications need the ability to associate an address-range with some
> key and latter revert to its initial default key. Pkey-0 comes close to
> providing this function but falls short, because the current
> implementation disallows applications to explicitly associate pkey-0 to
> the address range.
> 
> This patch clarifies the semantics of pkey-0 and provides the

grep 'This patch' Documentation/process

> corresponding implementation on powerpc.
> 
> Pkey-0 is special with the following semantics.
> (a) it is implicitly allocated and can never be freed. It always exists.
> (b) it is the default key assigned to any address-range.
> (c) it can be explicitly associated with any address-range.
> 
> Tested on x86_64.

I'm curious how the corresponding implementation on powerpc can be tested
on x86_64. Copy and paste is not enough ...

> 
> History:
>     v3 : added clarification of the semantics of pkey0.
>     		-- suggested by Dave Hansen
>     v2 : split the patch into two, one for x86 and one for powerpc
>     		-- suggested by Michael Ellermen

Please put the history below the --- seperator. It's not part of the
changelog. That way the tools can discard it when picking up the patch.

> 
> cc: Dave Hansen <dave.hansen@intel.com>
> cc: Michael Ellermen <mpe@ellerman.id.au>
> cc: Ingo Molnar <mingo@kernel.org>
> Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> ---
>  arch/x86/include/asm/pkeys.h | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
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

This comment is pretty useless. How should anyone figure out whats special
about pkey 0?

> +	if (!pkey || !mm_pkey_is_allocated(mm, pkey))

Why this extra check? mm_pkey_is_allocated(mm, 0) should not return true
ever. If it does, then this wants to be fixed.

Thanks,

	tglx
