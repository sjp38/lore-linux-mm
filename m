Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id C74EB900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 03:04:24 -0400 (EDT)
Received: by payr10 with SMTP id r10so23666353pay.1
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 00:04:24 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id b4si4528358pas.87.2015.06.04.00.04.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jun 2015 00:04:23 -0700 (PDT)
Received: by padj3 with SMTP id j3so23580996pad.0
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 00:04:23 -0700 (PDT)
Date: Thu, 4 Jun 2015 16:04:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCH 07/10] zsmalloc: introduce auto-compact support
Message-ID: <20150604070416.GK2241@blaptop>
References: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1432911928-14654-8-git-send-email-sergey.senozhatsky@gmail.com>
 <20150604045725.GI2241@blaptop>
 <20150604053056.GA662@swordfish>
 <20150604062712.GJ2241@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150604062712.GJ2241@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 04, 2015 at 03:27:12PM +0900, Minchan Kim wrote:
> On Thu, Jun 04, 2015 at 02:30:56PM +0900, Sergey Senozhatsky wrote:
> > On (06/04/15 13:57), Minchan Kim wrote:
> > > On Sat, May 30, 2015 at 12:05:25AM +0900, Sergey Senozhatsky wrote:
> > > > perform class compaction in zs_free(), if zs_free() has created
> > > > a ZS_ALMOST_EMPTY page. this is the most trivial `policy'.
> > > 
> > > Finally, I got realized your intention.
> > > 
> > > Actually, I had a plan to add /sys/block/zram0/compact_threshold_ratio
> > > which means to compact automatically when compr_data_size/mem_used_total
> > > is below than the threshold but I didn't try because it could be done
> > > by usertool.
> > > 
> > > Another reason I didn't try the approach is that it could scan all of
> > > zs_objects repeatedly withtout any freeing zspage in some corner cases,
> > > which could be big overhead we should prevent so we might add some
> > > heuristic. as an example, we could delay a few compaction trial when
> > > we found a few previous trials as all fails.
> > 
> > this is why I use zs_can_compact() -- to evict from zs_compact() as soon
> > as possible. so useless scans are minimized (well, at least expected). I'm
> > also thinking of a threshold-based solution -- do class auto-compaction
> > only if we can free X pages, for example.
> > 
> > the problem of compaction is that there is no compaction until you trigger
> > it.
> > 
> > and fragmented classes are not necessarily a win. if writes don't happen
> > to a fragmented class-X (and we basically can't tell if they will, nor we
> > can estimate; it's up to I/O and data patterns, compression algorithm, etc.)
> > then class-X stays fragmented w/o any use.
> 
> The problem is migration/freeing old zspage/allocating new zspage is
> not a cheap, either.
> If the system has no problem with small fragmented space, there is
> no point to keep such overheads.
> 
> So, ideal is we should trigger compaction once we realized system
> is trouble but I don't have any good idea to detect it.
> That's why i wanted to rely on the decision from user via
> compact_threshold_ratio.
> 
> > 
> > > It's simple design of mm/compaction.c to prevent pointless overhead
> > > but historically it made pains several times and required more
> > > complicated logics but it's still painful.
> > > 
> > > Other thing I found recently is that it's not always win zsmalloc
> > > for zram is not fragmented. The fragmented space could be used
> > > for storing upcoming compressed objects although it is wasted space
> > > at the moment but if we don't have any hole(ie, fragment space)
> > > via frequent compaction, zsmalloc should allocate a new zspage
> > > which could be allocated on movable pageblock by fallback of
> > > nonmovable pageblock request on highly memory pressure system
> > > so it accelerates fragment problem of the system memory.
> > 
> > yes, but compaction almost always leave classes fragmented. I think
> > it's a corner case, when the number of unused allocated objects was
> > exactly the same as the number of objects that we migrated and the
> > number of migrated objects was exactly N*maxobj_per_zspage, so we
> > left the class w/o any unused objects (OBJ_ALLOCATED == OBJ_USED).
> > classes have 'holes' after compaction.
> > 
> > 
> > > So, I want to pass the policy to userspace.
> > > If we found it's really trobule on userspace, then, we need more
> > > thinking.
> > 
> > well, it can be under config "aggressive compaction" or "automatic
> > compaction" option.
> > 
> 
> If you really want to do it automatically without any feedback
> form the userspace, we should find better algorithm.

How about using slab shrinker?
If there is memory pressure, it would be called by VM and we will
try compaction without user's intervention and excessive object
scanning should be avoid by your zs_can_compact.

The concern I had about fragmentation spread out all over pageblock
should be solved as another issue. I'm plaing to make zsmalloced
page migratable. I hope we should work out it firstly to prevent
system heavy memory fragmentation by automatic compaction.

> 
> -- 
> Kind regards,
> Minchan Kim

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
