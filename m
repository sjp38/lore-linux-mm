Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1C3696B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 08:37:50 -0400 (EDT)
Received: by weoy45 with SMTP id y45so12496418weo.2
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 05:37:49 -0700 (PDT)
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id y1si16850338wiw.27.2015.03.24.05.37.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 05:37:48 -0700 (PDT)
Received: by wgdm6 with SMTP id m6so170099819wgd.2
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 05:37:47 -0700 (PDT)
Message-ID: <55115A99.40705@plexistor.com>
Date: Tue, 24 Mar 2015 14:37:45 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] RFC: dax: dax_prepare_freeze
References: <55100B78.501@plexistor.com> <55100D10.6090902@plexistor.com>
In-Reply-To: <55100D10.6090902@plexistor.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>

On 03/23/2015 02:54 PM, Boaz Harrosh wrote:
> From: Boaz Harrosh <boaz@plexistor.com>
> 
> When freezing an FS, we must write protect all IS_DAX()
> inodes that have an mmap mapping on an inode. Otherwise
> application will be able to modify previously faulted-in
> file pages.
> 
> I'm actually doing a full unmap_mapping_range because
> there is no readily available "mapping_write_protect" like
> functionality. I do not think it is worth it to define one
> just for here and just for some extra read-faults after an
> fs_freeze.
> 
> How hot-path is fs_freeze at all?
> 

OK So reinspecting this was a complete raw RFC. I need to do
more work on this thing

comments below ...

> CC: Jan Kara <jack@suse.cz>
> CC: Matthew Wilcox <matthew.r.wilcox@intel.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
> ---
>  fs/dax.c           | 30 ++++++++++++++++++++++++++++++
>  fs/super.c         |  3 +++
>  include/linux/fs.h |  1 +
>  3 files changed, 34 insertions(+)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index d0bd1f4..f3fc28b 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -549,3 +549,33 @@ int dax_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
>  	return dax_zero_page_range(inode, from, length, get_block);
>  }
>  EXPORT_SYMBOL_GPL(dax_truncate_page);
> +
> +/* This is meant to be called as part of freeze_super. otherwise we might
> + * Need some extra locking before calling here.
> + */
> +void dax_prepare_freeze(struct super_block *sb)
> +{
> +	struct inode *inode;
> +
> +	/* TODO: each DAX fs has some private mount option to enable DAX. If
> +	 * We made that option a generic MS_DAX_ENABLE super_block flag we could
> +	 * Avoid the 95% extra unneeded loop-on-all-inodes every freeze.
> +	 * if (!(sb->s_flags & MS_DAX_ENABLE))
> +	 *	return 0;
> +	 */
> +
> +	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
> +		/* TODO: For freezing we can actually do with write-protecting
> +		 * the page. But I cannot find a ready made function that does
> +		 * that for a giving mapping (with all the proper locking).
> +		 * How performance sensitive is the all sb_freeze API?
> +		 * For now we can just unmap the all mapping, and pay extra
> +		 * on read faults.
> +		 */
> +		/* NOTE: Do not unmap private COW mapped pages it will not
> +		 * modify the FS.
> +		 */
> +		if (IS_DAX(inode))
> +			unmap_mapping_range(inode->i_mapping, 0, 0, 0);

So what happens here is that we loop on all sb->s_inodes every freeze
and in the not DAX case just do nothing.

It could be nice to have a flag at the sb level to tel us if we need
to expect IS_DAX() inodes at all, for example when we are mounted on
an harddisk it should not be set.

All of ext2/4 and now Dave's xfs have their own
	XFS_MOUNT_DAX / EXT2_MOUNT_DAX / EXT4_MOUNT_DAX

Is it OK if I unify all this on sb->s_flags |= MS_MOUNT_DAX so I can check it
here in Generic code? The option parsing will be done by each FS but
the flag be global?

> +	}
> +}
> diff --git a/fs/super.c b/fs/super.c
> index 2b7dc90..9ef490c 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -1329,6 +1329,9 @@ int freeze_super(struct super_block *sb)
>  	/* All writers are done so after syncing there won't be dirty data */
>  	sync_filesystem(sb);
>  
> +	/* Need to take care of DAX mmaped inodes */
> +	dax_prepare_freeze(sb);
> +

So if CONFIG_FS_DAX is not set this will not compile I need to
define an empty one if not set

Cheers
Boaz


>  	/* Now wait for internal filesystem counter */
>  	sb->s_writers.frozen = SB_FREEZE_FS;
>  	smp_wmb();
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 24af817..3b943d4 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2599,6 +2599,7 @@ int dax_truncate_page(struct inode *, loff_t from, get_block_t);
>  int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t);
>  int dax_pfn_mkwrite(struct vm_area_struct *, struct vm_fault *);
>  #define dax_mkwrite(vma, vmf, gb)	dax_fault(vma, vmf, gb)
> +void dax_prepare_freeze(struct super_block *sb);
>  
>  #ifdef CONFIG_BLOCK
>  typedef void (dio_submit_t)(int rw, struct bio *bio, struct inode *inode,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
