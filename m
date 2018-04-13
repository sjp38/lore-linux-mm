Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A9C6B6B000C
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 08:14:36 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id f19so4427446pfn.6
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 05:14:36 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t16si4536380pfj.10.2018.04.13.05.14.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Apr 2018 05:14:35 -0700 (PDT)
Date: Fri, 13 Apr 2018 14:14:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: Remove memcg_cgroup::id from IDR on
 mem_cgroup_css_alloc() failure
Message-ID: <20180413121433.GM17484@dhcp22.suse.cz>
References: <20180413085553.GF17484@dhcp22.suse.cz>
 <ed75d18c-f516-2feb-53a8-6d2836e1da59@virtuozzo.com>
 <20180413110200.GG17484@dhcp22.suse.cz>
 <06931a83-91d2-3dcf-31cf-0b98d82e957f@virtuozzo.com>
 <20180413112036.GH17484@dhcp22.suse.cz>
 <6dbc33bb-f3d5-1a46-b454-13c6f5865fcd@virtuozzo.com>
 <20180413113855.GI17484@dhcp22.suse.cz>
 <8a81c801-35c8-767d-54b0-df9f1ca0abc0@virtuozzo.com>
 <20180413115454.GL17484@dhcp22.suse.cz>
 <abfd4903-c455-fac2-7ed6-73707cda64d1@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <abfd4903-c455-fac2-7ed6-73707cda64d1@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 13-04-18 15:07:14, Kirill Tkhai wrote:
> On 13.04.2018 14:54, Michal Hocko wrote:
> > On Fri 13-04-18 14:49:32, Kirill Tkhai wrote:
> >> On 13.04.2018 14:38, Michal Hocko wrote:
> >>> On Fri 13-04-18 14:29:11, Kirill Tkhai wrote:
> > [...]
> >>>> mem_cgroup_id_put_many() unpins css, but this may be not the last reference to the css.
> >>>> Thus, we release ID earlier, then all references to css are freed.
> >>>
> >>> Right and so what. If we have released the idr then we are not going to
> >>> do that again in css_free. That is why we have that memcg->id.id > 0
> >>> check before idr_remove and memcg->id.id = 0 for the last memcg ref.
> >>> count. So again, why cannot we do the clean up in mem_cgroup_free and
> >>> have a less confusing code? Or am I just not getting your point and
> >>> being dense here?
> >>
> >> We can, but mem_cgroup_free() called from mem_cgroup_css_alloc() is unlikely case.
> >> The likely case is mem_cgroup_free() is called from mem_cgroup_css_free(), where
> >> this idr manipulations will be a noop. Noop in likely case looks more confusing
> >> for me.
> > 
> > Well, I would really prefer to have _free being symmetric to _alloc so
> > that you can rely that the full state is gone after _free is called.
> > This confused the hell out of me. Because I _did_ expect that
> > mem_cgroup_free would do that and so I was looking at completely
> > different place.
> >  
> >> Less confusing will be to move
> >>
> >>         memcg->id.id = idr_alloc(&mem_cgroup_idr, NULL,
> >>                                  1, MEM_CGROUP_ID_MAX,
> >>                                  GFP_KERNEL);
> >>
> >> into mem_cgroup_css_alloc(). How are you think about this?
> > 
> > I would have to double check. Maybe it can be done on top. But for the
> > actual fix and a stable backport potentially should be as clear as
> > possible. Your original patch would be just fine but if I would prefer 
> > mem_cgroup_free for the symmetry.
> 
> We definitely can move id allocation to mem_cgroup_css_alloc(), but this
> is really not for an easy fix, which will be backported to stable.
> 
> Moving idr destroy to mem_cgroup_free() hides IDR trick. My IMHO it's less
> readable for a reader.
> 
> The main problem is allocation asymmetric, and we shouldn't handle it on free path...

Well, this is probably a matter of taste. I will not argue. I will not
object if Johannes is OK with your patch. But the whole thing confused
hell out of me so I would rather un-clutter it...
-- 
Michal Hocko
SUSE Labs
