Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3D9466B0038
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 12:09:14 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so7520593pad.2
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 09:09:13 -0700 (PDT)
Date: Mon, 7 Oct 2013 12:09:09 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCHv5 11/11] x86, mm: enable split page table lock for PMD
 level
Message-ID: <20131007160909.GA15214@home.goodmis.org>
References: <1381154053-4848-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1381154053-4848-12-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1381154053-4848-12-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Oct 07, 2013 at 04:54:13PM +0300, Kirill A. Shutemov wrote:
>  
>  config ARCH_HIBERNATION_HEADER
> diff --git a/arch/x86/include/asm/pgalloc.h b/arch/x86/include/asm/pgalloc.h
> index b4389a468f..e2fb2b6934 100644
> --- a/arch/x86/include/asm/pgalloc.h
> +++ b/arch/x86/include/asm/pgalloc.h
> @@ -80,12 +80,21 @@ static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
>  #if PAGETABLE_LEVELS > 2
>  static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
>  {
> -	return (pmd_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
> +	struct page *page;
> +	page = alloc_pages(GFP_KERNEL | __GFP_REPEAT| __GFP_ZERO, 0);
> +	if (!page)
> +		return NULL;
> +	if (!pgtable_pmd_page_ctor(page)) {
> +		__free_pages(page, 0);
> +		return NULL;

Thanks for thinking about us -rt folks :-)

Yeah, this is good, as we can't put the lock into the page table.

Consider this and the previous patch:

Reviewed-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve

> +	}
> +	return (pmd_t *)page_address(page);
>  }
>  
>  static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
>  {
>  	BUG_ON((unsigned long)pmd & (PAGE_SIZE-1));
> +	pgtable_pmd_page_dtor(virt_to_page(pmd));
>  	free_page((unsigned long)pmd);
>  }
>  
> -- 
> 1.8.4.rc3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
