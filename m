Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E3F456B0007
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 02:59:46 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id s18-v6so1503251edr.15
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 23:59:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x13-v6sor1142760edr.37.2018.08.02.23.59.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Aug 2018 23:59:45 -0700 (PDT)
MIME-Version: 1.0
References: <1533275285-12387-1-git-send-email-zhaoyang.huang@spreadtrum.com>
 <CAGWkznE_Z+eJ+81eZN_KT7KXSFyCxfoafeMFSzirT7OaL+vbRA@mail.gmail.com> <20180803061817.GC27245@dhcp22.suse.cz>
In-Reply-To: <20180803061817.GC27245@dhcp22.suse.cz>
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Date: Fri, 3 Aug 2018 14:59:34 +0800
Message-ID: <CAGWkznHV44vxsnB9rmKO_k-orhTvupeJhk_cTKP128boM=6Egw@mail.gmail.com>
Subject: Re: [PATCH v1] mm:memcg: skip memcg of current in mem_cgroup_soft_limit_reclaim
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, kernel-patch-test@lists.linaro.org

On Fri, Aug 3, 2018 at 2:18 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 03-08-18 14:11:26, Zhaoyang Huang wrote:
> > On Fri, Aug 3, 2018 at 1:48 PM Zhaoyang Huang <huangzhaoyang@gmail.com> wrote:
> > >
> > > for the soft_limit reclaim has more directivity than global reclaim, we40960
> > > have current memcg be skipped to avoid potential page thrashing.
> > >
> > The patch is tested in our android system with 2GB ram.  The case
> > mainly focus on the smooth slide of pictures on a gallery, which used
> > to stall on the direct reclaim for over several hundred
> > millionseconds. By further debugging, we find that the direct reclaim
> > spend most of time to reclaim pages on its own with softlimit set to
> > 40960KB. I add a ftrace event to verify that the patch can help
> > escaping such scenario. Furthermore, we also measured the major fault
> > of this process(by dumpsys of android). The result is the patch can
> > help to reduce 20% of the major fault during the test.
>
> I have asked already asked. Why do you use the soft limit in the first
> place? It is known to cause excessive reclaim and long stalls.

It is required by Google for applying new version of android system.
There was such a mechanism called LMK in previous ANDROID version,
which will kill process when in memory contention like OOM does. I
think Google want to drop such rough way for reclaiming pages and turn
to memcg. They setup different memcg groups for different process of
the system and set their softlimit according to the oom_adj. Their
original purpose is to reclaim pages gentlely in direct reclaim and
kswapd. During the debugging process , it seems to me that memcg maybe
tunable somehow. At least , the patch works on our system.
> --
> Michal Hocko
> SUSE Labs
