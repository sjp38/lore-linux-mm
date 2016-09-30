Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 25C0A6B0038
	for <linux-mm@kvack.org>; Fri, 30 Sep 2016 05:56:36 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id bv10so188634171pad.2
        for <linux-mm@kvack.org>; Fri, 30 Sep 2016 02:56:36 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id e79si19420910pfb.162.2016.09.30.02.56.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Sep 2016 02:56:35 -0700 (PDT)
Date: Fri, 30 Sep 2016 02:56:27 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v4 10/12] dax: add struct iomap based DAX PMD support
Message-ID: <20160930095627.GB5299@infradead.org>
References: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com>
 <1475189370-31634-11-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1475189370-31634-11-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, linux-xfs@vger.kernel.org

> -/*
> - * We use lowest available bit in exceptional entry for locking, other two
> - * bits to determine entry type. In total 3 special bits.
> - */
> -#define RADIX_DAX_SHIFT	(RADIX_TREE_EXCEPTIONAL_SHIFT + 3)
> -#define RADIX_DAX_PTE (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 1))
> -#define RADIX_DAX_PMD (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 2))
> -#define RADIX_DAX_TYPE_MASK (RADIX_DAX_PTE | RADIX_DAX_PMD)
> -#define RADIX_DAX_TYPE(entry) ((unsigned long)entry & RADIX_DAX_TYPE_MASK)
> -#define RADIX_DAX_SECTOR(entry) (((unsigned long)entry >> RADIX_DAX_SHIFT))
> -#define RADIX_DAX_ENTRY(sector, pmd) ((void *)((unsigned long)sector << \
> -		RADIX_DAX_SHIFT | (pmd ? RADIX_DAX_PMD : RADIX_DAX_PTE) | \
> -		RADIX_TREE_EXCEPTIONAL_ENTRY))
> -

Please split the move of these constants into a separate patch.

> -static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index)
> +static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
> +		unsigned long new_type)
>  {
> +	bool pmd_downgrade = false; /* splitting 2MiB entry into 4k entries? */
>  	void *entry, **slot;
>  
>  restart:
>  	spin_lock_irq(&mapping->tree_lock);
>  	entry = get_unlocked_mapping_entry(mapping, index, &slot);
> +
> +	if (entry && new_type == RADIX_DAX_PMD) {
> +		if (!radix_tree_exceptional_entry(entry) ||
> +				RADIX_DAX_TYPE(entry) == RADIX_DAX_PTE) {
> +			spin_unlock_irq(&mapping->tree_lock);
> +			return ERR_PTR(-EEXIST);
> +		}
> +	} else if (entry && new_type == RADIX_DAX_PTE) {
> +		if (radix_tree_exceptional_entry(entry) &&
> +		    RADIX_DAX_TYPE(entry) == RADIX_DAX_PMD &&
> +		    (unsigned long)entry & (RADIX_DAX_HZP|RADIX_DAX_EMPTY)) {
> +			pmd_downgrade = true;
> +		}
> +	}

	Would be nice to use switch on the type here:

	old_type = RADIX_DAX_TYPE(entry);

	if (entry) {
		switch (new_type) {
		case RADIX_DAX_PMD:
			if (!radix_tree_exceptional_entry(entry) ||
			    oldentry == RADIX_DAX_PTE) {
			    	entry = ERR_PTR(-EEXIST);
				goto out_unlock;
			}
			break;
		case RADIX_DAX_PTE:
			if (radix_tree_exceptional_entry(entry) &&
			    old_entry = RADIX_DAX_PMD &&
			    (unsigned long)entry & 
			      (RADIX_DAX_HZP|RADIX_DAX_EMPTY))
			      	..

Btw, why are only RADIX_DAX_PTE and RADIX_DAX_PMD in the type mask,
and not RADIX_DAX_HZP and RADIX_DAX_EMPTY?  With that we could use the
above old_entry local variable over this function and make it a lot les
of a mess.

>  static void *dax_insert_mapping_entry(struct address_space *mapping,
>  				      struct vm_fault *vmf,
> -				      void *entry, sector_t sector)
> +				      void *entry, sector_t sector,
> +				      unsigned long new_type, bool hzp)

And then we could also drop the hzp argument here..

>  #ifdef CONFIG_FS_IOMAP
> +static inline sector_t dax_iomap_sector(struct iomap *iomap, loff_t pos)
> +{
> +	return iomap->blkno + (((pos & PAGE_MASK) - iomap->offset) >> 9);
> +}

Please split adding this new helper into a separate patch.

> +#if defined(CONFIG_FS_DAX_PMD)

Please use #ifdef here.

> +#define RADIX_DAX_TYPE(entry) ((unsigned long)entry & RADIX_DAX_TYPE_MASK)
> +#define RADIX_DAX_SECTOR(entry) (((unsigned long)entry >> RADIX_DAX_SHIFT))
> +
> +/* entries begin locked */
> +#define RADIX_DAX_ENTRY(sector, type) ((void *)(RADIX_TREE_EXCEPTIONAL_ENTRY |\
> +	type | (unsigned long)sector << RADIX_DAX_SHIFT | RADIX_DAX_ENTRY_LOCK))
> +#define RADIX_DAX_HZP_ENTRY() ((void *)(RADIX_TREE_EXCEPTIONAL_ENTRY | \
> +	RADIX_DAX_PMD | RADIX_DAX_HZP | RADIX_DAX_EMPTY | RADIX_DAX_ENTRY_LOCK))
> +#define RADIX_DAX_EMPTY_ENTRY(type) ((void *)(RADIX_TREE_EXCEPTIONAL_ENTRY | \
> +		type | RADIX_DAX_EMPTY | RADIX_DAX_ENTRY_LOCK))
> +
> +#define RADIX_DAX_ORDER(type) (type == RADIX_DAX_PMD ? PMD_SHIFT-PAGE_SHIFT : 0)

All these macros don't properly brace their arguments.  I think
you'd make your life a lot easier by making them inline functions.

> +#if defined(CONFIG_FS_DAX_PMD)

#ifdef, please

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
