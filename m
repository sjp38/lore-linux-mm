Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E8C546B026C
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:21:10 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id s12so7353394plp.11
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 04:21:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p33si11003693pld.453.2017.12.19.04.21.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 04:21:09 -0800 (PST)
Date: Tue, 19 Dec 2017 13:21:04 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 06/10] writeback: introduce
 super_operations->write_metadata
Message-ID: <20171219122104.GF2277@quack2.suse.cz>
References: <1513029335-5112-1-git-send-email-josef@toxicpanda.com>
 <1513029335-5112-7-git-send-email-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513029335-5112-7-git-send-email-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Mon 11-12-17 16:55:31, Josef Bacik wrote:
> @@ -1621,12 +1647,18 @@ static long writeback_sb_inodes(struct super_block *sb,
>  		 * background threshold and other termination conditions.
>  		 */
>  		if (wrote) {
> -			if (time_is_before_jiffies(start_time + HZ / 10UL))
> -				break;
> -			if (work->nr_pages <= 0)
> +			if (time_is_before_jiffies(start_time + HZ / 10UL) ||
> +			    work->nr_pages <= 0) {
> +				done = true;
>  				break;
> +			}
>  		}
>  	}
> +	if (!done && sb->s_op->write_metadata) {
> +		spin_unlock(&wb->list_lock);
> +		wrote += writeback_sb_metadata(sb, wb, work);
> +		spin_lock(&wb->list_lock);
> +	}
>  	return wrote;
>  }

One thing I've notice when looking at this patch again: This duplicates the
metadata writeback done in __writeback_inodes_wb(). So you probably need a
new helper function like writeback_sb() that will call writeback_sb_inodes()
and handle metadata writeback and call that from wb_writeback() instead of
writeback_sb_inodes() directly.

								Honza

> @@ -1635,6 +1667,7 @@ static long __writeback_inodes_wb(struct bdi_writeback *wb,
>  {
>  	unsigned long start_time = jiffies;
>  	long wrote = 0;
> +	bool done = false;
>  
>  	while (!list_empty(&wb->b_io)) {
>  		struct inode *inode = wb_inode(wb->b_io.prev);
> @@ -1654,12 +1687,39 @@ static long __writeback_inodes_wb(struct bdi_writeback *wb,
>  
>  		/* refer to the same tests at the end of writeback_sb_inodes */
>  		if (wrote) {
> -			if (time_is_before_jiffies(start_time + HZ / 10UL))
> -				break;
> -			if (work->nr_pages <= 0)
> +			if (time_is_before_jiffies(start_time + HZ / 10UL) ||
> +			    work->nr_pages <= 0) {
> +				done = true;
>  				break;
> +			}
>  		}
>  	}
> +
> +	if (!done && wb_stat(wb, WB_METADATA_DIRTY_BYTES)) {
> +		LIST_HEAD(list);
> +
> +		spin_unlock(&wb->list_lock);
> +		spin_lock(&wb->bdi->sb_list_lock);
> +		list_splice_init(&wb->bdi->dirty_sb_list, &list);
> +		while (!list_empty(&list)) {
> +			struct super_block *sb;
> +
> +			sb = list_first_entry(&list, struct super_block,
> +					      s_bdi_dirty_list);
> +			list_move_tail(&sb->s_bdi_dirty_list,
> +				       &wb->bdi->dirty_sb_list);
> +			if (!sb->s_op->write_metadata)
> +				continue;
> +			if (!trylock_super(sb))
> +				continue;
> +			spin_unlock(&wb->bdi->sb_list_lock);
> +			wrote += writeback_sb_metadata(sb, wb, work);
> +			spin_lock(&wb->bdi->sb_list_lock);
> +			up_read(&sb->s_umount);
> +		}
> +		spin_unlock(&wb->bdi->sb_list_lock);
> +		spin_lock(&wb->list_lock);
> +	}
>  	/* Leave any unwritten inodes on b_io */
>  	return wrote;
>  }
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
