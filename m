Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6D7786B0038
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 13:52:54 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id a198so4897586lfb.6
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:52:54 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id t20si1130037lff.308.2017.02.22.10.52.52
        for <linux-mm@kvack.org>;
        Wed, 22 Feb 2017 10:52:52 -0800 (PST)
Date: Wed, 22 Feb 2017 19:52:15 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v4 16/28] x86: Add support for changing memory
 encryption attribute
Message-ID: <20170222185215.atbntnyw7252kkbk@pd.tnic>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154535.19244.6294.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170216154535.19244.6294.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On Thu, Feb 16, 2017 at 09:45:35AM -0600, Tom Lendacky wrote:
> Add support for changing the memory encryption attribute for one or more
> memory pages.

"This will be useful when we, ...., for example."

> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/cacheflush.h |    3 ++
>  arch/x86/mm/pageattr.c            |   66 +++++++++++++++++++++++++++++++++++++
>  2 files changed, 69 insertions(+)
> 
> diff --git a/arch/x86/include/asm/cacheflush.h b/arch/x86/include/asm/cacheflush.h
> index 872877d..33ae60a 100644
> --- a/arch/x86/include/asm/cacheflush.h
> +++ b/arch/x86/include/asm/cacheflush.h
> @@ -12,6 +12,7 @@
>   * Executability : eXeutable, NoteXecutable
>   * Read/Write    : ReadOnly, ReadWrite
>   * Presence      : NotPresent
> + * Encryption    : Encrypted, Decrypted
>   *
>   * Within a category, the attributes are mutually exclusive.
>   *
> @@ -47,6 +48,8 @@
>  int set_memory_rw(unsigned long addr, int numpages);
>  int set_memory_np(unsigned long addr, int numpages);
>  int set_memory_4k(unsigned long addr, int numpages);
> +int set_memory_encrypted(unsigned long addr, int numpages);
> +int set_memory_decrypted(unsigned long addr, int numpages);
>  
>  int set_memory_array_uc(unsigned long *addr, int addrinarray);
>  int set_memory_array_wc(unsigned long *addr, int addrinarray);
> diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
> index 91c5c63..9710f5c 100644
> --- a/arch/x86/mm/pageattr.c
> +++ b/arch/x86/mm/pageattr.c
> @@ -1742,6 +1742,72 @@ int set_memory_4k(unsigned long addr, int numpages)
>  					__pgprot(0), 1, 0, NULL);
>  }
>  
> +static int __set_memory_enc_dec(unsigned long addr, int numpages, bool enc)
> +{
> +	struct cpa_data cpa;
> +	unsigned long start;
> +	int ret;
> +
> +	/* Nothing to do if the _PAGE_ENC attribute is zero */
> +	if (_PAGE_ENC == 0)

Why not:

	if (!sme_active())

?

> +		return 0;
> +
> +	/* Save original start address since it will be modified */

That's obvious - it is a small-enough function to fit on the screen. No
need for the comment.

> +	start = addr;
> +
> +	memset(&cpa, 0, sizeof(cpa));
> +	cpa.vaddr = &addr;
> +	cpa.numpages = numpages;
> +	cpa.mask_set = enc ? __pgprot(_PAGE_ENC) : __pgprot(0);
> +	cpa.mask_clr = enc ? __pgprot(0) : __pgprot(_PAGE_ENC);
> +	cpa.pgd = init_mm.pgd;
> +
> +	/* Should not be working on unaligned addresses */
> +	if (WARN_ONCE(*cpa.vaddr & ~PAGE_MASK,
> +		      "misaligned address: %#lx\n", *cpa.vaddr))

Use addr here so that you don't have to deref. gcc is probably smart
enough but the code should look more readable this way too.

> +		*cpa.vaddr &= PAGE_MASK;

I know, you must use cpa.vaddr here but if you move that alignment check
over the cpa assignment, you can use addr solely.

> +
> +	/* Must avoid aliasing mappings in the highmem code */
> +	kmap_flush_unused();
> +	vm_unmap_aliases();
> +
> +	/*
> +	 * Before changing the encryption attribute, we need to flush caches.
> +	 */
> +	if (static_cpu_has(X86_FEATURE_CLFLUSH))
> +		cpa_flush_range(start, numpages, 1);
> +	else
> +		cpa_flush_all(1);

I guess we don't really need the distinction since a SME CPU most
definitely implies CLFLUSH support but ok, let's be careful.

> +
> +	ret = __change_page_attr_set_clr(&cpa, 1);
> +
> +	/*
> +	 * After changing the encryption attribute, we need to flush TLBs
> +	 * again in case any speculative TLB caching occurred (but no need
> +	 * to flush caches again).  We could just use cpa_flush_all(), but
> +	 * in case TLB flushing gets optimized in the cpa_flush_range()
> +	 * path use the same logic as above.
> +	 */
> +	if (static_cpu_has(X86_FEATURE_CLFLUSH))
> +		cpa_flush_range(start, numpages, 0);
> +	else
> +		cpa_flush_all(0);
> +
> +	return ret;
> +}

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
