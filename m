Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 534C46B0095
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 18:59:20 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id up15so4705188pbc.30
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 15:59:20 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:5])
        by mx.google.com with ESMTP id zz3si17823242pac.115.2014.06.02.15.59.18
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 15:59:19 -0700 (PDT)
Date: Tue, 3 Jun 2014 08:59:11 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
Message-ID: <20140602225911.GU14410@dastard>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
 <1401260039-18189-2-git-send-email-minchan@kernel.org>
 <CA+55aFxXdc22dirnE49UbQP_2s2vLQpjQFL+NptuyK7Xry6c=g@mail.gmail.com>
 <20140528223142.GO8554@dastard>
 <CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>
 <20140529013007.GF6677@dastard>
 <CA+55aFzdq2V-Q3WUV7hQJG8jBSAvBqdYLVTNtbD4ObVZ5yDRmw@mail.gmail.com>
 <5389393D.2030305@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5389393D.2030305@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Fri, May 30, 2014 at 08:06:53PM -0600, Jens Axboe wrote:
> On 2014-05-28 20:42, Linus Torvalds wrote:
> >Well, we've definitely have had some issues with deeper callchains
> >with md, but I suspect virtio might be worse, and the new blk-mq code
> >is lilkely worse in this respect too.
> 
> I don't think blk-mq is worse than the older stack, in fact it
> should be better. The call chains are shorter, and a lot less cruft
> on the stack. Historically the stack issues have been nested
> devices, however. And for sync IO, we do run it inline, so if the
> driver chews up a lot of stack, well...

Hi Jens - as we found out with the mm code, there's a significant
disconnect between what the code looks like (i.e. it may use very
little stack directly) and what the compiler is generating.

Before blk-mq:

  9)     3952     112   scsi_request_fn+0x4b/0x490
 10)     3840      32   __blk_run_queue+0x37/0x50
 11)     3808      64   queue_unplugged+0x39/0xb0
 12)     3744     112   blk_flush_plug_list+0x20b/0x240

Now with blk-mq:

  3)     4672      96   virtio_queue_rq+0xd2/0x1e0
  4)     4576     128   __blk_mq_run_hw_queue+0x1f0/0x3e0
  5)     4448      16   blk_mq_run_hw_queue+0x35/0x40
  6)     4432      80   blk_mq_insert_requests+0xc7/0x130
  7)     4352      96   blk_mq_flush_plug_list+0x129/0x140
  8)     4256     112   blk_flush_plug_list+0xe7/0x230

So previously flushing a plug used rough 200 bytes of stack.  With
blk-mq, it's over 400 bytes. IOWs, blk-mq has more than doubled the
block layer stack usage...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
