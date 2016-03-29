Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 69A5F6B007E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 04:35:15 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id p65so15281959wmp.0
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 01:35:15 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id f70si15321246wmd.99.2016.03.29.01.35.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Mar 2016 01:35:14 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id p65so3062075wmp.1
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 01:35:14 -0700 (PDT)
Date: Tue, 29 Mar 2016 10:35:10 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC PATCH 2/2] x86/hugetlb: Attempt PUD_SIZE mapping alignment
 if PMD sharing enabled
Message-ID: <20160329083510.GA27941@gmail.com>
References: <1459213970-17957-1-git-send-email-mike.kravetz@oracle.com>
 <1459213970-17957-3-git-send-email-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459213970-17957-3-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steve Capper <steve.capper@linaro.org>, Andrew Morton <akpm@linux-foundation.org>


* Mike Kravetz <mike.kravetz@oracle.com> wrote:

> When creating a hugetlb mapping, attempt PUD_SIZE alignment if the
> following conditions are met:
> - Address passed to mmap or shmat is NULL
> - The mapping is flaged as shared
> - The mapping is at least PUD_SIZE in length
> If a PUD_SIZE aligned mapping can not be created, then fall back to a
> huge page size mapping.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  arch/x86/mm/hugetlbpage.c | 64 ++++++++++++++++++++++++++++++++++++++++++++---
>  1 file changed, 61 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
> index 42982b2..4f53af5 100644
> --- a/arch/x86/mm/hugetlbpage.c
> +++ b/arch/x86/mm/hugetlbpage.c
> @@ -78,14 +78,39 @@ static unsigned long hugetlb_get_unmapped_area_bottomup(struct file *file,
>  {
>  	struct hstate *h = hstate_file(file);
>  	struct vm_unmapped_area_info info;
> +	bool pud_size_align = false;
> +	unsigned long ret_addr;
> +
> +	/*
> +	 * If PMD sharing is enabled, align to PUD_SIZE to facilitate
> +	 * sharing.  Only attempt alignment if no address was passed in,
> +	 * flags indicate sharing and size is big enough.
> +	 */
> +	if (IS_ENABLED(CONFIG_ARCH_WANT_HUGE_PMD_SHARE) &&
> +	    !addr && flags & MAP_SHARED && len >= PUD_SIZE)
> +		pud_size_align = true;
>  
>  	info.flags = 0;
>  	info.length = len;
>  	info.low_limit = current->mm->mmap_legacy_base;
>  	info.high_limit = TASK_SIZE;
> -	info.align_mask = PAGE_MASK & ~huge_page_mask(h);
> +	if (pud_size_align)
> +		info.align_mask = PAGE_MASK & (PUD_SIZE - 1);
> +	else
> +		info.align_mask = PAGE_MASK & ~huge_page_mask(h);
>  	info.align_offset = 0;
> -	return vm_unmapped_area(&info);
> +	ret_addr = vm_unmapped_area(&info);
> +
> +	/*
> +	 * If failed with PUD_SIZE alignment, try again with huge page
> +	 * size alignment.
> +	 */
> +	if ((ret_addr & ~PAGE_MASK) && pud_size_align) {
> +		info.align_mask = PAGE_MASK & ~huge_page_mask(h);
> +		ret_addr = vm_unmapped_area(&info);
> +	}

So AFAICS 'ret_addr' is either page aligned, or is an error code. Wouldn't it be a 
lot easier to read to say:

	if ((long)ret_addr > 0 && pud_size_align) {
		info.align_mask = PAGE_MASK & ~huge_page_mask(h);
		ret_addr = vm_unmapped_area(&info);
	}

	return ret_addr;

to make it clear that it's about error handling, not some alignment 
requirement/restriction?

>  	/*
> +	 * If failed with PUD_SIZE alignment, try again with huge page
> +	 * size alignment.
> +	 */
> +	if ((addr & ~PAGE_MASK) && pud_size_align) {
> +		info.align_mask = PAGE_MASK & ~huge_page_mask(h);
> +		addr = vm_unmapped_area(&info);
> +	}

Ditto.

>  		addr = vm_unmapped_area(&info);
> +
> +		/*
> +		 * If failed again with PUD_SIZE alignment, finally try with
> +		 * huge page size alignment.
> +		 */
> +		if (addr & ~PAGE_MASK) {
> +			info.align_mask = PAGE_MASK & ~huge_page_mask(h);
> +			addr = vm_unmapped_area(&info);

Ditto.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
