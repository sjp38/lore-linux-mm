Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C44D96B0044
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 00:40:07 -0500 (EST)
Date: Fri, 9 Jan 2009 14:33:46 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 2/4] memcg: fix error path of
 mem_cgroup_move_parent
Message-Id: <20090109143346.5ad2b971.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090109051522.GC9737@balbir.in.ibm.com>
References: <20090108190818.b663ce20.nishimura@mxp.nes.nec.co.jp>
	<20090108191445.cd860c37.nishimura@mxp.nes.nec.co.jp>
	<20090109051522.GC9737@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: nishimura@mxp.nes.nec.co.jp, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizf@cn.fujitsu.com, menage@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 9 Jan 2009 10:45:22 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> * Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> [2009-01-08 19:14:45]:
> 
> > There is a bug in error path of mem_cgroup_move_parent.
> > 
> > Extra refcnt got from try_charge should be dropped, and usages incremented
> > by try_charge should be decremented in both error paths:
> > 
> >     A: failure at get_page_unless_zero
> >     B: failure at isolate_lru_page
> > 
> > This bug makes this parent directory unremovable.
> > 
> > In case of A, rmdir doesn't return, because res.usage doesn't go
> > down to 0 at mem_cgroup_force_empty even after all the pc in
> > lru are removed.
> > In case of B, rmdir fails and returns -EBUSY, because it has
> > extra ref counts even after res.usage goes down to 0.
> > 
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> >  mm/memcontrol.c |   23 +++++++++++++++--------
> >  1 files changed, 15 insertions(+), 8 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 62e69d8..288e22c 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -983,14 +983,15 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
> >  	if (pc->mem_cgroup != from)
> >  		goto out;
> > 
> > -	css_put(&from->css);
> >  	res_counter_uncharge(&from->res, PAGE_SIZE);
> >  	mem_cgroup_charge_statistics(from, pc, false);
> >  	if (do_swap_account)
> >  		res_counter_uncharge(&from->memsw, PAGE_SIZE);
> > +	css_put(&from->css);
> > +
> > +	css_get(&to->css);
> >  	pc->mem_cgroup = to;
> >  	mem_cgroup_charge_statistics(to, pc, true);
> > -	css_get(&to->css);
> >  	ret = 0;
> >  out:
> >  	unlock_page_cgroup(pc);
> > @@ -1023,8 +1024,10 @@ static int mem_cgroup_move_parent(struct page_cgroup *pc,
> >  	if (ret || !parent)
> >  		return ret;
> > 
> > -	if (!get_page_unless_zero(page))
> > -		return -EBUSY;
> > +	if (!get_page_unless_zero(page)) {
> > +		ret = -EBUSY;
> > +		goto uncharge;
> > +	}
> > 
> >  	ret = isolate_lru_page(page);
> > 
> > @@ -1033,19 +1036,23 @@ static int mem_cgroup_move_parent(struct page_cgroup *pc,
> > 
> >  	ret = mem_cgroup_move_account(pc, child, parent);
> > 
> > -	/* drop extra refcnt by try_charge() (move_account increment one) */
> > -	css_put(&parent->css);
> >  	putback_lru_page(page);
> >  	if (!ret) {
> >  		put_page(page);
> > +		/* drop extra refcnt by try_charge() */
> > +		css_put(&parent->css);
> >  		return 0;
> >  	}
> > -	/* uncharge if move fails */
> > +
> >  cancel:
> > +	put_page(page);
> > +uncharge:
> > +	/* drop extra refcnt by try_charge() */
> > +	css_put(&parent->css);
> > +	/* uncharge if move fails */
> >  	res_counter_uncharge(&parent->res, PAGE_SIZE);
> >  	if (do_swap_account)
> >  		res_counter_uncharge(&parent->memsw, PAGE_SIZE);
> > -	put_page(page);
> >  	return ret;
> >  }
> > 
> >
> 
> Looks good to me, just out of curiousity how did you catch this error?
> Through review or testing? 
> 
Through testing.

I got "an unremovable directory" sometimes, which had res.usage remained
even after all lru lists had become empty, or which had ref counts remained
even after res.usage had become 0.
And tracked down the cause of this problem .


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
