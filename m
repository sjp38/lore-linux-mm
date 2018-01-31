Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8C5D56B0003
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 14:41:14 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id y13so15642083pfl.16
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 11:41:14 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id a91-v6si71890pld.125.2018.01.31.11.41.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 11:41:13 -0800 (PST)
Subject: Re: [PATCH] x86/mm: Rename flush_tlb_single() and flush_tlb_one()
References: <3303b02e3c3d049dc5235d5651e0ae6d29a34354.1517414378.git.luto@kernel.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <032133ea-0f5a-379a-2bff-58142518a96e@intel.com>
Date: Wed, 31 Jan 2018 11:41:10 -0800
MIME-Version: 1.0
In-Reply-To: <3303b02e3c3d049dc5235d5651e0ae6d29a34354.1517414378.git.luto@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, linux-kernel@vger.kernel.org, x86@kernel.org
Cc: linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bpetkov@suse.de>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Eduardo Valentin <eduval@amazon.com>, Will Deacon <will.deacon@arm.com>

> @@ -437,18 +437,31 @@ static inline void __flush_tlb_all(void)
>  /*
>   * flush one page in the kernel mapping
>   */
> -static inline void __flush_tlb_one(unsigned long addr)
> +static inline void __flush_tlb_one_kernel(unsigned long addr)
>  {
>  	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ONE);
> -	__flush_tlb_single(addr);
> +
> +	/*
> +	 * If PTI is off, then __flush_tlb_one_user() is just INVLPG or its
> +	 * paravirt equivalent.  Even with PCID, this is sufficient: we only
> +	 * use PCID if we also use global PTEs for the kernel mapping, and
> +	 * INVLPG flushes global translations across all address spaces.

This looks good.

> +	 * If PTI is on, then the kernel is mapped with non-global PTEs, and
> +	 * __flush_tlb_one_user() will flush the given address for the current
> +	 * kernel address space and for its usermode counterpart, but it goes
> +	 * not flush it for other address spaces.
> +	 */
> +	__flush_tlb_one_user(addr);

s/goes/does/

It also goes off and flushes the address out of the user asid.  That
_seems_ a bit goofy, but it is needed for addresses that might be mapped
into the user asid, so it's definitely safe.  Might be worth calling out.

Maybe add a (if one exists) or something like:

... kernel address space and for its usermode counterpart (if one exists).

>  	if (!static_cpu_has(X86_FEATURE_PTI))
>  		return;
>  
>  	/*
> -	 * __flush_tlb_single() will have cleared the TLB entry for this ASID,
> -	 * but since kernel space is replicated across all, we must also
> -	 * invalidate all others.
> +	 * See above.  We need to propagate the flush to all other address
> +	 * spaces.  In principle, we only need to propagate it to kernelmode
> +	 * address spaces, but the extra bookkeeping we would need is not
> +	 * worth it.
>  	 */
>  	invalidate_other_asid();
>  }

That comment is true, except if we were invalidating a user-mapped
address.  Right?

We've just been pretending so far for the purposes of TLB invalidation
that all kernel addresses are potentially user-mapped.

The name change looks really good to me, though.  Thanks for doing this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
