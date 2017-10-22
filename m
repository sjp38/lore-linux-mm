Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CA7F56B0033
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 19:53:46 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v78so14946401pfk.8
        for <linux-mm@kvack.org>; Sun, 22 Oct 2017 16:53:46 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id d125si4054218pgc.444.2017.10.22.16.53.44
        for <linux-mm@kvack.org>;
        Sun, 22 Oct 2017 16:53:45 -0700 (PDT)
Date: Mon, 23 Oct 2017 08:53:35 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v2 4/4] lockdep: Assign a lock_class per gendisk used for
 wait_for_completion()
Message-ID: <20171022235334.GH3310@X58A-UD3R>
References: <1508392531-11284-1-git-send-email-byungchul.park@lge.com>
 <1508396607-25362-1-git-send-email-byungchul.park@lge.com>
 <1508396607-25362-5-git-send-email-byungchul.park@lge.com>
 <20171020144451.GA16793@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171020144451.GA16793@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: peterz@infradead.org, mingo@kernel.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, idryomov@gmail.com, kernel-team@lge.com

On Fri, Oct 20, 2017 at 07:44:51AM -0700, Christoph Hellwig wrote:
> The Subject prefix for this should be "block:".
> 
> > @@ -945,7 +945,7 @@ int submit_bio_wait(struct bio *bio)
> >  {
> >  	struct submit_bio_ret ret;
> >  
> > -	init_completion(&ret.event);
> > +	init_completion_with_map(&ret.event, &bio->bi_disk->lockdep_map);
> 
> FYI, I have an outstanding patch to simplify this a lot, which
> switches this to DECLARE_COMPLETION_ONSTACK.  I can delay this or let
> you pick it up with your series, but we'll need a variant of
> DECLARE_COMPLETION_ONSTACK with the lockdep annotations.

Hello,

I'm sorry for late.

I think your patch makes block code simpler and better. I like it.

But, I just wonder if it's related to my series. Is it proper to add
your patch into my series?

Thanks,
Byungchul

> Patch below for reference:
> 
> ---
> >From d65b89843c9f82c0744643515ba51dd10e66e67b Mon Sep 17 00:00:00 2001
> From: Christoph Hellwig <hch@lst.de>
> Date: Thu, 5 Oct 2017 18:31:02 +0200
> Subject: block: use DECLARE_COMPLETION_ONSTACK in submit_bio_wait
> 
> Simplify the code by getting rid of the submit_bio_ret structure.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  block/bio.c | 19 +++++--------------
>  1 file changed, 5 insertions(+), 14 deletions(-)
> 
> diff --git a/block/bio.c b/block/bio.c
> index 8338304ea256..4e18e959fc0a 100644
> --- a/block/bio.c
> +++ b/block/bio.c
> @@ -917,17 +917,9 @@ int bio_iov_iter_get_pages(struct bio *bio, struct iov_iter *iter)
>  }
>  EXPORT_SYMBOL_GPL(bio_iov_iter_get_pages);
>  
> -struct submit_bio_ret {
> -	struct completion event;
> -	int error;
> -};
> -
>  static void submit_bio_wait_endio(struct bio *bio)
>  {
> -	struct submit_bio_ret *ret = bio->bi_private;
> -
> -	ret->error = blk_status_to_errno(bio->bi_status);
> -	complete(&ret->event);
> +	complete(bio->bi_private);
>  }
>  
>  /**
> @@ -943,16 +935,15 @@ static void submit_bio_wait_endio(struct bio *bio)
>   */
>  int submit_bio_wait(struct bio *bio)
>  {
> -	struct submit_bio_ret ret;
> +	DECLARE_COMPLETION_ONSTACK(done);
>  
> -	init_completion(&ret.event);
> -	bio->bi_private = &ret;
> +	bio->bi_private = &done;
>  	bio->bi_end_io = submit_bio_wait_endio;
>  	bio->bi_opf |= REQ_SYNC;
>  	submit_bio(bio);
> -	wait_for_completion_io(&ret.event);
> +	wait_for_completion_io(&done);
>  
> -	return ret.error;
> +	return blk_status_to_errno(bio->bi_status);
>  }
>  EXPORT_SYMBOL(submit_bio_wait);
>  
> -- 
> 2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
