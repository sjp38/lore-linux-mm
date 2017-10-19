Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 05C5D6B0253
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 18:51:45 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id m189so9603223qke.21
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 15:51:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a27si7490258qtd.351.2017.10.19.15.51.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 15:51:44 -0700 (PDT)
Date: Fri, 20 Oct 2017 06:51:10 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH v3 07/49] bcache: comment on direct access to bvec table
Message-ID: <20171019225109.GA27130@ming.t460p>
References: <20170808084548.18963-1-ming.lei@redhat.com>
 <20170808084548.18963-8-ming.lei@redhat.com>
 <20170810112603.GD20308@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810112603.GD20308@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jens Axboe <axboe@fb.com>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-bcache@vger.kernel.org

On Thu, Aug 10, 2017 at 04:26:03AM -0700, Christoph Hellwig wrote:
> I think all this bcache code needs bigger attention.  For one
> bio_alloc_pages is only used in bcache, so we should move it in there.

Looks a good idea.

> 
> Second the way  bio_alloc_pages is currently written looks potentially
> dangerous for multi-page biovecs, so we should think about a better
> calling convention.  The way bcache seems to generally use it is by
> allocating a bio, then calling bch_bio_map on it and then calling
> bio_alloc_pages.  I think it just needs a new bio_alloc_pages calling
> convention that passes the size to be allocated and stop looking into
> the segment count.

Looks a good idea, will try to do in this way.

> 
> Second bch_bio_map isn't something we should be doing in a driver,
> it should be rewritten using bio_add_page.

Yes, the idea way is to use bio_add_page always, but given
bch_bio_map() is used on a fresh bio, it is safe, and this
work can be done in another bcache cleanup patch.

> 
> > diff --git a/drivers/md/bcache/btree.c b/drivers/md/bcache/btree.c
> > index 866dcf78ff8e..3da595ae565b 100644
> > --- a/drivers/md/bcache/btree.c
> > +++ b/drivers/md/bcache/btree.c
> > @@ -431,6 +431,7 @@ static void do_btree_node_write(struct btree *b)
> >  
> >  		continue_at(cl, btree_node_write_done, NULL);
> >  	} else {
> > +		/* No harm for multipage bvec since the new is just allocated */
> >  		b->bio->bi_vcnt = 0;
> 
> This should go away - bio_alloc_pages or it's replacement should not
> modify bi_vcnt on failure.

OK.

> 
> > +	/* single page bio, safe for multipage bvec */
> >  	dc->sb_bio.bi_io_vec[0].bv_page = sb_page;
> 
> needs to use bio_add_page.

OK.

> 
> > +	/* single page bio, safe for multipage bvec */
> >  	ca->sb_bio.bi_io_vec[0].bv_page = sb_page;
> 
> needs to use bio_add_page.

OK.

-- 
Ming

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
