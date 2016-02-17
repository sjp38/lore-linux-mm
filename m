Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1D3626B0005
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 17:10:10 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id g62so182991401wme.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 14:10:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b63si43782207wme.9.2016.02.17.14.10.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Feb 2016 14:10:09 -0800 (PST)
Date: Wed, 17 Feb 2016 23:10:29 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 3/6] ext4: Online defrag not supported with DAX
Message-ID: <20160217221029.GM14140@quack.suse.cz>
References: <1455680059-20126-1-git-send-email-ross.zwisler@linux.intel.com>
 <1455680059-20126-4-git-send-email-ross.zwisler@linux.intel.com>
 <20160217215037.GB30126@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160217215037.GB30126@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Jens Axboe <axboe@kernel.dk>, Matthew Wilcox <willy@linux.intel.com>, linux-block@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, xfs@oss.sgi.com

On Wed 17-02-16 14:50:37, Ross Zwisler wrote:
> On Tue, Feb 16, 2016 at 08:34:16PM -0700, Ross Zwisler wrote:
> > Online defrag operations for ext4 are hard coded to use the page cache.
> > See ext4_ioctl() -> ext4_move_extents() -> move_extent_per_page()
> > 
> > When combined with DAX I/O, which circumvents the page cache, this can
> > result in data corruption.  This was observed with xfstests ext4/307 and
> > ext4/308.
> > 
> > Fix this by only allowing online defrag for non-DAX files.
> 
> Jan,
> 
> Thinking about this a bit more, it's probably the case that the data
> corruption I was observing was due to us skipping the writeback of the dirty
> page cache pages because S_DAX was set.
> 
> I do think we have a problem with defrag because it is doing the extent
> swapping using the page cache, and we won't flush the dirty pages due to
> S_DAX being set.
> 
> This patch is the quick and easy answer, and is perhaps appropriate for v4.5.
> 
> Looking forward, though, what do you think the correct solution is?  Making an
> extent swapper that doesn't use the page cache (as I believe XFS has? see
> xfs_swap_extents()), or maybe just unsetting S_DAX while we do the defrag and
> being careful to block out page faults and I/O?  Or is it acceptable to just
> say that DAX and defrag are mutually exclusive for ext4?

For 4.5 I'd just say just make them exclusive. Long term, we could just
avoid using page cache for copying data - grab all the necessary locks,
wait for all DIO to complete, evict anything in pagecache, copy data, swap
extents. It could even result in a simpler code.

								Honza


> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > ---
> >  fs/ext4/ioctl.c | 5 +++++
> >  1 file changed, 5 insertions(+)
> > 
> > diff --git a/fs/ext4/ioctl.c b/fs/ext4/ioctl.c
> > index 0f6c369..e32c86f 100644
> > --- a/fs/ext4/ioctl.c
> > +++ b/fs/ext4/ioctl.c
> > @@ -583,6 +583,11 @@ group_extend_out:
> >  				 "Online defrag not supported with bigalloc");
> >  			err = -EOPNOTSUPP;
> >  			goto mext_out;
> > +		} else if (IS_DAX(inode)) {
> > +			ext4_msg(sb, KERN_ERR,
> > +				 "Online defrag not supported with DAX");
> > +			err = -EOPNOTSUPP;
> > +			goto mext_out;
> >  		}
> >  
> >  		err = mnt_want_write_file(filp);
> > -- 
> > 2.5.0
> > 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
