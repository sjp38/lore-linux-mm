Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 860E26B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 19:44:49 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id y13so279986pdi.30
        for <linux-mm@kvack.org>; Thu, 29 May 2014 16:44:49 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id cs2si2896429pbc.242.2014.05.29.16.44.47
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 16:44:48 -0700 (PDT)
Date: Fri, 30 May 2014 08:45:22 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: virtio ring cleanups, which save stack on older gcc
Message-ID: <20140529234522.GL10092@bbox>
References: <87oayh6s3s.fsf@rustcorp.com.au>
 <1401348405-18614-1-git-send-email-rusty@rustcorp.com.au>
 <20140529074117.GI10092@bbox>
 <87fvjs7sge.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87fvjs7sge.fsf@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Thu, May 29, 2014 at 08:38:33PM +0930, Rusty Russell wrote:
> Minchan Kim <minchan@kernel.org> writes:
> > Hello Rusty,
> >
> > On Thu, May 29, 2014 at 04:56:41PM +0930, Rusty Russell wrote:
> >> They don't make much difference: the easier fix is use gcc 4.8
> >> which drops stack required across virtio block's virtio_queue_rq
> >> down to that kmalloc in virtio_ring from 528 to 392 bytes.
> >> 
> >> Still, these (*lightly tested*) patches reduce to 432 bytes,
> >> even for gcc 4.6.4.  Posted here FYI.
> >
> > I am testing with below which was hack for Dave's idea so don't have
> > a machine to test your patches until tomorrow.
> > So, I will queue your patches into testing machine tomorrow morning.
> 
> More interesting would be updating your compiler to 4.8, I think.
> Saving <100 bytes on virtio is not going to save you, right?

But in my report, virtio_ring consumes more than yours.
As I mentioned other thread to Steven, I don't know why stacktrace report
vring_add_indirect consumes 376-byte. Apparently, objdump says it didn't
consume too much so I'd like to test your patches and see the result.

Thanks.

[ 1065.604404] kworker/-5766    0d..2 1071625993us : stack_trace_call:  10)     6376     376   vring_add_indirect+0x36/0x200
[ 1065.604404] kworker/-5766    0d..2 1071625993us : stack_trace_call:  11)     6000     144   virtqueue_add_sgs+0x2e2/0x320
[ 1065.604404] kworker/-5766    0d..2 1071625993us : stack_trace_call:  12)     5856     288   __virtblk_add_req+0xda/0x1b0
[ 1065.604404] kworker/-5766    0d..2 1071625993us : stack_trace_call:  13)     5568      96   virtio_queue_rq+0xd3/0x1d0

> 
> Cheers,
> Rusty.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
