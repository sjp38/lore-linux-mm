Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id C700C6B0009
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 04:24:10 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id a4so61676606wme.1
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 01:24:10 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id 143si3071110wme.24.2016.02.26.01.24.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 01:24:09 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id b205so8031657wmb.1
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 01:24:09 -0800 (PST)
Date: Fri, 26 Feb 2016 10:24:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160226092406.GB8940@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225092315.GD17573@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602252219020.9793@eggly.anvils>
 <009a01d1706a$e666dc00$b3349400$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <009a01d1706a$e666dc00$b3349400$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Hugh Dickins' <hughd@google.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Linus Torvalds' <torvalds@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'David Rientjes' <rientjes@google.com>, 'Tetsuo Handa' <penguin-kernel@i-love.sakura.ne.jp>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>, 'Sergey Senozhatsky' <sergey.senozhatsky.work@gmail.com>

On Fri 26-02-16 15:54:19, Hillf Danton wrote:
> > 
> > It didn't really help, I'm afraid: it reduces the actual number of OOM
> > kills which occur before the job is terminated, but doesn't stop the
> > job from being terminated very soon.
> > 
> > I also tried Hillf's patch (separately) too, but as you expected,
> > it didn't seem to make any difference.
> > 
> Perhaps non-costly means NOFAIL as shown by folding the two

nofail only means that the page allocator doesn't return with NULL.
OOM killer is still not put aside...

> patches into one. Can it make any sense?
> 
> thanks
> Hillf
> --- a/mm/page_alloc.c	Thu Feb 25 15:43:18 2016
> +++ b/mm/page_alloc.c	Fri Feb 26 15:18:55 2016
> @@ -3113,6 +3113,8 @@ should_reclaim_retry(gfp_t gfp_mask, uns
>  	struct zone *zone;
>  	struct zoneref *z;
>  
> +	if (order <= PAGE_ALLOC_COSTLY_ORDER)
> +		return true;

This is defeating the whole purpose of the rework - to behave
deterministically. You have just disabled the oom killer completely.
This is not the way to go

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
