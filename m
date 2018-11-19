Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 34F816B199A
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 03:27:51 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id d196so67786809qkb.6
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 00:27:51 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u47si291310qth.262.2018.11.19.00.27.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 00:27:50 -0800 (PST)
Date: Mon, 19 Nov 2018 16:27:23 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V10 11/19] bcache: avoid to use
 bio_for_each_segment_all() in bch_bio_alloc_pages()
Message-ID: <20181119082722.GE16736@ming.t460p>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-12-ming.lei@redhat.com>
 <20181116004402.GF23828@vader>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181116004402.GF23828@vader>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 15, 2018 at 04:44:02PM -0800, Omar Sandoval wrote:
> On Thu, Nov 15, 2018 at 04:52:58PM +0800, Ming Lei wrote:
> > bch_bio_alloc_pages() is always called on one new bio, so it is safe
> > to access the bvec table directly. Given it is the only kind of this
> > case, open code the bvec table access since bio_for_each_segment_all()
> > will be changed to support for iterating over multipage bvec.
> > 
> > Cc: Dave Chinner <dchinner@redhat.com>
> > Cc: Kent Overstreet <kent.overstreet@gmail.com>
> > Acked-by: Coly Li <colyli@suse.de>
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
> >  drivers/md/bcache/util.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/drivers/md/bcache/util.c b/drivers/md/bcache/util.c
> > index 20eddeac1531..8517aebcda2d 100644
> > --- a/drivers/md/bcache/util.c
> > +++ b/drivers/md/bcache/util.c
> > @@ -270,7 +270,7 @@ int bch_bio_alloc_pages(struct bio *bio, gfp_t gfp_mask)
> >  	int i;
> >  	struct bio_vec *bv;
> >  
> > -	bio_for_each_segment_all(bv, bio, i) {
> > +	for (i = 0, bv = bio->bi_io_vec; i < bio->bi_vcnt; bv++) {
> 
> This is missing an i++.

Good catch, will fix it in next version.

thanks,
Ming
