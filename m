Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 69E8E6B061B
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 17:18:52 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id z13-v6so13933703pgv.18
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 14:18:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q3-v6sor33344754plb.60.2018.11.15.14.18.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Nov 2018 14:18:50 -0800 (PST)
Date: Thu, 15 Nov 2018 14:18:47 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH V10 03/19] block: use bio_for_each_bvec() to compute
 multi-page bvec count
Message-ID: <20181115221847.GD9348@vader>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-4-ming.lei@redhat.com>
 <20181115202028.GC9348@vader>
 <20181115210510.GA24908@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115210510.GA24908@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Snitzer <snitzer@redhat.com>
Cc: Ming Lei <ming.lei@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 15, 2018 at 04:05:10PM -0500, Mike Snitzer wrote:
> On Thu, Nov 15 2018 at  3:20pm -0500,
> Omar Sandoval <osandov@osandov.com> wrote:
> 
> > On Thu, Nov 15, 2018 at 04:52:50PM +0800, Ming Lei wrote:
> > > First it is more efficient to use bio_for_each_bvec() in both
> > > blk_bio_segment_split() and __blk_recalc_rq_segments() to compute how
> > > many multi-page bvecs there are in the bio.
> > > 
> > > Secondly once bio_for_each_bvec() is used, the bvec may need to be
> > > splitted because its length can be very longer than max segment size,
> > > so we have to split the big bvec into several segments.
> > > 
> > > Thirdly when splitting multi-page bvec into segments, the max segment
> > > limit may be reached, so the bio split need to be considered under
> > > this situation too.
> > > 
> > > Cc: Dave Chinner <dchinner@redhat.com>
> > > Cc: Kent Overstreet <kent.overstreet@gmail.com>
> > > Cc: Mike Snitzer <snitzer@redhat.com>
> > > Cc: dm-devel@redhat.com
> > > Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> > > Cc: linux-fsdevel@vger.kernel.org
> > > Cc: Shaohua Li <shli@kernel.org>
> > > Cc: linux-raid@vger.kernel.org
> > > Cc: linux-erofs@lists.ozlabs.org
> > > Cc: David Sterba <dsterba@suse.com>
> > > Cc: linux-btrfs@vger.kernel.org
> > > Cc: Darrick J. Wong <darrick.wong@oracle.com>
> > > Cc: linux-xfs@vger.kernel.org
> > > Cc: Gao Xiang <gaoxiang25@huawei.com>
> > > Cc: Christoph Hellwig <hch@lst.de>
> > > Cc: Theodore Ts'o <tytso@mit.edu>
> > > Cc: linux-ext4@vger.kernel.org
> > > Cc: Coly Li <colyli@suse.de>
> > > Cc: linux-bcache@vger.kernel.org
> > > Cc: Boaz Harrosh <ooo@electrozaur.com>
> > > Cc: Bob Peterson <rpeterso@redhat.com>
> > > Cc: cluster-devel@redhat.com
> > > Signed-off-by: Ming Lei <ming.lei@redhat.com>
> > > ---
> > >  block/blk-merge.c | 90 ++++++++++++++++++++++++++++++++++++++++++++++---------
> > >  1 file changed, 76 insertions(+), 14 deletions(-)
> > > 
> > > diff --git a/block/blk-merge.c b/block/blk-merge.c
> > > index 91b2af332a84..6f7deb94a23f 100644
> > > --- a/block/blk-merge.c
> > > +++ b/block/blk-merge.c
> > > @@ -160,6 +160,62 @@ static inline unsigned get_max_io_size(struct request_queue *q,
> > >  	return sectors;
> > >  }
> > >  
> > > +/*
> > > + * Split the bvec @bv into segments, and update all kinds of
> > > + * variables.
> > > + */
> > > +static bool bvec_split_segs(struct request_queue *q, struct bio_vec *bv,
> > > +		unsigned *nsegs, unsigned *last_seg_size,
> > > +		unsigned *front_seg_size, unsigned *sectors)
> > > +{
> > > +	bool need_split = false;
> > > +	unsigned len = bv->bv_len;
> > > +	unsigned total_len = 0;
> > > +	unsigned new_nsegs = 0, seg_size = 0;
> > 
> > "unsigned int" here and everywhere else.
> 
> Curious why?  I've wondered what govens use of "unsigned" vs "unsigned
> int" recently and haven't found _the_ reason to pick one over the other.

My only reason to prefer unsigned int is consistency. unsigned int is
much more common in the kernel:

$ ag --cc -s 'unsigned\s+int' | wc -l
129632
$ ag --cc -s 'unsigned\s+(?!char|short|int|long)' | wc -l
22435

checkpatch also warns on plain unsigned.
