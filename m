Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 239486B0007
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 11:55:59 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id o2-v6so1409978edt.4
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 08:55:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i3-v6si2213399edq.22.2018.06.27.08.55.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jun 2018 08:55:57 -0700 (PDT)
Subject: Re: [PATCH V7 20/24] bcache: avoid to use bio_for_each_segment_all()
 in bch_bio_alloc_pages()
References: <20180627124548.3456-1-ming.lei@redhat.com>
 <20180627124548.3456-21-ming.lei@redhat.com>
From: Coly Li <colyli@suse.de>
Message-ID: <e1499d87-62b8-40a8-75a5-d9d1d81ce9c5@suse.de>
Date: Wed, 27 Jun 2018 23:55:33 +0800
MIME-Version: 1.0
In-Reply-To: <20180627124548.3456-21-ming.lei@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Kent Overstreet <kent.overstreet@gmail.com>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, Mike Snitzer <snitzer@redhat.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>, linux-bcache@vger.kernel.org

On 2018/6/27 8:45 PM, Ming Lei wrote:
> bch_bio_alloc_pages() is always called on one new bio, so it is safe
> to access the bvec table directly. Given it is the only kind of this
> case, open code the bvec table access since bio_for_each_segment_all()
> will be changed to support for iterating over multipage bvec.
> 
> Cc: Coly Li <colyli@suse.de>
> Cc: linux-bcache@vger.kernel.org
> Signed-off-by: Ming Lei <ming.lei@redhat.com>
> ---
>  drivers/md/bcache/util.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/md/bcache/util.c b/drivers/md/bcache/util.c
> index fc479b026d6d..9f2a6fd5dfc9 100644
> --- a/drivers/md/bcache/util.c
> +++ b/drivers/md/bcache/util.c
> @@ -268,7 +268,7 @@ int bch_bio_alloc_pages(struct bio *bio, gfp_t gfp_mask)
>  	int i;
>  	struct bio_vec *bv;
> 

Hi Ming,

> -	bio_for_each_segment_all(bv, bio, i) {
> +	for (i = 0, bv = bio->bi_io_vec; i < bio->bi_vcnt; bv++) {


Is it possible to treat this as a special condition of
bio_for_each_segement_all() ? I mean only iterate one time in
bvec_for_each_segment(). I hope the above change is not our last choice
before I reply an Acked-by :-)

Thanks.

Coly Li

>  		bv->bv_page = alloc_page(gfp_mask);
>  		if (!bv->bv_page) {
>  			while (--bv >= bio->bi_io_vec)
> 
