Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id AC6DE6B02CF
	for <linux-mm@kvack.org>; Fri, 25 May 2018 00:42:37 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id w74-v6so515483qka.4
        for <linux-mm@kvack.org>; Thu, 24 May 2018 21:42:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h18-v6sor15362559qkj.134.2018.05.24.21.42.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 May 2018 21:42:31 -0700 (PDT)
Date: Fri, 25 May 2018 00:42:27 -0400
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: Re: [RESEND PATCH V5 12/33] block: introduce bio_segments()
Message-ID: <20180525044227.GA8740@kmo-pixel>
References: <20180525034621.31147-1-ming.lei@redhat.com>
 <20180525034621.31147-13-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180525034621.31147-13-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>

On Fri, May 25, 2018 at 11:46:00AM +0800, Ming Lei wrote:
> There are still cases in which we need to use bio_segments() for get the
> number of segment, so introduce it.
> 
> Signed-off-by: Ming Lei <ming.lei@redhat.com>
> ---
>  include/linux/bio.h | 25 ++++++++++++++++++++-----
>  1 file changed, 20 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/bio.h b/include/linux/bio.h
> index 08af9272687f..b24c00f99c9c 100644
> --- a/include/linux/bio.h
> +++ b/include/linux/bio.h
> @@ -227,9 +227,9 @@ static inline bool bio_rewind_iter(struct bio *bio, struct bvec_iter *iter,
>  
>  #define bio_iter_last(bvec, iter) ((iter).bi_size == (bvec).bv_len)
>  
> -static inline unsigned bio_pages(struct bio *bio)
> +static inline unsigned __bio_elements(struct bio *bio, bool seg)

This is a rather silly helper function, there isn't any actual code that's
shared, everything's behind an if () statement. Just open code it in bio_pages()
and bio_segments()

>  {
> -	unsigned segs = 0;
> +	unsigned elems = 0;
>  	struct bio_vec bv;
>  	struct bvec_iter iter;
>  
> @@ -249,10 +249,25 @@ static inline unsigned bio_pages(struct bio *bio)
>  		break;
>  	}
>  
> -	bio_for_each_page(bv, bio, iter)
> -		segs++;
> +	if (!seg) {
> +		bio_for_each_page(bv, bio, iter)
> +			elems++;
> +	} else {
> +		bio_for_each_segment(bv, bio, iter)
> +			elems++;
> +	}
> +
> +	return elems;
> +}
> +
> +static inline unsigned bio_pages(struct bio *bio)
> +{
> +	return __bio_elements(bio, false);
> +}
>  
> -	return segs;
> +static inline unsigned bio_segments(struct bio *bio)
> +{
> +	return __bio_elements(bio, true);
>  }
>  
>  /*
> -- 
> 2.9.5
> 
