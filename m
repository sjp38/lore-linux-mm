Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 757116B1996
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 03:26:18 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id z126so67510494qka.10
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 00:26:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s11si10464940qvb.13.2018.11.19.00.26.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 00:26:17 -0800 (PST)
Date: Mon, 19 Nov 2018 16:25:49 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V10 10/19] block: loop: pass multi-page bvec to iov_iter
Message-ID: <20181119082548.GD16736@ming.t460p>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-11-ming.lei@redhat.com>
 <20181116004022.GE23828@vader>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181116004022.GE23828@vader>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 15, 2018 at 04:40:22PM -0800, Omar Sandoval wrote:
> On Thu, Nov 15, 2018 at 04:52:57PM +0800, Ming Lei wrote:
> > iov_iter is implemented with bvec itererator, so it is safe to pass
> > multipage bvec to it, and this way is much more efficient than
> > passing one page in each bvec.
> > 
> > Cc: Dave Chinner <dchinner@redhat.com>
> > Cc: Kent Overstreet <kent.overstreet@gmail.com>
> > Cc: Mike Snitzer <snitzer@redhat.com>
> > Cc: dm-devel@redhat.com
> > Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> > Cc: linux-fsdevel@vger.kernel.org
> > Cc: Shaohua Li <shli@kernel.org>
> > Cc: linux-raid@vger.kernel.org
> > Cc: linux-erofs@lists.ozlabs.org
> > Cc: David Sterba <dsterba@suse.com>
> > Cc: linux-btrfs@vger.kernel.org
> > Cc: Darrick J. Wong <darrick.wong@oracle.com>
> > Cc: linux-xfs@vger.kernel.org
> > Cc: Gao Xiang <gaoxiang25@huawei.com>
> > Cc: Christoph Hellwig <hch@lst.de>
> > Cc: Theodore Ts'o <tytso@mit.edu>
> > Cc: linux-ext4@vger.kernel.org
> > Cc: Coly Li <colyli@suse.de>
> > Cc: linux-bcache@vger.kernel.org
> > Cc: Boaz Harrosh <ooo@electrozaur.com>
> > Cc: Bob Peterson <rpeterso@redhat.com>
> > Cc: cluster-devel@redhat.com
> 
> Reviewed-by: Omar Sandoval <osandov@fb.com>
> 
> Comments below.
> 
> > Signed-off-by: Ming Lei <ming.lei@redhat.com>
> > ---
> >  drivers/block/loop.c | 23 ++++++++++++-----------
> >  1 file changed, 12 insertions(+), 11 deletions(-)
> > 
> > diff --git a/drivers/block/loop.c b/drivers/block/loop.c
> > index bf6bc35aaf88..a3fd418ec637 100644
> > --- a/drivers/block/loop.c
> > +++ b/drivers/block/loop.c
> > @@ -515,16 +515,16 @@ static int lo_rw_aio(struct loop_device *lo, struct loop_cmd *cmd,
> >  	struct bio *bio = rq->bio;
> >  	struct file *file = lo->lo_backing_file;
> >  	unsigned int offset;
> > -	int segments = 0;
> > +	int nr_bvec = 0;
> >  	int ret;
> >  
> >  	if (rq->bio != rq->biotail) {
> > -		struct req_iterator iter;
> > +		struct bvec_iter iter;
> >  		struct bio_vec tmp;
> >  
> >  		__rq_for_each_bio(bio, rq)
> > -			segments += bio_segments(bio);
> > -		bvec = kmalloc_array(segments, sizeof(struct bio_vec),
> > +			nr_bvec += bio_bvecs(bio);
> > +		bvec = kmalloc_array(nr_bvec, sizeof(struct bio_vec),
> >  				     GFP_NOIO);
> >  		if (!bvec)
> >  			return -EIO;
> > @@ -533,13 +533,14 @@ static int lo_rw_aio(struct loop_device *lo, struct loop_cmd *cmd,
> >  		/*
> >  		 * The bios of the request may be started from the middle of
> >  		 * the 'bvec' because of bio splitting, so we can't directly
> > -		 * copy bio->bi_iov_vec to new bvec. The rq_for_each_segment
> > +		 * copy bio->bi_iov_vec to new bvec. The bio_for_each_bvec
> >  		 * API will take care of all details for us.
> >  		 */
> > -		rq_for_each_segment(tmp, rq, iter) {
> > -			*bvec = tmp;
> > -			bvec++;
> > -		}
> > +		__rq_for_each_bio(bio, rq)
> > +			bio_for_each_bvec(tmp, bio, iter) {
> > +				*bvec = tmp;
> > +				bvec++;
> > +			}
> 
> Even if they're not strictly necessary, could you please include the
> curly braces for __rq_for_each_bio() here?

Sure, will do it.

> 
> >  		bvec = cmd->bvec;
> >  		offset = 0;
> >  	} else {
> > @@ -550,11 +551,11 @@ static int lo_rw_aio(struct loop_device *lo, struct loop_cmd *cmd,
> >  		 */
> >  		offset = bio->bi_iter.bi_bvec_done;
> >  		bvec = __bvec_iter_bvec(bio->bi_io_vec, bio->bi_iter);
> > -		segments = bio_segments(bio);
> > +		nr_bvec = bio_bvecs(bio);
> 
> This scared me for a second, but it's fine to do here because we haven't
> actually enabled multipage bvecs yet, right?

Well, it is fine, all helpers supporting multi-page bvec actually works
well when it isn't enabled, cause single-page bvec is one special case in
which multi-page bevc helpers have to deal with.

Thanks,
Ming
