Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id C28656B0003
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 07:44:05 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id b14so73654587wmb.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 04:44:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l7si95735967wjq.40.2016.01.06.04.44.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 06 Jan 2016 04:44:04 -0800 (PST)
Subject: Re: [PATCH 0/3] OOM detection rework v4
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <201512242141.EAH69761.MOVFQtHSFOJFLO@I-love.SAKURA.ne.jp>
 <201512282108.EDI82328.OHFLtVJOSQFMFO@I-love.SAKURA.ne.jp>
 <201512282313.DHE87075.OSLJOFOtMVQHFF@I-love.SAKURA.ne.jp>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <568D0C10.1090504@suse.cz>
Date: Wed, 6 Jan 2016 13:44:00 +0100
MIME-Version: 1.0
In-Reply-To: <201512282313.DHE87075.OSLJOFOtMVQHFF@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@kernel.org, akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/28/2015 03:13 PM, Tetsuo Handa wrote:
> Tetsuo Handa wrote:
>> Tetsuo Handa wrote:
>> > I got OOM killers while running heavy disk I/O (extracting kernel source,
>> > running lxr's genxref command). (Environ: 4 CPUs / 2048MB RAM / no swap / XFS)
>> > Do you think these OOM killers reasonable? Too weak against fragmentation?
>>
>> Since I cannot establish workload that caused December 24's natural OOM
>> killers, I used the following stressor for generating similar situation.
>>
> 
> I came to feel that I am observing a different problem which is currently
> hidden behind the "too small to fail" memory-allocation rule. That is, tasks
> requesting order > 0 pages are continuously losing the competition when
> tasks requesting order = 0 pages dominate, for reclaimed pages are stolen
> by tasks requesting order = 0 pages before reclaimed pages are combined to
> order > 0 pages (or maybe order > 0 pages are immediately split into
> order = 0 pages due to tasks requesting order = 0 pages).

Hm I would expect that as long as there are some reserves left that your
reproducer cannot grab, there are some free pages left and the allocator should
thus preserve the order-2 pages that combine, since order-0 allocations will get
existing order-0 pages before splitting higher orders. Compaction should also be
able to successfully combine order-2 without racing allocators thanks to per-cpu
caching (but I'd have to check).

So I think the problem is not higher-order page itself, but that order-2 needs 4
pages and thus needs to pass a bit higher watermark, thus being at disadvantage
to order-0 allocations. Thus I would expect the order-2 pages to be there, but
not available for allocation due to watermarks.

> Currently, order <= PAGE_ALLOC_COSTLY_ORDER allocations implicitly retry
> unless chosen by the OOM killer. Therefore, even if tasks requesting
> order = 2 pages lost the competition when there are tasks requesting
> order = 0 pages, the order = 2 allocation request is implicitly retried
> and therefore the OOM killer is not invoked (though there is a problem that
> tasks requesting order > 0 allocation will stall as long as tasks requesting
> order = 0 pages dominate).
> 
> But this patchset introduced a limit of 16 retries. Thus, if tasks requesting
> order = 2 pages lost the competition for 16 times due to tasks requesting
> order = 0 pages, tasks requesting order = 2 pages invoke the OOM killer.
> To avoid the OOM killer, we need to make sure that pages reclaimed for
> order > 0 allocations will not be stolen by tasks requesting order = 0
> allocations.
> 
> Is my feeling plausible?
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
