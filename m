Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id F16426B0003
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 09:14:26 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id b6so1741466plx.3
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 06:14:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e22sor1178554pgn.235.2018.02.06.06.14.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Feb 2018 06:14:25 -0800 (PST)
Date: Tue, 6 Feb 2018 06:14:18 -0800
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -mm] mm, swap, frontswap: Fix THP swap if frontswap
 enabled
Message-ID: <20180206141418.GA25912@eng-minchan1.roam.corp.google.com>
References: <20180206065404.18815-1-ying.huang@intel.com>
 <20180206083101.GA17082@eng-minchan1.roam.corp.google.com>
 <871shy3421.fsf@yhuang-dev.intel.com>
 <20180206090244.GA20545@eng-minchan1.roam.corp.google.com>
 <20180206094822.GA2265@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180206094822.GA2265@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Shakeel Butt <shakeelb@google.com>, stable@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hi Sergey,

On Tue, Feb 06, 2018 at 06:48:22PM +0900, Sergey Senozhatsky wrote:
> Hello,
> 
> On (02/06/18 01:02), Minchan Kim wrote:
> [..]
> > Can't we simple do like that if you want to make it simple and rely on someone
> > who makes frontswap THP-aware later?
> > 
> > diff --git a/mm/swapfile.c b/mm/swapfile.c
> > index 42fe5653814a..4bf1725407aa 100644
> > --- a/mm/swapfile.c
> > +++ b/mm/swapfile.c
> > @@ -934,7 +934,11 @@ int get_swap_pages(int n_goal, bool cluster, swp_entry_t swp_entries[])
> >  
> >         /* Only single cluster request supported */
> >         WARN_ON_ONCE(n_goal > 1 && cluster);
> > +#ifdef CONFIG_FRONTSWAP
> 
> Wouldn't #ifdef CONFIG_THP_SWAP be better? frontswap_enabled() is 'false'
> on CONFIG_FRONTSWAP configs, should be compiled out anyway.

Agree.

> 
> > +       /* Now, frontswap doesn't support THP page */
> > +       if (frontswap_enabled() && cluster)
> > +               return;
> > +#endif
> >         avail_pgs = atomic_long_read(&nr_swap_pages) / nr_pages;
> >         if (avail_pgs <= 0)
> >                 goto noswap;
> 
> Looks interesting. Technically, can be done earlier - in get_swap_page(),
> can't it? get_swap_page() has the PageTransHuge(page) && CONFIG_THP_SWAP
> condition checks. Can add frontswap dependency there. Something like
> 
> 	if (PageTransHuge(page)) {
> 		if (IS_ENABLED(CONFIG_THP_SWAP))
> +			if (!frontswap_enabled())
> 				get_swap_pages(1, true, &entry);
> 		return entry;
> 	}

Looks better but it introduces frontswap thing to swap_slots.c while
all frontswap works in swapfile.c.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
