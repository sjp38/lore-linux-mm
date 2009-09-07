Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C9C9A6B0095
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 00:51:41 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp06.in.ibm.com (8.14.3/8.13.1) with ESMTP id n874pfoW012860
	for <linux-mm@kvack.org>; Mon, 7 Sep 2009 10:21:41 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n874peO72166802
	for <linux-mm@kvack.org>; Mon, 7 Sep 2009 10:21:41 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n874pemZ016561
	for <linux-mm@kvack.org>; Mon, 7 Sep 2009 14:51:40 +1000
Date: Mon, 7 Sep 2009 10:21:37 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [mmotm][BUGFIX][PATCH] memcg: fix softlimit css refcnt
 handling(yet another one)
Message-ID: <20090907045137.GE8315@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090903141727.ccde7e91.nishimura@mxp.nes.nec.co.jp>
 <20090904131835.ac2b8cc8.kamezawa.hiroyu@jp.fujitsu.com>
 <20090904141157.4640ec1e.nishimura@mxp.nes.nec.co.jp>
 <20090904142143.15ffcb53.kamezawa.hiroyu@jp.fujitsu.com>
 <20090904142654.08dd159f.kamezawa.hiroyu@jp.fujitsu.com>
 <20090904154050.25873aa5.nishimura@mxp.nes.nec.co.jp>
 <20090904163758.a5604fee.kamezawa.hiroyu@jp.fujitsu.com>
 <20090904190726.6442f3df.d-nishimura@mtf.biglobe.ne.jp>
 <20090907080403.5e4510b3.d-nishimura@mtf.biglobe.ne.jp>
 <20090907094912.5cbbbaa5.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090907094912.5cbbbaa5.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-09-07 09:49:12]:

> > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 
> > refcount of the "victim" should be decremented before exiting the loop.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Nice!
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> > ---
> >  mm/memcontrol.c |    8 ++++++--
> >  1 files changed, 6 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index ac51294..011aba6 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1133,8 +1133,10 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> >  				 * anything, it might because there are
> >  				 * no reclaimable pages under this hierarchy
> >  				 */
> > -				if (!check_soft || !total)
> > +				if (!check_soft || !total) {
> > +					css_put(&victim->css);
> >  					break;
> > +				}
> >  				/*
> >  				 * We want to do more targetted reclaim.
> >  				 * excess >> 2 is not to excessive so as to
> > @@ -1142,8 +1144,10 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> >  				 * coming back to reclaim from this cgroup
> >  				 */
> >  				if (total >= (excess >> 2) ||
> > -					(loop > MEM_CGROUP_MAX_RECLAIM_LOOPS))
> > +					(loop > MEM_CGROUP_MAX_RECLAIM_LOOPS)) {
> > +					css_put(&victim->css);
> >  					break;
> > +				}
> >  			}
> >  		}
> >  		if (!mem_cgroup_local_usage(&victim->stat)) {

Good catch! Sorry for the late response I've been away


Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
