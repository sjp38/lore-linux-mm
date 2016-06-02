Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id CDE736B0253
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 02:46:02 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id um11so36283509pab.2
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 23:46:02 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id m81si56356266pfa.117.2016.06.01.23.46.01
        for <linux-mm@kvack.org>;
        Wed, 01 Jun 2016 23:46:01 -0700 (PDT)
Date: Thu, 2 Jun 2016 15:46:44 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Why __alloc_contig_migrate_range calls migrate_prep() at first?
Message-ID: <20160602064644.GB3304@bbox>
References: <tencent_29E1A2CA78CE0C9046C1494E@qq.com>
 <20160601074010.GO19976@bbox>
 <231748d4-6d9b-85d9-6796-e4625582e148@foxmail.com>
 <20160602022242.GB9133@js1304-P5Q-DELUXE>
 <20160602042916.GB3024@bbox>
 <20160602062918.GA9770@js1304-P5Q-DELUXE>
MIME-Version: 1.0
In-Reply-To: <20160602062918.GA9770@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Wang Sheng-Hui <shhuiw@foxmail.com>, akpm <akpm@linux-foundation.org>, mgorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>

On Thu, Jun 02, 2016 at 03:29:18PM +0900, Joonsoo Kim wrote:
> On Thu, Jun 02, 2016 at 01:29:16PM +0900, Minchan Kim wrote:
> > On Thu, Jun 02, 2016 at 11:22:43AM +0900, Joonsoo Kim wrote:
> > > On Thu, Jun 02, 2016 at 09:19:19AM +0800, Wang Sheng-Hui wrote:
> > > > 
> > > > 
> > > > On 6/1/2016 3:40 PM, Minchan Kim wrote:
> > > > > On Wed, Jun 01, 2016 at 11:42:29AM +0800, Wang Sheng-Hui wrote:
> > > > >> Dear,
> > > > >>
> > > > >> Sorry to trouble you.
> > > > >>
> > > > >> I noticed cma_alloc would turn to  __alloc_contig_migrate_range for allocating pages.
> > > > >> But  __alloc_contig_migrate_range calls  migrate_prep() at first, even if the requested page
> > > > >> is single and free, lru_add_drain_all still run (called by  migrate_prep())?
> > > > >>
> > > > >> Image a large chunk of free contig pages for CMA, various drivers may request a single page from
> > > > >> the CMA area, we'll get  lru_add_drain_all run for each page.
> > > > >>
> > > > >> Should we detect if the required pages are free before migrate_prep(), or detect at least for single 
> > > > >> page allocation?
> > > > > That makes sense to me.
> > > > >
> > > > > How about calling migrate_prep once migrate_pages fails in the first trial?
> > > > 
> > > > Minchan,
> > > > 
> > > > I tried your patch in my env, and the number of calling migrate_prep() dropped a lot.
> > > > 
> > > > In my case, CMA reserved 512MB, and the linux will call migrate_prep() 40~ times during bootup,
> > > > most are single page allocation request to CMA.
> > > > With your patch, migrate_prep() is not called for the single pages allocation requests as the free
> > > > pages in CMA area is enough.
> > > > 
> > > > Will you please push the patch to upstream?
> > > 
> > > It is not correct.
> > > 
> > > migrate_prep() is called to move lru pages in lruvec to LRU. In
> > > isolate_migratepages_range(), non LRU pages are just skipped so if
> > > page is on the lruvec it will not be isolated and error isn't returned.
> > > So, "if (ret) migrate_prep()" will not be called and we can't catch
> > > the page in lruvec.
> > 
> > Ah,, true. Thanks for correcting.
> > 
> > Simple fix is to remove migrate_prep in there and retry if test_pages_isolated
> > found migration is failed at least once.
> 
> Hmm...much better than before. But, it makes me wonder what his
> painpoint is. He want to remove migrate_prep() which calls
> lru_add_drain_all() needlessly. But, we already have one in alloc_contig_range().
> So, he will not be happy entirely with following change.

It will reduce the numer of drain IPI call so it would be win compared to old.

> Moreover, lru_add_drain_all() is there without any validation. It is there
> since we need to gather migrated pages in lruvec but I think that it
> is sufficient to call lru_add_drain_cpu() and drain_local_pages(), respectively.

Maybe, it is heritage of memory hotplugging. :(
Should be more optimized. Hope you will look into that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
