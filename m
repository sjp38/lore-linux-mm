Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 993658D0001
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 17:33:48 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so684494pad.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 14:33:47 -0800 (PST)
Date: Wed, 14 Nov 2012 14:33:44 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5 03/11] thp: copy_huge_pmd(): copy huge zero page
In-Reply-To: <1352300463-12627-4-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.00.1211141433150.13515@chino.kir.corp.google.com>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com> <1352300463-12627-4-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

On Wed, 7 Nov 2012, Kirill A. Shutemov wrote:

> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index ff834ea..0d903bf 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -701,6 +701,18 @@ static inline struct page *alloc_hugepage(int defrag)
>  }
>  #endif
>  
> +static void set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
> +		struct vm_area_struct *vma, unsigned long haddr, pmd_t *pmd)
> +{
> +	pmd_t entry;
> +	entry = pfn_pmd(huge_zero_pfn, vma->vm_page_prot);
> +	entry = pmd_wrprotect(entry);
> +	entry = pmd_mkhuge(entry);
> +	set_pmd_at(mm, haddr, pmd, entry);
> +	pgtable_trans_huge_deposit(mm, pgtable);
> +	mm->nr_ptes++;
> +}
> +
>  int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  			       unsigned long address, pmd_t *pmd,
>  			       unsigned int flags)
> @@ -778,6 +790,11 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  		pte_free(dst_mm, pgtable);
>  		goto out_unlock;
>  	}
> +	if (is_huge_zero_pmd(pmd)) {
> +		set_huge_zero_page(pgtable, dst_mm, vma, addr, dst_pmd);
> +		ret = 0;
> +		goto out_unlock;
> +	}

You said in the introduction message in this series that you still allow 
splitting of the pmd, so why no check for pmd_trans_splitting() before 
this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
