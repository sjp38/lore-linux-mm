Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E9C5F6B004D
	for <linux-mm@kvack.org>; Sun,  7 Jun 2009 19:15:40 -0400 (EDT)
Date: Mon, 8 Jun 2009 09:03:22 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: Low overhead patches for the memory cgroup controller (v3)
Message-Id: <20090608090322.eb14ff85.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090605094721.GK11755@balbir.in.ibm.com>
References: <b7dd123f0a15fff62150bc560747d7f0.squirrel@webmail-b.css.fujitsu.com>
	<20090515181639.GH4451@balbir.in.ibm.com>
	<20090518191107.8a7cc990.kamezawa.hiroyu@jp.fujitsu.com>
	<20090531235121.GA6120@balbir.in.ibm.com>
	<20090602085744.2eebf211.kamezawa.hiroyu@jp.fujitsu.com>
	<20090605053107.GF11755@balbir.in.ibm.com>
	<20090605150527.c263037c.nishimura@mxp.nes.nec.co.jp>
	<20090605094721.GK11755@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, KOSAKI Motohiro <m-kosaki@ceres.dti.ne.jp>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 5 Jun 2009 17:47:21 +0800, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> * nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2009-06-05 15:05:27]:
> 
> > Hmm.. I can't see any practical changes from v2 except for PCG_ACCT -> PCG_ACCT_LRU.
> > 
> > > @@ -1107,9 +1118,24 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
> > >  		css_put(&mem->css);
> > >  		return;
> > >  	}
> > > +
> > >  	pc->mem_cgroup = mem;
> > >  	smp_wmb();
> > > -	pc->flags = pcg_default_flags[ctype];
> > > +	switch (ctype) {
> > > +	case MEM_CGROUP_CHARGE_TYPE_CACHE:
> > > +	case MEM_CGROUP_CHARGE_TYPE_SHMEM:
> > > +		SetPageCgroupCache(pc);
> > > +		SetPageCgroupUsed(pc);
> > > +		break;
> > > +	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
> > > +		SetPageCgroupUsed(pc);
> > I think we need ClearPageCgroupCache() here.
> > Otherwise, we cannot trust PageCgroupCache() in mem_cgroup_charge_statistics().
> > A page can be reused, but we don't cleare PCG_CACHE on free/alloc of page.
> 
> Yes, I know, I think it is best to set pc->flags to 0 before setting
> the bits. Thanks!
> 
I don't think clearing pc->flags is a good idea.
It can break PCG_ACCT_LRU bit.
ClearPageCgroupCache() before SetPageCgroupUsed() in case of CHARGE_TYPE_MAPPED
would be enough.

Thanks,
Daisuke Nishimura.

> > 
> > > +		break;
> > > +	default:
> > > +		break;
> > > +	}
> > > +
> > > +	if (mem == root_mem_cgroup)
> > > +		SetPageCgroupRoot(pc);
> > >  
> > I think you should set PCG_ROOT before setting PCG_USED.
> > IIUC, PCG_ROOT bit must be visible already when PCG_USED is set.
> 
> Kame pointed to something similar, I am going to remove PCG_ROOT in
> the next version.
> 
> -- 
> 	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
