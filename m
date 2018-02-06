Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 73F496B0003
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 04:48:29 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x11so1204198pgr.9
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 01:48:29 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p10sor259794pgn.8.2018.02.06.01.48.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Feb 2018 01:48:28 -0800 (PST)
Date: Tue, 6 Feb 2018 18:48:22 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH -mm] mm, swap, frontswap: Fix THP swap if frontswap
 enabled
Message-ID: <20180206094822.GA2265@jagdpanzerIV>
References: <20180206065404.18815-1-ying.huang@intel.com>
 <20180206083101.GA17082@eng-minchan1.roam.corp.google.com>
 <871shy3421.fsf@yhuang-dev.intel.com>
 <20180206090244.GA20545@eng-minchan1.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180206090244.GA20545@eng-minchan1.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Shakeel Butt <shakeelb@google.com>, stable@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello,

On (02/06/18 01:02), Minchan Kim wrote:
[..]
> Can't we simple do like that if you want to make it simple and rely on someone
> who makes frontswap THP-aware later?
> 
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 42fe5653814a..4bf1725407aa 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -934,7 +934,11 @@ int get_swap_pages(int n_goal, bool cluster, swp_entry_t swp_entries[])
>  
>         /* Only single cluster request supported */
>         WARN_ON_ONCE(n_goal > 1 && cluster);
> +#ifdef CONFIG_FRONTSWAP

Wouldn't #ifdef CONFIG_THP_SWAP be better? frontswap_enabled() is 'false'
on CONFIG_FRONTSWAP configs, should be compiled out anyway.

> +       /* Now, frontswap doesn't support THP page */
> +       if (frontswap_enabled() && cluster)
> +               return;
> +#endif
>         avail_pgs = atomic_long_read(&nr_swap_pages) / nr_pages;
>         if (avail_pgs <= 0)
>                 goto noswap;

Looks interesting. Technically, can be done earlier - in get_swap_page(),
can't it? get_swap_page() has the PageTransHuge(page) && CONFIG_THP_SWAP
condition checks. Can add frontswap dependency there. Something like

	if (PageTransHuge(page)) {
		if (IS_ENABLED(CONFIG_THP_SWAP))
+			if (!frontswap_enabled())
				get_swap_pages(1, true, &entry);
		return entry;
	}

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
