Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 42B4A6B0073
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 01:21:53 -0400 (EDT)
Date: Fri, 19 Apr 2013 07:16:15 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 16/18] ext4: update ext4_ext_remove_space trace point
Message-ID: <20130419051615.GG19244@quack.suse.cz>
References: <1365498867-27782-1-git-send-email-lczerner@redhat.com>
 <1365498867-27782-17-git-send-email-lczerner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365498867-27782-17-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukas Czerner <lczerner@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org

On Tue 09-04-13 11:14:25, Lukas Czerner wrote:
> Add "end" variable.
> 
> Signed-off-by: Lukas Czerner <lczerner@redhat.com>
  You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/ext4/extents.c           |    6 +++---
>  include/trace/events/ext4.h |   21 ++++++++++++++-------
>  2 files changed, 17 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/ext4/extents.c b/fs/ext4/extents.c
> index 4adaa8a..9023b76 100644
> --- a/fs/ext4/extents.c
> +++ b/fs/ext4/extents.c
> @@ -2666,7 +2666,7 @@ int ext4_ext_remove_space(struct inode *inode, ext4_lblk_t start,
>  		return PTR_ERR(handle);
>  
>  again:
> -	trace_ext4_ext_remove_space(inode, start, depth);
> +	trace_ext4_ext_remove_space(inode, start, end, depth);
>  
>  	/*
>  	 * Check if we are removing extents inside the extent tree. If that
> @@ -2832,8 +2832,8 @@ again:
>  		}
>  	}
>  
> -	trace_ext4_ext_remove_space_done(inode, start, depth, partial_cluster,
> -			path->p_hdr->eh_entries);
> +	trace_ext4_ext_remove_space_done(inode, start, end, depth,
> +			partial_cluster, path->p_hdr->eh_entries);
>  
>  	/* If we still have something in the partial cluster and we have removed
>  	 * even the first extent, then we should free the blocks in the partial
> diff --git a/include/trace/events/ext4.h b/include/trace/events/ext4.h
> index 60b329a..c92500c 100644
> --- a/include/trace/events/ext4.h
> +++ b/include/trace/events/ext4.h
> @@ -2027,14 +2027,16 @@ TRACE_EVENT(ext4_ext_rm_idx,
>  );
>  
>  TRACE_EVENT(ext4_ext_remove_space,
> -	TP_PROTO(struct inode *inode, ext4_lblk_t start, int depth),
> +	TP_PROTO(struct inode *inode, ext4_lblk_t start,
> +		 ext4_lblk_t end, int depth),
>  
> -	TP_ARGS(inode, start, depth),
> +	TP_ARGS(inode, start, end, depth),
>  
>  	TP_STRUCT__entry(
>  		__field(	dev_t,		dev	)
>  		__field(	ino_t,		ino	)
>  		__field(	ext4_lblk_t,	start	)
> +		__field(	ext4_lblk_t,	end	)
>  		__field(	int,		depth	)
>  	),
>  
> @@ -2042,26 +2044,29 @@ TRACE_EVENT(ext4_ext_remove_space,
>  		__entry->dev	= inode->i_sb->s_dev;
>  		__entry->ino	= inode->i_ino;
>  		__entry->start	= start;
> +		__entry->end	= end;
>  		__entry->depth	= depth;
>  	),
>  
> -	TP_printk("dev %d,%d ino %lu since %u depth %d",
> +	TP_printk("dev %d,%d ino %lu start %u end %u depth %d",
>  		  MAJOR(__entry->dev), MINOR(__entry->dev),
>  		  (unsigned long) __entry->ino,
>  		  (unsigned) __entry->start,
> +		  (unsigned) __entry->end,
>  		  __entry->depth)
>  );
>  
>  TRACE_EVENT(ext4_ext_remove_space_done,
> -	TP_PROTO(struct inode *inode, ext4_lblk_t start, int depth,
> -		ext4_lblk_t partial, unsigned short eh_entries),
> +	TP_PROTO(struct inode *inode, ext4_lblk_t start, ext4_lblk_t end,
> +		 int depth, ext4_lblk_t partial, unsigned short eh_entries),
>  
> -	TP_ARGS(inode, start, depth, partial, eh_entries),
> +	TP_ARGS(inode, start, end, depth, partial, eh_entries),
>  
>  	TP_STRUCT__entry(
>  		__field(	dev_t,		dev		)
>  		__field(	ino_t,		ino		)
>  		__field(	ext4_lblk_t,	start		)
> +		__field(	ext4_lblk_t,	end		)
>  		__field(	int,		depth		)
>  		__field(	ext4_lblk_t,	partial		)
>  		__field(	unsigned short,	eh_entries	)
> @@ -2071,16 +2076,18 @@ TRACE_EVENT(ext4_ext_remove_space_done,
>  		__entry->dev		= inode->i_sb->s_dev;
>  		__entry->ino		= inode->i_ino;
>  		__entry->start		= start;
> +		__entry->end		= end;
>  		__entry->depth		= depth;
>  		__entry->partial	= partial;
>  		__entry->eh_entries	= eh_entries;
>  	),
>  
> -	TP_printk("dev %d,%d ino %lu since %u depth %d partial %u "
> +	TP_printk("dev %d,%d ino %lu start %u end %u depth %d partial %u "
>  		  "remaining_entries %u",
>  		  MAJOR(__entry->dev), MINOR(__entry->dev),
>  		  (unsigned long) __entry->ino,
>  		  (unsigned) __entry->start,
> +		  (unsigned) __entry->end,
>  		  __entry->depth,
>  		  (unsigned) __entry->partial,
>  		  (unsigned short) __entry->eh_entries)
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
