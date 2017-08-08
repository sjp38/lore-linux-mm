Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1A10B6B02B4
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 08:36:44 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id y129so33720018pgy.1
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 05:36:44 -0700 (PDT)
Received: from server.coly.li (server.coly.li. [162.144.45.48])
        by mx.google.com with ESMTPS id k12si839174pfa.197.2017.08.08.05.36.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 05:36:42 -0700 (PDT)
Subject: Re: [PATCH v3 07/49] bcache: comment on direct access to bvec table
References: <20170808084548.18963-1-ming.lei@redhat.com>
 <20170808084548.18963-8-ming.lei@redhat.com>
From: Coly Li <i@coly.li>
Message-ID: <12a50c71-7b66-f9a4-6f9b-c10987426e30@coly.li>
Date: Tue, 8 Aug 2017 20:36:21 +0800
MIME-Version: 1.0
In-Reply-To: <20170808084548.18963-8-ming.lei@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>, Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-bcache@vger.kernel.org

On 2017/8/8 a,?a??4:45, Ming Lei wrote:
> Looks all are safe after multipage bvec is supported.
> 
> Cc: linux-bcache@vger.kernel.org
> Signed-off-by: Ming Lei <ming.lei@redhat.com>

Acked-by: Coly Li <colyli@suse.de>

Coly Li


> ---
>  drivers/md/bcache/btree.c | 1 +
>  drivers/md/bcache/super.c | 6 ++++++
>  drivers/md/bcache/util.c  | 7 +++++++
>  3 files changed, 14 insertions(+)
> 
> diff --git a/drivers/md/bcache/btree.c b/drivers/md/bcache/btree.c
> index 866dcf78ff8e..3da595ae565b 100644
> --- a/drivers/md/bcache/btree.c
> +++ b/drivers/md/bcache/btree.c
> @@ -431,6 +431,7 @@ static void do_btree_node_write(struct btree *b)
>  
>  		continue_at(cl, btree_node_write_done, NULL);
>  	} else {
> +		/* No harm for multipage bvec since the new is just allocated */
>  		b->bio->bi_vcnt = 0;
>  		bch_bio_map(b->bio, i);
>  
> diff --git a/drivers/md/bcache/super.c b/drivers/md/bcache/super.c
> index 8352fad765f6..6808f548cd13 100644
> --- a/drivers/md/bcache/super.c
> +++ b/drivers/md/bcache/super.c
> @@ -208,6 +208,7 @@ static void write_bdev_super_endio(struct bio *bio)
>  
>  static void __write_super(struct cache_sb *sb, struct bio *bio)
>  {
> +	/* single page bio, safe for multipage bvec */
>  	struct cache_sb *out = page_address(bio->bi_io_vec[0].bv_page);
>  	unsigned i;
>  
> @@ -1154,6 +1155,8 @@ static void register_bdev(struct cache_sb *sb, struct page *sb_page,
>  	dc->bdev->bd_holder = dc;
>  
>  	bio_init(&dc->sb_bio, dc->sb_bio.bi_inline_vecs, 1);
> +
> +	/* single page bio, safe for multipage bvec */
>  	dc->sb_bio.bi_io_vec[0].bv_page = sb_page;
>  	get_page(sb_page);
>  
> @@ -1799,6 +1802,7 @@ void bch_cache_release(struct kobject *kobj)
>  	for (i = 0; i < RESERVE_NR; i++)
>  		free_fifo(&ca->free[i]);
>  
> +	/* single page bio, safe for multipage bvec */
>  	if (ca->sb_bio.bi_inline_vecs[0].bv_page)
>  		put_page(ca->sb_bio.bi_io_vec[0].bv_page);
>  
> @@ -1854,6 +1858,8 @@ static int register_cache(struct cache_sb *sb, struct page *sb_page,
>  	ca->bdev->bd_holder = ca;
>  
>  	bio_init(&ca->sb_bio, ca->sb_bio.bi_inline_vecs, 1);
> +
> +	/* single page bio, safe for multipage bvec */
>  	ca->sb_bio.bi_io_vec[0].bv_page = sb_page;
>  	get_page(sb_page);
>  
> diff --git a/drivers/md/bcache/util.c b/drivers/md/bcache/util.c
> index 8c3a938f4bf0..11b4230ea6ad 100644
> --- a/drivers/md/bcache/util.c
> +++ b/drivers/md/bcache/util.c
> @@ -223,6 +223,13 @@ uint64_t bch_next_delay(struct bch_ratelimit *d, uint64_t done)
>  		: 0;
>  }
>  
> +/*
> + * Generally it isn't good to access .bi_io_vec and .bi_vcnt
> + * directly, the preferred way is bio_add_page, but in
> + * this case, bch_bio_map() supposes that the bvec table
> + * is empty, so it is safe to access .bi_vcnt & .bi_io_vec
> + * in this way even after multipage bvec is supported.
> + */
>  void bch_bio_map(struct bio *bio, void *base)
>  {
>  	size_t size = bio->bi_iter.bi_size;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
