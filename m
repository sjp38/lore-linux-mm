Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 121CE6B007E
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 21:59:42 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id 4so14280918pfd.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 18:59:42 -0700 (PDT)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id wk6si6313747pac.91.2016.03.17.18.59.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Mar 2016 18:59:41 -0700 (PDT)
Received: by mail-pf0-x233.google.com with SMTP id 4so14280569pfd.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 18:59:41 -0700 (PDT)
Date: Fri, 18 Mar 2016 11:00:29 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH v3 1/5] mm/zsmalloc: introduce class auto-compaction
Message-ID: <20160318020029.GC572@swordfish>
References: <1457016363-11339-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1457016363-11339-2-git-send-email-sergey.senozhatsky@gmail.com>
 <20160314061759.GC10675@bbox>
 <20160314074159.GA542@swordfish>
 <20160315004611.GA19514@bbox>
 <20160315013303.GC2126@swordfish>
 <20160315061723.GB25154@bbox>
 <20160317012929.GA489@swordfish>
 <20160318011741.GD2154@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160318011741.GD2154@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

On (03/18/16 10:17), Minchan Kim wrote:
> > > > hm, in this scenario both solutions are less than perfect. we jump
> > > > X times over 40% margin, we have X*NR_CLASS compaction scans in the
> > > > end. the difference is that we queue less works, yes, but we don't
> > > > have to use workqueue in the first place; compaction can be done
> > > > asynchronously by a pool's dedicated kthread. so we will just
> > > > wake_up() the process.
> > > 
> > > Hmm, kthread is over-engineered to me. If we want to create new kthread
> > > in the system, I guess we should persuade many people to merge in.
> > > Surely, we should have why it couldn't be done by others(e.g., workqueue).
> > > 
> > > I think your workqueue approach is good to me.
> > > Only problem I can see with it is we cannot start compaction when
> > > we want instantly so my conclusion is we need both direct and
> > > background compaction.
> > 
> > well, if we will keep the shrinker callbacks then it's not such a huge
> > issue, IMHO. for that type of forward progress guarantees we can have
> > our own, dedicated, workqueue with a rescuer thread (WQ_MEM_RECLAIM).
> 
> What I meant with direct compaction is shrinker while backgroud
> compaction is workqueue.
> So do you mean that you agree to remain shrinker?

hm, probably yes, hard to say. we don't have yet a solution for background
compaction.

> And do you want to use workqueue with WQ_MEM_RECLAIM rather than
> new kthread?

I have some concerns here. WQ_MEM_RECLAIM implies that there is a kthread
attached to wq, a rescuer thread, which will be idle until wq declares mayday.
But the kthread will be allocated anyway. And we can queue only one global
compaction work at a time; so wq does not buy us a lot here and a simple
wake_up_process() looks much better. it make sense to use wq if we can have
N compaction jobs queued, like I did in my initial patch, but otherwise
it's sort of overkill, isn't it?

> > just thought... I think it'll be tricky to implement this. We scan classes
> > from HIGH class_size to SMALL class_size, counting fragmentation value and
> > re-calculating the global fragmentation all the time; once the global
> > fragmentation passes the watermark, we start compacting from HIGH to
> > SMALL. the problem here is that as soon as we calculated the class B
> > fragmentation index and moved to class A we can't trust B anymore. classes
> > are not locked and absolutely free to change. so the global fragmentation
> > index likely will be inaccurate.
> > 
> 
> Actually, I don't think such inaccuracy will make big trouble here.
> But How about this simple idea?
> 
> If zs_free find wasted space is bigger than threshold(e.g., 10M)
>
> user defined, zs_free can queue work for background compaction(
> that background compaction work should be WQ_MEM_RECLAIM |
> WQ_CPU_INTENSIVE?). Once that work is executed, the work compacts
> all size_class unconditionally.

ok. global pool stats that will give us a fragmentation index, so we can
start compaction when the entire pool passes the watermark, not an
individual class.

> With it, less background compaction and more simple algorithm,

so you want to have

	zs_free()
		check pool watermark
			queue class compaction
			queue pool compaction

?

I think a simpler one will be to just queue global compaction, if pool
is fragmented -- compact everything, like we do in shrinker callback.

> no harmful other works by WQ_CPU_INTENSIVE.
> 
> > so I'm thinking about triggering a global compaction from zs_free() (to
> > queue less works), but instead of calculating global watermark and compacting
> > afterwards, just compact every class that has fragmentation over XY% (for
> > example 30%). "iterate from HI to LO and compact everything that is too
> > fragmented".
> 
> The problem with approach is we can compact only small size class which
> is fragment ratio is higher than bigger size class but compaction benefit
> is smaller than higher size class which is lower fragment ratio.
> With that, continue to need to background work until it meets user-defined
> global threshold.

good point.

> > 
> > we still need some sort of a pool->compact_ts timestamp to prevent too
> > frequent compaction jobs.
> 
> Yes, we need something to throttle mechanism. Need time to think more. :)

yes, need to think more :)

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
