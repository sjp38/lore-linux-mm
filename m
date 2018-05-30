Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id AB8C56B0003
	for <linux-mm@kvack.org>; Wed, 30 May 2018 01:54:37 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id k21-v6so14732179ioj.19
        for <linux-mm@kvack.org>; Tue, 29 May 2018 22:54:37 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id r81-v6si14480772itc.52.2018.05.29.22.54.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 22:54:36 -0700 (PDT)
Date: Tue, 29 May 2018 22:54:31 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 14/34] iomap: add an iomap-based bmap implementation
Message-ID: <20180530055431.GC30110@magnolia>
References: <20180523144357.18985-1-hch@lst.de>
 <20180523144357.18985-15-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523144357.18985-15-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 23, 2018 at 04:43:37PM +0200, Christoph Hellwig wrote:
> This adds a simple iomap-based implementation of the legacy ->bmap
> interface.  Note that we can't easily add checks for rt or reflink
> files, so these will have to remain in the callers.  This interface
> just needs to die..
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Looks ok,
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> ---
>  fs/iomap.c            | 34 ++++++++++++++++++++++++++++++++++
>  include/linux/iomap.h |  3 +++
>  2 files changed, 37 insertions(+)
> 
> diff --git a/fs/iomap.c b/fs/iomap.c
> index f928df4ab9a9..fa278ed338ce 100644
> --- a/fs/iomap.c
> +++ b/fs/iomap.c
> @@ -1411,3 +1411,37 @@ int iomap_swapfile_activate(struct swap_info_struct *sis,
>  }
>  EXPORT_SYMBOL_GPL(iomap_swapfile_activate);
>  #endif /* CONFIG_SWAP */
> +
> +static loff_t
> +iomap_bmap_actor(struct inode *inode, loff_t pos, loff_t length,
> +		void *data, struct iomap *iomap)
> +{
> +	sector_t *bno = data, addr;
> +
> +	if (iomap->type == IOMAP_MAPPED) {
> +		addr = (pos - iomap->offset + iomap->addr) >> inode->i_blkbits;
> +		if (addr > INT_MAX)
> +			WARN(1, "would truncate bmap result\n");
> +		else
> +			*bno = addr;
> +	}
> +	return 0;
> +}
> +
> +/* legacy ->bmap interface.  0 is the error return (!) */
> +sector_t
> +iomap_bmap(struct address_space *mapping, sector_t bno,
> +		const struct iomap_ops *ops)
> +{
> +	struct inode *inode = mapping->host;
> +	loff_t pos = bno >> inode->i_blkbits;
> +	unsigned blocksize = i_blocksize(inode);
> +
> +	if (filemap_write_and_wait(mapping))
> +		return 0;
> +
> +	bno = 0;
> +	iomap_apply(inode, pos, blocksize, 0, ops, &bno, iomap_bmap_actor);
> +	return bno;
> +}
> +EXPORT_SYMBOL_GPL(iomap_bmap);
> diff --git a/include/linux/iomap.h b/include/linux/iomap.h
> index 819e0cd2a950..a044a824da85 100644
> --- a/include/linux/iomap.h
> +++ b/include/linux/iomap.h
> @@ -4,6 +4,7 @@
>  
>  #include <linux/types.h>
>  
> +struct address_space;
>  struct fiemap_extent_info;
>  struct inode;
>  struct iov_iter;
> @@ -100,6 +101,8 @@ loff_t iomap_seek_hole(struct inode *inode, loff_t offset,
>  		const struct iomap_ops *ops);
>  loff_t iomap_seek_data(struct inode *inode, loff_t offset,
>  		const struct iomap_ops *ops);
> +sector_t iomap_bmap(struct address_space *mapping, sector_t bno,
> +		const struct iomap_ops *ops);
>  
>  /*
>   * Flags for direct I/O ->end_io:
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
