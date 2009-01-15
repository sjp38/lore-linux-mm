Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A15316B005C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 00:16:10 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0F5G8eG003385
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 15 Jan 2009 14:16:08 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CCA6045DD7F
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 14:16:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 40FD645DD78
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 14:16:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 258791DB803C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 14:16:07 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A6C4D1DB8040
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 14:16:03 +0900 (JST)
Date: Thu, 15 Jan 2009 14:14:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 5/4] memcg: don't call res_counter_uncharge when
 obsolete
Message-Id: <20090115141458.818b4e9a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090115133814.a52460fa.nishimura@mxp.nes.nec.co.jp>
References: <20090113184533.6ffd2af9.nishimura@mxp.nes.nec.co.jp>
	<20090114175121.275ecd59.nishimura@mxp.nes.nec.co.jp>
	<7602a77a9fc6b1e8757468048fde749a.squirrel@webmail-b.css.fujitsu.com>
	<20090115100330.37d89d3d.nishimura@mxp.nes.nec.co.jp>
	<20090115110044.3a863af8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090115111420.8559bdb3.nishimura@mxp.nes.nec.co.jp>
	<20090115133814.a52460fa.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Jan 2009 13:38:14 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Thu, 15 Jan 2009 11:14:20 +0900, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > > > To handle the problem "parent may be obsolete",
> > > > > 
> > > > > call mem_cgroup_get(parent) at create()
> > > > > call mem_cgroup_put(parent) at freeing memcg.
> > > > >      (regardless of use_hierarchy.)
> > > > > 
> > > > > is clearer way to go, I think.
> > > > > 
> > > > > I wonder whether there is  mis-accounting problem or not..
> > > > > 
> hmm, after more consideration, although this patch can prevent the BUG,
> it can leak memsw accounting of parents because memsw of parents, which
> have been incremented by charge, does not decremented.
> 
> I'll try pet/put parent approach..
> Or any other good ideas ?
> 
> 
I believe get/put at create/destroy is enough now..
Let's try and see what happens.

Thanks,
-Kame


> Thanks,
> Daisuke Nishimura.
> 
> > > > > So, adding css_tryget() around problematic code can be a fix.
> > > > > --
> > > > >   mem = swap_cgroup_record();
> > > > >   if (css_tryget(&mem->css)) {
> > > > >       res_counter_uncharge(&mem->memsw, PAZE_SIZE);
> > > > >       css_put(&mem->css)
> > > > >   }
> > > > > --
> > > > > I like css_tryget() rather than mem_cgroup_obsolete().
> > > > I agree.
> > > > The updated version is attached.
> > > > 
> > > > 
> > > > Thanks,
> > > > Daisuke nishimura.
> > > > 
> > > > > To be honest, I'd like to remove memcg special stuff when I can.
> > > > > 
> > > > > Thanks,
> > > > > -Kame
> > > > > 
> > > > ===
> > > > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > > > 
> > > > mem_cgroup_get ensures that the memcg that has been got can be accessed
> > > > even after the directory has been removed, but it doesn't ensure that parents
> > > > of it can be accessed: parents might have been freed already by rmdir.
> > > > 
> > > > This causes a bug in case of use_hierarchy==1, because res_counter_uncharge
> > > > climb up the tree.
> > > > 
> > > > Check if the memcg is obsolete by css_tryget, and don't call
> > > > res_counter_uncharge when obsole.
> > > > 
> > > > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > > seems nice loock.
> > > 
> > > 
> > > > ---
> > > >  mm/memcontrol.c |   15 ++++++++++++---
> > > >  1 files changed, 12 insertions(+), 3 deletions(-)
> > > > 
> > > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > > index fb62b43..4e3b100 100644
> > > > --- a/mm/memcontrol.c
> > > > +++ b/mm/memcontrol.c
> > > > @@ -1182,7 +1182,10 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
> > > >  		/* avoid double counting */
> > > >  		mem = swap_cgroup_record(ent, NULL);
> > > >  		if (mem) {
> > > > -			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> > > > +			if (!css_tryget(&mem->css)) {
> > > > +				res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> > > > +				css_put(&mem->css);
> > > > +			}
> > > >  			mem_cgroup_put(mem);
> > > >  		}
> > > >  	}
> > > 
> > > I think css_tryget() returns "ture" at success....
> > > 
> > > So,
> > > ==
> > > 	if (mem && css_tryget(&mem->css))
> > > 		res_counter....
> > > 
> > > is correct.
> > > 
> > > -Kame
> > > 
> > Ooops! you are right.
> > Sorry for my silly mistake..
> > 
> > "mem" is checked beforehand, so I think css_tryget would be enough.
> > I'm now testing the attached one.
> > 
> > 
> > Thanks,
> > Daisuke Nishimura.
> > ===
> > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 
> > mem_cgroup_get ensures that the memcg that has been got can be accessed
> > even after the directory has been removed, but it doesn't ensure that parents
> > of it can be accessed: parents might have been freed already by rmdir.
> > 
> > This causes a bug in case of use_hierarchy==1, because res_counter_uncharge
> > climb up the tree.
> > 
> > Check if the memcg is obsolete by css_tryget, and don't call
> > res_counter_uncharge when obsole.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> >  mm/memcontrol.c |   15 ++++++++++++---
> >  1 files changed, 12 insertions(+), 3 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index fb62b43..b9d5271 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1182,7 +1182,10 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
> >  		/* avoid double counting */
> >  		mem = swap_cgroup_record(ent, NULL);
> >  		if (mem) {
> > -			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> > +			if (css_tryget(&mem->css)) {
> > +				res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> > +				css_put(&mem->css);
> > +			}
> >  			mem_cgroup_put(mem);
> >  		}
> >  	}
> > @@ -1252,7 +1255,10 @@ void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
> >  		struct mem_cgroup *memcg;
> >  		memcg = swap_cgroup_record(ent, NULL);
> >  		if (memcg) {
> > -			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
> > +			if (css_tryget(&memcg->css)) {
> > +				res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
> > +				css_put(&memcg->css);
> > +			}
> >  			mem_cgroup_put(memcg);
> >  		}
> >  
> > @@ -1397,7 +1403,10 @@ void mem_cgroup_uncharge_swap(swp_entry_t ent)
> >  
> >  	memcg = swap_cgroup_record(ent, NULL);
> >  	if (memcg) {
> > -		res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
> > +		if (css_tryget(&memcg->css)) {
> > +			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
> > +			css_put(&memcg->css);
> > +		}
> >  		mem_cgroup_put(memcg);
> >  	}
> >  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
