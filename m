Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D1D5E6B039F
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 12:01:56 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l44so6715223wrc.11
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 09:01:56 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 60si36716705wra.123.2017.04.13.09.01.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 09:01:54 -0700 (PDT)
Date: Thu, 13 Apr 2017 12:01:47 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC 0/1] add support for reclaiming priorities per mem cgroup
Message-ID: <20170413160147.GB29727@cmpxchg.org>
References: <20170317231636.142311-1-timmurray@google.com>
 <20170330155123.GA3929@cmpxchg.org>
 <CAEe=SxmpXD=f9N_i+xe6gFUKKUefJYvBd8dSwxSM+7rbBBTniw@mail.gmail.com>
 <20170413043047.GA16783@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170413043047.GA16783@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, LKML <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, Suren Baghdasaryan <surenb@google.com>, Patrik Torstensson <totte@google.com>, Android Kernel Team <kernel-team@android.com>

On Thu, Apr 13, 2017 at 01:30:47PM +0900, Minchan Kim wrote:
> On Thu, Mar 30, 2017 at 12:40:32PM -0700, Tim Murray wrote:
> > As a result, I think there's still a need for relative priority
> > between mem cgroups, not just an absolute limit.
> > 
> > Does that make sense?
> 
> I agree with it.
> 
> Recently, embedded platform's workload for smart things would be much
> diverse(from game to alarm) so it's hard to handle the absolute limit
> proactively and userspace has more hints about what workloads are
> more important(ie, greedy) compared to others although it would be
> harmful for something(e.g., it's not visible effect to user)
> 
> As a such point of view, I support this idea as basic approach.
> And with thrashing detector from Johannes, we can do fine-tune of
> LRU balancing and vmpressure shooting time better.
> 
> Johannes,
> 
> Do you have any concern about this memcg prority idea?

While I fully agree that relative priority levels would be easier to
configure, this patch doesn't really do that. It allows you to set a
scan window divider to a fixed amount and, as I already pointed out,
the scan window is no longer representative of memory pressure.

[ Really, sc->priority should probably just be called LRU lookahead
  factor or something, there is not much about it being representative
  of any kind of urgency anymore. ]

With this patch, if you configure the priorities of two 8G groups to 0
and 4, reclaim will treat them exactly the same*. If you configure the
priorities of two 100G groups to 0 and 7, reclaim will treat them
exactly the same. The bigger the group, the more of the lower range of
the priority range becomes meaningless, because once the divider
produces outcomes bigger than SWAP_CLUSTER_MAX(32), it doesn't
actually bias reclaim anymore.

So that's not a portable relative scale of pressure discrimination.

But the bigger problem with this is that, as sc->priority doesn't
represent memory pressure anymore, it is merely a cut-off for which
groups to scan and which groups not to scan *based on their size*.

That is the same as setting memory.low!

* For simplicity, I'm glossing over the fact here that LRUs are split
  by type and into inactive/active, so in reality the numbers are a
  little different, but you get the point.

> Or
> Do you think the patchset you are preparing solve this situation?

It's certainly a requirement. In order to implement a relative scale
of memory pressure discrimination, we first need to be able to really
quantify memory pressure.

Then we can either allow setting absolute latency/slowdown minimums
for each group, with reclaim skipping groups above those thresholds,
or we can map a relative priority scale against the total slowdown due
to lack of memory in the system, and each group gets a relative share
based on its priority compared to other groups.

But there is no way around first having a working measure of memory
pressure before we can meaningfully distribute it among the groups.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
