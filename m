Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f198.google.com (mail-ig0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5381E6B0253
	for <linux-mm@kvack.org>; Fri, 27 May 2016 13:40:56 -0400 (EDT)
Received: by mail-ig0-f198.google.com with SMTP id q18so2017164igr.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 10:40:56 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id t185si14100205itg.88.2016.05.27.10.40.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 10:40:55 -0700 (PDT)
Date: Fri, 27 May 2016 10:40:50 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH] xfs: fail ->bmap for reflink inodes
Message-ID: <20160527174050.GA3509@birch.djwong.org>
References: <1464267724-31423-1-git-send-email-hch@lst.de>
 <1464267724-31423-2-git-send-email-hch@lst.de>
 <71afd256-5dfe-2ff9-ac25-b7519dadd5f9@scylladb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <71afd256-5dfe-2ff9-ac25-b7519dadd5f9@scylladb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avi Kivity <avi@scylladb.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org, xfs@oss.sgi.com

On Fri, May 27, 2016 at 08:32:18PM +0300, Avi Kivity wrote:
> On 05/26/2016 04:02 PM, Christoph Hellwig wrote:
> >Signed-off-by: Christoph Hellwig <hch@lst.de>
> >---
> >  fs/xfs/xfs_aops.c | 11 +++++++++++
> >  1 file changed, 11 insertions(+)
> >
> >diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> >index a955552..d053a9e 100644
> >--- a/fs/xfs/xfs_aops.c
> >+++ b/fs/xfs/xfs_aops.c
> >@@ -1829,6 +1829,17 @@ xfs_vm_bmap(
> >  	trace_xfs_vm_bmap(XFS_I(inode));
> >  	xfs_ilock(ip, XFS_IOLOCK_SHARED);
> >+
> >+	/*
> >+	 * The swap code (ab-)uses ->bmap to get a block mapping and then
> >+	 * bypasseN? the file system for actual I/O.  We really can't allow
> >+	 * that on reflinks inodes, so we have to skip out here.  And yes,
> >+	 * 0 is the magic code for a bmap error..
> >+	 */
> >+	if (xfs_is_reflink_inode(ip)) {
> >+		xfs_iunlock(ip, XFS_IOLOCK_SHARED);
> >+		return 0;
> >+	}
> >  	filemap_write_and_wait(mapping);
> >  	xfs_iunlock(ip, XFS_IOLOCK_SHARED);
> >  	return generic_block_bmap(mapping, block, xfs_get_blocks);
> 
> Don't you also have to prevent a swapfile from being reflinked after it's
> bmapped?  Or is that already taken care of?

Already taken care of, at least for XFS.

--D

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
