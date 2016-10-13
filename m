Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 506E26B0038
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 11:11:56 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id b75so51098043lfg.3
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 08:11:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x20si18201484wju.228.2016.10.13.08.11.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 13 Oct 2016 08:11:54 -0700 (PDT)
Date: Thu, 13 Oct 2016 17:11:49 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v6 14/17] dax: move put_(un)locked_mapping_entry() in
 dax.c
Message-ID: <20161013151149.GA30680@quack2.suse.cz>
References: <20161012225022.15507-1-ross.zwisler@linux.intel.com>
 <20161012225022.15507-15-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161012225022.15507-15-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Wed 12-10-16 16:50:19, Ross Zwisler wrote:
> No functional change.
> 
> The static functions put_locked_mapping_entry() and
> put_unlocked_mapping_entry() will soon be used in error cases in
> grab_mapping_entry(), so move their definitions above this function.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/dax.c | 50 +++++++++++++++++++++++++-------------------------
>  1 file changed, 25 insertions(+), 25 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index c45cc4d..0582c7c 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -382,6 +382,31 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
>  	}
>  }
>  
> +static void put_locked_mapping_entry(struct address_space *mapping,
> +				     pgoff_t index, void *entry)
> +{
> +	if (!radix_tree_exceptional_entry(entry)) {
> +		unlock_page(entry);
> +		put_page(entry);
> +	} else {
> +		dax_unlock_mapping_entry(mapping, index);
> +	}
> +}
> +
> +/*
> + * Called when we are done with radix tree entry we looked up via
> + * get_unlocked_mapping_entry() and which we didn't lock in the end.
> + */
> +static void put_unlocked_mapping_entry(struct address_space *mapping,
> +				       pgoff_t index, void *entry)
> +{
> +	if (!radix_tree_exceptional_entry(entry))
> +		return;
> +
> +	/* We have to wake up next waiter for the radix tree entry lock */
> +	dax_wake_mapping_entry_waiter(mapping, index, entry, false);
> +}
> +
>  /*
>   * Find radix tree entry at given index. If it points to a page, return with
>   * the page locked. If it points to the exceptional entry, return with the
> @@ -486,31 +511,6 @@ void dax_unlock_mapping_entry(struct address_space *mapping, pgoff_t index)
>  	dax_wake_mapping_entry_waiter(mapping, index, entry, false);
>  }
>  
> -static void put_locked_mapping_entry(struct address_space *mapping,
> -				     pgoff_t index, void *entry)
> -{
> -	if (!radix_tree_exceptional_entry(entry)) {
> -		unlock_page(entry);
> -		put_page(entry);
> -	} else {
> -		dax_unlock_mapping_entry(mapping, index);
> -	}
> -}
> -
> -/*
> - * Called when we are done with radix tree entry we looked up via
> - * get_unlocked_mapping_entry() and which we didn't lock in the end.
> - */
> -static void put_unlocked_mapping_entry(struct address_space *mapping,
> -				       pgoff_t index, void *entry)
> -{
> -	if (!radix_tree_exceptional_entry(entry))
> -		return;
> -
> -	/* We have to wake up next waiter for the radix tree entry lock */
> -	dax_wake_mapping_entry_waiter(mapping, index, entry, false);
> -}
> -
>  /*
>   * Delete exceptional DAX entry at @index from @mapping. Wait for radix tree
>   * entry to get unlocked before deleting it.
> -- 
> 2.9.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
