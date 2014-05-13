Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5DE4F6B003C
	for <linux-mm@kvack.org>; Tue, 13 May 2014 09:50:10 -0400 (EDT)
Received: by mail-ee0-f53.google.com with SMTP id c13so434935eek.26
        for <linux-mm@kvack.org>; Tue, 13 May 2014 06:50:09 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i49si13198130eem.312.2014.05.13.06.50.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 May 2014 06:50:09 -0700 (PDT)
Date: Tue, 13 May 2014 15:50:07 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 17/19] fs: buffer: Do not use unnecessary atomic
 operations when discarding buffers
Message-ID: <20140513135007.GE22070@quack.suse.cz>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-18-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1399974350-11089-18-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Tue 13-05-14 10:45:48, Mel Gorman wrote:
> Discarding buffers uses a bunch of atomic operations when discarding buffers
> because ...... I can't think of a reason. Use a cmpxchg loop to clear all the
> necessary flags. In most (all?) cases this will be a single atomic operations.
  Looks good. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  fs/buffer.c                 | 14 +++++++++-----
>  include/linux/buffer_head.h |  5 +++++
>  2 files changed, 14 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/buffer.c b/fs/buffer.c
> index 9ddb9fc..e80012d 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -1485,14 +1485,18 @@ EXPORT_SYMBOL(set_bh_page);
>   */
>  static void discard_buffer(struct buffer_head * bh)
>  {
> +	unsigned long b_state, b_state_old;
> +
>  	lock_buffer(bh);
>  	clear_buffer_dirty(bh);
>  	bh->b_bdev = NULL;
> -	clear_buffer_mapped(bh);
> -	clear_buffer_req(bh);
> -	clear_buffer_new(bh);
> -	clear_buffer_delay(bh);
> -	clear_buffer_unwritten(bh);
> +	b_state = bh->b_state;
> +	for (;;) {
> +		b_state_old = cmpxchg(&bh->b_state, b_state, (b_state & ~BUFFER_FLAGS_DISCARD));
> +		if (b_state_old == b_state)
> +			break;
> +		b_state = b_state_old;
> +	}
>  	unlock_buffer(bh);
>  }
>  
> diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
> index c40302f..95f565a 100644
> --- a/include/linux/buffer_head.h
> +++ b/include/linux/buffer_head.h
> @@ -77,6 +77,11 @@ struct buffer_head {
>  	atomic_t b_count;		/* users using this buffer_head */
>  };
>  
> +/* Bits that are cleared during an invalidate */
> +#define BUFFER_FLAGS_DISCARD \
> +	(1 << BH_Mapped | 1 << BH_New | 1 << BH_Req | \
> +	 1 << BH_Delay | 1 << BH_Unwritten)
> +
>  /*
>   * macro tricks to expand the set_buffer_foo(), clear_buffer_foo()
>   * and buffer_foo() functions.
> -- 
> 1.8.4.5
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
