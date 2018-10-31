Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B8C5B6B0270
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 05:03:03 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i81-v6so13197551pfj.1
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 02:03:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h20-v6sor27058516pgg.78.2018.10.31.02.03.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Oct 2018 02:03:02 -0700 (PDT)
Date: Wed, 31 Oct 2018 12:02:55 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/3] mm: introduce mm_[p4d|pud|pmd]_folded
Message-ID: <20181031090255.bvmp3jnsdaunhzn7@kshutemo-mobl1>
References: <1539621759-5967-1-git-send-email-schwidefsky@de.ibm.com>
 <1539621759-5967-2-git-send-email-schwidefsky@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1539621759-5967-2-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Li Wang <liwang@redhat.com>, Guenter Roeck <linux@roeck-us.net>, Janosch Frank <frankja@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, Oct 15, 2018 at 06:42:37PM +0200, Martin Schwidefsky wrote:
> Add three architecture overrideable function to test if the
> p4d, pud, or pmd layer of a page table is folded or not.
> 
> Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> ---
>  include/linux/mm.h | 40 ++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 40 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0416a7204be3..d1029972541c 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h

Shouldn't it be somewhere in asm-generic/pgtable*?

> @@ -105,6 +105,46 @@ extern int mmap_rnd_compat_bits __read_mostly;
>  #define mm_zero_struct_page(pp)  ((void)memset((pp), 0, sizeof(struct page)))
>  #endif
>  
> +/*
> + * On some architectures it depends on the mm if the p4d/pud or pmd
> + * layer of the page table hierarchy is folded or not.
> + */
> +#ifndef mm_p4d_folded
> +#define mm_p4d_folded(mm) mm_p4d_folded(mm)

Do we need to define it in generic header?

> +static inline bool mm_p4d_folded(struct mm_struct *mm)
> +{
> +#ifdef __PAGETABLE_P4D_FOLDED
> +	return 1;
> +#else
> +	return 0;
> +#endif

Maybe
	return __is_defined(__PAGETABLE_P4D_FOLDED);

?

-- 
 Kirill A. Shutemov
