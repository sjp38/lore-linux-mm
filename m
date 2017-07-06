Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 52EB96B0313
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 08:48:46 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id v193so1173208itc.10
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 05:48:46 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 194si199841itx.90.2017.07.06.05.48.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Jul 2017 05:48:45 -0700 (PDT)
Subject: Re: mm/slab: What is cache_reap work for?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201706271935.DJJ18719.OMFLFFHJSOVtQO@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.20.1706300856530.3291@east.gentwo.org>
	<201707042215.ICG90672.FStFMFQOHLOOJV@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.20.1707050906290.448@east.gentwo.org>
In-Reply-To: <alpine.DEB.2.20.1707050906290.448@east.gentwo.org>
Message-Id: <201707062148.ADG35932.HOJOLFQMVFFStO@I-love.SAKURA.ne.jp>
Date: Thu, 6 Jul 2017 21:48:38 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com
Cc: linux-mm@kvack.org, mhocko@kernel.org

Christoph Lameter wrote:
> On Tue, 4 Jul 2017, Tetsuo Handa wrote:
> 
> > Thank you for explanation. What I observed is that it seems that
> > cache_reap work was not able to run because it used system_wq when
> > the system was unable to allocate memory for new worker thread due to
> > infinite too_many_isolated() loop in shrink_inactive_list().
> 
> Its ok for it not to run for awhile but that potentially traps memory. And
> you want more memory to be freed.
> 
> > I wondered whether cache_reap work qualifies as an mm_percpu_wq user
> > if cache_reap work does something like what vmstat_work work does (e.g.
> > update statistic counters which affect progress of memory allocation).
> > But "calls other functions that are used during regular slab allocation"
> > means cache_reap work cannot qualify as an mm_percpu_wq user...
> 
> Well if you audit the functions called then you may be able to get there.
> 

As far as I checked, it seems that the only operation that cache_reap work
might sleep is cond_resched(). Thus, I think that cache_reap work can
qualify as an mm_percpu_wq user.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
