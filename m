Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7BCEE6B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 08:52:19 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id bk3so9690843wjc.4
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 05:52:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id tz15si54368974wjb.56.2016.12.14.05.52.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Dec 2016 05:52:18 -0800 (PST)
Date: Wed, 14 Dec 2016 14:52:16 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161214135215.GL25573@dhcp22.suse.cz>
References: <201612132106.IJH12421.LJStOQMVHFOFOF@I-love.SAKURA.ne.jp>
 <20161214093706.GA16064@pathway.suse.cz>
 <201612142037.EED00059.VJMOFLtSOQFFOH@I-love.SAKURA.ne.jp>
 <20161214123644.GE16064@pathway.suse.cz>
 <20161214124437.GJ25573@dhcp22.suse.cz>
 <201612142236.IIF57367.SVJOFMOFHtFOLQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612142236.IIF57367.SVJOFMOFHtFOLQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: pmladek@suse.com, linux-mm@kvack.org, sergey.senozhatsky@gmail.com

On Wed 14-12-16 22:36:29, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 14-12-16 13:36:44, Petr Mladek wrote:
> > [...]
> > > There are basically two solution for this situation:
> > > 
> > > 1. Fix printk() so that it does not block forever. This will
> > >    get solved by the async printk patchset[*]. In the meantime,
> > >    a particular sensitive location might be worked around
> > >    by using printk_deferred() instead of printk()[**]
> > 
> > Absolutely!
> > 
> > > 2. Reduce the amount of messages. It is insane to report
> > >    the same problem many times so that the same messages
> > >    fill the entire log buffer. Note that the allocator
> > >    is not the only sinner here.
> > 
> > sure and the ratelimit patch should help in that direction.
> > show_mem for each allocation stall is really way too much.
> 
> dump_stack() from warn_alloc() for each allocation stall is also too much.
> Regarding synchronous watchdog like warn_alloc(), each thread's backtrace
> never change for that allocation request because it is always called from
> the same location (i.e. __alloc_pages_slowpath()). Backtrace might be useful
> for the first time of each thread's first allocation stall report for
> that allocation request, but subsequent ones are noises unless backtrace
> of the first time was corrupted/dropped,

Well, the problem is when the ringbuffer overflows and then we lose
older data - and the stack as well. But I agree that dumping it for each
allocation is a lot of noise. We can be more clever than that but this
is more complicated I guess. A global ratelimit will not work and we
most probably do not want to have per task ratelimit I believe because
that sounds too much.

> for they are only saying that
> allocation retry loop did not get stuck inside e.g. shrink_inactive_list().
> Maybe we don't need to call warn_alloc() for each allocation stall; call
> warn_alloc() only once and then use one-liner report.

The thing is that we want occasional show_mem because we want to see how
the situation with the memory counters evolves over time.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
