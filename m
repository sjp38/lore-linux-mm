Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 30EBA6B0005
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 18:18:08 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f75so35972086wmf.2
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 15:18:08 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id yu10si20989446wjb.74.2016.06.06.15.18.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 15:18:06 -0700 (PDT)
Date: Mon, 6 Jun 2016 18:15:50 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 05/10] mm: remove LRU balancing effect of temporary page
 isolation
Message-ID: <20160606221550.GA6665@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-6-hannes@cmpxchg.org>
 <1465250169.16365.147.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1465250169.16365.147.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Mon, Jun 06, 2016 at 05:56:09PM -0400, Rik van Riel wrote:
> On Mon, 2016-06-06 at 15:48 -0400, Johannes Weiner wrote:
> > 
> > +void lru_cache_putback(struct page *page)
> > +{
> > +	struct pagevec *pvec = &get_cpu_var(lru_putback_pvec);
> > +
> > +	get_page(page);
> > +	if (!pagevec_space(pvec))
> > +		__pagevec_lru_add(pvec, false);
> > +	pagevec_add(pvec, page);
> > +	put_cpu_var(lru_putback_pvec);
> > +}
> > 
> 
> Wait a moment.
> 
> So now we have a putback_lru_page, which does adjust
> the statistics, and an lru_cache_putback which does
> not?
> 
> This function could use a name that is not as similar
> to its counterpart :)

lru_cache_add() and lru_cache_putback() are the two sibling functions,
where the first influences the LRU balance and the second one doesn't.

The last hunk in the patch (obscured by showing the label instead of
the function name as context) updates putback_lru_page() from using
lru_cache_add() to using lru_cache_putback().

Does that make sense?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
