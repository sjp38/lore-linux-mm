Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id F00546B19B9
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 03:46:00 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id x125so49941576qka.17
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 00:46:00 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t7si6096884qtd.217.2018.11.19.00.45.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 00:45:59 -0800 (PST)
Date: Mon, 19 Nov 2018 16:45:23 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V10 14/19] block: enable multipage bvecs
Message-ID: <20181119084522.GK16736@ming.t460p>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-15-ming.lei@redhat.com>
 <20181116015627.GI23828@vader>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181116015627.GI23828@vader>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 15, 2018 at 05:56:27PM -0800, Omar Sandoval wrote:
> On Thu, Nov 15, 2018 at 04:53:01PM +0800, Ming Lei wrote:
> > This patch pulls the trigger for multi-page bvecs.
> > 
> > Now any request queue which supports queue cluster will see multi-page
> > bvecs.
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
> > Signed-off-by: Ming Lei <ming.lei@redhat.com>
> > ---
> >  block/bio.c | 24 ++++++++++++++++++------
> >  1 file changed, 18 insertions(+), 6 deletions(-)
> > 
> > diff --git a/block/bio.c b/block/bio.c
> > index 6486722d4d4b..ed6df6f8e63d 100644
> > --- a/block/bio.c
> > +++ b/block/bio.c
> 
> This comment above __bio_try_merge_page() doesn't make sense after this
> change:
> 
>  This is a
>  a useful optimisation for file systems with a block size smaller than the
>  page size.
> 
> Can you please get rid of it in this patch?

I understand __bio_try_merge_page() still works for original cases, so
looks the optimization for sub-pagesize is still there too, isn't it?

> 
> > @@ -767,12 +767,24 @@ bool __bio_try_merge_page(struct bio *bio, struct page *page,
> >  
> >  	if (bio->bi_vcnt > 0) {
> >  		struct bio_vec *bv = &bio->bi_io_vec[bio->bi_vcnt - 1];
> > -
> > -		if (page == bv->bv_page && off == bv->bv_offset + bv->bv_len) {
> > -			bv->bv_len += len;
> > -			bio->bi_iter.bi_size += len;
> > -			return true;
> > -		}
> > +		struct request_queue *q = NULL;
> > +
> > +		if (page == bv->bv_page && off == (bv->bv_offset + bv->bv_len)
> > +				&& (off + len) <= PAGE_SIZE)
> > +			goto merge;
> 
> The parentheses around (bv->bv_offset + bv->bv_len) and (off + len) are
> unnecessary noise.
> 
> What's the point of the new (off + len) <= PAGE_SIZE check?

Yeah, I don't know why I did it, :-(, the check is absolutely always true.

> 
> > +
> > +		if (bio->bi_disk)
> > +			q = bio->bi_disk->queue;
> > +
> > +		/* disable multi-page bvec too if cluster isn't enabled */
> > +		if (!q || !blk_queue_cluster(q) ||
> > +		    ((page_to_phys(bv->bv_page) + bv->bv_offset + bv->bv_len) !=
> > +		     (page_to_phys(page) + off)))
> 
> More unnecessary parentheses here.

OK.

Thanks,
Ming
