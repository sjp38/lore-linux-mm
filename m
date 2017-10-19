Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 97B5E6B0038
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 19:58:25 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id j140so9011874itj.10
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 16:58:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u203si2241471itf.128.2017.10.19.16.58.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 16:58:24 -0700 (PDT)
Date: Fri, 20 Oct 2017 07:58:13 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH v3 37/49] fs/mpage: convert to
 bio_for_each_segment_all_sp()
Message-ID: <20171019235813.GF27130@ming.t460p>
References: <20170808084548.18963-1-ming.lei@redhat.com>
 <20170808084548.18963-38-ming.lei@redhat.com>
 <20170810121612.GG14607@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810121612.GG14607@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jens Axboe <axboe@fb.com>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, Aug 10, 2017 at 05:16:12AM -0700, Christoph Hellwig wrote:
> >  	struct bio_vec *bv;
> > +	struct bvec_iter_all bia;
> >  	int i;
> >  
> > -	bio_for_each_segment_all(bv, bio, i) {
> > +	bio_for_each_segment_all_sp(bv, bio, i, bia) {
> >  		struct page *page = bv->bv_page;
> >  		page_endio(page, op_is_write(bio_op(bio)),
> >  				blk_status_to_errno(bio->bi_status));
> 
> Hmm.  Going back to my previous comment about implementing the single
> page variants on top of multipage - I wonder if we should simply
> do that in the callers, e.g. something like:
> 
> 	bio_for_each_segment_all(bv, bio, i) {
> 		bvec_for_each_page(page, bv, j) {
> 			page_endio(page, op_is_write(bio_op(bio)),
> 				blk_status_to_errno(bio->bi_status));
> 		}
> 	}
> 
> with additional helpers to get the length and offset for the page, e.g.
> 
> bvec_page_offset(bv, idx)
> bvev_page_len(bv, idx)
> 
> While this is a little more code in the callers it's a lot easier to
> understand.

Actually this patch is only a rename and the helper's sematics isn't
changed, so it doesn't affect the readability or understandablity,
and it clarifies that the helper fetches one page each time.

Also, once multipage bvec is done, we can rename bio_for_each_segment_all_sp()
into bio_for_each_page_all(), and rename bio_for_each_segment_all_mp() into
bio_for_each_segment_all(), which should be much easier to understand.

-- 
Ming

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
