Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 803726B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 04:51:16 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 62-v6so12370982pfw.21
        for <linux-mm@kvack.org>; Thu, 31 May 2018 01:51:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d5-v6si9978070pln.567.2018.05.31.01.51.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 May 2018 01:51:15 -0700 (PDT)
Date: Thu, 31 May 2018 10:51:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: force charge kmem counter too
Message-ID: <20180531085109.GJ15278@dhcp22.suse.cz>
References: <20180525185501.82098-1-shakeelb@google.com>
 <20180526185144.xvh7ejlyelzvqwdb@esperanza>
 <CALvZod5yTxcuB_Aao-a0ChNEnwyBJk9UPvEQ80s9tZFBQ0cxpw@mail.gmail.com>
 <20180528091110.GG1517@dhcp22.suse.cz>
 <CALvZod6x5iRmcJ6pYKS+jwJd855jnwmVcPK9tnKbuJ9Hfppa-A@mail.gmail.com>
 <20180529083153.GR27180@dhcp22.suse.cz>
 <CALvZod67qzq+hQLms4Wut5LNVBjBcEQPpMp9zxF6NE5k+7CLOw@mail.gmail.com>
 <20180531060133.GA31477@rodete-desktop-imager.corp.google.com>
 <20180531065642.GI15278@dhcp22.suse.cz>
 <20180531082317.GA52285@rodete-desktop-imager.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180531082317.GA52285@rodete-desktop-imager.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Shakeel Butt <shakeelb@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 31-05-18 17:23:17, Minchan Kim wrote:
> On Thu, May 31, 2018 at 08:56:42AM +0200, Michal Hocko wrote:
> > On Thu 31-05-18 15:01:33, Minchan Kim wrote:
> > > On Wed, May 30, 2018 at 11:14:33AM -0700, Shakeel Butt wrote:
> > > > On Tue, May 29, 2018 at 1:31 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > > > > On Mon 28-05-18 10:23:07, Shakeel Butt wrote:
> > > > >> On Mon, May 28, 2018 at 2:11 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > > > >> Though is there a precedence where the broken feature is not fixed
> > > > >> because an alternative is available?
> > > > >
> > > > > Well, I can see how breaking GFP_NOFAIL semantic is problematic, on the
> > > > > other hand we keep saying that kmem accounting in v1 is hard usable and
> > > > > strongly discourage people from using it. Sure we can add the code which
> > > > > handles _this_ particular case but that wouldn't make the whole thing
> > > > > more usable I strongly suspect. Maybe I am wrong and you can provide
> > > > > some specific examples. Is GFP_NOFAIL that common to matter?
> > > > >
> > > > > In any case we should balance between the code maintainability here.
> > > > > Adding more cruft into the allocator path is not free.
> > > > >
> > > > 
> > > > We do not use kmem limits internally and this is something I found
> > > > through code inspection. If this patch is increasing the cost of code
> > > > maintainability I am fine with dropping it but at least there should a
> > > > comment saying that kmem limits are broken and no need fix.
> > >  
> > > I agree.
> > > 
> > > Even, I didn't know kmem is strongly discouraged until now. Then,
> > > why is it enabled by default on cgroup v1?
> > 
> > You have to set a non-zero limit to make it active IIRC. The code is
> 
> Maybe, no. I didn't set anything. IOW, it was a default without any setting
> and I hit this as you can remember.
> http://lkml.kernel.org/r/<20180418022912.248417-1-minchan@kernel.org>
> We don't need to allocate memory for stuff even maintainers discourage.

Well, you can disable the whole kmem accounting by cgroup.memory=nokmem
kernel parameter. I wasn't very happy when we removed the config option
which would have put all the tracking aside even when no limit is set
but the argument was that the ifdefery was growing into an
unmaintainable mess and I have to agree with that. So here we are...
-- 
Michal Hocko
SUSE Labs
