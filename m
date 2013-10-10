Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id EA8136B003A
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 16:19:23 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kl14so3251874pab.39
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 13:19:23 -0700 (PDT)
Date: Thu, 10 Oct 2013 21:18:05 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 11/34] arm: handle pgtable_page_ctor() fail
Message-ID: <20131010201805.GR25034@n2100.arm.linux.org.uk>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com> <1381428359-14843-12-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1381428359-14843-12-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

So, all I see is this patch, with such a brilliant description which
describes what this change is about, why it is being made, and so
forth, and you're sending it to me, presumably because you want me to
do something with it.  No, not really.

What context do I have to say whether this is correct or not?  How can
I test it when the mainline version of pgtable_page_ctor returns void,
so if I were to apply this patch I'd get compile errors.

Oh, I guess you're changing pgtable_page_ctor() in some way.  What is
the nature of that change?

Please, I'm not a mind reader.  Please ensure that your "generic" patch
of your series reaches the appropriate recipients: if you don't want to
explicitly Cc: all the people individually, please at least copy all
relevant mailing lists found for the entire series.

(No, I am not on the excessively noisy linux-arch: I dropped off it
years ago because it just became yet another mailing list to endlessly
talk mainly about x86 rather than being a separate list to linux-kernel
which discussed problems relevant to many arch maintainers.)

Thanks.

On Thu, Oct 10, 2013 at 09:05:36PM +0300, Kirill A. Shutemov wrote:
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Russell King <linux@arm.linux.org.uk>
> ---
>  arch/arm/include/asm/pgalloc.h | 12 +++++++-----
>  1 file changed, 7 insertions(+), 5 deletions(-)
> 
> diff --git a/arch/arm/include/asm/pgalloc.h b/arch/arm/include/asm/pgalloc.h
> index 943504f53f..78a7793616 100644
> --- a/arch/arm/include/asm/pgalloc.h
> +++ b/arch/arm/include/asm/pgalloc.h
> @@ -102,12 +102,14 @@ pte_alloc_one(struct mm_struct *mm, unsigned long addr)
>  #else
>  	pte = alloc_pages(PGALLOC_GFP, 0);
>  #endif
> -	if (pte) {
> -		if (!PageHighMem(pte))
> -			clean_pte_table(page_address(pte));
> -		pgtable_page_ctor(pte);
> +	if (!pte)
> +		return NULL;
> +	if (!PageHighMem(pte))
> +		clean_pte_table(page_address(pte));
> +	if (!pgtable_page_ctor(pte)) {
> +		__free_page(pte);
> +		return NULL;
>  	}
> -
>  	return pte;
>  }
>  
> -- 
> 1.8.4.rc3
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
