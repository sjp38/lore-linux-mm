Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id F097B6B0038
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 12:04:46 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id b7so3709782wrd.16
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 09:04:46 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id k12si3530231edl.288.2018.01.12.09.04.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 12 Jan 2018 09:04:45 -0800 (PST)
Date: Fri, 12 Jan 2018 12:05:01 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 07/15] mm: memcontrol: fix excessive complexity in
 memory.stat reporting
Message-ID: <20180112170501.GA10320@cmpxchg.org>
References: <5a208303.hxMsAOT0gjSsd0Gf%akpm@linux-foundation.org>
 <20171201135750.GB8097@cmpxchg.org>
 <20171206170635.e3e45c895750538ee9283033@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171206170635.e3e45c895750538ee9283033@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, mhocko@suse.com, vdavydov.dev@gmail.com

Sorry, this email slipped through the cracks.

On Wed, Dec 06, 2017 at 05:06:35PM -0800, Andrew Morton wrote:
> On Fri, 1 Dec 2017 13:57:50 +0000 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > The memcg cpu_dead callback can be called early during startup
> > (CONFIG_DEBUG_HOTPLUG_CPU0) with preemption enabled, which triggers a
> > warning in its __this_cpu_xchg() calls. But CPU locality is always
> > guaranteed, which is the only thing we really care about here.
> > 
> > Using the preemption-safe this_cpu_xchg() addresses this problem.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> > 
> > Andrew, can you please merge this fixlet into the original patch?
> 
> Did.
> 
> I see that lkp-robot identified a performance regression and pointed
> the finger at this patch?

Right, it reports a perf drop in page fault stress tests, but that is
to be the expected trade-off. Before, we'd do everything per cpu, and
have to collapse all counters everytime somebody would read the stats.
Now we fold them in batches, which introduces a periodic atomic when
the batches are flushed (same frequency as we per-cpu cache charges
for the atomic page_counter).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
