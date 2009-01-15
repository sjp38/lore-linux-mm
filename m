Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 405A06B005C
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 21:30:38 -0500 (EST)
Date: Thu, 15 Jan 2009 11:14:20 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 5/4] memcg: don't call res_counter_uncharge when
 obsolete
Message-Id: <20090115111420.8559bdb3.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090115110044.3a863af8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090113184533.6ffd2af9.nishimura@mxp.nes.nec.co.jp>
	<20090114175121.275ecd59.nishimura@mxp.nes.nec.co.jp>
	<7602a77a9fc6b1e8757468048fde749a.squirrel@webmail-b.css.fujitsu.com>
	<20090115100330.37d89d3d.nishimura@mxp.nes.nec.co.jp>
	<20090115110044.3a863af8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

> > > To handle the problem "parent may be obsolete",
> > > 
> > > call mem_cgroup_get(parent) at create()
> > > call mem_cgroup_put(parent) at freeing memcg.
> > >      (regardless of use_hierarchy.)
> > > 
> > > is clearer way to go, I think.
> > > 
> > > I wonder whether there is  mis-accounting problem or not..
> > > 
> > > So, adding css_tryget() around problematic code can be a fix.
> > > --
> > >   mem = swap_cgroup_record();
> > >   if (css_tryget(&mem->css)) {
> > >       res_counter_uncharge(&mem->memsw, PAZE_SIZE);
> > >       css_put(&mem->css)
> > >   }
> > > --
> > > I like css_tryget() rather than mem_cgroup_obsolete().
> > I agree.
> > The updated version is attached.
> > 
> > 
> > Thanks,
> > Daisuke nishimura.
> > 
> > > To be honest, I'd like to remove memcg special stuff when I can.
> > > 
> > > Thanks,
> > > -Kame
> > > 
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
> seems nice loock.
> 
> 
> > ---
> >  mm/memcontrol.c |   15 ++++++++++++---
> >  1 files changed, 12 insertions(+), 3 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index fb62b43..4e3b100 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1182,7 +1182,10 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
> >  		/* avoid double counting */
> >  		mem = swap_cgroup_record(ent, NULL);
> >  		if (mem) {
> > -			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> > +			if (!css_tryget(&mem->css)) {
> > +				res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> > +				css_put(&mem->css);
> > +			}
> >  			mem_cgroup_put(mem);
> >  		}
> >  	}
> 
> I think css_tryget() returns "ture" at success....
> 
> So,
> ==
> 	if (mem && css_tryget(&mem->css))
> 		res_counter....
> 
> is correct.
> 
> -Kame
> 
Ooops! you are right.
Sorry for my silly mistake..

"mem" is checked beforehand, so I think css_tryget would be enough.
I'm now testing the attached one.


Thanks,
Daisuke Nishimura.
===
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

mem_cgroup_get ensures that the memcg that has been got can be accessed
even after the directory has been removed, but it doesn't ensure that parents
of it can be accessed: parents might have been freed already by rmdir.

This causes a bug in case of use_hierarchy==1, because res_counter_uncharge
climb up the tree.

Check if the memcg is obsolete by css_tryget, and don't call
res_counter_uncharge when obsole.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fb62b43..b9d5271 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1182,7 +1182,10 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 		/* avoid double counting */
 		mem = swap_cgroup_record(ent, NULL);
 		if (mem) {
-			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+			if (css_tryget(&mem->css)) {
+				res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+				css_put(&mem->css);
+			}
 			mem_cgroup_put(mem);
 		}
 	}
@@ -1252,7 +1255,10 @@ void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
 		struct mem_cgroup *memcg;
 		memcg = swap_cgroup_record(ent, NULL);
 		if (memcg) {
-			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
+			if (css_tryget(&memcg->css)) {
+				res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
+				css_put(&memcg->css);
+			}
 			mem_cgroup_put(memcg);
 		}
 
@@ -1397,7 +1403,10 @@ void mem_cgroup_uncharge_swap(swp_entry_t ent)
 
 	memcg = swap_cgroup_record(ent, NULL);
 	if (memcg) {
-		res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
+		if (css_tryget(&memcg->css)) {
+			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
+			css_put(&memcg->css);
+		}
 		mem_cgroup_put(memcg);
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
