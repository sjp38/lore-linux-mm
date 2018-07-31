Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9DD946B0008
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 08:06:11 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i26-v6so3429448edr.4
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 05:06:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d4-v6si77064edc.199.2018.07.31.05.06.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 05:06:10 -0700 (PDT)
Date: Tue, 31 Jul 2018 14:06:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: terminate the reclaim early when direct reclaiming
Message-ID: <20180731120607.GK4557@dhcp22.suse.cz>
References: <1533035368-30911-1-git-send-email-zhaoyang.huang@spreadtrum.com>
 <20180731111924.GI4557@dhcp22.suse.cz>
 <CAGWkznGrc4cgMN4P5OJKGi_UV6kU_6yjV9XcPHv5MVRn11+pzw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGWkznGrc4cgMN4P5OJKGi_UV6kU_6yjV9XcPHv5MVRn11+pzw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-patch-test@lists.linaro.org

On Tue 31-07-18 19:58:20, Zhaoyang Huang wrote:
> On Tue, Jul 31, 2018 at 7:19 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Tue 31-07-18 19:09:28, Zhaoyang Huang wrote:
> > > This patch try to let the direct reclaim finish earlier than it used
> > > to be. The problem comes from We observing that the direct reclaim
> > > took a long time to finish when memcg is enabled. By debugging, we
> > > find that the reason is the softlimit is too low to meet the loop
> > > end criteria. So we add two barriers to judge if it has reclaimed
> > > enough memory as same criteria as it is in shrink_lruvec:
> > > 1. for each memcg softlimit reclaim.
> > > 2. before starting the global reclaim in shrink_zone.
> >
> > Then I would really recommend to not use soft limit at all. It has
> > always been aggressive. I have propose to make it less so in the past we
> > have decided to go that way because we simply do not know whether
> > somebody depends on that behavior. Your changelog doesn't really tell
> > the whole story. Why is this a problem all of the sudden? Nothing has
> > really changed recently AFAICT. Cgroup v1 interface is mostly for
> > backward compatibility, we have much better ways to accomplish
> > workloads isolation in cgroup v2.
> >
> > So why does it matter all of the sudden?
> >
> > Besides that EXPORT_SYMBOL for such a low level functionality as the
> > memory reclaim is a big no-no.
> >
> > So without a much better explanation and with a low level symbol
> > exported NAK from me.
> >
> My test workload is from Android system, where the multimedia apps
> require much pages. We observed that one thread of the process trapped
> into mem_cgroup_soft_limit_reclaim within direct reclaim and also
> blocked other thread in mmap or do_page_fault(by semphore?).

This requires a much more specific analysis

> Furthermore, we also observed other long time direct reclaim related
> with soft limit which are supposed to cause page thrash as the
> allocator itself is the most right of the rb_tree .

I do not follow.

> Besides, even
> without the soft_limit, shall the 'direct reclaim' check the watermark
> firstly before shrink_node, for the concurrent kswapd may have
> reclaimed enough pages for allocation.

Yes, but the direct reclaim is also a way to throttle allocation
requests and we want them to do at least some work. Making shortcuts
here can easily backfire and allow somebody to runaway too quickly.
Not that this wouldn't be possible right now but adding more heuristic
is surely tricky and far from trivial.
-- 
Michal Hocko
SUSE Labs
