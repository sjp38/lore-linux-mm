Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 54ED86B005D
	for <linux-mm@kvack.org>; Mon,  3 Sep 2012 18:03:42 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so9076017pbb.14
        for <linux-mm@kvack.org>; Mon, 03 Sep 2012 15:03:41 -0700 (PDT)
Date: Tue, 4 Sep 2012 07:03:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch v4]swap: add a simple random read swapin detection
Message-ID: <20120903220332.GA1997@barrios>
References: <20120827040037.GA8062@kernel.org>
 <503B8997.4040604@openvz.org>
 <20120830103612.GA12292@kernel.org>
 <20120830174223.GB2141@barrios>
 <20120903072137.GA26821@kernel.org>
 <20120903083245.GA7674@bbox>
 <20120903114631.GA5410@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120903114631.GA5410@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: akpm@linux-foundation.org, Konstantin Khlebnikov <khlebnikov@openvz.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "riel@redhat.com" <riel@redhat.com>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>

On Mon, Sep 03, 2012 at 07:46:31PM +0800, Shaohua Li wrote:
> On Mon, Sep 03, 2012 at 05:32:45PM +0900, Minchan Kim wrote:
> > Don't we need initialization?
> > 
> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index 0f3b7cd..c0f3221 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -416,6 +416,9 @@ static void anon_vma_ctor(void *data)
> >  
> >         mutex_init(&anon_vma->mutex);
> >         atomic_set(&anon_vma->refcount, 0);
> > +#ifdef CONFIG_SWAP
> > +       atomic_set(&anon_vma->swapra_miss, 0);
> > +#endif
> >         INIT_LIST_HEAD(&anon_vma->head);
> >  }
> 
> Sorry about this silly problem. I'm wondering why I didn't notice it, maybe
> because only tested random swap after move swapra_miss to anon_vma.
> 
> 
> Subject: swap: add a simple random read swapin detection
> 
> The swapin readahead does a blind readahead regardless if the swapin is
> sequential. This is ok for harddisk and random read, because read big size has
> no penality in harddisk, and if the readahead pages are garbage, they can be
> reclaimed fastly. But for SSD, big size read is more expensive than small size
> read. If readahead pages are garbage, such readahead only has overhead.
> 
> This patch addes a simple random read detection like what file mmap readahead
> does. If random read is detected, swapin readahead will be skipped. This
> improves a lot for a swap workload with random IO in a fast SSD.
> 
> I run anonymous mmap write micro benchmark, which will triger swapin/swapout.
> 			runtime changes with path
> randwrite harddisk	-38.7%
> seqwrite harddisk	-1.1%
> randwrite SSD		-46.9%
> seqwrite SSD		+0.3%
> 
> For both harddisk and SSD, the randwrite swap workload run time is reduced
> significant. sequential write swap workload hasn't chanage.
> 
> Interesting is the randwrite harddisk test is improved too. This might be
> because swapin readahead need allocate extra memory, which further tights
> memory pressure, so more swapout/swapin.
> 
> This patch depends on readahead-fault-retry-breaks-mmap-file-read-random-detection.patch
> 
> V2->V3:
> move swapra_miss to 'struct anon_vma' as suggested by Konstantin. 
> 
> V1->V2:
> 1. Move the swap readahead accounting to separate functions as suggested by Riel.
> 2. Enable the logic only with CONFIG_SWAP enabled as suggested by Minchan.
> 
> Signed-off-by: Shaohua Li <shli@fusionio.com>
> Acked-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Minchan Kim <minchan@kernel.org>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
