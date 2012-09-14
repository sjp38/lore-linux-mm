Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id CB6A96B01B1
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 04:27:44 -0400 (EDT)
Date: Fri, 14 Sep 2012 10:27:41 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/memcontrol.c: Remove duplicate inclusion of sock.h
 file
Message-ID: <20120914082741.GC28039@dhcp22.suse.cz>
References: <1347350934-17712-1-git-send-email-sachin.kamat@linaro.org>
 <20120911095200.GB8058@dhcp22.suse.cz>
 <20120912072520.GB17516@dhcp22.suse.cz>
 <50504CE1.8030509@parallels.com>
 <20120912125647.GH21579@dhcp22.suse.cz>
 <20120912130935.GJ21579@dhcp22.suse.cz>
 <CAK9yfHwMnC65BvY3RG7duf_Cmt5hf1VLV=vZRag4Mm6nHdQ-GA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAK9yfHwMnC65BvY3RG7duf_Cmt5hf1VLV=vZRag4Mm6nHdQ-GA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sachin Kamat <sachin.kamat@linaro.org>, Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri 14-09-12 13:28:07, Sachin Kamat wrote:
> Hi Michal,
> 
> Has this patch been accepted?

Not yet. I am waiting for Glauber to ack it.

> 
> On 12 September 2012 18:39, Michal Hocko <mhocko@suse.cz> wrote:
> > On Wed 12-09-12 14:56:47, Michal Hocko wrote:
> >> On Wed 12-09-12 12:50:41, Glauber Costa wrote:
> >> [...]
> >> > >> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >> > >> index 795e525..85ec9ff 100644
> >> > >> --- a/mm/memcontrol.c
> >> > >> +++ b/mm/memcontrol.c
> >> > >> @@ -50,8 +50,12 @@
> >> > >>  #include <linux/cpu.h>
> >> > >>  #include <linux/oom.h>
> >> > >>  #include "internal.h"
> >> > >> +
> >> > >> +#ifdef CONFIG_MEMCG_KMEM
> >> > >>  #include <net/sock.h>
> >> > >> +#include <net/ip.h>
> >> > >>  #include <net/tcp_memcontrol.h>
> >> > >> +#endif
> >> > >>
> >> > >>  #include <asm/uaccess.h>
> >> > >>
> >> > >> @@ -326,7 +330,7 @@ struct mem_cgroup {
> >> > >>          struct mem_cgroup_stat_cpu nocpu_base;
> >> > >>          spinlock_t pcp_counter_lock;
> >> > >>
> >> > >> -#ifdef CONFIG_INET
> >> > >> +#ifdef CONFIG_MEMCG_KMEM
> >> > >>          struct tcp_memcontrol tcp_mem;
> >> > >>  #endif
> >> > >>  };
> >> >
> >> > If you are changing this, why not test for both? This field will be
> >> > useless with inet disabled. I usually don't like conditional in
> >> > structures (note that the "kmem" res counter in my patchsets is not
> >> > conditional to KMEM!!), but since the decision was made to make this one
> >> > conditional, I think INET is a much better test. I am fine with both though.
> >>
> >>  You are right of course. Updated patch bellow:
> >
> > Bahh. And I managed to send a different patch than I tested...
> > ---
> > From 0617ff7114bdf424160a8f1533784c837d426ec2 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.cz>
> > Date: Tue, 11 Sep 2012 10:38:42 +0200
> > Subject: [PATCH] memcg: clean up networking headers file inclusion
> >
> > Memory controller doesn't need anything from the networking stack unless
> > CONFIG_MEMCG_KMEM is selected.
> > Now we are including net/sock.h and net/tcp_memcontrol.h unconditionally
> > which is not necessary. Moreover struct mem_cgroup contains tcp_mem even
> > if CONFIG_MEMCG_KMEM is not selected which is not necessary.
> >
> > Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > ---
> >  mm/memcontrol.c |    8 +++++---
> >  1 file changed, 5 insertions(+), 3 deletions(-)
> >
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 795e525..1a217b4 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -50,8 +50,12 @@
> >  #include <linux/cpu.h>
> >  #include <linux/oom.h>
> >  #include "internal.h"
> > +
> > +#if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_INET)
> >  #include <net/sock.h>
> > +#include <net/ip.h>
> >  #include <net/tcp_memcontrol.h>
> > +#endif
> >
> >  #include <asm/uaccess.h>
> >
> > @@ -326,7 +330,7 @@ struct mem_cgroup {
> >         struct mem_cgroup_stat_cpu nocpu_base;
> >         spinlock_t pcp_counter_lock;
> >
> > -#ifdef CONFIG_INET
> > +#if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_INET)
> >         struct tcp_memcontrol tcp_mem;
> >  #endif
> >  };
> > @@ -413,8 +417,6 @@ struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *s)
> >
> >  /* Writing them here to avoid exposing memcg's inner layout */
> >  #ifdef CONFIG_MEMCG_KMEM
> > -#include <net/sock.h>
> > -#include <net/ip.h>
> >
> >  static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
> >  void sock_update_memcg(struct sock *sk)
> > --
> > 1.7.10.4
> >
> > --
> > Michal Hocko
> > SUSE Labs
> 
> 
> 
> -- 
> With warm regards,
> Sachin

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
