Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 438DA6B020E
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 08:13:12 -0400 (EDT)
Date: Fri, 14 Sep 2012 14:13:09 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] memcg: clean up networking headers file inclusion
Message-ID: <20120914121309.GM28039@dhcp22.suse.cz>
References: <20120914112118.GG28039@dhcp22.suse.cz>
 <50531339.1000805@parallels.com>
 <20120914113400.GI28039@dhcp22.suse.cz>
 <50531696.1080708@parallels.com>
 <20120914120138.GK28039@dhcp22.suse.cz>
 <5052E550.9000506@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5052E550.9000506@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sachin Kamat <sachin.kamat@linaro.org>

On Fri 14-09-12 12:05:36, Glauber Costa wrote:
> On 09/14/2012 04:01 PM, Michal Hocko wrote:
> > On Fri 14-09-12 15:35:50, Glauber Costa wrote:
> >> On 09/14/2012 03:34 PM, Michal Hocko wrote:
> >>> On Fri 14-09-12 15:21:29, Glauber Costa wrote:
> >>>> On 09/14/2012 03:21 PM, Michal Hocko wrote:
> >>>>> Hi,
> >>>>> so I did some more changes to ifdefery of sock kmem part. The patch is
> >>>>> below. 
> >>>>> Glauber please have a look at it. I do not think any of the
> >>>>> functionality wrapped inside CONFIG_MEMCG_KMEM without CONFIG_INET is
> >>>>> reusable for generic CONFIG_MEMCG_KMEM, right?
> >>>> Almost right.
> >>>>
> >>>>
> >>>>
> >>>>>  }
> >>>>>  
> >>>>>  /* Writing them here to avoid exposing memcg's inner layout */
> >>>>> -#ifdef CONFIG_MEMCG_KMEM
> >>>>> -#include <net/sock.h>
> >>>>> -#include <net/ip.h>
> >>>>> +#if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
> >>>>>  
> >>>>>  static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
> >>>>
> >>>> This one is. ^^^^
> >>>
> >>> But this is just a forward declaration. And btw. it makes my compiler
> >>> complain about:
> >>> mm/memcontrol.c:421: warning: a??mem_cgroup_is_roota?? declared inline after being called
> >>> mm/memcontrol.c:421: warning: previous declaration of a??mem_cgroup_is_roota?? was here
> >>>
> >>> But I didn't care much yet. It is probaly that my compiler is too old to
> >>> be clever about this.
> >>>
> >> Weird, this code is in tree for a long time.
> > 
> > Yes I think it is just compiler issue. Anyway the trivial patch bellow
> > does the trick.
> 
> That seems to be alright, and it works for me as well.

OK, I will post it on top of the last version.

> 
> 
> > ---
> > From 28a803e6e07c5b7ae6b88d7b26801666781aa899 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.cz>
> > Date: Fri, 14 Sep 2012 13:56:32 +0200
> > Subject: [PATCH] memcg: move mem_cgroup_is_root upwards
> > MIME-Version: 1.0
> > Content-Type: text/plain; charset=UTF-8
> > Content-Transfer-Encoding: 8bit
> > 
> > kmem code uses this function and it is better to not use forward
> > declarations for static inline functions as some (older) compilers don't
> > like it:
> > 
> > gcc version 4.3.4 [gcc-4_3-branch revision 152973] (SUSE Linux)
> > 
> > mm/memcontrol.c:421: warning: a??mem_cgroup_is_roota?? declared inline after being called
> > mm/memcontrol.c:421: warning: previous declaration of a??mem_cgroup_is_roota?? was here
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > ---
> >  mm/memcontrol.c |   11 +++++------
> >  1 file changed, 5 insertions(+), 6 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 0cd25e9..df69552 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -415,10 +415,14 @@ struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *s)
> >  	return container_of(s, struct mem_cgroup, css);
> >  }
> >  
> > +static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
> > +{
> > +	return (memcg == root_mem_cgroup);
> > +}
> > +
> >  /* Writing them here to avoid exposing memcg's inner layout */
> >  #if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
> >  
> > -static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
> >  void sock_update_memcg(struct sock *sk)
> >  {
> >  	if (mem_cgroup_sockets_enabled) {
> > @@ -1014,11 +1018,6 @@ void mem_cgroup_iter_break(struct mem_cgroup *root,
> >  	     iter != NULL;				\
> >  	     iter = mem_cgroup_iter(NULL, iter, NULL))
> >  
> > -static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
> > -{
> > -	return (memcg == root_mem_cgroup);
> > -}
> > -
> >  void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
> >  {
> >  	struct mem_cgroup *memcg;
> > 
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
