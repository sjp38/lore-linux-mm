Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5E290828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 07:37:47 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id l65so133195146wmf.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 04:37:47 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id b82si27335173wme.79.2016.01.08.04.37.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 04:37:45 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id l65so15926501wmf.3
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 04:37:45 -0800 (PST)
Date: Fri, 8 Jan 2016 13:37:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160108123744.GC14657@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <201512242141.EAH69761.MOVFQtHSFOJFLO@I-love.SAKURA.ne.jp>
 <201512282108.EDI82328.OHFLtVJOSQFMFO@I-love.SAKURA.ne.jp>
 <201512282313.DHE87075.OSLJOFOtMVQHFF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201512282313.DHE87075.OSLJOFOtMVQHFF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 28-12-15 23:13:31, Tetsuo Handa wrote:
> Tetsuo Handa wrote:
> > Tetsuo Handa wrote:
> > > I got OOM killers while running heavy disk I/O (extracting kernel source,
> > > running lxr's genxref command). (Environ: 4 CPUs / 2048MB RAM / no swap / XFS)
> > > Do you think these OOM killers reasonable? Too weak against fragmentation?
> >
> > Since I cannot establish workload that caused December 24's natural OOM
> > killers, I used the following stressor for generating similar situation.
> >
> 
> I came to feel that I am observing a different problem which is currently
> hidden behind the "too small to fail" memory-allocation rule. That is, tasks
> requesting order > 0 pages are continuously losing the competition when
> tasks requesting order = 0 pages dominate, for reclaimed pages are stolen
> by tasks requesting order = 0 pages before reclaimed pages are combined to
> order > 0 pages (or maybe order > 0 pages are immediately split into
> order = 0 pages due to tasks requesting order = 0 pages).
> 
> Currently, order <= PAGE_ALLOC_COSTLY_ORDER allocations implicitly retry
> unless chosen by the OOM killer. Therefore, even if tasks requesting
> order = 2 pages lost the competition when there are tasks requesting
> order = 0 pages, the order = 2 allocation request is implicitly retried
> and therefore the OOM killer is not invoked (though there is a problem that
> tasks requesting order > 0 allocation will stall as long as tasks requesting
> order = 0 pages dominate).

Yes this is possible and nothing new. High order allocations (even small
orders) are never for free and more expensive than order-0. I have seen
an OOM killer striking while there were megs of free memory on a larger
machine just because of the high fragmentation.

> But this patchset introduced a limit of 16 retries.

We retry 16 times _only_ if the reclaim hasn't made _any_ progress
which means it hasn't reclaimed a single page. We can still fail due to
watermarks check for the required order but I think this is a correct
and desirable behavior because there is no guarantee that lower order
pages will get coalesced after more retries. The primary point of this
rework is to make the whole thing more deterministic.

So we can see some OOM reports for high orders (<COSTLY) which would
survive before just because we have retried so many times that we
end up allocating that single high order page but this was a pure luck
and indeterministic behavior. That being said I agree we might end up
doing some more tuning for non-costly high order allocation but it
should be bounded as well and based on failures on some reasonable
workloads. I haven't got to OOM reports you have posted yet but I
definitely plan to check them soon.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
