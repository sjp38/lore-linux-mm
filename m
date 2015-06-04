Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id F21D8900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 01:30:34 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so23078325pdb.2
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 22:30:34 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com. [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id pv5si4129776pbb.244.2015.06.03.22.30.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 22:30:33 -0700 (PDT)
Received: by pdbki1 with SMTP id ki1so23036592pdb.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 22:30:33 -0700 (PDT)
Date: Thu, 4 Jun 2015 14:30:56 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH 07/10] zsmalloc: introduce auto-compact support
Message-ID: <20150604053056.GA662@swordfish>
References: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1432911928-14654-8-git-send-email-sergey.senozhatsky@gmail.com>
 <20150604045725.GI2241@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150604045725.GI2241@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (06/04/15 13:57), Minchan Kim wrote:
> On Sat, May 30, 2015 at 12:05:25AM +0900, Sergey Senozhatsky wrote:
> > perform class compaction in zs_free(), if zs_free() has created
> > a ZS_ALMOST_EMPTY page. this is the most trivial `policy'.
> 
> Finally, I got realized your intention.
> 
> Actually, I had a plan to add /sys/block/zram0/compact_threshold_ratio
> which means to compact automatically when compr_data_size/mem_used_total
> is below than the threshold but I didn't try because it could be done
> by usertool.
> 
> Another reason I didn't try the approach is that it could scan all of
> zs_objects repeatedly withtout any freeing zspage in some corner cases,
> which could be big overhead we should prevent so we might add some
> heuristic. as an example, we could delay a few compaction trial when
> we found a few previous trials as all fails.

this is why I use zs_can_compact() -- to evict from zs_compact() as soon
as possible. so useless scans are minimized (well, at least expected). I'm
also thinking of a threshold-based solution -- do class auto-compaction
only if we can free X pages, for example.

the problem of compaction is that there is no compaction until you trigger
it.

and fragmented classes are not necessarily a win. if writes don't happen
to a fragmented class-X (and we basically can't tell if they will, nor we
can estimate; it's up to I/O and data patterns, compression algorithm, etc.)
then class-X stays fragmented w/o any use.


> It's simple design of mm/compaction.c to prevent pointless overhead
> but historically it made pains several times and required more
> complicated logics but it's still painful.
> 
> Other thing I found recently is that it's not always win zsmalloc
> for zram is not fragmented. The fragmented space could be used
> for storing upcoming compressed objects although it is wasted space
> at the moment but if we don't have any hole(ie, fragment space)
> via frequent compaction, zsmalloc should allocate a new zspage
> which could be allocated on movable pageblock by fallback of
> nonmovable pageblock request on highly memory pressure system
> so it accelerates fragment problem of the system memory.

yes, but compaction almost always leave classes fragmented. I think
it's a corner case, when the number of unused allocated objects was
exactly the same as the number of objects that we migrated and the
number of migrated objects was exactly N*maxobj_per_zspage, so we
left the class w/o any unused objects (OBJ_ALLOCATED == OBJ_USED).
classes have 'holes' after compaction.


> So, I want to pass the policy to userspace.
> If we found it's really trobule on userspace, then, we need more
> thinking.

well, it can be under config "aggressive compaction" or "automatic
compaction" option.

	-ss

> Thanks.
> 
> > 
> > probably it would make zs_can_compact() to return an estimated number
> > of pages that potentially will be free and trigger auto-compaction
> > only when it's above some limit (e.g. at least 4 zs pages); or put it
> > under config option.
> > 
> > this also tweaks __zs_compact() -- we can't do reschedule
> > anymore, waiting for new pages in the current class. so we
> > compact as much as we can and return immediately if compaction
> > is not possible anymore.
> > 
> > auto-compaction is not a replacement of manual compaction.
> > 
> > compiled linux kernel with auto-compaction:
> > 
> > cat /sys/block/zram0/mm_stat
> > 2339885056 1601034235 1624076288        0 1624076288    19961     1106
> > 
> > performing additional manual compaction:
> > 
> > echo 1 > /sys/block/zram0/compact
> > cat /sys/block/zram0/mm_stat
> > 2339885056 1601034235 1624051712        0 1624076288    19961     1114
> > 
> > manual compaction was able to migrate additional 8 objects. so
> > auto-compaction is 'good enough'.
> > 
> > TEST
> > 
> > this test copies a 1.3G linux kernel tar to mounted zram disk,
> > and extracts it.
> > 
> > w/auto-compaction:
> > 
> > cat /sys/block/zram0/mm_stat
> >  1171456    26006    86016        0    86016    32781        0
> > 
> > time tar xf linux-3.10.tar.gz -C linux
> > 
> > real    0m16.970s
> > user    0m15.247s
> > sys     0m8.477s
> > 
> > du -sh linux
> > 2.0G    linux
> > 
> > cat /sys/block/zram0/mm_stat
> > 3547353088 2993384270 3011088384        0 3011088384    24310      108
> > 
> > =====================================================================
> > 
> > w/o auto compaction:
> > 
> > cat /sys/block/zram0/mm_stat
> >  1171456    26000    81920        0    81920    32781        0
> > 
> > time tar xf linux-3.10.tar.gz -C linux
> > 
> > real    0m16.983s
> > user    0m15.267s
> > sys     0m8.417s
> > 
> > du -sh linux
> > 2.0G    linux
> > 
> > cat /sys/block/zram0/mm_stat
> > 3548917760 2993566924 3011317760        0 3011317760    23928        0
> > 
> > =====================================================================
> > 
> > iozone shows that auto-compacted code runs faster in several
> > tests, which is hardly trustworthy. anyway.
> > 
> > iozone -t 3 -R -r 16K -s 60M -I +Z
> > 
> >        test           base       auto-compact (compacted 66123 objs)
> >    Initial write   1603682.25          1645112.38
> >          Rewrite   2502243.31          2256570.31
> >             Read   7040860.00          7130575.00
> >          Re-read   7036490.75          7066744.25
> >     Reverse Read   6617115.25          6155395.50
> >      Stride read   6705085.50          6350030.38
> >      Random read   6668497.75          6350129.38
> >   Mixed workload   5494030.38          5091669.62
> >     Random write   2526834.44          2500977.81
> >           Pwrite   1656874.00          1663796.94
> >            Pread   3322818.91          3359683.44
> >           Fwrite   4090124.25          4099773.88
> >            Fread   10358916.25         10324409.75
> > 
> > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > ---
> >  mm/zsmalloc.c | 25 +++++++++++++------------
> >  1 file changed, 13 insertions(+), 12 deletions(-)
> > 
> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > index c2a640a..70bf481 100644
> > --- a/mm/zsmalloc.c
> > +++ b/mm/zsmalloc.c
> > @@ -1515,34 +1515,28 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
> >  
> >  		while ((dst_page = isolate_target_page(class))) {
> >  			cc.d_page = dst_page;
> > -			/*
> > -			 * If there is no more space in dst_page, resched
> > -			 * and see if anyone had allocated another zspage.
> > -			 */
> > +
> >  			if (!migrate_zspage(pool, class, &cc))
> > -				break;
> > +				goto out;
> >  
> >  			putback_zspage(pool, class, dst_page);
> >  		}
> >  
> > -		/* Stop if we couldn't find slot */
> > -		if (dst_page == NULL)
> > +		if (!dst_page)
> >  			break;
> > -
> >  		putback_zspage(pool, class, dst_page);
> >  		putback_zspage(pool, class, src_page);
> > -		spin_unlock(&class->lock);
> > -		cond_resched();
> > -		spin_lock(&class->lock);
> >  	}
> >  
> > +out:
> > +	if (dst_page)
> > +		putback_zspage(pool, class, dst_page);
> >  	if (src_page)
> >  		putback_zspage(pool, class, src_page);
> >  
> >  	spin_unlock(&class->lock);
> >  }
> >  
> > -
> >  unsigned long zs_get_total_pages(struct zs_pool *pool)
> >  {
> >  	return atomic_long_read(&pool->pages_allocated);
> > @@ -1741,6 +1735,13 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
> >  	unpin_tag(handle);
> >  
> >  	free_handle(pool, handle);
> > +
> > +	/*
> > +	 * actual fullness might have changed, __zs_compact() checks
> > +	 * if compaction makes sense
> > +	 */
> > +	if (fullness == ZS_ALMOST_EMPTY)
> > +		__zs_compact(pool, class);
> >  }
> >  EXPORT_SYMBOL_GPL(zs_free);
> >  
> > -- 
> > 2.4.2.337.gfae46aa
> > 
> 
> -- 
> Kind regards,
> Minchan Kim
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
