Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 021806B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 08:16:17 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id l2so5501736pgu.2
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 05:16:16 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id e127si4111123pfe.495.2017.08.10.05.16.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 05:16:16 -0700 (PDT)
Date: Thu, 10 Aug 2017 05:16:12 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 37/49] fs/mpage: convert to
 bio_for_each_segment_all_sp()
Message-ID: <20170810121612.GG14607@infradead.org>
References: <20170808084548.18963-1-ming.lei@redhat.com>
 <20170808084548.18963-38-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170808084548.18963-38-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

>  	struct bio_vec *bv;
> +	struct bvec_iter_all bia;
>  	int i;
>  
> -	bio_for_each_segment_all(bv, bio, i) {
> +	bio_for_each_segment_all_sp(bv, bio, i, bia) {
>  		struct page *page = bv->bv_page;
>  		page_endio(page, op_is_write(bio_op(bio)),
>  				blk_status_to_errno(bio->bi_status));

Hmm.  Going back to my previous comment about implementing the single
page variants on top of multipage - I wonder if we should simply
do that in the callers, e.g. something like:

	bio_for_each_segment_all(bv, bio, i) {
		bvec_for_each_page(page, bv, j) {
			page_endio(page, op_is_write(bio_op(bio)),
				blk_status_to_errno(bio->bi_status));
		}
	}

with additional helpers to get the length and offset for the page, e.g.

bvec_page_offset(bv, idx)
bvev_page_len(bv, idx)

While this is a little more code in the callers it's a lot easier to
understand.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
