Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id BE3166B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 20:40:23 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id b126so19853693ite.3
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 17:40:23 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id y15si32719162pfb.59.2016.06.14.17.40.22
        for <linux-mm@kvack.org>;
        Tue, 14 Jun 2016 17:40:23 -0700 (PDT)
Date: Wed, 15 Jun 2016 09:40:27 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 3/3] mm: per-process reclaim
Message-ID: <20160615004027.GA17127@bbox>
References: <1465804259-29345-1-git-send-email-minchan@kernel.org>
 <1465804259-29345-4-git-send-email-minchan@kernel.org>
 <20160613150653.GA30642@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160613150653.GA30642@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Sangwoo Park <sangwoo2.park@lge.com>

Hi Johannes,

On Mon, Jun 13, 2016 at 11:06:53AM -0400, Johannes Weiner wrote:
> Hi Minchan,
> 
> On Mon, Jun 13, 2016 at 04:50:58PM +0900, Minchan Kim wrote:
> > These day, there are many platforms available in the embedded market
> > and sometime, they has more hints about workingset than kernel so
> > they want to involve memory management more heavily like android's
> > lowmemory killer and ashmem or user-daemon with lowmemory notifier.
> > 
> > This patch adds add new method for userspace to manage memory
> > efficiently via knob "/proc/<pid>/reclaim" so platform can reclaim
> > any process anytime.
> 
> Cgroups are our canonical way to control system resources on a per
> process or group-of-processes level. I don't like the idea of adding
> ad-hoc interfaces for single-use cases like this.
> 
> For this particular case, you can already stick each app into its own
> cgroup and use memory.force_empty to target-reclaim them.
> 
> Or better yet, set the soft limits / memory.low to guide physical
> memory pressure, once it actually occurs, toward the least-important
> apps? We usually prefer doing work on-demand rather than proactively.
> 
> The one-cgroup-per-app model would give Android much more control and
> would also remove a *lot* of overhead during task switches, see this:
> https://lkml.org/lkml/2014/12/19/358

I didn't notice that. Thanks for the pointing.
I read the thread you pointed out and read memcg code.

Firstly, I thought one-cgroup-per-app model is abuse of memcg but now
I feel your suggestion does make sense that it's right direction for
control memory from the userspace. Just a concern is that not sure
how hard we can map memory management model from global memory pressure
to per-app pressure model smoothly.

A question is it seems cgroup2 doesn't have per-cgroup swappiness.
Why?

I think we need it in one-cgroup-per-app model.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
