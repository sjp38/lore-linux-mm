Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id BA3B96B0069
	for <linux-mm@kvack.org>; Mon, 17 Nov 2014 22:08:54 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id r10so22578478pdi.3
        for <linux-mm@kvack.org>; Mon, 17 Nov 2014 19:08:54 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id fm3si36883156pab.94.2014.11.17.19.08.52
        for <linux-mm@kvack.org>;
        Mon, 17 Nov 2014 19:08:53 -0800 (PST)
Date: Tue, 18 Nov 2014 12:11:26 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v5 1/4] mm/page_alloc: fix incorrect isolation behavior
 by rechecking migratetype
Message-ID: <20141118031125.GA12197@js1304-P5Q-DELUXE>
References: <1414740330-4086-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1414740330-4086-2-git-send-email-iamjoonsoo.kim@lge.com>
 <CAL1ERfMxR0BPQ-1hsD+Z-Oizkt4WHzL_rwYmKd2n70R=H0X22Q@mail.gmail.com>
 <20141114103301.GD21422@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141114103301.GD21422@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Weijie Yang <weijie.yang.kh@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Fri, Nov 14, 2014 at 10:33:01AM +0000, Mel Gorman wrote:
> > > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > > index 4593567..3d090af 100644
> > > --- a/include/linux/mmzone.h
> > > +++ b/include/linux/mmzone.h
> > > @@ -431,6 +431,15 @@ struct zone {
> > >          */
> > >         int                     nr_migrate_reserve_block;
> > >
> > > +#ifdef CONFIG_MEMORY_ISOLATION
> > > +       /*
> > > +        * Number of isolated pageblock. It is used to solve incorrect
> > > +        * freepage counting problem due to racy retrieving migratetype
> > > +        * of pageblock. Protected by zone->lock.
> > > +        */
> > > +       unsigned long           nr_isolate_pageblock;
> > > +#endif
> > > +
> > 
> > First sorry for this deferred reply, I see these patches have been merged
> > into the mainline.
> > However, I still have a tiny question:
> > Why use ZONE_PADDING(_pad1_)  seperate it and zone->lock?
> > How about move it to the same cacheline with zone->lock, because it is
> > accessed under zone->lock?
> > 
> 
> zone->lock is currently sharing lines with the data that is frequently
> updated under zone lock and some of the dirty data cache line bouncing has
> completed when the lock is acquired. nr_isolate_pageblock is a read-mostly
> field and in some cases will never be used. It's fine where it is beside
> other read-mostly fields.
> 

My bad...
I don't remember why I decide that place. :/

It seems better to move nr_isolate_pageblock to the same cacheline with
zone->lock, but, as Mel said, it is rarely used field so improvement would
be marginal.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
