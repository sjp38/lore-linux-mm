Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 389EA6B005C
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 19:51:53 -0400 (EDT)
Date: Fri, 25 Sep 2009 08:39:56 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 4/8] memcg: add interface to migrate charge
Message-Id: <20090925083956.39e652e4.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090924155459.a137a9b6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
	<20090917160103.1bcdddee.nishimura@mxp.nes.nec.co.jp>
	<20090924144214.508469d1.nishimura@mxp.nes.nec.co.jp>
	<20090924144718.d779ed0e.nishimura@mxp.nes.nec.co.jp>
	<20090924155459.a137a9b6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 24 Sep 2009 15:54:59 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 24 Sep 2009 14:47:18 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > This patch adds "memory.migrate_charge" file and handlers of it.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> >  mm/memcontrol.c |   65 +++++++++++++++++++++++++++++++++++++++++++++++++++---
> >  1 files changed, 61 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 7e8874d..30499d9 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -225,6 +225,8 @@ struct mem_cgroup {
> >  	/* set when res.limit == memsw.limit */
> >  	bool		memsw_is_minimum;
> >  
> > +	bool	 	migrate_charge;
> > +
> >  	/*
> >  	 * statistics. This must be placed at the end of memcg.
> >  	 */
> > @@ -2843,6 +2845,27 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
> >  	return 0;
> >  }
> >  
> > +static u64 mem_cgroup_migrate_charge_read(struct cgroup *cgrp,
> > +					struct cftype *cft)
> > +{
> > +	return mem_cgroup_from_cont(cgrp)->migrate_charge;
> > +}
> > +
> > +static int mem_cgroup_migrate_charge_write(struct cgroup *cgrp,
> > +					struct cftype *cft, u64 val)
> > +{
> > +	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
> > +
> > +	if (val != 0 && val != 1)
> > +		return -EINVAL;
> > +
> > +	cgroup_lock();
> > +	mem->migrate_charge = val;
> > +	cgroup_unlock();
> > +
> > +	return 0;
> > +}
> 
> Do we need cgroup_lock() here ?
> Is this lock agaisnt race with attach() ?
> If so, adding commentary is better.
> 
I thought so..., but, considering more, it would be unnecessary because we check it
only once in mem_cgroup_can_attach() in current implementation.
I'll add some comments anyway.

> BTW, migrate_charge is an ambiguous name.
> 
>   Does migrate_charge mean
>   (1) When a task is migrated "into" this cgroup, charges of that
>       will be moved from the orignal cgroup ?
>   (2) When a task is migrated "from" this cgroup, charges of that
>       will be moved to a destination cgroup ?
> 
> And I don't like using word as "migrate" here because it is associated
> with page-migration ;)
> 
Agreed.

> If you don't mind, how about "recharge_at_immigrate" or some ?
> (But I believe there will be better words....)
> 
Seems good for me.
Thank you for your suggestion.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
