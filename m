Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id D88916B025C
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 12:46:22 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id 124so34265770pfg.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 09:46:22 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id 10si44308727pfk.172.2016.02.29.09.46.21
        for <linux-mm@kvack.org>;
        Mon, 29 Feb 2016 09:46:21 -0800 (PST)
Date: Mon, 29 Feb 2016 10:46:03 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 1/3] DAX: move RADIX_DAX_ definitions to dax.c
Message-ID: <20160229174603.GA13447@linux.intel.com>
References: <145663588892.3865.9987439671424028216.stgit@notabene>
 <145663616971.3865.212066814876758706.stgit@notabene>
 <100D68C7BA14664A8938383216E40DE0421D3AB4@FMSMSX114.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <100D68C7BA14664A8938383216E40DE0421D3AB4@FMSMSX114.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>
Cc: NeilBrown <neilb@suse.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Feb 29, 2016 at 02:28:46PM +0000, Wilcox, Matthew R wrote:
> I agree with this patch, but it's already part of the patchset that I'm
> working on, so merging this patch now would just introduce churn for me.
> 
> -----Original Message-----
> From: NeilBrown [mailto:neilb@suse.com] 
> Sent: Saturday, February 27, 2016 9:09 PM
> To: Ross Zwisler; Wilcox, Matthew R; Andrew Morton; Jan Kara
> Cc: linux-kernel@vger.kernel.org; linux-fsdevel@vger.kernel.org; linux-mm@kvack.org
> Subject: [PATCH 1/3] DAX: move RADIX_DAX_ definitions to dax.c
> 
> These don't belong in radix-tree.c any more than PAGECACHE_TAG_* do.
> Let's try to maintain the idea that radix-tree simply implements an
> abstract data type.

Looks good.  I'm fine with this change, whether it happens via this standalone
patch or via Matthew's larger change set.

> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  fs/dax.c                   |    9 +++++++++
>  include/linux/radix-tree.h |    9 ---------
>  2 files changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index 711172450da6..9c4d697fb6fc 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -32,6 +32,15 @@
>  #include <linux/pfn_t.h>
>  #include <linux/sizes.h>
>  
> +#define RADIX_DAX_MASK	0xf
> +#define RADIX_DAX_SHIFT	4
> +#define RADIX_DAX_PTE  (0x4 | RADIX_TREE_EXCEPTIONAL_ENTRY)
> +#define RADIX_DAX_PMD  (0x8 | RADIX_TREE_EXCEPTIONAL_ENTRY)
> +#define RADIX_DAX_TYPE(entry) ((unsigned long)entry & RADIX_DAX_MASK)
> +#define RADIX_DAX_SECTOR(entry) (((unsigned long)entry >> RADIX_DAX_SHIFT))
> +#define RADIX_DAX_ENTRY(sector, pmd) ((void *)((unsigned long)sector << \
> +		RADIX_DAX_SHIFT | (pmd ? RADIX_DAX_PMD : RADIX_DAX_PTE)))
> +
>  static long dax_map_atomic(struct block_device *bdev, struct blk_dax_ctl *dax)
>  {
>  	struct request_queue *q = bdev->bd_queue;
> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> index f54be7082207..968150ab8a1c 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -51,15 +51,6 @@
>  #define RADIX_TREE_EXCEPTIONAL_ENTRY	2
>  #define RADIX_TREE_EXCEPTIONAL_SHIFT	2
>  
> -#define RADIX_DAX_MASK	0xf
> -#define RADIX_DAX_SHIFT	4
> -#define RADIX_DAX_PTE  (0x4 | RADIX_TREE_EXCEPTIONAL_ENTRY)
> -#define RADIX_DAX_PMD  (0x8 | RADIX_TREE_EXCEPTIONAL_ENTRY)
> -#define RADIX_DAX_TYPE(entry) ((unsigned long)entry & RADIX_DAX_MASK)
> -#define RADIX_DAX_SECTOR(entry) (((unsigned long)entry >> RADIX_DAX_SHIFT))
> -#define RADIX_DAX_ENTRY(sector, pmd) ((void *)((unsigned long)sector << \
> -		RADIX_DAX_SHIFT | (pmd ? RADIX_DAX_PMD : RADIX_DAX_PTE)))
> -
>  static inline int radix_tree_is_indirect_ptr(void *ptr)
>  {
>  	return (int)((unsigned long)ptr & RADIX_TREE_INDIRECT_PTR);
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
