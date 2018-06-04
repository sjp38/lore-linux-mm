Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1FF106B0006
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 12:23:55 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id u13-v6so5062324lfg.10
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 09:23:55 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id v18-v6si20950747lji.20.2018.06.04.09.23.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jun 2018 09:23:53 -0700 (PDT)
Date: Mon, 4 Jun 2018 17:23:06 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 2/2] mm: don't skip memory guarantee calculations
Message-ID: <20180604162259.GA3404@castle>
References: <20180522132528.23769-1-guro@fb.com>
 <20180522132528.23769-2-guro@fb.com>
 <20180604122953.GN19202@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180604122953.GN19202@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, kernel-team@fb.com, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jun 04, 2018 at 02:29:53PM +0200, Michal Hocko wrote:
> On Tue 22-05-18 14:25:28, Roman Gushchin wrote:
> > There are two cases when effective memory guarantee calculation
> > is mistakenly skipped:
> > 
> > 1) If memcg is a child of the root cgroup, and the root
> > cgroup is not root_mem_cgroup (in other words, if the reclaim
> > is targeted). Top-level memory cgroups are handled specially
> > in mem_cgroup_protected(), because the root memory cgroup doesn't
> > have memory guarantee and can't limit its children guarantees.
> > So, all effective guarantee calculation is skipped.
> > But in case of targeted reclaim things are different:
> > cgroups, which parent exceeded its memory limit aren't special.
> > 
> > 2) If memcg has no charged memory (memory usage is 0). In this
> > case mem_cgroup_protected() always returns MEMCG_PROT_NONE, which
> > is correct and prevents to generate fake memory low events for
> > empty cgroups. But skipping memory emin/elow calculation is wrong:
> > if there is no global memory pressure there might be no good
> > chance again, so we can end up with effective guarantees set to 0
> > without any reason.
> 
> Roman, so these two patches are on top of the min limit patches, right?
> The fact that they come after just makes me feel this whole thing is not
> completely thought through and I would like to see all 4 patch in one
> series describing the whole design. We are getting really close to the
> merge window and last minute updates makes me really nervouse. Can you
> please repost the whole thing after the merge window, please?

Hi, Michal!

These changes are fixing some edge cases which I've discovered
when I started writing unit tests for the memory controller
(see in tools/testing/selftesting/cgroup/). All these edge cases
are temporarily effects which exist only when there is no
global memory pressure.

We're already using my implementation in production for some time,
and so far had no issues with it.

Please note, that the existing implementation of memory.low has much more
serious problems: it barely works without some significant configuration
tweaks (e.g. set all memory.low in the hierarchy to max, except leaves),
which are painful in production.

I'm happy to discuss any concrete issues/concerns, but I really see
no reasons to drop it from the mm tree now and start the discussion
from scratch.

Thank you!
