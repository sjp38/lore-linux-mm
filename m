Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 78BE16B0003
	for <linux-mm@kvack.org>; Wed, 30 May 2018 01:50:38 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id o24-v6so13094949ioa.20
        for <linux-mm@kvack.org>; Tue, 29 May 2018 22:50:38 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id n82-v6si11918125ita.142.2018.05.29.22.50.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 22:50:37 -0700 (PDT)
Date: Tue, 29 May 2018 22:50:33 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 11/34] iomap: move IOMAP_F_BOUNDARY to gfs2
Message-ID: <20180530055033.GZ30110@magnolia>
References: <20180523144357.18985-1-hch@lst.de>
 <20180523144357.18985-12-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523144357.18985-12-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cluster-devel@redhat.com

On Wed, May 23, 2018 at 04:43:34PM +0200, Christoph Hellwig wrote:
> Just define a range of fs specific flags and use that in gfs2 instead of
> exposing this internal flag flobally.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Looks ok to me, but better if the gfs2 folks [cc'd now] ack this...
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> ---
>  fs/gfs2/bmap.c        | 8 +++++---
>  include/linux/iomap.h | 9 +++++++--
>  2 files changed, 12 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/gfs2/bmap.c b/fs/gfs2/bmap.c
> index cbeedd3cfb36..8efa6297e19c 100644
> --- a/fs/gfs2/bmap.c
> +++ b/fs/gfs2/bmap.c
> @@ -683,6 +683,8 @@ static void gfs2_stuffed_iomap(struct inode *inode, struct iomap *iomap)
>  	iomap->type = IOMAP_INLINE;
>  }
>  
> +#define IOMAP_F_GFS2_BOUNDARY IOMAP_F_PRIVATE
> +
>  /**
>   * gfs2_iomap_begin - Map blocks from an inode to disk blocks
>   * @inode: The inode
> @@ -774,7 +776,7 @@ int gfs2_iomap_begin(struct inode *inode, loff_t pos, loff_t length,
>  	bh = mp.mp_bh[ip->i_height - 1];
>  	len = gfs2_extent_length(bh->b_data, bh->b_size, ptr, lend - lblock, &eob);
>  	if (eob)
> -		iomap->flags |= IOMAP_F_BOUNDARY;
> +		iomap->flags |= IOMAP_F_GFS2_BOUNDARY;
>  	iomap->length = (u64)len << inode->i_blkbits;
>  
>  out_release:
> @@ -846,12 +848,12 @@ int gfs2_block_map(struct inode *inode, sector_t lblock,
>  
>  	if (iomap.length > bh_map->b_size) {
>  		iomap.length = bh_map->b_size;
> -		iomap.flags &= ~IOMAP_F_BOUNDARY;
> +		iomap.flags &= ~IOMAP_F_GFS2_BOUNDARY;
>  	}
>  	if (iomap.addr != IOMAP_NULL_ADDR)
>  		map_bh(bh_map, inode->i_sb, iomap.addr >> inode->i_blkbits);
>  	bh_map->b_size = iomap.length;
> -	if (iomap.flags & IOMAP_F_BOUNDARY)
> +	if (iomap.flags & IOMAP_F_GFS2_BOUNDARY)
>  		set_buffer_boundary(bh_map);
>  	if (iomap.flags & IOMAP_F_NEW)
>  		set_buffer_new(bh_map);
> diff --git a/include/linux/iomap.h b/include/linux/iomap.h
> index 13d19b4c29a9..819e0cd2a950 100644
> --- a/include/linux/iomap.h
> +++ b/include/linux/iomap.h
> @@ -27,8 +27,7 @@ struct vm_fault;
>   * written data and requires fdatasync to commit them to persistent storage.
>   */
>  #define IOMAP_F_NEW		0x01	/* blocks have been newly allocated */
> -#define IOMAP_F_BOUNDARY	0x02	/* mapping ends at metadata boundary */
> -#define IOMAP_F_DIRTY		0x04	/* uncommitted metadata */
> +#define IOMAP_F_DIRTY		0x02	/* uncommitted metadata */
>  
>  /*
>   * Flags that only need to be reported for IOMAP_REPORT requests:
> @@ -36,6 +35,12 @@ struct vm_fault;
>  #define IOMAP_F_MERGED		0x10	/* contains multiple blocks/extents */
>  #define IOMAP_F_SHARED		0x20	/* block shared with another file */
>  
> +/*
> + * Flags from 0x1000 up are for file system specific usage:
> + */
> +#define IOMAP_F_PRIVATE		0x1000
> +
> +
>  /*
>   * Magic value for addr:
>   */
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
