Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7C1FD6B1800
	for <linux-mm@kvack.org>; Sun, 18 Nov 2018 21:25:52 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id k66so66883821qkf.1
        for <linux-mm@kvack.org>; Sun, 18 Nov 2018 18:25:52 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d18si5453101qta.143.2018.11.18.18.25.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Nov 2018 18:25:51 -0800 (PST)
Date: Mon, 19 Nov 2018 10:25:26 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V10 01/19] block: introduce multi-page page bvec helpers
Message-ID: <20181119022525.GD10838@ming.t460p>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-2-ming.lei@redhat.com>
 <20181115182559.GA9348@vader>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115182559.GA9348@vader>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 15, 2018 at 10:25:59AM -0800, Omar Sandoval wrote:
> On Thu, Nov 15, 2018 at 04:52:48PM +0800, Ming Lei wrote:
> > This patch introduces helpers of 'mp_bvec_iter_*' for multipage
> > bvec support.
> > 
> > The introduced helpers treate one bvec as real multi-page segment,
> > which may include more than one pages.
> > 
> > The existed helpers of bvec_iter_* are interfaces for supporting current
> > bvec iterator which is thought as single-page by drivers, fs, dm and
> > etc. These introduced helpers will build single-page bvec in flight, so
> > this way won't break current bio/bvec users, which needn't any change.
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
> But a couple of comments below.
> 
> > Signed-off-by: Ming Lei <ming.lei@redhat.com>
> > ---
> >  include/linux/bvec.h | 63 +++++++++++++++++++++++++++++++++++++++++++++++++---
> >  1 file changed, 60 insertions(+), 3 deletions(-)
> > 
> > diff --git a/include/linux/bvec.h b/include/linux/bvec.h
> > index 02c73c6aa805..8ef904a50577 100644
> > --- a/include/linux/bvec.h
> > +++ b/include/linux/bvec.h
> > @@ -23,6 +23,44 @@
> >  #include <linux/kernel.h>
> >  #include <linux/bug.h>
> >  #include <linux/errno.h>
> > +#include <linux/mm.h>
> > +
> > +/*
> > + * What is multi-page bvecs?
> > + *
> > + * - bvecs stored in bio->bi_io_vec is always multi-page(mp) style
> > + *
> > + * - bvec(struct bio_vec) represents one physically contiguous I/O
> > + *   buffer, now the buffer may include more than one pages after
> > + *   multi-page(mp) bvec is supported, and all these pages represented
> > + *   by one bvec is physically contiguous. Before mp support, at most
> > + *   one page is included in one bvec, we call it single-page(sp)
> > + *   bvec.
> > + *
> > + * - .bv_page of the bvec represents the 1st page in the mp bvec
> > + *
> > + * - .bv_offset of the bvec represents offset of the buffer in the bvec
> > + *
> > + * The effect on the current drivers/filesystem/dm/bcache/...:
> > + *
> > + * - almost everyone supposes that one bvec only includes one single
> > + *   page, so we keep the sp interface not changed, for example,
> > + *   bio_for_each_segment() still returns bvec with single page
> > + *
> > + * - bio_for_each_segment*() will be changed to return single-page
> > + *   bvec too
> > + *
> > + * - during iterating, iterator variable(struct bvec_iter) is always
> > + *   updated in multipage bvec style and that means bvec_iter_advance()
> > + *   is kept not changed
> > + *
> > + * - returned(copied) single-page bvec is built in flight by bvec
> > + *   helpers from the stored multipage bvec
> > + *
> > + * - In case that some components(such as iov_iter) need to support
> > + *   multi-page bvec, we introduce new helpers(mp_bvec_iter_*) for
> > + *   them.
> > + */
> 
> This comment sounds more like a commit message (i.e., how were things
> before, and how are we changing them). In a couple of years when I read
> this code, I probably won't care how it was changed, just how it works.
> So I think a comment explaining the concepts of multi-page and
> single-page bvecs is very useful, but please move all of the "foo was
> changed" and "before mp support" type stuff to the commit message.

OK.

> 
> >  /*
> >   * was unsigned short, but we might as well be ready for > 64kB I/O pages
> > @@ -50,16 +88,35 @@ struct bvec_iter {
> >   */
> >  #define __bvec_iter_bvec(bvec, iter)	(&(bvec)[(iter).bi_idx])
> >  
> > -#define bvec_iter_page(bvec, iter)				\
> > +#define mp_bvec_iter_page(bvec, iter)				\
> >  	(__bvec_iter_bvec((bvec), (iter))->bv_page)
> >  
> > -#define bvec_iter_len(bvec, iter)				\
> > +#define mp_bvec_iter_len(bvec, iter)				\
> >  	min((iter).bi_size,					\
> >  	    __bvec_iter_bvec((bvec), (iter))->bv_len - (iter).bi_bvec_done)
> >  
> > -#define bvec_iter_offset(bvec, iter)				\
> > +#define mp_bvec_iter_offset(bvec, iter)				\
> >  	(__bvec_iter_bvec((bvec), (iter))->bv_offset + (iter).bi_bvec_done)
> >  
> > +#define mp_bvec_iter_page_idx(bvec, iter)			\
> > +	(mp_bvec_iter_offset((bvec), (iter)) / PAGE_SIZE)
> > +
> > +/*
> > + * <page, offset,length> of single-page(sp) segment.
> > + *
> > + * This helpers are for building sp bvec in flight.
> > + */
> > +#define bvec_iter_offset(bvec, iter)					\
> > +	(mp_bvec_iter_offset((bvec), (iter)) % PAGE_SIZE)
> > +
> > +#define bvec_iter_len(bvec, iter)					\
> > +	min_t(unsigned, mp_bvec_iter_len((bvec), (iter)),		\
> > +	    (PAGE_SIZE - (bvec_iter_offset((bvec), (iter)))))
> 
> The parentheses around (bvec_iter_offset((bvec), (iter))) and
> (PAGE_SIZE - (bvec_iter_offset((bvec), (iter)))) are unnecessary
> clutter. This looks easier to read to me:

Good catch!

Thanks,
Ming
