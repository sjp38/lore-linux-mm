Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A4DFC3A5A6
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 15:24:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DB7423407
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 15:24:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DB7423407
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 947596B0006; Fri, 30 Aug 2019 11:24:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FA9E6B0008; Fri, 30 Aug 2019 11:24:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 80F846B000A; Fri, 30 Aug 2019 11:24:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0012.hostedemail.com [216.40.44.12])
	by kanga.kvack.org (Postfix) with ESMTP id 602C66B0006
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 11:24:52 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id E65581F87B
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 15:24:51 +0000 (UTC)
X-FDA: 75879466782.21.slave23_649db5c7d431a
X-HE-Tag: slave23_649db5c7d431a
X-Filterd-Recvd-Size: 4415
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 15:24:51 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 17DFEAD49;
	Fri, 30 Aug 2019 15:24:50 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 82B441E43A8; Fri, 30 Aug 2019 17:24:49 +0200 (CEST)
Date: Fri, 30 Aug 2019 17:24:49 +0200
From: Jan Kara <jack@suse.cz>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Jan Kara <jack@suse.cz>, linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	Amir Goldstein <amir73il@gmail.com>,
	Boaz Harrosh <boaz@plexistor.com>, linux-fsdevel@vger.kernel.org,
	stable@vger.kernel.org
Subject: Re: [PATCH 3/3] xfs: Fix stale data exposure when readahead races
 with hole punch
Message-ID: <20190830152449.GA25069@quack2.suse.cz>
References: <20190829131034.10563-1-jack@suse.cz>
 <20190829131034.10563-4-jack@suse.cz>
 <20190829155204.GD5354@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190829155204.GD5354@magnolia>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 29-08-19 08:52:04, Darrick J. Wong wrote:
> On Thu, Aug 29, 2019 at 03:10:34PM +0200, Jan Kara wrote:
> > Hole puching currently evicts pages from page cache and then goes on to
> > remove blocks from the inode. This happens under both XFS_IOLOCK_EXCL
> > and XFS_MMAPLOCK_EXCL which provides appropriate serialization with
> > racing reads or page faults. However there is currently nothing that
> > prevents readahead triggered by fadvise() or madvise() from racing with
> > the hole punch and instantiating page cache page after hole punching has
> > evicted page cache in xfs_flush_unmap_range() but before it has removed
> > blocks from the inode. This page cache page will be mapping soon to be
> > freed block and that can lead to returning stale data to userspace or
> > even filesystem corruption.
> > 
> > Fix the problem by protecting handling of readahead requests by
> > XFS_IOLOCK_SHARED similarly as we protect reads.
> > 
> > CC: stable@vger.kernel.org
> > Link: https://lore.kernel.org/linux-fsdevel/CAOQ4uxjQNmxqmtA_VbYW0Su9rKRk2zobJmahcyeaEVOFKVQ5dw@mail.gmail.com/
> > Reported-by: Amir Goldstein <amir73il@gmail.com>
> > Signed-off-by: Jan Kara <jack@suse.cz>
> 
> Is there a test on xfstests to demonstrate this race?

No, but I can try to create one.

> Will test it out though...
> 
> Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

Thanks. BTW, will you pick up these patches please?

								Honza

> 
> --D
> 
> > ---
> >  fs/xfs/xfs_file.c | 26 ++++++++++++++++++++++++++
> >  1 file changed, 26 insertions(+)
> > 
> > diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
> > index 28101bbc0b78..d952d5962e93 100644
> > --- a/fs/xfs/xfs_file.c
> > +++ b/fs/xfs/xfs_file.c
> > @@ -28,6 +28,7 @@
> >  #include <linux/falloc.h>
> >  #include <linux/backing-dev.h>
> >  #include <linux/mman.h>
> > +#include <linux/fadvise.h>
> >  
> >  static const struct vm_operations_struct xfs_file_vm_ops;
> >  
> > @@ -933,6 +934,30 @@ xfs_file_fallocate(
> >  	return error;
> >  }
> >  
> > +STATIC int
> > +xfs_file_fadvise(
> > +	struct file	*file,
> > +	loff_t		start,
> > +	loff_t		end,
> > +	int		advice)
> > +{
> > +	struct xfs_inode *ip = XFS_I(file_inode(file));
> > +	int ret;
> > +	int lockflags = 0;
> > +
> > +	/*
> > +	 * Operations creating pages in page cache need protection from hole
> > +	 * punching and similar ops
> > +	 */
> > +	if (advice == POSIX_FADV_WILLNEED) {
> > +		lockflags = XFS_IOLOCK_SHARED;
> > +		xfs_ilock(ip, lockflags);
> > +	}
> > +	ret = generic_fadvise(file, start, end, advice);
> > +	if (lockflags)
> > +		xfs_iunlock(ip, lockflags);
> > +	return ret;
> > +}
> >  
> >  STATIC loff_t
> >  xfs_file_remap_range(
> > @@ -1232,6 +1257,7 @@ const struct file_operations xfs_file_operations = {
> >  	.fsync		= xfs_file_fsync,
> >  	.get_unmapped_area = thp_get_unmapped_area,
> >  	.fallocate	= xfs_file_fallocate,
> > +	.fadvise	= xfs_file_fadvise,
> >  	.remap_file_range = xfs_file_remap_range,
> >  };
> >  
> > -- 
> > 2.16.4
> > 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

