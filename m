Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id F27BC6B003C
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 04:08:04 -0400 (EDT)
Date: Fri, 22 Mar 2013 09:07:49 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: fix memcg_cache_name() to use cgroup_name()
Message-ID: <20130322080749.GB31457@dhcp22.suse.cz>
References: <514A60CD.60208@huawei.com>
 <20130321090849.GF6094@dhcp22.suse.cz>
 <20130321102257.GH6094@dhcp22.suse.cz>
 <514BB23E.70908@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <514BB23E.70908@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>

On Fri 22-03-13 09:22:06, Li Zefan wrote:
> On 2013/3/21 18:22, Michal Hocko wrote:
> > On Thu 21-03-13 10:08:49, Michal Hocko wrote:
> >> On Thu 21-03-13 09:22:21, Li Zefan wrote:
> >>> As cgroup supports rename, it's unsafe to dereference dentry->d_name
> >>> without proper vfs locks. Fix this by using cgroup_name().
> >>>
> >>> Signed-off-by: Li Zefan <lizefan@huawei.com>
> >>> ---
> >>>
> >>> This patch depends on "cgroup: fix cgroup_path() vs rename() race",
> >>> which has been queued for 3.10.
> >>>
> >>> ---
> >>>  mm/memcontrol.c | 15 +++++++--------
> >>>  1 file changed, 7 insertions(+), 8 deletions(-)
> >>>
> >>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >>> index 53b8201..72be5c9 100644
> >>> --- a/mm/memcontrol.c
> >>> +++ b/mm/memcontrol.c
> >>> @@ -3217,17 +3217,16 @@ void mem_cgroup_destroy_cache(struct kmem_cache *cachep)
> >>>  static char *memcg_cache_name(struct mem_cgroup *memcg, struct kmem_cache *s)
> >>>  {
> >>>  	char *name;
> >>> -	struct dentry *dentry;
> >>> +
> >>> +	name = (char *)__get_free_page(GFP_TEMPORARY);
> >>
> >> Ouch. Can we use a static temporary buffer instead?
> > 
> >> This is called from workqueue context so we do not have to be afraid
> >> of the deep call chain.
> > 
> > Bahh, I was thinking about two things at the same time and that is how
> > it ends... I meant a temporary buffer on the stack. But a separate
> > allocation sounds even easier.
> > 
> 
> Actually I don't care much about which way to take. Use on-stack buffer (if stack
> usage is not a concern) or local static buffer (caller already held memcg_cache_mutex)
> is simplest.
> 
> But why it's bad to allocate a page for temp use?

GFP_TEMPORARY groups short lived allocations but the mem cache is not
an ideal candidate of this type of allocations..

> >> It is also not a hot path AFAICS.
> >>
> >> Even GFP_ATOMIC for kasprintf would be an improvement IMO.
> > 
> > What about the following (not even compile tested because I do not have
> > cgroup_name in my tree yet):
> 
> No, it won't compile. ;)

Somehow expected so as this was just a quick hack to show what I meant.
The full patch is bellow (compile time tested on top of for-3.10 branch
this time :P)
---
