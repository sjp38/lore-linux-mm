Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id A5A076B0006
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 20:55:17 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id l5-v6so3114035pli.8
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 17:55:17 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id t18si7718122pfg.246.2018.02.26.17.55.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 17:55:16 -0800 (PST)
Date: Tue, 27 Feb 2018 09:56:13 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH v3 1/3] mm/free_pcppages_bulk: update pcp->count inside
Message-ID: <20180227015613.GA9141@intel.com>
References: <20180226135346.7208-1-aaron.lu@intel.com>
 <20180226135346.7208-2-aaron.lu@intel.com>
 <alpine.DEB.2.20.1802261345550.135844@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1802261345550.135844@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>

On Mon, Feb 26, 2018 at 01:48:14PM -0800, David Rientjes wrote:
> On Mon, 26 Feb 2018, Aaron Lu wrote:
> 
> > Matthew Wilcox found that all callers of free_pcppages_bulk() currently
> > update pcp->count immediately after so it's natural to do it inside
> > free_pcppages_bulk().
> > 
> > No functionality or performance change is expected from this patch.
> > 
> > Suggested-by: Matthew Wilcox <willy@infradead.org>
> > Signed-off-by: Aaron Lu <aaron.lu@intel.com>
> > ---
> >  mm/page_alloc.c | 10 +++-------
> >  1 file changed, 3 insertions(+), 7 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index cb416723538f..3154859cccd6 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1117,6 +1117,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
> >  	int batch_free = 0;
> >  	bool isolated_pageblocks;
> >  
> > +	pcp->count -= count;
> >  	spin_lock(&zone->lock);
> >  	isolated_pageblocks = has_isolate_pageblock(zone);
> >  
> 
> Why modify pcp->count before the pages have actually been freed?

When count is still count and not zero after pages have actually been
freed :-)

> 
> I doubt that it matters too much, but at least /proc/zoneinfo uses 
> zone->lock.  I think it should be done after the lock is dropped.

Agree that it looks a bit weird to do it beforehand and I just want to
avoid adding one more local variable here.

pcp->count is not protected by zone->lock though so even we do it after
dropping the lock, it could still happen that zoneinfo shows a wrong
value of pcp->count while it should be zero(this isn't a problem since
zoneinfo doesn't need to be precise).

Anyway, I'll follow your suggestion here to avoid confusion.
 
> Otherwise, looks good.

Thanks for taking a look at this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
