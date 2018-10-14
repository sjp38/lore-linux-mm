Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6A7526B0005
	for <linux-mm@kvack.org>; Sun, 14 Oct 2018 19:05:41 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id s24-v6so14117201plp.12
        for <linux-mm@kvack.org>; Sun, 14 Oct 2018 16:05:41 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id 4-v6si9199195plh.99.2018.10.14.16.05.39
        for <linux-mm@kvack.org>;
        Sun, 14 Oct 2018 16:05:40 -0700 (PDT)
Date: Mon, 15 Oct 2018 10:05:36 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 24/25] xfs: support returning partial reflink results
Message-ID: <20181014230536.GY6311@dastard>
References: <153938912912.8361.13446310416406388958.stgit@magnolia>
 <153938931226.8361.7365948775364411156.stgit@magnolia>
 <20181014173546.GI30673@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181014173546.GI30673@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

On Sun, Oct 14, 2018 at 10:35:46AM -0700, Christoph Hellwig wrote:
> On Fri, Oct 12, 2018 at 05:08:32PM -0700, Darrick J. Wong wrote:
> > From: Darrick J. Wong <darrick.wong@oracle.com>
> > 
> > Back when the XFS reflink code only supported clone_file_range, we were
> > only able to return zero or negative error codes to userspace.  However,
> > now that copy_file_range (which returns bytes copied) can use XFS'
> > clone_file_range, we have the opportunity to return partial results.
> > For example, if userspace sends a 1GB clone request and we run out of
> > space halfway through, we at least can tell userspace that we completed
> > 512M of that request like a regular write.
> > 
> > Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> > ---
> >  fs/xfs/xfs_file.c    |    5 +----
> >  fs/xfs/xfs_reflink.c |   20 +++++++++++++++-----
> >  fs/xfs/xfs_reflink.h |    2 +-
> >  3 files changed, 17 insertions(+), 10 deletions(-)
> > 
> > 
> > diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
> > index bc9e94bcb7a3..b2b15b8dc4a1 100644
> > --- a/fs/xfs/xfs_file.c
> > +++ b/fs/xfs/xfs_file.c
> > @@ -928,14 +928,11 @@ xfs_file_remap_range(
> >  	loff_t		len,
> >  	unsigned int	remap_flags)
> >  {
> > -	int		ret;
> > -
> >  	if (!remap_check_flags(remap_flags, RFR_SAME_DATA))
> >  		return -EINVAL;
> >  
> > -	ret = xfs_reflink_remap_range(file_in, pos_in, file_out, pos_out,
> > +	return xfs_reflink_remap_range(file_in, pos_in, file_out, pos_out,
> >  			len, remap_flags);
> 
> Is there any reason not to merge xfs_file_remap_range and
> xfs_reflink_remap_range at this point?

Yeah, that seems like a good idea to me - pulling all the
vfs/generic code interactions back up into xfs_file.c would match
how the rest of the file operations are layered w.r.t. external and
internal XFS code...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
