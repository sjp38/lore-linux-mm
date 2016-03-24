Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7D15B6B0005
	for <linux-mm@kvack.org>; Thu, 24 Mar 2016 08:11:05 -0400 (EDT)
Received: by mail-pf0-f169.google.com with SMTP id u190so55778890pfb.3
        for <linux-mm@kvack.org>; Thu, 24 Mar 2016 05:11:05 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id e72si11911159pfb.126.2016.03.24.05.11.04
        for <linux-mm@kvack.org>;
        Thu, 24 Mar 2016 05:11:04 -0700 (PDT)
Message-ID: <1458821494.7860.9.camel@linux.intel.com>
Subject: Re: [Intel-gfx] [PATCH 1/2] shmem: Support for registration of
 Driver/file owner specific ops
From: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Date: Thu, 24 Mar 2016 14:11:34 +0200
In-Reply-To: <1458713384-25688-1-git-send-email-akash.goel@intel.com>
References: <1458713384-25688-1-git-send-email-akash.goel@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akash.goel@intel.com, intel-gfx@lists.freedesktop.org
Cc: linux-mm@kvack.org, Sourab Gupta <sourab.gupta@intel.com>, Hugh Dickins <hughd@google.com>

On ke, 2016-03-23 at 11:39 +0530, akash.goel@intel.com wrote:
> From: Chris Wilson <chris@chris-wilson.co.uk>
> 
> This provides support for the Drivers or shmem file owners to register
> a set of callbacks, which can be invoked from the address space operations
> methods implemented by shmem.
> This allow the file owners to hook into the shmem address space operations
> to do some extra/custom operations in addition to the default ones.
> 
> The private_data field of address_space struct is used to store the pointer
> to driver specific ops.
> Currently only one ops field is defined, which is migratepage, but can be
> extended on need basis.
> 
> The need for driver specific operations arises since some of the operations
> (like migratepage) may not be handled completely within shmem, so as to be
> effective, and would need some driver specific handling also.
> 
> Specifically, i915.ko would like to participate in migratepage().
> i915.ko uses shmemfs to provide swappable backing storage for its user
> objects, but when those objects are in use by the GPU it must pin the entire
> object until the GPU is idle. As a result, large chunks of memory can be
> arbitrarily withdrawn from page migration, resulting in premature
> out-of-memory due to fragmentation. However, if i915.ko can receive the
> migratepage() request, it can then flush the object from the GPU, remove
> its pin and thus enable the migration.
> 
> Since Gfx allocations are one of the major consumer of system memory, its
> imperative to have such a mechanism to effectively deal with fragmentation.
> And therefore the need for such a provision for initiating driver specific
> actions during address space operations.
> 
> Cc: Hugh Dickins <hughd@google.com>
> Cc: linux-mm@kvack.org
> Signed-off-by: Sourab Gupta <sourab.gupta@intel.com>
> Signed-off-by: Akash Goel <akash.goel@intel.com>
> ---
> A include/linux/shmem_fs.h | 17 +++++++++++++++++
> A mm/shmem.cA A A A A A A A A A A A A A A | 17 ++++++++++++++++-
> A 2 files changed, 33 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
> index 4d4780c..6cfa76a 100644
> --- a/include/linux/shmem_fs.h
> +++ b/include/linux/shmem_fs.h
> @@ -34,11 +34,28 @@ struct shmem_sb_info {
> A 	struct mempolicy *mpol;A A A A A /* default memory policy for mappings */
> A };
> A 
> +struct shmem_dev_info {
> +	void *dev_private_data;
> +	int (*dev_migratepage)(struct address_space *mapping,
> +			A A A A A A A struct page *newpage, struct page *page,
> +			A A A A A A A enum migrate_mode mode, void *dev_priv_data);

One might want to have a separate shmem_dev_operations struct or
similar.

> +};
> +
> A static inline struct shmem_inode_info *SHMEM_I(struct inode *inode)
> A {
> A 	return container_of(inode, struct shmem_inode_info, vfs_inode);
> A }
> A 
> +static inline int shmem_set_device_ops(struct address_space *mapping,
> +				struct shmem_dev_info *info)
> +{
> +	if (mapping->private_data != NULL)
> +		return -EEXIST;
> +

I did a quick random peek and most set functions are just void and
override existing data. I'd suggest the same.

> +	mapping->private_data = info;

Also, doesn't this kinda steal the mapping->private_data, might that be
unexpected for the user? I notice currently it's not being touched at
all.

> +	return 0;
> +}
> +
> A /*
> A  * Functions in mm/shmem.c called directly from elsewhere:
> A  */
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 440e2a7..f8625c4 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -952,6 +952,21 @@ redirty:
> A 	return 0;
> A }
> A 
> +#ifdef CONFIG_MIGRATION
> +static int shmem_migratepage(struct address_space *mapping,
> +			A A A A A struct page *newpage, struct page *page,
> +			A A A A A enum migrate_mode mode)
> +{
> +	struct shmem_dev_info *dev_info = mapping->private_data;
> +
> +	if (dev_info && dev_info->dev_migratepage)
> +		return dev_info->dev_migratepage(mapping, newpage, page,
> +				mode, dev_info->dev_private_data);
> +
> +	return migrate_page(mapping, newpage, page, mode);
> +}
> +#endif
> +
> A #ifdef CONFIG_NUMA
> A #ifdef CONFIG_TMPFS
> A static void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
> @@ -3168,7 +3183,7 @@ static const struct address_space_operations shmem_aops = {
> A 	.write_end	= shmem_write_end,
> A #endif
> A #ifdef CONFIG_MIGRATION
> -	.migratepage	= migrate_page,
> +	.migratepage	= shmem_migratepage,
> A #endif
> A 	.error_remove_page = generic_error_remove_page,
> A };
-- 
Joonas Lahtinen
Open Source Technology Center
Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
