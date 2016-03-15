Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1259B6B0005
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 20:45:22 -0400 (EDT)
Received: by mail-pf0-f177.google.com with SMTP id x3so3209855pfb.1
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 17:45:22 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 68si5159474pfj.77.2016.03.14.17.45.20
        for <linux-mm@kvack.org>;
        Mon, 14 Mar 2016 17:45:21 -0700 (PDT)
Date: Tue, 15 Mar 2016 09:46:11 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCH v3 1/5] mm/zsmalloc: introduce class auto-compaction
Message-ID: <20160315004611.GA19514@bbox>
References: <1457016363-11339-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1457016363-11339-2-git-send-email-sergey.senozhatsky@gmail.com>
 <20160314061759.GC10675@bbox>
 <20160314074159.GA542@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160314074159.GA542@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Mar 14, 2016 at 04:41:59PM +0900, Sergey Senozhatsky wrote:
> Hello Minchan,
> 
> On (03/14/16 15:17), Minchan Kim wrote:
> [..]
> > > demonstrates that class-896 has 12/26=46% of unused pages, class-2336 has
> > > 1648/4932=33% of unused pages, etc. And the more classes we will have as
> > > 'normal' classes (more than one object per-zspage) the bigger this problem
> > > will grow. The existing compaction relies on a user space (user can trigger
> > > compaction via `compact' zram's sysfs attr) or a shrinker; it does not
> > > happen automatically.
> > > 
> > > This patch introduces a 'watermark' value of unused pages and schedules a
> > > compaction work on a per-class basis once class's fragmentation becomes
> > > too big. So compaction is not performed in current I/O operation context,
> > > but in workqueue workers later.
> > > 
> > > The current watermark is set to 40% -- if class has 40+% of `freeable'
> > > pages then compaction work will be scheduled.
> > 
> > Could you explain why you select per-class watermark?
> 
> yes,
> 
> we do less work this way - scan and compact only one class, instead
> of locking and compacting all of them; which sounds reasonable.

Hmm,, It consumes more memory(i.e., sizeof(work_struct) + sizeof(void *)
+ sizeof(bool) * NR_CLASS) as well as kicking many work up to NR_CLASS.
I didn't test your patch but I guess I can make worst case scenario.

* make every class fragmented under 40%
* On the 40% boundary, repeated alloc/free of every class so every free
  can schedule work if it was not scheduled.
* Although class fragment is too high, it's not a problem if the class
  consumes small amount of memory.

I guess it can make degradation if I try to test on zsmalloc
microbenchmark.

As well, although I don't know workqueue internal well, thesedays,
I saw a few of mails related to workqueue(maybe, vmstat) and it had
some trouble if system memory pressure is heavy IIRC.

My approach is as follows, for exmaple.

Let's make a global ratio. Let's say it's 4M.
If zs_free(or something) realizes current fragment is over 4M,
kick compacion backgroud job.
The job scans from highest to lower class and compact zspages
in each size_class until it meets high watermark(e.g, 4M + 4M /2 =
6M fragment ratio).
And in the middle of background compaction, if we find it's too
many scan(e.g., 256 zspages or somethings), just bail out the
job for the latency and reschedule it for next time. At the next
time, we can continue from the last size class.

I know your concern is unncessary scan but I'm not sure it can
affect performance although we try to evaluate performance with
microbenchmark. It just loops and check with zs_can_compact
for 255 size class.

If you still don't like this approach, we can implement each
solution and test/compare. ;-)

> 
> 
> > Because my plan was we kick background work based on total fragmented memory
> > (i.e., considering used_pages/allocated_pages < some threshold).
> 
> if we know that a particular class B is fragmented and the rest of them
> are just fine, then we can compact only that class B, skipping extra job.
> 
> > IOW, if used_pages/allocated_pages is less than some ratio,
> > we kick background job with marking index of size class just freed
> > and then the job scans size_class from the index circulary.
> >
> > As well, we should put a upper bound to scan zspages to make it
> > deterministic.
> 
> you mean that __zs_compact() instead of just checking per-class
> zs_can_compact() should check global pool ratio and bail out if
> compaction of class Z has dropped the overall fragmentation ratio
> below some watermark?

Above my comment can explan the question.

> 
> my logic was that
>  -- suppose we have class A with fragmentation ratio 49% and class B
>  with 8% of wasted pages, so the overall pool fragmentation is
>  (50 + 10)/ 2 < 30%, while we still have almost 50% fragmented class.
>  if the aim is to reduce the memory wastage then per-class watermarks
>  seem to be more flexible.
> 
> > What do you think about it?
> 
> 	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
