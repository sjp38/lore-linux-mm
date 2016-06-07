Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B9B646B0005
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 09:57:37 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f75so46102215wmf.2
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 06:57:37 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 76si25297628wmk.119.2016.06.07.06.57.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 06:57:36 -0700 (PDT)
Date: Tue, 7 Jun 2016 09:57:26 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 05/10] mm: remove LRU balancing effect of temporary page
 isolation
Message-ID: <20160607135726.GA9978@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-6-hannes@cmpxchg.org>
 <1465250169.16365.147.camel@redhat.com>
 <20160606221550.GA6665@cmpxchg.org>
 <1465261878.16365.149.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1465261878.16365.149.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Mon, Jun 06, 2016 at 09:11:18PM -0400, Rik van Riel wrote:
> On Mon, 2016-06-06 at 18:15 -0400, Johannes Weiner wrote:
> > On Mon, Jun 06, 2016 at 05:56:09PM -0400, Rik van Riel wrote:
> > > 
> > > On Mon, 2016-06-06 at 15:48 -0400, Johannes Weiner wrote:
> > > > 
> > > >  
> > > > +void lru_cache_putback(struct page *page)
> > > > +{
> > > > +	struct pagevec *pvec = &get_cpu_var(lru_putback_pvec);
> > > > +
> > > > +	get_page(page);
> > > > +	if (!pagevec_space(pvec))
> > > > +		__pagevec_lru_add(pvec, false);
> > > > +	pagevec_add(pvec, page);
> > > > +	put_cpu_var(lru_putback_pvec);
> > > > +}
> > > > 
> > > Wait a moment.
> > > 
> > > So now we have a putback_lru_page, which does adjust
> > > the statistics, and an lru_cache_putback which does
> > > not?
> > > 
> > > This function could use a name that is not as similar
> > > to its counterpart :)
> > lru_cache_add() and lru_cache_putback() are the two sibling
> > functions,
> > where the first influences the LRU balance and the second one
> > doesn't.
> > 
> > The last hunk in the patch (obscured by showing the label instead of
> > the function name as context) updates putback_lru_page() from using
> > lru_cache_add() to using lru_cache_putback().
> > 
> > Does that make sense?
> 
> That means the page reclaim does not update the
> "rotated" statistics.  That seems undesirable,
> no?  Am I overlooking something?

Oh, reclaim doesn't use putback_lru_page(), except for the stray
unevictable corner case. It does open-coded putback in batch, and
those functions continue to update the reclaim statistics. See the
recent_scanned/recent_rotated manipulations in putback_inactive_pages(),
shrink_inactive_list(), and shrink_active_list().

putback_lru_page() is mainly used by page migration, cgroup migration,
mlock etc. - all operations which muck with the LRU for purposes other
than reclaim or aging, and so shouldn't affect the anon/file balance.

This patch only changes those LRU users, not page reclaim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
