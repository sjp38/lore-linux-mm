Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 519156B0003
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 12:26:29 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id o3-v6so18639972pll.7
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 09:26:29 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w12-v6si14004683pld.166.2018.10.16.09.26.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 09:26:27 -0700 (PDT)
Date: Tue, 16 Oct 2018 18:26:23 +0200
From: Frederic Weisbecker <frederic@kernel.org>
Subject: Re: [PATCH 0/2] mm/swap: Add locking for pagevec
Message-ID: <20181016162622.GA12144@lerouge>
References: <20180914145924.22055-1-bigeasy@linutronix.de>
 <02dd6505-2ee5-c1c1-2603-b759bc90d479@suse.cz>
 <20181015095048.GG5819@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181015095048.GG5819@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-mm@kvack.org, tglx@linutronix.de

On Mon, Oct 15, 2018 at 10:50:48AM +0100, Mel Gorman wrote:
> On Fri, Oct 12, 2018 at 09:21:41AM +0200, Vlastimil Babka wrote:
> > On 9/14/18 4:59 PM, Sebastian Andrzej Siewior wrote:
> > I think this evaluation is missing the other side of the story, and
> > that's the cost of using a spinlock (even uncontended) instead of
> > disabling preemption. The expectation for LRU pagevec is that the local
> > operations will be much more common than draining of other CPU's, so
> > it's optimized for the former.
> > 
> 
> Agreed, the drain operation should be extremely rare except under heavy
> memory pressure, particularly if mixed with THP allocations. The overall
> intent seems to be improving lockdep coverage but I don't think we
> should take a hit in the common case just to get that coverage. Bear in
> mind that the main point of the pagevec (whether it's true or not) is to
> avoid the much heavier LRU lock.

So indeed, if the only purpose of this patch were to make lockdep wiser,
a pair of spin_lock_acquire() / spin_unlock_release() would be enough to
teach it and would avoid the overhead.

Now another significant incentive behind this change is to improve CPU isolation.
Workloads relying on owning the entire CPU without being disturbed are interested
in this as it allows to offload some noise. It's no big deal for those who can
tolerate rare events but often CPU isolation is combined with deterministic latency
requirements.

So, I'm not saying this per-CPU spinlock is necessarily the right answer, I
don't know that code enough to have an opinion, but I still wish we can find
a solution.

Thanks.
