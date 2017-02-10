Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id F3CCD6B0389
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 17:14:10 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 189so46296358pfu.0
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 14:14:10 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 1si2856119plw.105.2017.02.10.14.14.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 14:14:10 -0800 (PST)
Date: Fri, 10 Feb 2017 14:13:57 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCHv6 15/37] thp: do not threat slab pages as huge in
 hpage_{nr_pages,size,mask}
Message-ID: <20170210221357.GF2267@bombadil.infradead.org>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
 <20170126115819.58875-16-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170126115819.58875-16-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Thu, Jan 26, 2017 at 02:57:57PM +0300, Kirill A. Shutemov wrote:
> Slab pages can be compound, but we shouldn't threat them as THP for
> pupose of hpage_* helpers, otherwise it would lead to confusing results.
> 
> For instance, ext4 uses slab pages for journal pages and we shouldn't
> confuse them with THPs. The easiest way is to exclude them in hpage_*
> helpers.

Well ... I think we should just deal with compound pages instead of just
huge or regular.  So I'm deferring comment on this patch.

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  include/linux/huge_mm.h | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index e5c9c26d2439..5e6c408f5b47 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -137,21 +137,21 @@ static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
>  }
>  static inline int hpage_nr_pages(struct page *page)
>  {
> -	if (unlikely(PageTransHuge(page)))
> +	if (unlikely(!PageSlab(page) && PageTransHuge(page)))
>  		return HPAGE_PMD_NR;
>  	return 1;
>  }
>  
>  static inline int hpage_size(struct page *page)
>  {
> -	if (unlikely(PageTransHuge(page)))
> +	if (unlikely(!PageSlab(page) && PageTransHuge(page)))
>  		return HPAGE_PMD_SIZE;
>  	return PAGE_SIZE;
>  }
>  
>  static inline unsigned long hpage_mask(struct page *page)
>  {
> -	if (unlikely(PageTransHuge(page)))
> +	if (unlikely(!PageSlab(page) && PageTransHuge(page)))
>  		return HPAGE_PMD_MASK;
>  	return PAGE_MASK;
>  }
> -- 
> 2.11.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
