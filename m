Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 271096B0007
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 10:47:49 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id z5-v6so1584292pln.20
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 07:47:49 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 33-v6si3088843plg.260.2018.06.13.07.47.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Jun 2018 07:47:48 -0700 (PDT)
Date: Wed, 13 Jun 2018 07:47:41 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH V6 12/30] block: introduce bio_chunks()
Message-ID: <20180613144741.GC4693@infradead.org>
References: <20180609123014.8861-1-ming.lei@redhat.com>
 <20180609123014.8861-13-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180609123014.8861-13-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>

> +static inline unsigned bio_chunks(struct bio *bio)
> +{
> +	unsigned chunks = 0;
> +	struct bio_vec bv;
> +	struct bvec_iter iter;
>  
> -	return segs;
> +	/*
> +	 * We special case discard/write same/write zeroes, because they
> +	 * interpret bi_size differently:
> +	 */
> +	switch (bio_op(bio)) {
> +	case REQ_OP_DISCARD:
> +	case REQ_OP_SECURE_ERASE:
> +	case REQ_OP_WRITE_ZEROES:
> +		return 0;
> +	case REQ_OP_WRITE_SAME:
> +		return 1;
> +	default:
> +		bio_for_each_chunk(bv, bio, iter)
> +			chunks++;
> +		return chunks;

Shouldn't this just return bio->bi_vcnt?
