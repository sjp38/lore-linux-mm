Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 35FE2280276
	for <linux-mm@kvack.org>; Fri, 23 Dec 2016 08:45:02 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id xr1so70980927wjb.7
        for <linux-mm@kvack.org>; Fri, 23 Dec 2016 05:45:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n4si32074684wmn.72.2016.12.23.05.45.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Dec 2016 05:45:00 -0800 (PST)
Date: Fri, 23 Dec 2016 14:44:57 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 2/4] dax: add stub for pmdp_huge_clear_flush()
Message-ID: <20161223134457.GG22679@quack2.suse.cz>
References: <1482441536-14550-1-git-send-email-ross.zwisler@linux.intel.com>
 <1482441536-14550-3-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1482441536-14550-3-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Thu 22-12-16 14:18:54, Ross Zwisler wrote:
> Add a pmdp_huge_clear_flush() stub for configs that don't define
> CONFIG_TRANSPARENT_HUGEPAGE.
> 
> We use a WARN_ON_ONCE() instead of a BUILD_BUG() because in the DAX code at
> least we do want this compile successfully even for configs without
> CONFIG_TRANSPARENT_HUGEPAGE.  It'll be a runtime decision whether we call
> this code gets called, based on whether we find DAX PMD entries in our
> tree.  We shouldn't ever find such PMD entries for
> !CONFIG_TRANSPARENT_HUGEPAGE configs, so this function should never be
> called.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  include/asm-generic/pgtable.h | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index 18af2bc..65e9536 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -178,9 +178,19 @@ extern pte_t ptep_clear_flush(struct vm_area_struct *vma,
>  #endif
>  
>  #ifndef __HAVE_ARCH_PMDP_HUGE_CLEAR_FLUSH
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  extern pmd_t pmdp_huge_clear_flush(struct vm_area_struct *vma,
>  			      unsigned long address,
>  			      pmd_t *pmdp);
> +#else
> +static inline pmd_t pmdp_huge_clear_flush(struct vm_area_struct *vma,
> +			      unsigned long address,
> +			      pmd_t *pmdp)
> +{
> +	WARN_ON_ONCE(1);
> +	return *pmdp;
> +}
> +#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>  #endif
>  
>  #ifndef __HAVE_ARCH_PTEP_SET_WRPROTECT
> -- 
> 2.7.4
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
