Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id BC5C16B0005
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 11:52:20 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id d18-v6so10862741qtj.20
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 08:52:20 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 27-v6sor5651978qvd.58.2018.08.06.08.52.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 08:52:19 -0700 (PDT)
Date: Mon, 6 Aug 2018 11:55:17 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcg: update memcg OOM messages on cgroup2
Message-ID: <20180806155517.GB14519@cmpxchg.org>
References: <20180803175743.GW1206094@devbig004.ftw2.facebook.com>
 <20180803203045.GA18725@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180803203045.GA18725@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Fri, Aug 03, 2018 at 01:30:49PM -0700, Roman Gushchin wrote:
> On Fri, Aug 03, 2018 at 10:57:43AM -0700, Tejun Heo wrote:
> > +	seq_pr_info(m, "pgfault %lu\n", events[PGFAULT]);
> > +	seq_pr_info(m, "pgmajfault %lu\n", events[PGMAJFAULT]);
> > +
> > +	seq_pr_info(m, "pgrefill %lu\n", events[PGREFILL]);
> > +	seq_pr_info(m, "pgscan %lu\n", events[PGSCAN_KSWAPD] +
> > +		    events[PGSCAN_DIRECT]);
> > +	seq_pr_info(m, "pgsteal %lu\n", events[PGSTEAL_KSWAPD] +
> > +		    events[PGSTEAL_DIRECT]);
> > +	seq_pr_info(m, "pgactivate %lu\n", events[PGACTIVATE]);
> > +	seq_pr_info(m, "pgdeactivate %lu\n", events[PGDEACTIVATE]);
> > +	seq_pr_info(m, "pglazyfree %lu\n", events[PGLAZYFREE]);
> > +	seq_pr_info(m, "pglazyfreed %lu\n", events[PGLAZYFREED]);
> >  
> > +	seq_pr_info(m, "workingset_refault %lu\n",
> > +		    stat[WORKINGSET_REFAULT]);
> > +	seq_pr_info(m, "workingset_activate %lu\n",
> > +		    stat[WORKINGSET_ACTIVATE]);
> > +	seq_pr_info(m, "workingset_nodereclaim %lu\n",
> > +		    stat[WORKINGSET_NODERECLAIM]);
> 
> I'm not sure we need all theses stats in the oom report.
> I'd drop the events part.

This info dump usually races with ongoing reclaim and frees. The VM
state might have changed quite a bit by the time this is all written
out, which sometimes makes it hard to rootcause from just the state
snapshots. Knowing what the VM was doing before the OOM is helpful.

I'd prefer we keep those in.
