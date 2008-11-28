Date: Fri, 28 Nov 2008 23:09:23 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [RFC][PATCH -mmotm 2/2] avoid oom
Message-Id: <20081128230923.c492bad6.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20081128195953.0f69d9ea.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081128180252.b7a73c86.nishimura@mxp.nes.nec.co.jp>
	<20081128180937.5d7b16c5.nishimura@mxp.nes.nec.co.jp>
	<20081128195953.0f69d9ea.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, d-nishimura@mtf.biglobe.ne.jp, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 28 Nov 2008 19:59:53 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Fri, 28 Nov 2008 18:09:37 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > In previous implementation, mem_cgroup_try_charge checked the return
> > value of mem_cgroup_try_to_free_pages, and just retried if some pages
> > had been reclaimed.
> > But now, try_charge(and mem_cgroup_hierarchical_reclaim called from it)
> > only checks whether the usage is less than the limit.
> > I see oom easily in some tests which didn't cause oom before.
> > 
> > This patch tries to change the behavior as before.
> > 
> > I've tested this patch with only one (except root) mem cgroup directory,
> > and a mem cgroup directory(use_hierarchy=1) which has 4 children with running
> > test programs on itself and each children's directories.
> > 
> > Of course, even after this patch is applied, oom happens if trying to use
> > too much memory.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> > 
> >  mm/memcontrol.c |   19 ++++++++++++-------
> >  1 files changed, 12 insertions(+), 7 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index e7806fc..ab134b7 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -592,6 +592,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> >  {
> >  	struct mem_cgroup *next_mem;
> >  	int ret = 0;
> > +	int child = 0;
> >  
> >  	/*
> >  	 * Reclaim unconditionally and don't check for return value.
> > @@ -600,9 +601,9 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> >  	 * but there might be left over accounting, even after children
> >  	 * have left.
> >  	 */
> > -	ret = try_to_free_mem_cgroup_pages(root_mem, gfp_mask, noswap);
> > +	ret += try_to_free_mem_cgroup_pages(root_mem, gfp_mask, noswap);
> >  	if (mem_cgroup_check_under_limit(root_mem))
> > -		return 0;
> > +		return 1;	/* indicate success of reclaim */
> >  
> >  	next_mem = mem_cgroup_get_first_node(root_mem);
> >  
> > @@ -614,14 +615,17 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> >  			cgroup_unlock();
> >  			continue;
> >  		}
> > -		ret = try_to_free_mem_cgroup_pages(next_mem, gfp_mask, noswap);
> > +		child++;
> > +		ret += try_to_free_mem_cgroup_pages(next_mem, gfp_mask, noswap);
> >  		if (mem_cgroup_check_under_limit(root_mem))
> > -			return 0;
> > +			return 1;	/* indicate success of reclaim */
> >  		cgroup_lock();
> >  		next_mem = mem_cgroup_get_next_node(next_mem, root_mem);
> >  		cgroup_unlock();
> >  	}
> > -	return ret;
> > +
> > +	/* reclaimed at least one page on average from root and each child */
> > +	return ret > child;
> >  }
> >  
> I can't understand why this heuristic...
> 
> just (ret != 0) is ?
> 
I also thought the same thing first.

I'm worrying about the case there are many and many children.
IMHO, this function rarely fails in such cases(just because there
are many candidates to reclaim from. Ah.. I should check at least
each memcgroup has charges), so I thought it would be better
to take account of the number of children, to prevent a long software
stuck at infinite loop at __mem_cgroup_try_charge.

Actually, I tested "return ret" version in my test (4 children) too,
and I didn't see a big difference(it seemed that in "return ret" version
it took a bit long time to cause oom, but I've not confirmed it in detail).

I must consider more.


Thanks,
Daisuke Nishimura.

> Thanks,
> -Kame
> 
> 
> 
> >  /*
> > @@ -684,8 +688,9 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> >  		if (!(gfp_mask & __GFP_WAIT))
> >  			goto nomem;
> >  
> > -		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, gfp_mask,
> > -							noswap);
> > +		if (mem_cgroup_hierarchical_reclaim(mem_over_limit, gfp_mask,
> > +							noswap))
> > +			continue;
> >  
> >  		/*
> >  		 * try_to_free_mem_cgroup_pages() might not give us a full
> > 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
