Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3CEF96B0025
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 06:22:58 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id t18-v6so1539992plo.9
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 03:22:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o63sor869766pga.62.2018.02.08.03.22.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Feb 2018 03:22:56 -0800 (PST)
Date: Thu, 8 Feb 2018 20:22:51 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH -mm -v2] mm, swap, frontswap: Fix THP swap if frontswap
 enabled
Message-ID: <20180208112251.GA710@jagdpanzerIV>
References: <20180207070035.30302-1-ying.huang@intel.com>
 <20180207130534.259cd71a595c6275b2da38d3@linux-foundation.org>
 <20180208013635.GA596@jagdpanzerIV>
 <20180208102521.GB74192@eng-minchan1.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180208102521.GB74192@eng-minchan1.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Huang, Ying" <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <huang.ying.caritas@gmail.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Shakeel Butt <shakeelb@google.com>, stable@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (02/08/18 02:25), Minchan Kim wrote:
[..]
> > >  	if (PageTransHuge(page)) {
> > > -		if (IS_ENABLED(CONFIG_THP_SWAP))
> > > -			get_swap_pages(1, true, &entry);
> > > +		/* Frontswap doesn't support THP */
> > > +		if (!frontswap_enabled()) {
> > > +			if (IS_ENABLED(CONFIG_THP_SWAP))
> > > +				get_swap_pages(1, true, &entry);
> > > +		}
> > >  		return entry;
> > >  	}
> > 
> > I have proposed exactly the same thing [1], Minchan commented that
> > it would introduce frontswap dependency to swap_slots.c [2]. Which
> > is true, but I'd still probably prefer to handle it all in
> > get_swap_page. Minchan, any objections?
> 
> I didn't want to spread out frontswap stuff unless it has good value
> because most of frontswap functions are located in mm/swapfile.c
> at this moment.

Sure, your points are perfectly valid. At the same time it might be the
case that we already kind of expose that THP dependency thing to vmscan.
The whole

	if (!add_to_swap()) {
		if (!PageTransHuge(page))
			goto activate_locked;

		split_huge_page_to_list(page);
		add_to_swap(page);
	}

looks a bit suspicious - if add_to_swap() fails and the page is THP then
split it and add_to_swap() again.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
