Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD10A6B0003
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 13:13:55 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id s15-v6so13556928wmh.7
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 10:13:55 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id f2-v6si9959748wmg.24.2018.10.16.10.13.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 16 Oct 2018 10:13:54 -0700 (PDT)
Date: Tue, 16 Oct 2018 19:13:48 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 0/2] mm/swap: Add locking for pagevec
In-Reply-To: <20181016162622.GA12144@lerouge>
Message-ID: <alpine.DEB.2.21.1810161911480.1725@nanos.tec.linutronix.de>
References: <20180914145924.22055-1-bigeasy@linutronix.de> <02dd6505-2ee5-c1c1-2603-b759bc90d479@suse.cz> <20181015095048.GG5819@techsingularity.net> <20181016162622.GA12144@lerouge>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <frederic@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-mm@kvack.org

On Tue, 16 Oct 2018, Frederic Weisbecker wrote:

> On Mon, Oct 15, 2018 at 10:50:48AM +0100, Mel Gorman wrote:
> > On Fri, Oct 12, 2018 at 09:21:41AM +0200, Vlastimil Babka wrote:
> > > On 9/14/18 4:59 PM, Sebastian Andrzej Siewior wrote:
> > > I think this evaluation is missing the other side of the story, and
> > > that's the cost of using a spinlock (even uncontended) instead of
> > > disabling preemption. The expectation for LRU pagevec is that the local
> > > operations will be much more common than draining of other CPU's, so
> > > it's optimized for the former.
> > > 
> > 
> > Agreed, the drain operation should be extremely rare except under heavy
> > memory pressure, particularly if mixed with THP allocations. The overall
> > intent seems to be improving lockdep coverage but I don't think we
> > should take a hit in the common case just to get that coverage. Bear in
> > mind that the main point of the pagevec (whether it's true or not) is to
> > avoid the much heavier LRU lock.
> 
> So indeed, if the only purpose of this patch were to make lockdep wiser,
> a pair of spin_lock_acquire() / spin_unlock_release() would be enough to
> teach it and would avoid the overhead.
> 
> Now another significant incentive behind this change is to improve CPU isolation.
> Workloads relying on owning the entire CPU without being disturbed are interested
> in this as it allows to offload some noise. It's no big deal for those who can
> tolerate rare events but often CPU isolation is combined with deterministic latency
> requirements.
> 
> So, I'm not saying this per-CPU spinlock is necessarily the right answer, I
> don't know that code enough to have an opinion, but I still wish we can find
> a solution.

One way to solve this and I had played with it already is to make the smp
function call based variant and the lock based variant switchable at boot
time with a static key. That way CPU isolation can select it and take the
penalty while normal workloads are not affected.

Thanks,

	tglx
