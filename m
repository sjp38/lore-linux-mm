Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7CA436B0269
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 11:52:59 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id q3-v6so17356082qki.4
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 08:52:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d14-v6sor7882999qvj.63.2018.08.01.08.52.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 08:52:58 -0700 (PDT)
Date: Wed, 1 Aug 2018 11:55:52 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: Remove memcg_cgroup::id from IDR on
 mem_cgroup_css_alloc() failure
Message-ID: <20180801155552.GA8600@cmpxchg.org>
References: <8a81c801-35c8-767d-54b0-df9f1ca0abc0@virtuozzo.com>
 <20180413115454.GL17484@dhcp22.suse.cz>
 <abfd4903-c455-fac2-7ed6-73707cda64d1@virtuozzo.com>
 <20180413121433.GM17484@dhcp22.suse.cz>
 <20180413125101.GO17484@dhcp22.suse.cz>
 <20180726162512.6056b5d7c1d2a5fbff6ce214@linux-foundation.org>
 <20180727193134.GA10996@cmpxchg.org>
 <20180729192621.py4znecoinw5mqcp@esperanza>
 <20180730153113.GB4567@cmpxchg.org>
 <20180731163908.603d7a27c6534341e1afa724@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180731163908.603d7a27c6534341e1afa724@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Kirill Tkhai <ktkhai@virtuozzo.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 31, 2018 at 04:39:08PM -0700, Andrew Morton wrote:
> On Mon, 30 Jul 2018 11:31:13 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > Subject: [PATCH] mm: memcontrol: simplify memcg idr allocation and error
> >  unwinding
> > 
> > The memcg ID is allocated early in the multi-step memcg creation
> > process, which needs 2-step ID allocation and IDR publishing, as well
> > as two separate IDR cleanup/unwind sites on error.
> > 
> > Defer the IDR allocation until the last second during onlining to
> > eliminate all this complexity. There is no requirement to have the ID
> > and IDR entry earlier than that. And the root reference to the ID is
> > put in the offline path, so this matches nicely.
> 
> This patch isn't aware of Kirill's later "mm, memcg: assign memcg-aware
> shrinkers bitmap to memcg", which altered mem_cgroup_css_online():
> 
> @@ -4356,6 +4470,11 @@ static int mem_cgroup_css_online(struct
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  
> +	if (memcg_alloc_shrinker_maps(memcg)) {
> +		mem_cgroup_id_remove(memcg);
> +		return -ENOMEM;
> +	}
> +
>  	/* Online state pins memcg ID, memcg ID pins CSS */
>  	atomic_set(&memcg->id.ref, 1);
>  	css_get(css);
> 

Hm, that looks out of place too. The bitmaps are allocated for the
entire lifetime of the css, not just while it's online.

Any objections to the following fixup to that patch?
