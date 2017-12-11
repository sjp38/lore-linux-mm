Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3956A6B0033
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 16:55:04 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f8so13916584pgs.9
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 13:55:04 -0800 (PST)
Received: from ipmail03.adl6.internode.on.net (ipmail03.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id k21si11447729pff.411.2017.12.11.13.55.01
        for <linux-mm@kvack.org>;
        Mon, 11 Dec 2017 13:55:02 -0800 (PST)
Date: Tue, 12 Dec 2017 08:55:00 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v4 72/73] xfs: Convert mru cache to XArray
Message-ID: <20171211215500.GU5858@dastard>
References: <20171206012901.GZ4094@dastard>
 <20171206020208.GK26021@bombadil.infradead.org>
 <20171206031456.GE4094@dastard>
 <20171206044549.GO26021@bombadil.infradead.org>
 <20171206084404.GF4094@dastard>
 <20171206140648.GB32044@bombadil.infradead.org>
 <20171207003843.GG4094@dastard>
 <20171208230131.GC32293@bombadil.infradead.org>
 <20171210235745.GR5858@dastard>
 <20171211042315.GA25236@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171211042315.GA25236@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, Dec 10, 2017 at 08:23:15PM -0800, Matthew Wilcox wrote:
> On Mon, Dec 11, 2017 at 10:57:45AM +1100, Dave Chinner wrote:
> > i.e.  the fact the cmpxchg failed may not have anything to do with a
> > race condtion - it failed because the slot wasn't empty like we
> > expected it to be. There can be any number of reasons the slot isn't
> > empty - the API should not "document" that the reason the insert
> > failed was a race condition. It should document the case that we
> > "couldn't insert because there was an existing entry in the slot".
> > Let the surrounding code document the reason why that might have
> > happened - it's not for the API to assume reasons for failure.
> > 
> > i.e. this API and potential internal implementation makes much
> > more sense:
> > 
> > int
> > xa_store_iff_empty(...)
> > {
> > 	curr = xa_cmpxchg(&pag->pag_ici_xa, agino, NULL, ip, GFP_NOFS);
> > 	if (!curr)
> > 		return 0;	/* success! */
> > 	if (!IS_ERR(curr))
> > 		return -EEXIST;	/* failed - slot not empty */
> > 	return PTR_ERR(curr);	/* failed - XA internal issue */
> > }
> > 
> > as it replaces the existing preload and insert code in the XFS code
> > paths whilst letting us handle and document the "insert failed
> > because slot not empty" case however we want. It implies nothing
> > about *why* the slot wasn't empty, just that we couldn't do the
> > insert because it wasn't empty.
> 
> Yeah, OK.  So, over the top of the recent changes I'm looking at this:
> 
> I'm not in love with xa_store_empty() as a name.  I almost want
> xa_store_weak(), but after my MAP_FIXED_WEAK proposed name got shot
> down, I'm leery of it.  "empty" is at least a concept we already have
> in the API with the comment for xa_init() talking about an empty array
> and xa_empty().  I also considered xa_store_null and xa_overwrite_null
> and xa_replace_null().  Naming remains hard.
> 
> diff --git a/fs/xfs/xfs_icache.c b/fs/xfs/xfs_icache.c
> index 941f38bb94a4..586b43836905 100644
> --- a/fs/xfs/xfs_icache.c
> +++ b/fs/xfs/xfs_icache.c
> @@ -451,7 +451,7 @@ xfs_iget_cache_miss(
>  	int			flags,
>  	int			lock_flags)
>  {
> -	struct xfs_inode	*ip, *curr;
> +	struct xfs_inode	*ip;
>  	int			error;
>  	xfs_agino_t		agino = XFS_INO_TO_AGINO(mp, ino);
>  	int			iflags;
> @@ -498,8 +498,7 @@ xfs_iget_cache_miss(
>  	xfs_iflags_set(ip, iflags);
>  
>  	/* insert the new inode */
> -	curr = xa_cmpxchg(&pag->pag_ici_xa, agino, NULL, ip, GFP_NOFS);
> -	error = __xa_race(curr, -EAGAIN);
> +	error = xa_store_empty(&pag->pag_ici_xa, agino, ip, GFP_NOFS, -EAGAIN);
>  	if (error)
>  		goto out_unlock;

Can we avoid encoding the error to be returned into the function
call? No other generic/library API does this, so this seems like a
highly unusual special snowflake approach. I just don't see how
creating a whole new error specification convention is justified
for the case where it *might* save a line or two of error checking
code in a caller?

I'd much prefer that the API defines the error on failure, and let
the caller handle that specific error however they need to like
every other library interface we have...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
