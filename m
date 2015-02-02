Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 05B3B6B006C
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 02:01:45 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id fa1so78740988pad.8
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 23:01:44 -0800 (PST)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id r2si22690783pde.8.2015.02.01.23.01.42
        for <linux-mm@kvack.org>;
        Sun, 01 Feb 2015 23:01:44 -0800 (PST)
Date: Mon, 2 Feb 2015 16:03:21 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 3/4] mm/page_alloc: separate steal decision from steal
 behaviour part
Message-ID: <20150202070321.GB6488@js1304-P5Q-DELUXE>
References: <1422621252-29859-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1422621252-29859-4-git-send-email-iamjoonsoo.kim@lge.com>
 <BLU436-SMTP21184383897546B937E3C68833E0@phx.gbl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BLU436-SMTP21184383897546B937E3C68833E0@phx.gbl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.ok@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Jan 31, 2015 at 08:38:10PM +0800, Zhang Yanfei wrote:
> At 2015/1/30 20:34, Joonsoo Kim wrote:
> > From: Joonsoo <iamjoonsoo.kim@lge.com>
> > 
> > This is preparation step to use page allocator's anti fragmentation logic
> > in compaction. This patch just separates steal decision part from actual
> > steal behaviour part so there is no functional change.
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > ---
> >  mm/page_alloc.c | 49 ++++++++++++++++++++++++++++++++-----------------
> >  1 file changed, 32 insertions(+), 17 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 8d52ab1..ef74750 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1122,6 +1122,24 @@ static void change_pageblock_range(struct page *pageblock_page,
> >  	}
> >  }
> >  
> > +static bool can_steal_freepages(unsigned int order,
> > +				int start_mt, int fallback_mt)
> > +{
> > +	if (is_migrate_cma(fallback_mt))
> > +		return false;
> > +
> > +	if (order >= pageblock_order)
> > +		return true;
> > +
> > +	if (order >= pageblock_order / 2 ||
> > +		start_mt == MIGRATE_RECLAIMABLE ||
> > +		start_mt == MIGRATE_UNMOVABLE ||
> > +		page_group_by_mobility_disabled)
> > +		return true;
> > +
> > +	return false;
> > +}
> 
> So some comments which can tell the cases can or cannot steal freepages
> from other migratetype is necessary IMHO. Actually we can just
> move some comments in try_to_steal_pages to here.

Yes, move some comments looks sufficient to me. I will fix it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
