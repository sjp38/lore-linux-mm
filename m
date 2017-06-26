Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 125706B02B4
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 01:28:32 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z45so27184458wrb.13
        for <linux-mm@kvack.org>; Sun, 25 Jun 2017 22:28:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 9si2121604wrk.320.2017.06.25.22.28.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 25 Jun 2017 22:28:30 -0700 (PDT)
Date: Mon, 26 Jun 2017 07:28:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/6] mm, migration: do not trigger OOM killer when
 migrating memory
Message-ID: <20170626052827.GA31972@dhcp22.suse.cz>
References: <20170623085345.11304-1-mhocko@kernel.org>
 <20170623085345.11304-7-mhocko@kernel.org>
 <20170623134305.4f59f673051120f95303fd89@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170623134305.4f59f673051120f95303fd89@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri 23-06-17 13:43:05, Andrew Morton wrote:
> On Fri, 23 Jun 2017 10:53:45 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Page migration (for memory hotplug, soft_offline_page or mbind) needs
> > to allocate a new memory. This can trigger an oom killer if the target
> > memory is depleated. Although quite unlikely, still possible, especially
> > for the memory hotplug (offlining of memoery). Up to now we didn't
> > really have reasonable means to back off. __GFP_NORETRY can fail just
> > too easily and __GFP_THISNODE sticks to a single node and that is not
> > suitable for all callers.
> > 
> > But now that we have __GFP_RETRY_MAYFAIL we should use it.  It is
> > preferable to fail the migration than disrupt the system by killing some
> > processes.
> 
> I'm not sure which tree this is against...

next-20170623

> 
> > --- a/mm/memory-failure.c
> > +++ b/mm/memory-failure.c
> > @@ -1492,7 +1492,8 @@ static struct page *new_page(struct page *p, unsigned long private, int **x)
> >  
> >  		return alloc_huge_page_node(hstate, nid);
> >  	} else {
> > -		return __alloc_pages_node(nid, GFP_HIGHUSER_MOVABLE, 0);
> > +		return __alloc_pages_node(nid,
> > +				GFP_HIGHUSER_MOVABLE | __GFP_RETRY_MAYFAIL, 0);
> >  	}
> >  }
> 
> new_page() is now
> 
> static struct page *new_page(struct page *p, unsigned long private, int **x)
> {
> 	int nid = page_to_nid(p);
> 
> 	return new_page_nodemask(p, nid, &node_states[N_MEMORY]);
> }
> 
> and new_page_nodemask() uses __GFP_RETRY_MAYFAIL so I simply dropped
> the above hunk.

Ohh, right. This is
http://lkml.kernel.org/r/20170622193034.28972-4-mhocko@kernel.org. I've
just didn't realize it was not in mmotm yet. So yes the hunk can be
dropped, new_page_nodemask does what we need.
 
Sorry about that
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
