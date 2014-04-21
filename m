Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 51CD46B0035
	for <linux-mm@kvack.org>; Mon, 21 Apr 2014 15:41:49 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id kq14so4052515pab.23
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 12:41:48 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id m8si21378750pbd.116.2014.04.21.12.41.47
        for <linux-mm@kvack.org>;
        Mon, 21 Apr 2014 12:41:48 -0700 (PDT)
Date: Mon, 21 Apr 2014 12:41:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm/compaction: cleanup isolate_freepages()
Message-Id: <20140421124146.c8beacf0d58aafff2085a461@linux-foundation.org>
In-Reply-To: <20140417000745.GF27534@bbox>
References: <5342BA34.8050006@suse.cz>
	<1397553507-15330-1-git-send-email-vbabka@suse.cz>
	<1397553507-15330-2-git-send-email-vbabka@suse.cz>
	<20140417000745.GF27534@bbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Heesub Shin <heesub.shin@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dongjun Shin <d.j.shin@samsung.com>, Sunghwan Yun <sunghwan.yun@samsung.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Thu, 17 Apr 2014 09:07:45 +0900 Minchan Kim <minchan@kernel.org> wrote:

> Hi Vlastimil,
> 
> Below just nitpicks.

It seems you were ignored ;)

> >  {
> >  	struct page *page;
> > -	unsigned long high_pfn, low_pfn, pfn, z_end_pfn;
> > +	unsigned long pfn, low_pfn, next_free_pfn, z_end_pfn;
> 
> Could you add comment for each variable?
> 
> unsigned long pfn; /* scanning cursor */
> unsigned long low_pfn; /* lowest pfn free scanner is able to scan */
> unsigned long next_free_pfn; /* start pfn for scaning at next truen */
> unsigned long z_end_pfn; /* zone's end pfn */
> 
> 
> > @@ -688,11 +688,10 @@ static void isolate_freepages(struct zone *zone,
> >  	low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
> >  
> >  	/*
> > -	 * Take care that if the migration scanner is at the end of the zone
> > -	 * that the free scanner does not accidentally move to the next zone
> > -	 * in the next isolation cycle.
> > +	 * Seed the value for max(next_free_pfn, pfn) updates. If there are
> > +	 * none, the pfn < low_pfn check will kick in.
> 
>        "none" what? I'd like to clear more.

I did this:

--- a/mm/compaction.c~mm-compaction-cleanup-isolate_freepages-fix
+++ a/mm/compaction.c
@@ -662,7 +662,10 @@ static void isolate_freepages(struct zon
 				struct compact_control *cc)
 {
 	struct page *page;
-	unsigned long pfn, low_pfn, next_free_pfn, z_end_pfn;
+	unsigned long pfn;	     /* scanning cursor */
+	unsigned long low_pfn;	     /* lowest pfn scanner is able to scan */
+	unsigned long next_free_pfn; /* start pfn for scaning at next round */
+	unsigned long z_end_pfn;     /* zone's end pfn */
 	int nr_freepages = cc->nr_freepages;
 	struct list_head *freelist = &cc->freepages;
 
@@ -679,8 +682,8 @@ static void isolate_freepages(struct zon
 	low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
 
 	/*
-	 * Seed the value for max(next_free_pfn, pfn) updates. If there are
-	 * none, the pfn < low_pfn check will kick in.
+	 * Seed the value for max(next_free_pfn, pfn) updates. If no pages are
+	 * isolated, the pfn < low_pfn check will kick in.
 	 */
 	next_free_pfn = 0;
 
> > @@ -766,9 +765,9 @@ static void isolate_freepages(struct zone *zone,
> >  	 * so that compact_finished() may detect this
> >  	 */
> >  	if (pfn < low_pfn)
> > -		cc->free_pfn = max(pfn, zone->zone_start_pfn);
> > -	else
> > -		cc->free_pfn = high_pfn;
> > +		next_free_pfn = max(pfn, zone->zone_start_pfn);
> 
> Why we need max operation?
> IOW, what's the problem if we do (next_free_pfn = pfn)?

An answer to this would be useful, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
