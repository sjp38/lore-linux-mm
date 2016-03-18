Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 14D156B007E
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 21:16:47 -0400 (EDT)
Received: by mail-io0-f169.google.com with SMTP id o5so36516548iod.2
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 18:16:47 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id pn6si347554igb.44.2016.03.17.18.16.45
        for <linux-mm@kvack.org>;
        Thu, 17 Mar 2016 18:16:46 -0700 (PDT)
Date: Fri, 18 Mar 2016 10:17:41 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCH v3 1/5] mm/zsmalloc: introduce class auto-compaction
Message-ID: <20160318011741.GD2154@bbox>
References: <1457016363-11339-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1457016363-11339-2-git-send-email-sergey.senozhatsky@gmail.com>
 <20160314061759.GC10675@bbox>
 <20160314074159.GA542@swordfish>
 <20160315004611.GA19514@bbox>
 <20160315013303.GC2126@swordfish>
 <20160315061723.GB25154@bbox>
 <20160317012929.GA489@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160317012929.GA489@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Sergey,

On Thu, Mar 17, 2016 at 10:29:30AM +0900, Sergey Senozhatsky wrote:
> Hello Minchan,
> 
> On (03/15/16 15:17), Minchan Kim wrote:
> [..]
> > > hm, in this scenario both solutions are less than perfect. we jump
> > > X times over 40% margin, we have X*NR_CLASS compaction scans in the
> > > end. the difference is that we queue less works, yes, but we don't
> > > have to use workqueue in the first place; compaction can be done
> > > asynchronously by a pool's dedicated kthread. so we will just
> > > wake_up() the process.
> > 
> > Hmm, kthread is over-engineered to me. If we want to create new kthread
> > in the system, I guess we should persuade many people to merge in.
> > Surely, we should have why it couldn't be done by others(e.g., workqueue).
> > 
> > I think your workqueue approach is good to me.
> > Only problem I can see with it is we cannot start compaction when
> > we want instantly so my conclusion is we need both direct and
> > background compaction.
> 
> well, if we will keep the shrinker callbacks then it's not such a huge
> issue, IMHO. for that type of forward progress guarantees we can have
> our own, dedicated, workqueue with a rescuer thread (WQ_MEM_RECLAIM).

What I meant with direct compaction is shrinker while backgroud
compaction is workqueue.
So do you mean that you agree to remain shrinker?
And do you want to use workqueue with WQ_MEM_RECLAIM rather than
new kthread?

> 
> > > > If zs_free(or something) realizes current fragment is over 4M,
> > > > kick compacion backgroud job.
> > > 
> > > yes, zs_free() is the only place that introduces fragmentation.
> > > 
> > > > The job scans from highest to lower class and compact zspages
> > > > in each size_class until it meets high watermark(e.g, 4M + 4M /2 =
> > > > 6M fragment ratio).
> 
> just thought... I think it'll be tricky to implement this. We scan classes
> from HIGH class_size to SMALL class_size, counting fragmentation value and
> re-calculating the global fragmentation all the time; once the global
> fragmentation passes the watermark, we start compacting from HIGH to
> SMALL. the problem here is that as soon as we calculated the class B
> fragmentation index and moved to class A we can't trust B anymore. classes
> are not locked and absolutely free to change. so the global fragmentation
> index likely will be inaccurate.
> 

Actually, I don't think such inaccuracy will make big trouble here.
But How about this simple idea?

If zs_free find wasted space is bigger than threshold(e.g., 10M)
user defined, zs_free can queue work for background compaction(
that background compaction work should be WQ_MEM_RECLAIM |
WQ_CPU_INTENSIVE?). Once that work is executed, the work compacts
all size_class unconditionally.

With it, less background compaction and more simple algorithm,
no harmful other works by WQ_CPU_INTENSIVE.

> so I'm thinking about triggering a global compaction from zs_free() (to
> queue less works), but instead of calculating global watermark and compacting
> afterwards, just compact every class that has fragmentation over XY% (for
> example 30%). "iterate from HI to LO and compact everything that is too
> fragmented".

The problem with approach is we can compact only small size class which
is fragment ratio is higher than bigger size class but compaction benefit
is smaller than higher size class which is lower fragment ratio.
With that, continue to need to background work until it meets user-defined
global threshold.

> 
> we still need some sort of a pool->compact_ts timestamp to prevent too
> frequent compaction jobs.

Yes, we need something to throttle mechanism. Need time to think more. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
