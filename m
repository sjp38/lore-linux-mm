Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id A3A786B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 14:01:09 -0500 (EST)
Received: by pfbo64 with SMTP id o64so31236344pfb.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 11:01:09 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id k80si10090872pfb.144.2015.12.14.11.01.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 11:01:08 -0800 (PST)
Subject: Re: [PATCH v6 4/4] x86: mm: support ARCH_MMAP_RND_BITS.
References: <1449856338-30984-1-git-send-email-dcashman@android.com>
 <1449856338-30984-2-git-send-email-dcashman@android.com>
 <1449856338-30984-3-git-send-email-dcashman@android.com>
 <1449856338-30984-4-git-send-email-dcashman@android.com>
 <1449856338-30984-5-git-send-email-dcashman@android.com>
From: "H. Peter Anvin" <hpa@zytor.com>
Message-ID: <566F1154.7030703@zytor.com>
Date: Mon, 14 Dec 2015 10:58:28 -0800
MIME-Version: 1.0
In-Reply-To: <1449856338-30984-5-git-send-email-dcashman@android.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Cashman <dcashman@android.com>, linux-kernel@vger.kernel.org
Cc: linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, ebiederm@xmission.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, catalin.marinas@arm.com, will.deacon@arm.com, x86@kernel.org, hecmargi@upv.es, bp@suse.de, dcashman@google.com, arnd@arndb.de, jonathanh@nvidia.com

On 12/11/15 09:52, Daniel Cashman wrote:
> From: dcashman <dcashman@google.com>
> 
> x86: arch_mmap_rnd() uses hard-coded values, 8 for 32-bit and 28 for
> 64-bit, to generate the random offset for the mmap base address.
> This value represents a compromise between increased ASLR
> effectiveness and avoiding address-space fragmentation. Replace it
> with a Kconfig option, which is sensibly bounded, so that platform
> developers may choose where to place this compromise. Keep default
> values as new minimums.
> 
> Signed-off-by: Daniel Cashman <dcashman@android.com>

OK, this is around the time when I make a lecture about the danger of
expecting the compiler to make certain transformations:

> diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
> index 844b06d..647fecf 100644
> --- a/arch/x86/mm/mmap.c
> +++ b/arch/x86/mm/mmap.c
> @@ -69,14 +69,14 @@ unsigned long arch_mmap_rnd(void)
>  {
>  	unsigned long rnd;
>  
> -	/*
> -	 *  8 bits of randomness in 32bit mmaps, 20 address space bits
> -	 * 28 bits of randomness in 64bit mmaps, 40 address space bits
> -	 */
>  	if (mmap_is_ia32())
> -		rnd = (unsigned long)get_random_int() % (1<<8);
> +#ifdef CONFIG_COMPAT
> +		rnd = (unsigned long)get_random_int() % (1 << mmap_rnd_compat_bits);
> +#else
> +		rnd = (unsigned long)get_random_int() % (1 << mmap_rnd_bits);
> +#endif
>  	else
> -		rnd = (unsigned long)get_random_int() % (1<<28);
> +		rnd = (unsigned long)get_random_int() % (1 << mmap_rnd_bits);
>  
>  	return rnd << PAGE_SHIFT;
>  }
> 

Now, you and I know that both variants can be implemented with a simple
AND, but I have a strong suspicion that once this is turned into a
variable, this will in fact be changed from an AND to a divide.

So I'd prefer to use the
"get_random_int() & ((1UL << mmap_rnd_bits) - 1)" construct instead.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
