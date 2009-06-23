Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4BA2E6B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 00:52:19 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e38.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n5N4oq2q028552
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 22:50:52 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5N4rve6230234
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 22:53:57 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5N4ruKW022012
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 22:53:57 -0600
Date: Tue, 23 Jun 2009 10:23:16 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: Low overhead patches for the memory cgroup controller (v5)
Message-ID: <20090623045316.GF8642@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090615043900.GF23577@balbir.in.ibm.com> <20090622154343.9cdbf23a.akpm@linux-foundation.org> <20090623090116.556d4f97.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090623090116.556d4f97.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyuki@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, lizf@cn.fujitsu.com, menage@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-06-23 09:01:16]:

> On Mon, 22 Jun 2009 15:43:43 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Mon, 15 Jun 2009 10:09:00 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > >
> > > ...
> > > 
> > > This patch changes the memory cgroup and removes the overhead associated
> > > with accounting all pages in the root cgroup. As a side-effect, we can
> > > no longer set a memory hard limit in the root cgroup.
> > > 
> > > A new flag to track whether the page has been accounted or not
> > > has been added as well. Flags are now set atomically for page_cgroup,
> > > pcg_default_flags is now obsolete and removed.
> > > 
> > > ...
> > >
> > > @@ -1114,9 +1121,22 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
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
> > > +		ClearPageCgroupCache(pc);
> > > +		SetPageCgroupUsed(pc);
> > > +		break;
> > > +	default:
> > > +		break;
> > > +	}
> > 
> > Do we still need the smp_wmb()?
> > 
> > It's hard to say, because we forgot to document it :(
> > 
> Sorry for lack of documentation.
> 
> pc->mem_cgroup should be visible before SetPageCgroupUsed(). Othrewise,
> A routine believes USED bit will see bad pc->mem_cgroup.
> 
> I'd like to  add a comment later (againt new mmotm.)
>

Thanks Kamezawa! We do use the barrier Andrew, an easy way to find
affected code is to look at the smp_rmb()'s we have. But it is better
documented.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
