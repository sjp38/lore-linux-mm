Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id ACCDE6B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 08:36:38 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q10so29306764pgq.7
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 05:36:38 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id q28si52933784pfl.44.2016.12.14.05.36.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Dec 2016 05:36:37 -0800 (PST)
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201612132106.IJH12421.LJStOQMVHFOFOF@I-love.SAKURA.ne.jp>
	<20161214093706.GA16064@pathway.suse.cz>
	<201612142037.EED00059.VJMOFLtSOQFFOH@I-love.SAKURA.ne.jp>
	<20161214123644.GE16064@pathway.suse.cz>
	<20161214124437.GJ25573@dhcp22.suse.cz>
In-Reply-To: <20161214124437.GJ25573@dhcp22.suse.cz>
Message-Id: <201612142236.IIF57367.SVJOFMOFHtFOLQ@I-love.SAKURA.ne.jp>
Date: Wed, 14 Dec 2016 22:36:29 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, pmladek@suse.com
Cc: linux-mm@kvack.org, sergey.senozhatsky@gmail.com

Michal Hocko wrote:
> On Wed 14-12-16 13:36:44, Petr Mladek wrote:
> [...]
> > There are basically two solution for this situation:
> > 
> > 1. Fix printk() so that it does not block forever. This will
> >    get solved by the async printk patchset[*]. In the meantime,
> >    a particular sensitive location might be worked around
> >    by using printk_deferred() instead of printk()[**]
> 
> Absolutely!
> 
> > 2. Reduce the amount of messages. It is insane to report
> >    the same problem many times so that the same messages
> >    fill the entire log buffer. Note that the allocator
> >    is not the only sinner here.
> 
> sure and the ratelimit patch should help in that direction.
> show_mem for each allocation stall is really way too much.

dump_stack() from warn_alloc() for each allocation stall is also too much.
Regarding synchronous watchdog like warn_alloc(), each thread's backtrace
never change for that allocation request because it is always called from
the same location (i.e. __alloc_pages_slowpath()). Backtrace might be useful
for the first time of each thread's first allocation stall report for
that allocation request, but subsequent ones are noises unless backtrace
of the first time was corrupted/dropped, for they are only saying that
allocation retry loop did not get stuck inside e.g. shrink_inactive_list().
Maybe we don't need to call warn_alloc() for each allocation stall; call
warn_alloc() only once and then use one-liner report.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
