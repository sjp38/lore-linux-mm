Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7E1F06B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 07:33:53 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id u57so247130wes.15
        for <linux-mm@kvack.org>; Thu, 29 May 2014 04:33:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id em6si1573983wib.59.2014.05.29.04.33.30
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 04:33:31 -0700 (PDT)
Date: Thu, 29 May 2014 14:33:17 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 4/4] virtio_ring: unify direct/indirect code paths.
Message-ID: <20140529113317.GE30210@redhat.com>
References: <87oayh6s3s.fsf@rustcorp.com.au>
 <1401348405-18614-1-git-send-email-rusty@rustcorp.com.au>
 <1401348405-18614-5-git-send-email-rusty@rustcorp.com.au>
 <20140529075256.GZ30445@twins.programming.kicks-ass.net>
 <87iooo7skp.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87iooo7skp.fsf@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Minchan Kim <minchan@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Thu, May 29, 2014 at 08:35:58PM +0930, Rusty Russell wrote:
> Peter Zijlstra <peterz@infradead.org> writes:
> > On Thu, May 29, 2014 at 04:56:45PM +0930, Rusty Russell wrote:
> >> Before:
> >> 	gcc 4.8.2: virtio_blk: stack used = 392
> >> 	gcc 4.6.4: virtio_blk: stack used = 480
> >> 
> >> After:
> >> 	gcc 4.8.2: virtio_blk: stack used = 408
> >> 	gcc 4.6.4: virtio_blk: stack used = 432
> >
> > Is it worth it to make the good compiler worse? People are going to use
> > the newer GCC more as time goes on anyhow.
> 
> No, but it's only 16 bytes of stack loss for a simplicity win:
> 
>  virtio_ring.c |  120 +++++++++++++++++++++-------------------------------------
>  1 file changed, 45 insertions(+), 75 deletions(-)
> 
> Cheers,
> Rusty.

I'm concerned that we are doing an extra descriptor walk now though.
And desc == &vq.desc at the end is kind of ugly too.

How about
		if (indirect)
                        vq->vring.desc[i].next = i + 1;
		else
                        i = vq->vring.desc[i].next;

or something like this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
