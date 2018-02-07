Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 10EE56B033B
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 11:55:56 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id b15so870293wrb.0
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 08:55:56 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id i89si1301381edc.520.2018.02.07.08.55.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Feb 2018 08:55:54 -0800 (PST)
Date: Wed, 7 Feb 2018 11:55:47 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcontrol: fix NR_WRITEBACK leak in memcg and
 system stats
Message-ID: <20180207165547.GB29418@cmpxchg.org>
References: <20180203082353.17284-1-hannes@cmpxchg.org>
 <CALvZod5-35Y+_eot6-6J5HyssnmAW-wfYhuQdxxA9Zj8Ng2e+g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod5-35Y+_eot6-6J5HyssnmAW-wfYhuQdxxA9Zj8Ng2e+g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.com>, Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, kernel-team@fb.com

Hi Shakeel,

On Wed, Feb 07, 2018 at 07:44:08AM -0800, Shakeel Butt wrote:
> On Sat, Feb 3, 2018 at 12:23 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > After the ("a983b5ebee57 mm: memcontrol: fix excessive complexity in
> > memory.stat reporting"), we observed slowly upward creeping
> > NR_WRITEBACK counts over the course of several days, both the
> > per-memcg stats as well as the system counter in e.g. /proc/meminfo.
> >
> > The conversion from full per-cpu stat counts to per-cpu cached atomic
> > stat counts introduced an irq-unsafe RMW operation into the updates.
> >
> > Most stat updates come from process context, but one notable exception
> > is the NR_WRITEBACK counter. While writebacks are issued from process
> > context, they are retired from (soft)irq context.
> >
> > When writeback completions interrupt the RMW counter updates of new
> > writebacks being issued, the decs from the completions are lost.
> >
> > Since the global updates are routed through the joint lruvec API, both
> > the memcg counters as well as the system counters are affected.
> >
> > This patch makes the joint stat and event API irq safe.
> >
> > Fixes: a983b5ebee57 ("mm: memcontrol: fix excessive complexity in memory.stat reporting")
> > Debugged-by: Tejun Heo <tj@kernel.org>
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Should this be considered for stable?

The stable tree is only for fixes to already released kernels, but
there is no release containing the faulty patch:

$ git describe --tags a983b5ebee57
v4.15-3322-ga983b5ebee57

nor was the faulty patch itself marked for stable.

So as long as this fix makes it into 4.16 we should be good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
