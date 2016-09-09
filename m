Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5E8D96B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 04:29:37 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g141so8715571wmd.0
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 01:29:37 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x13si1938853wmf.38.2016.09.09.01.29.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Sep 2016 01:29:36 -0700 (PDT)
Date: Fri, 9 Sep 2016 10:29:29 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/3] writeback: introduce super_operations->write_metadata
Message-ID: <20160909082929.GD22777@quack2.suse.cz>
References: <1471887302-12730-1-git-send-email-jbacik@fb.com>
 <1471887302-12730-4-git-send-email-jbacik@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1471887302-12730-4-git-send-email-jbacik@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <jbacik@fb.com>
Cc: linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, jack@suse.com, viro@zeniv.linux.org.uk, dchinner@redhat.com, hch@lst.de, linux-mm@kvack.org

On Mon 22-08-16 13:35:02, Josef Bacik wrote:
> Now that we have metadata counters in the VM, we need to provide a way to kick
> writeback on dirty metadata.  Introduce super_operations->write_metadata.  This
> allows file systems to deal with writing back any dirty metadata we need based
> on the writeback needs of the system.  Since there is no inode to key off of we
> need a list in the bdi for dirty super blocks to be added.  From there we can
> find any dirty sb's on the bdi we are currently doing writeback on and call into
> their ->write_metadata callback.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>
...
> @@ -1639,11 +1664,38 @@ static long __writeback_inodes_wb(struct bdi_writeback *wb,
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
> +		}
> +	}
> +
> +	if (!done && wb_stat(wb, WB_METADATA_DIRTY)) {
> +		LIST_HEAD(list);
> +
> +		spin_unlock(&wb->list_lock);
> +		spin_lock(&wb->bdi->sb_list_lock);
> +		list_splice_init(&wb->bdi->dirty_sb_list, &list);
> +		while (!list_empty(&list)) {
> +			struct super_block *sb;
> +
> +			sb = list_first_entry(&list, struct super_block,
> +					      s_bdi_list);
> +			list_move_tail(&sb->s_bdi_list,
> +				       &wb->bdi->dirty_sb_list);
> +			if (!sb->s_op->write_metadata)
> +				continue;
> +			if (!trylock_super(sb))
> +				continue;
> +			spin_unlock(&wb->bdi->sb_list_lock);
> +			wrote += writeback_sb_metadata(sb, wb, work);
> +			spin_lock(&wb->bdi->sb_list_lock);
> +			up_read(&sb->s_umount);
>  		}
> +		spin_unlock(&wb->bdi->sb_list_lock);
> +		spin_lock(&wb->list_lock);
>  	}
>  	/* Leave any unwritten inodes on b_io */
>  	return wrote;

So this will hook metadata writeback into the periodic writeback but when
work->sb is set, metadata won't be written because in that case we call
writeback_sb_inodes() directly. So you need to call writeback_sb_metadata()
from wb_writeback() in that case as well. 

...

> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index f3f0b4c8..c063ac6 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1430,6 +1430,8 @@ struct super_block {
>  
>  	spinlock_t		s_inode_wblist_lock;
>  	struct list_head	s_inodes_wb;	/* writeback inodes */
> +
> +	struct list_head	s_bdi_list;

Maybe call this s_bdi_dirty_list?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
