Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0B3716B0254
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 02:16:33 -0400 (EDT)
Received: by mail-ig0-f171.google.com with SMTP id nk17so58080900igb.1
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 23:16:33 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id qf3si2173704igb.48.2016.03.14.23.16.31
        for <linux-mm@kvack.org>;
        Mon, 14 Mar 2016 23:16:32 -0700 (PDT)
Date: Tue, 15 Mar 2016 15:17:24 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCH v3 1/5] mm/zsmalloc: introduce class auto-compaction
Message-ID: <20160315061723.GB25154@bbox>
References: <1457016363-11339-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1457016363-11339-2-git-send-email-sergey.senozhatsky@gmail.com>
 <20160314061759.GC10675@bbox>
 <20160314074159.GA542@swordfish>
 <20160315004611.GA19514@bbox>
 <20160315013303.GC2126@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160315013303.GC2126@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 15, 2016 at 10:33:03AM +0900, Sergey Senozhatsky wrote:
> On (03/15/16 09:46), Minchan Kim wrote:
> [..]
> > > yes,
> > > 
> > > we do less work this way - scan and compact only one class, instead
> > > of locking and compacting all of them; which sounds reasonable.
> > 
> > Hmm,, It consumes more memory(i.e., sizeof(work_struct) + sizeof(void *)
> > + sizeof(bool) * NR_CLASS) as well as kicking many work up to NR_CLASS.
> 
> yes, it does. not really happy with it either.
> 
> > I didn't test your patch but I guess I can make worst case scenario.
> > 
> > * make every class fragmented under 40%
> > * On the 40% boundary, repeated alloc/free of every class so every free
> >   can schedule work if it was not scheduled.
> > * Although class fragment is too high, it's not a problem if the class
> >   consumes small amount of memory.
> 
> hm, in this scenario both solutions are less than perfect. we jump
> X times over 40% margin, we have X*NR_CLASS compaction scans in the
> end. the difference is that we queue less works, yes, but we don't
> have to use workqueue in the first place; compaction can be done
> asynchronously by a pool's dedicated kthread. so we will just
> wake_up() the process.

Hmm, kthread is over-engineered to me. If we want to create new kthread
in the system, I guess we should persuade many people to merge in.
Surely, we should have why it couldn't be done by others(e.g., workqueue).

I think your workqueue approach is good to me.
Only problem I can see with it is we cannot start compaction when
we want instantly so my conclusion is we need both direct and
background compaction.

For shrinker and user-space trigger knob, we could compact in that context
while we could queue background job to compact in zs_free.

> 
> > I guess it can make degradation if I try to test on zsmalloc
> > microbenchmark.
> > 
> > As well, although I don't know workqueue internal well, thesedays,
> > I saw a few of mails related to workqueue(maybe, vmstat) and it had
> > some trouble if system memory pressure is heavy IIRC.
> 
> yes, you are right. wq provides WQ_MEM_RECLAIM bit for this
> case -- a special kthread that it will wake up to process works.
> 
> > My approach is as follows, for exmaple.
> >
> > Let's make a global ratio. Let's say it's 4M.
> 
> ok. should it depend on pool size?  min(20% of pool_size, XXMB)?

Maybe, that could be a knob but need to think more what should be
default. In this moment, clear thing is that we should prevent
frequent ping-pong background compaction as repeated alloc/free
with dancing on threshold boundary.

> 
> > If zs_free(or something) realizes current fragment is over 4M,
> > kick compacion backgroud job.
> 
> yes, zs_free() is the only place that introduces fragmentation.
> 
> > The job scans from highest to lower class and compact zspages
> > in each size_class until it meets high watermark(e.g, 4M + 4M /2 =
> > 6M fragment ratio).
> 
> ok.
> 
> > And in the middle of background compaction, if we find it's too
> > many scan(e.g., 256 zspages or somethings), just bail out the
> > job for the latency and reschedule it for next time. At the next
> > time, we can continue from the last size class.
> 
> ok. I'd probably prefer more simple rules here:
> -- bail out because it has compacted XXMB
>    so the fragmentation ratio is *expected* to be below the watermark

Need high watermark to stop compaction.
It will prevent frequent background compaction triggering.


> -- nothing to scan anymore
>    compaction is executed concurrently with zs_free()/zs_malloc()
>    calls, it's harder to control/guarantee some global state.
> 
> overall, no real objections. this approach can work, I think. need
> to test it.

Thanks, Sergey!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
