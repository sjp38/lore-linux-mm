Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id BF1A06B0005
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 07:02:06 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id h1so4192533wre.0
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 04:02:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d28si2026019eda.68.2018.04.13.04.02.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Apr 2018 04:02:05 -0700 (PDT)
Date: Fri, 13 Apr 2018 13:02:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: Remove memcg_cgroup::id from IDR on
 mem_cgroup_css_alloc() failure
Message-ID: <20180413110200.GG17484@dhcp22.suse.cz>
References: <152354470916.22460.14397070748001974638.stgit@localhost.localdomain>
 <20180413085553.GF17484@dhcp22.suse.cz>
 <ed75d18c-f516-2feb-53a8-6d2836e1da59@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ed75d18c-f516-2feb-53a8-6d2836e1da59@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 13-04-18 12:35:22, Kirill Tkhai wrote:
> On 13.04.2018 11:55, Michal Hocko wrote:
> > On Thu 12-04-18 17:52:04, Kirill Tkhai wrote:
> > [...]
> >> @@ -4471,6 +4477,7 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
> >>  
> >>  	return &memcg->css;
> >>  fail:
> >> +	mem_cgroup_id_remove(memcg);
> >>  	mem_cgroup_free(memcg);
> >>  	return ERR_PTR(-ENOMEM);
> >>  }
> > 
> > The only path which jumps to fail: here (in the current mmotm tree) is 
> > 	error = memcg_online_kmem(memcg);
> > 	if (error)
> > 		goto fail;
> > 
> > AFAICS and the only failure path in memcg_online_kmem
> > 	memcg_id = memcg_alloc_cache_id();
> > 	if (memcg_id < 0)
> > 		return memcg_id;
> > 
> > I am not entirely clear on memcg_alloc_cache_id but it seems we do clean
> > up properly. Or am I missing something?
> 
> memcg_alloc_cache_id() may allocate a lot of memory, in case of the system reached
> memcg_nr_cache_ids cgroups. In this case it iterates over all LRU lists, and double
> size of every of them. In case of memory pressure it can fail. If this occurs,
> mem_cgroup::id is not unhashed from IDR and we leak this id.

OK, my bad I was looking at the bad code path. So you want to clean up
after mem_cgroup_alloc not memcg_online_kmem. Now it makes much more
sense. Sorry for the confusion on my end.

Anyway, shouldn't we do the thing in mem_cgroup_free() to be symmetric
to mem_cgroup_alloc?
-- 
Michal Hocko
SUSE Labs
