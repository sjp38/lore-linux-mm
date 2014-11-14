Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id A3E836B00EC
	for <linux-mm@kvack.org>; Fri, 14 Nov 2014 05:33:08 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id n12so18986797wgh.13
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 02:33:07 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fx3si48477340wjb.132.2014.11.14.02.33.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 14 Nov 2014 02:33:07 -0800 (PST)
Date: Fri, 14 Nov 2014 10:33:01 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v5 1/4] mm/page_alloc: fix incorrect isolation behavior
 by rechecking migratetype
Message-ID: <20141114103301.GD21422@suse.de>
References: <1414740330-4086-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1414740330-4086-2-git-send-email-iamjoonsoo.kim@lge.com>
 <CAL1ERfMxR0BPQ-1hsD+Z-Oizkt4WHzL_rwYmKd2n70R=H0X22Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAL1ERfMxR0BPQ-1hsD+Z-Oizkt4WHzL_rwYmKd2n70R=H0X22Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang.kh@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index 4593567..3d090af 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -431,6 +431,15 @@ struct zone {
> >          */
> >         int                     nr_migrate_reserve_block;
> >
> > +#ifdef CONFIG_MEMORY_ISOLATION
> > +       /*
> > +        * Number of isolated pageblock. It is used to solve incorrect
> > +        * freepage counting problem due to racy retrieving migratetype
> > +        * of pageblock. Protected by zone->lock.
> > +        */
> > +       unsigned long           nr_isolate_pageblock;
> > +#endif
> > +
> 
> First sorry for this deferred reply, I see these patches have been merged
> into the mainline.
> However, I still have a tiny question:
> Why use ZONE_PADDING(_pad1_)  seperate it and zone->lock?
> How about move it to the same cacheline with zone->lock, because it is
> accessed under zone->lock?
> 

zone->lock is currently sharing lines with the data that is frequently
updated under zone lock and some of the dirty data cache line bouncing has
completed when the lock is acquired. nr_isolate_pageblock is a read-mostly
field and in some cases will never be used. It's fine where it is beside
other read-mostly fields.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
