Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 402B06B0009
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 07:38:58 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id z83so1066684wmc.2
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 04:38:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j20si1987258ede.348.2018.04.13.04.38.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Apr 2018 04:38:57 -0700 (PDT)
Date: Fri, 13 Apr 2018 13:38:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: Remove memcg_cgroup::id from IDR on
 mem_cgroup_css_alloc() failure
Message-ID: <20180413113855.GI17484@dhcp22.suse.cz>
References: <152354470916.22460.14397070748001974638.stgit@localhost.localdomain>
 <20180413085553.GF17484@dhcp22.suse.cz>
 <ed75d18c-f516-2feb-53a8-6d2836e1da59@virtuozzo.com>
 <20180413110200.GG17484@dhcp22.suse.cz>
 <06931a83-91d2-3dcf-31cf-0b98d82e957f@virtuozzo.com>
 <20180413112036.GH17484@dhcp22.suse.cz>
 <6dbc33bb-f3d5-1a46-b454-13c6f5865fcd@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6dbc33bb-f3d5-1a46-b454-13c6f5865fcd@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 13-04-18 14:29:11, Kirill Tkhai wrote:
> On 13.04.2018 14:20, Michal Hocko wrote:
> > On Fri 13-04-18 14:06:40, Kirill Tkhai wrote:
> >> On 13.04.2018 14:02, Michal Hocko wrote:
> >>> On Fri 13-04-18 12:35:22, Kirill Tkhai wrote:
> >>>> On 13.04.2018 11:55, Michal Hocko wrote:
> >>>>> On Thu 12-04-18 17:52:04, Kirill Tkhai wrote:
> >>>>> [...]
> >>>>>> @@ -4471,6 +4477,7 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
> >>>>>>  
> >>>>>>  	return &memcg->css;
> >>>>>>  fail:
> >>>>>> +	mem_cgroup_id_remove(memcg);
> >>>>>>  	mem_cgroup_free(memcg);
> >>>>>>  	return ERR_PTR(-ENOMEM);
> >>>>>>  }
> >>>>>
> >>>>> The only path which jumps to fail: here (in the current mmotm tree) is 
> >>>>> 	error = memcg_online_kmem(memcg);
> >>>>> 	if (error)
> >>>>> 		goto fail;
> >>>>>
> >>>>> AFAICS and the only failure path in memcg_online_kmem
> >>>>> 	memcg_id = memcg_alloc_cache_id();
> >>>>> 	if (memcg_id < 0)
> >>>>> 		return memcg_id;
> >>>>>
> >>>>> I am not entirely clear on memcg_alloc_cache_id but it seems we do clean
> >>>>> up properly. Or am I missing something?
> >>>>
> >>>> memcg_alloc_cache_id() may allocate a lot of memory, in case of the system reached
> >>>> memcg_nr_cache_ids cgroups. In this case it iterates over all LRU lists, and double
> >>>> size of every of them. In case of memory pressure it can fail. If this occurs,
> >>>> mem_cgroup::id is not unhashed from IDR and we leak this id.
> >>>
> >>> OK, my bad I was looking at the bad code path. So you want to clean up
> >>> after mem_cgroup_alloc not memcg_online_kmem. Now it makes much more
> >>> sense. Sorry for the confusion on my end.
> >>>
> >>> Anyway, shouldn't we do the thing in mem_cgroup_free() to be symmetric
> >>> to mem_cgroup_alloc?
> >>
> >> We can't, since it's called from mem_cgroup_css_free(), which doesn't have a deal
> >> with idr freeing. All the asymmetry, we see, is because of the trick to unhash ID
> >> earlier, then from mem_cgroup_css_free().
> > 
> > Are you sure. It's been some time since I've looked at the quite complex
> > cgroup tear down code but from what I remember, css_free is called on
> > the css release (aka when the reference count drops to zero). mem_cgroup_id_put_many
> > seems to unpin the css reference so we should have idr_remove by the
> > time when css_free is called. Or am I still wrong and should go over the
> > brain hurting cgroup removal code again?
> 
> mem_cgroup_id_put_many() unpins css, but this may be not the last reference to the css.
> Thus, we release ID earlier, then all references to css are freed.

Right and so what. If we have released the idr then we are not going to
do that again in css_free. That is why we have that memcg->id.id > 0
check before idr_remove and memcg->id.id = 0 for the last memcg ref.
count. So again, why cannot we do the clean up in mem_cgroup_free and
have a less confusing code? Or am I just not getting your point and
being dense here?
-- 
Michal Hocko
SUSE Labs
