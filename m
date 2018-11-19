Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3A78D6B196D
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 02:57:47 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id j125so1094854qke.12
        for <linux-mm@kvack.org>; Sun, 18 Nov 2018 23:57:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w6si2717317qvc.170.2018.11.18.23.57.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Nov 2018 23:57:46 -0800 (PST)
Date: Mon, 19 Nov 2018 15:57:21 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V10 05/19] block: introduce bvec_last_segment()
Message-ID: <20181119075720.GC16519@ming.t460p>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-6-ming.lei@redhat.com>
 <20181115232356.GA23238@vader>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115232356.GA23238@vader>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 15, 2018 at 03:23:56PM -0800, Omar Sandoval wrote:
> On Thu, Nov 15, 2018 at 04:52:52PM +0800, Ming Lei wrote:
> > BTRFS and guard_bio_eod() need to get the last singlepage segment
> > from one multipage bvec, so introduce this helper to make them happy.
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
> Minor comments below.
> 
> > Signed-off-by: Ming Lei <ming.lei@redhat.com>
> > ---
> >  include/linux/bvec.h | 25 +++++++++++++++++++++++++
> >  1 file changed, 25 insertions(+)
> > 
> > diff --git a/include/linux/bvec.h b/include/linux/bvec.h
> > index 3d61352cd8cf..01616a0b6220 100644
> > --- a/include/linux/bvec.h
> > +++ b/include/linux/bvec.h
> > @@ -216,4 +216,29 @@ static inline bool mp_bvec_iter_advance(const struct bio_vec *bv,
> >  	.bi_bvec_done	= 0,						\
> >  }
> >  
> > +/*
> > + * Get the last singlepage segment from the multipage bvec and store it
> > + * in @seg
> > + */
> > +static inline void bvec_last_segment(const struct bio_vec *bvec,
> > +		struct bio_vec *seg)
> 
> Indentation is all messed up here.

Will fix it.

> 
> > +{
> > +	unsigned total = bvec->bv_offset + bvec->bv_len;
> > +	unsigned last_page = total / PAGE_SIZE;
> > +
> > +	if (last_page * PAGE_SIZE == total)
> > +		last_page--;
> 
> I think this could just be
> 
> 	unsigned int last_page = (total - 1) / PAGE_SIZE;

This way is really elegant.

Thanks,
Ming
