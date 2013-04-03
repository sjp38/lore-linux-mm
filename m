Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 3D9936B00B6
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 04:18:45 -0400 (EDT)
Date: Wed, 3 Apr 2013 10:18:43 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -v2] memcg: don't do cleanup manually if
 mem_cgroup_css_online() fails
Message-ID: <20130403081843.GC14384@dhcp22.suse.cz>
References: <515A8A40.6020406@huawei.com>
 <20130402121600.GK24345@dhcp22.suse.cz>
 <20130402141646.GQ24345@dhcp22.suse.cz>
 <515AE948.1000704@parallels.com>
 <20130402142825.GA32520@dhcp22.suse.cz>
 <515AEC3A.2030401@parallels.com>
 <20130402150422.GB32520@dhcp22.suse.cz>
 <515BA6C9.2000704@huawei.com>
 <20130403074300.GA14384@dhcp22.suse.cz>
 <515BDEF2.1080900@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <515BDEF2.1080900@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Glauber Costa <glommer@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Wed 03-04-13 15:49:06, Li Zefan wrote:
> On 2013/4/3 15:43, Michal Hocko wrote:
> > On Wed 03-04-13 11:49:29, Li Zefan wrote:
> >>>> Yes, indeed you are very right - and thanks for looking at such depth.
> >>>
> >>> So what about the patch bellow? It seems that I provoked all this mess
> >>> but my brain managed to push it away so I do not remember why I thought
> >>> the parent needs reference drop... It is "only" 3.9 thing fortunately.
> >>> ---
> >>> >From 3aff5d958f1d0717795018f7d0d6b63d53ad1dd3 Mon Sep 17 00:00:00 2001
> >>> From: Li Zefan <lizefan@huawei.com>
> >>> Date: Tue, 2 Apr 2013 16:37:39 +0200
> >>> Subject: [PATCH] memcg: don't do cleanup manually if mem_cgroup_css_online()
> >>>  fails
> >>>
> >>> mem_cgroup_css_online is called with memcg with refcnt = 1 and it
> >>> expects that mem_cgroup_css_free will drop this last reference.
> >>> This doesn't hold when memcg_init_kmem fails though and a reference is
> >>> dropped for both memcg and its parent explicitly if it returns with an
> >>> error.
> >>>
> >>> This is not correct for two reasons. Firstly mem_cgroup_put on parent is
> >>> excessive because mem_cgroup_put is hierarchy aware and secondly only
> >>> memcg_propagate_kmem takes an additional reference.
> >>>
> >>> The first one is a real use-after-free bug introduced by e4715f01
> >>> (memcg: avoid dangling reference count in creation failure)
> >>>
> >>> The later one is non-issue right now because the only implementation
> >>> of init_cgroup seems to be tcp_init_cgroup which doesn't fail
> >>> but it is better to make the error handling saner and move the
> >>> mem_cgroup_put(memcg) to memcg_propagate_kmem where it belongs.
> >>>
> >>> Signed-off-by: Li Zefan <lizefan@huawei.com>
> >>> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> >>> ---
> >>>  mm/memcontrol.c |   13 +++----------
> >>>  1 file changed, 3 insertions(+), 10 deletions(-)
> >>>
> >>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >>> index f608546..cf9ba7e 100644
> >>> --- a/mm/memcontrol.c
> >>> +++ b/mm/memcontrol.c
> >>> @@ -5306,6 +5306,8 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
> >>>  	ret = memcg_update_cache_sizes(memcg);
> >>>  	mutex_unlock(&set_limit_mutex);
> >>>  out:
> >>> +	if (ret)
> >>> +		mem_cgroup_put(memcg);
> >>
> >> Correct me if I'm wrong, but I think:
> >>
> >> When memcg_propagate_kmem() calls mem_cgroup_get(), it's because the kmemcg
> >> is active by inheritance. Then when memcg_update_cache_sizes() fails, leading
> >> to mem_cgroup_css_free() is called by cgroup core:
> >>
> >> static void mem_cgroup_css_free(struct cgroup *cont)
> >> {
> >>         struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> >>
> >>         kmem_cgroup_destroy(memcg);
> >>
> >>         mem_cgroup_put(memcg);
> >> }
> >>
> >> static void kmem_cgroup_destroy(struct mem_cgroup *memcg)
> >> {
> >>         mem_cgroup_sockets_destroy(memcg);
> >>
> >>         memcg_kmem_mark_dead(memcg);
> >>
> >>         if (res_counter_read_u64(&memcg->kmem, RES_USAGE) != 0)
> >>                 return;
> >>
> >>         if (memcg_kmem_test_and_clear_dead(memcg))
> >>                 mem_cgroup_put(memcg);    <------- !!!!!!!!!
> >> }
> > 
> > But memcg_update_cache_sizes calls memcg_kmem_clear_activated on the
> > error path.
> > 
> 
> But memcg_kmem_mark_dead() checks the ACCOUNT flag not the ACCOUNTED flag.
> Am I missing something?
> 

Dang. You are right! Glauber, is there any reason why
memcg_kmem_mark_dead checks only KMEM_ACCOUNTED_ACTIVE rather than
KMEM_ACCOUNTED_MASK?

This all is very confusing to say the least.

Anyway, this all means that Li's first patch is correct. I am not sure I
like it though. I think that the refcount cleanup should be done as
close to where it has been taken as possible otherwise we will end up in
this "chase the nasty details" again and again. There are definitely two
bugs here. The one introduced by e4715f01 and the other one introduced
even earlier (I haven't checked that history yet). I think we should do
something like the 2 follow up patches but if you guys think that the smaller
patch from Li is more appropriate then I will not block it.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
