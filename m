Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3BD096B0008
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 10:57:27 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id f8-v6so2110597qth.9
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 07:57:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j8-v6sor1441695qvi.152.2018.06.13.07.57.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Jun 2018 07:57:26 -0700 (PDT)
Date: Wed, 13 Jun 2018 10:57:22 -0400
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: Re: [PATCH V6 12/30] block: introduce bio_chunks()
Message-ID: <20180613145722.GA17340@kmo-pixel>
References: <20180609123014.8861-1-ming.lei@redhat.com>
 <20180609123014.8861-13-ming.lei@redhat.com>
 <20180613144741.GC4693@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180613144741.GC4693@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Ming Lei <ming.lei@redhat.com>, Jens Axboe <axboe@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>

On Wed, Jun 13, 2018 at 07:47:41AM -0700, Christoph Hellwig wrote:
> > +static inline unsigned bio_chunks(struct bio *bio)
> > +{
> > +	unsigned chunks = 0;
> > +	struct bio_vec bv;
> > +	struct bvec_iter iter;
> >  
> > -	return segs;
> > +	/*
> > +	 * We special case discard/write same/write zeroes, because they
> > +	 * interpret bi_size differently:
> > +	 */
> > +	switch (bio_op(bio)) {
> > +	case REQ_OP_DISCARD:
> > +	case REQ_OP_SECURE_ERASE:
> > +	case REQ_OP_WRITE_ZEROES:
> > +		return 0;
> > +	case REQ_OP_WRITE_SAME:
> > +		return 1;
> > +	default:
> > +		bio_for_each_chunk(bv, bio, iter)
> > +			chunks++;
> > +		return chunks;
> 
> Shouldn't this just return bio->bi_vcnt?

No.

bio->bi_vcnt is only for the owner of a bio (the code that originally allocated
it and filled it out) to use, and really the only legit use is
bio_for_each_segment_all() (iterating over segments without using bi_iter
because it's already been iterated to the end), and as a convenience thing for
bio_add_page.

Code that has a bio submitted to it can _not_ use bio->bi_vcnt, it's perfectly
legal for it to be 0 (and it is for e.g. bio splits).
