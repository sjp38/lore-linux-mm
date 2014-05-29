Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id 176746B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 07:07:02 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id w62so208762wes.30
        for <linux-mm@kvack.org>; Thu, 29 May 2014 04:07:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id q3si20094842wic.7.2014.05.29.04.06.28
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 04:06:29 -0700 (PDT)
Date: Thu, 29 May 2014 13:07:23 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/4] virtio_net: pass well-formed sg to
 virtqueue_add_inbuf()
Message-ID: <20140529100723.GA30210@redhat.com>
References: <87oayh6s3s.fsf@rustcorp.com.au>
 <1401348405-18614-1-git-send-email-rusty@rustcorp.com.au>
 <1401348405-18614-3-git-send-email-rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1401348405-18614-3-git-send-email-rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Minchan Kim <minchan@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Thu, May 29, 2014 at 04:56:43PM +0930, Rusty Russell wrote:
> This is the only place which doesn't hand virtqueue_add_inbuf or
> virtqueue_add_outbuf a well-formed, well-terminated sg.  Fix it,
> so we can make virtio_add_* simpler.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> ---
>  drivers/net/virtio_net.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 8a852b5f215f..63299b04cdf2 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -590,6 +590,8 @@ static int add_recvbuf_big(struct receive_queue *rq, gfp_t gfp)
>  	offset = sizeof(struct padded_vnet_hdr);
>  	sg_set_buf(&rq->sg[1], p + offset, PAGE_SIZE - offset);
>  
> +	sg_mark_end(&rq->sg[MAX_SKB_FRAGS + 2 - 1]);
> +
>  	/* chain first in list head */
>  	first->private = (unsigned long)list;
>  	err = virtqueue_add_inbuf(rq->vq, rq->sg, MAX_SKB_FRAGS + 2,

Not that performance of add_recvbuf_big actually mattered anymore, but
in fact this can be done in virtnet_probe if we like.


Anyway

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> -- 
> 1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
