Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 18D016B0005
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 09:43:08 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id r97so52697424lfi.2
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 06:43:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 78si3562381wmq.114.2016.07.21.06.43.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jul 2016 06:43:06 -0700 (PDT)
Date: Thu, 21 Jul 2016 15:43:03 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/page_owner: Align with pageblock_nr pages
Message-ID: <20160721134303.GM26379@dhcp22.suse.cz>
References: <1468938136-24228-1-git-send-email-zhongjiang@huawei.com>
 <20160720072404.GD11249@dhcp22.suse.cz>
 <2f7fabe7-2717-2634-6e09-9b9edd71bf8b@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2f7fabe7-2717-2634-6e09-9b9edd71bf8b@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: iamjoonsoo.kim@lge.com, zhongjiang <zhongjiang@huawei.com>, akpm@linux-foundation.org, linux-mm@kvack.org

On Thu 21-07-16 14:21:46, Vlastimil Babka wrote:
> On 07/20/2016 09:24 AM, Michal Hocko wrote:
> > On Tue 19-07-16 22:22:16, zhongjiang wrote:
> > > From: zhong jiang <zhongjiang@huawei.com>
> > > 
> > > when pfn_valid(pfn) return false, pfn should be align with
> > > pageblock_nr_pages other than MAX_ORDER_NR_PAGES in
> > > init_pages_in_zone, because the skipped 2M may be valid pfn,
> > > as a result, early allocated count will not be accurate.
> > 
> > I really do not understand this changelog. I thought that
> > MAX_ORDER_NR_PAGES and pageblock_nr_pages are the same thing but they
> > might not be for HUGETLB.
> 
> The common situation on x86 is that pageblock is 512 pages (2MB) and
> MAX_ORDER_NR_PAGES is 1024 (4MB).
> 
> > Should init_pages_in_zone depend on something
> > like HUGETLB? Is this even correct I would have expected that we should
> > initialize in the page block steps so MAX_ORDER_NR_PAGES. Could you
> > clarify Joonsoo, please?
> 
> On !CONFIG_HOLES_IN_ZONE systems, pfn_valid() should give the same outcome
> within MAX_ORDER_NR_PAGES blocks (modulo zone boundaries). So the ALIGN
> using MAX_ORDER_NR_PAGES is correct for these systems. What's somewhat weird
> is that the rest of the for loop uses pageblock_nr_pages, but it doesn't
> affect the outcome.
> 
> On CONFIG_HOLES_IN_ZONE the situation is less clear. The hole can be
> theoretically anywhere within MAX_ORDER_NR_PAGES, including the first pfn.
> If it's the first pfn, init_pages_in_zone() will skip MAX_ORDER_NR_PAGES.
> The patch helps if the hole is e.g. the first 2MB of a 4MB pageblock... then
> the second 2MB will be picked up after this patch. But it's still not
> thorough in all situations. Strictly speaking, one these systems one would
> have to avoid the MAX_ORDER_NR_PAGES skip completely, and just check each
> pfn one by one to be sure nothing is missed.
> 
> But that's potentially costly, so for example, __pageblock_pfn_to_page()
> (that originated in compaction) assumes that the hole is in the middle, and
> checks first and last pfn of pageblock. So it has a pageblock granularity
> like this patch, but still is more restrictive.
> 
> I wish there was a better solution that would get used everywhere...
> possibly making the CONFIG_HOLES_IN_ZONE configs also declare the
> granularity of holes, so we don't need to check each pfn...

Ehm, head spins... So this suggests that MAX_ORDER_NR_PAGES sounds like
a better iterator for systems without holes and neither
pageblock_nr_pages nor MAX_ORDER_NR_PAGES for reliably for systems with
holes. Did I get it right?

If yes is the patch an improvement at all?

> > > Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> > > ---
> > >  mm/page_owner.c | 2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > diff --git a/mm/page_owner.c b/mm/page_owner.c
> > > index c6cda3e..aa2c486 100644
> > > --- a/mm/page_owner.c
> > > +++ b/mm/page_owner.c
> > > @@ -310,7 +310,7 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
> > >  	 */
> > >  	for (; pfn < end_pfn; ) {
> > >  		if (!pfn_valid(pfn)) {
> > > -			pfn = ALIGN(pfn + 1, MAX_ORDER_NR_PAGES);
> > > +			pfn = ALIGN(pfn + 1, pageblock_nr_pages);
> > >  			continue;
> > >  		}
> > > 
> > > --
> > > 1.8.3.1
> > 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
