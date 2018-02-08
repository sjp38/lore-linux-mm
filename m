Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 92BAE6B0022
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 05:25:27 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id v31so2147715otb.1
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 02:25:27 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n13sor1427749ote.132.2018.02.08.02.25.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Feb 2018 02:25:26 -0800 (PST)
Date: Thu, 8 Feb 2018 02:25:21 -0800
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -mm -v2] mm, swap, frontswap: Fix THP swap if frontswap
 enabled
Message-ID: <20180208102521.GB74192@eng-minchan1.roam.corp.google.com>
References: <20180207070035.30302-1-ying.huang@intel.com>
 <20180207130534.259cd71a595c6275b2da38d3@linux-foundation.org>
 <20180208013635.GA596@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180208013635.GA596@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Huang, Ying" <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <huang.ying.caritas@gmail.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Shakeel Butt <shakeelb@google.com>, stable@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Thu, Feb 08, 2018 at 10:36:35AM +0900, Sergey Senozhatsky wrote:
> On (02/07/18 13:05), Andrew Morton wrote:
> [..]
> > hm.  This is assuming that "cluster==true" means "this is thp swap". 
> > That's presently true, but is it appropriate that get_swap_pages() is
> > peeking at "cluster" to work out why it is being called?
> > 
> > Or would it be cleaner to do this in get_swap_page()?  Something like
> > 
> > --- a/mm/swap_slots.c~a
> > +++ a/mm/swap_slots.c
> > @@ -317,8 +317,11 @@ swp_entry_t get_swap_page(struct page *p
> >  	entry.val = 0;
> >  
> >  	if (PageTransHuge(page)) {
> > -		if (IS_ENABLED(CONFIG_THP_SWAP))
> > -			get_swap_pages(1, true, &entry);
> > +		/* Frontswap doesn't support THP */
> > +		if (!frontswap_enabled()) {
> > +			if (IS_ENABLED(CONFIG_THP_SWAP))
> > +				get_swap_pages(1, true, &entry);
> > +		}
> >  		return entry;
> >  	}
> 
> I have proposed exactly the same thing [1], Minchan commented that
> it would introduce frontswap dependency to swap_slots.c [2]. Which
> is true, but I'd still probably prefer to handle it all in
> get_swap_page. Minchan, any objections?

I didn't want to spread out frontswap stuff unless it has good value
because most of frontswap functions are located in mm/swapfile.c
at this moment. It gives me good feeling frontswap's abstraction
is wonderful.
However, if frontswap matainer has no problem, I am not against, either.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
