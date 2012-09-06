Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 246526B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 19:31:01 -0400 (EDT)
Date: Fri, 7 Sep 2012 08:32:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/3] memory-hotplug: bug fix race between isolation and
 allocation
Message-ID: <20120906233238.GD16231@bbox>
References: <1346829962-31989-1-git-send-email-minchan@kernel.org>
 <1346829962-31989-4-git-send-email-minchan@kernel.org>
 <20120905094041.GF11266@suse.de>
 <20120906044903.GA16150@bbox>
 <20120906092424.GP11266@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120906092424.GP11266@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Sep 06, 2012 at 10:24:24AM +0100, Mel Gorman wrote:
> On Thu, Sep 06, 2012 at 01:49:03PM +0900, Minchan Kim wrote:
> > > > __offline_isolated_pages
> > > > /*
> > > >  * BUG_ON hit or offline page
> > > >  * which is used by someone
> > > >  */
> > > > BUG_ON(!PageBuddy(page A));
> > > > 
> > > 
> > > offline_page calling BUG_ON because someone allocated the page is
> > > ridiculous. I did not spot where that check is but it should be changed. The
> > > correct action is to retry the isolation.
> > 
> > It is where __offline_isolated_pges.
> > 
> > ..
> >         while (pfn < end_pfn) {
> >                 if (!pfn_valid(pfn)) {
> >                         pfn++;
> >                         continue;
> >                 }    
> >                 page = pfn_to_page(pfn);
> >                 BUG_ON(page_count(page));
> >                 BUG_ON(!PageBuddy(page)); <---- HERE
> >                 order = page_order(page);
> > ...
> > 
> > Comment of offline_isolated_pages says following as.
> > 
> >         We cannot do rollback at this point
> > 
> > So if the comment is true, BUG_ON does make sense to me.
> 
> It's massive overkill. I see no reason why it cannot return EBUSY all the
> way back up to offline_pages() and retry with the migration step.  It would
> both remove that BUG_ON and improve reliability of memory hot-remove.
> 
> > But I don't see why we can't retry it as I look thorugh code.
> > Anyway, It's another story which isn't related to this patch.
> > 
> 
> True.
> 
> > > 
> > > > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > 
> > > At no point in the changelog do you actually say what he patch does :/
> > 
> > Argh, I will do.
> > 
> > > 
> > > > ---
> > > >  mm/page_isolation.c |    5 ++++-
> > > >  1 file changed, 4 insertions(+), 1 deletion(-)
> > > > 
> > > > diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> > > > index acf65a7..4699d1f 100644
> > > > --- a/mm/page_isolation.c
> > > > +++ b/mm/page_isolation.c
> > > > @@ -196,8 +196,11 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn)
> > > >  			continue;
> > > >  		}
> > > >  		page = pfn_to_page(pfn);
> > > > -		if (PageBuddy(page))
> > > > +		if (PageBuddy(page)) {
> > > > +			if (get_page_migratetype(page) != MIGRATE_ISOLATE)
> > > > +				break;
> > > >  			pfn += 1 << page_order(page);
> > > > +		}
> > > 
> > > It is possible the page is moved to the MIGRATE_ISOLATE list between when
> > > the page was freed to the buddy allocator and this check was made. The
> > > page->index information is stale and the impact is that the hotplug
> > > operation fails when it could have succeeded. That said, I think it is a
> > > very unlikely race that will never happen in practice.
> > 
> > I understand you mean move_freepages which I have missed. Right?
> 
> Yes.
> 
> > Then, I will fix it, too.
> > 
> > > 
> > > More importantly, the effect of this path is that EBUSY gets bubbled all
> > > the way up and the hotplug operations fails. This is fine but as the page
> > > is free at the time this problem is detected you also have the option
> > > of moving the PageBuddy page to the MIGRATE_ISOLATE list at this time
> > > if you take the zone lock. This will mean you need to change the name of
> > > test_pages_isolated() of course.
> > 
> > Sorry, I can't get your point. Could you elaborate it more?
> 
> You detect a PageBuddy page but it's on the wrong list. Instead of returning
> and failing memory-hotremove, move the free page to the correct list at
> the time it is detected.

Good idea.

> 
> > Is it related to this patch?
> 
> No, it's not important and was a suggestion on how it could be made
> better. However, retrying hot-remove would be even better again. I'm not
> suggesting it be done as part of this series.

Mel, Thanks for your review.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
