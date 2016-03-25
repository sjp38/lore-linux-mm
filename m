Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 18F656B0005
	for <linux-mm@kvack.org>; Fri, 25 Mar 2016 06:44:23 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id tt10so44376759pab.3
        for <linux-mm@kvack.org>; Fri, 25 Mar 2016 03:44:23 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id 78si18699795pfq.236.2016.03.25.03.44.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Mar 2016 03:44:21 -0700 (PDT)
Date: Fri, 25 Mar 2016 03:44:18 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 4/5] dax: use sb_issue_zerout instead of calling
 dax_clear_sectors
Message-ID: <20160325104418.GA10525@infradead.org>
References: <1458861450-17705-1-git-send-email-vishal.l.verma@intel.com>
 <1458861450-17705-5-git-send-email-vishal.l.verma@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1458861450-17705-5-git-send-email-vishal.l.verma@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vishal Verma <vishal.l.verma@intel.com>
Cc: linux-nvdimm@ml01.01.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <matthew.r.wilcox@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Mar 24, 2016 at 05:17:29PM -0600, Vishal Verma wrote:
> @@ -72,16 +72,7 @@ xfs_zero_extent(
>  	struct xfs_mount *mp = ip->i_mount;
>  	xfs_daddr_t	sector = xfs_fsb_to_db(ip, start_fsb);
>  	sector_t	block = XFS_BB_TO_FSBT(mp, sector);
> -	ssize_t		size = XFS_FSB_TO_B(mp, count_fsb);
>  
> -	if (IS_DAX(VFS_I(ip)))
> -		return dax_clear_sectors(xfs_find_bdev_for_inode(VFS_I(ip)),
> -				sector, size);
> -
> -	/*
> -	 * let the block layer decide on the fastest method of
> -	 * implementing the zeroing.
> -	 */
>  	return sb_issue_zeroout(mp->m_super, block, count_fsb, GFP_NOFS);

While not new: using sb_issue_zeroout in XFS is wrong as it doesn't
account for the RT device.  We need the xfs_find_bdev_for_inode and
call blkdev_issue_zeroout directly with the bdev it returned.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
