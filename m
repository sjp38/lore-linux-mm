Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E58826B0082
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 03:18:04 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0A9F53EE0C2
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 16:18:00 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E3CA945DE5D
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 16:17:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C982645DE58
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 16:17:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BB1471DB804F
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 16:17:59 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 769FE1DB804D
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 16:17:59 +0900 (JST)
Date: Thu, 30 Jun 2011 16:10:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] [Cleanup] memcg: export memory cgroup's swappiness v2
Message-Id: <20110630161039.604f91b9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110630063231.GA12342@tiehlicka.suse.cz>
References: <20110629190325.28aa2dc6.kamezawa.hiroyu@jp.fujitsu.com>
	<20110629130043.4dc47249.akpm@linux-foundation.org>
	<20110630123229.37424449.kamezawa.hiroyu@jp.fujitsu.com>
	<20110630063231.GA12342@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Ying Han <yinghan@google.com>

On Thu, 30 Jun 2011 08:32:32 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Thu 30-06-11 12:32:29, KAMEZAWA Hiroyuki wrote:
> > On Wed, 29 Jun 2011 13:00:43 -0700
> > Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> > > On Wed, 29 Jun 2011 19:03:25 +0900
> > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > 
> > > > Each memory cgroup has 'swappiness' value and it can be accessed by
> > > > get_swappiness(memcg). The major user is try_to_free_mem_cgroup_pages()
> > > > and swappiness is passed by argument. It's propagated by scan_control.
> > > > 
> > > > get_swappiness is static function but some planned updates will need to
> > > > get swappiness from files other than memcontrol.c
> > > > This patch exports get_swappiness() as mem_cgroup_swappiness().
> > > > By this, we can remove the argument of swapiness from try_to_free...
> > > > and drop swappiness from scan_control. only memcg uses it.
> > > > 
> > > 
> > > > +extern unsigned int mem_cgroup_swappiness(struct mem_cgroup *mem);
> > > > +unsigned int mem_cgroup_swappiness(struct mem_cgroup *memcg)
> > > > +static int vmscan_swappiness(struct scan_control *sc)
> > > 
> > > The patch seems a bit confused about the signedness of swappiness.
> > > 
> > 
> > ok, v3 here. Now, memcg's one use "int" because vm_swapiness is "int".
> > ==
> > 
> > From af1bae8f2c6a8dbff048222bb45c7162b505f38b Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Wed, 29 Jun 2011 18:24:49 +0900
> > Subject: [PATCH] export memory cgroup's swappines by mem_cgroup_swappiness()
> > 
> > Each memory cgroup has 'swappiness' value and it can be accessed by
> > get_swappiness(memcg). The major user is try_to_free_mem_cgroup_pages()
> > and swappiness is passed by argument. It's propagated by scan_control.
> > 
> > get_swappiness is static function but some planned updates will need to
> > get swappiness from files other than memcontrol.c
> > This patch exports get_swappiness() as mem_cgroup_swappiness().
> > By this, we can remove the argument of swapiness from try_to_free...
> > and drop swappiness from scan_control. only memcg uses it.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
> 
> > 
> > Changelog:
> >   - adjusted signedness to vm_swappiness.
> >   - drop swappiness from scan_control
> > ---
> >  include/linux/swap.h |   10 +++++++---
> >  mm/memcontrol.c      |   15 +++++++--------
> >  mm/vmscan.c          |   23 ++++++++++-------------
> >  3 files changed, 24 insertions(+), 24 deletions(-)
> > 
> [...]
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 3e7d5e6..db70176 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> [...]
> > @@ -4288,7 +4287,7 @@ static u64 mem_cgroup_swappiness_read(struct cgroup *cgrp, struct cftype *cft)
> >  {
> >  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> >  
> > -	return get_swappiness(memcg);
> > +	return mem_cgroup_swappiness(memcg);
> >  }
> 
> If you want to be type clean you should change this one as well. I
> think it is worth it, though. The function is called only to return the
> current value to userspace and mem_cgroup_swappiness_write guaranties
> that it falls down into <0,100> interval. Additionally, cftype doesn't
> have any read specialization for int values so you would need to use a
> generic one. Finally if you changed read part you should change also
> write part and add > 0 check which is a lot of code for not that good
> reason.

I don't want to make this type-clean. Should I add type casting as
==
 return (u64) mem_cgroup_swappiness(memcg);
==
?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
