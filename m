Date: Thu, 2 Oct 2008 14:13:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/6] memcg: new force_empty and move_account
Message-Id: <20081002141313.0882baba.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081001093804.b392e418.randy.dunlap@oracle.com>
References: <20081001165233.404c8b9c.kamezawa.hiroyu@jp.fujitsu.com>
	<20081001165912.236af3e7.kamezawa.hiroyu@jp.fujitsu.com>
	<20081001093804.b392e418.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Thank yoy for review!

On Wed, 1 Oct 2008 09:38:04 -0700
Randy Dunlap <randy.dunlap@oracle.com> wrote:

> On Wed, 1 Oct 2008 16:59:12 +0900 KAMEZAWA Hiroyuki wrote:
> 
> >  Documentation/controllers/memory.txt |   10 -
> >  mm/memcontrol.c                      |  267 +++++++++++++++++++++++++++--------
> >  2 files changed, 216 insertions(+), 61 deletions(-)
> > 
> > Index: mmotm-2.6.27-rc7+/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-2.6.27-rc7+.orig/mm/memcontrol.c
> > +++ mmotm-2.6.27-rc7+/mm/memcontrol.c
> > @@ -538,6 +533,24 @@ nomem:
> >  	return -ENOMEM;
> >  }
> >  
> > +/**
> > + * mem_cgroup_try_charge - get charge of PAGE_SIZE.
> > + * @mm: an mm_struct which is charged against. (when *memcg is NULL)
> > + * @gfp_mask: gfp_mask for reclaim.
> > + * @memcg: a pointer to memory cgroup which is charged against.
> > + *
> > + * charge aginst memory cgroup pointed by *memcg. if *memcg == NULL, estimated
> > + * memory cgroup from @mm is got and stored in *memcg.
> > + *
> > + * Retruns 0 if success. -ENOMEM at failure.
> > + */
> > +
> > +int mem_cgroup_try_charge(struct mm_struct *mm,
> > +			  gfp_t mask, struct mem_cgroup **memcg)
> > +{
> > +	return __mem_cgroup_try_charge(mm, mask, memcg, false);
> > +}
> > +
> >  /*
> >   * commit a charge got by mem_cgroup_try_charge() and makes page_cgroup to be
> >   * USED state. If already USED, uncharge and return.
> > @@ -567,11 +580,109 @@ static void __mem_cgroup_commit_charge(s
> >  	mz = page_cgroup_zoneinfo(pc);
> >  
> >  	spin_lock_irqsave(&mz->lru_lock, flags);
> > -	__mem_cgroup_add_list(mz, pc);
> > +	__mem_cgroup_add_list(mz, pc, true);
> >  	spin_unlock_irqrestore(&mz->lru_lock, flags);
> >  	unlock_page_cgroup(pc);
> >  }
> >  
> > +/**
> > + * mem_cgroup_move_account - move account of the page
> > + * @pc   ... page_cgroup of the page.
> > + * @from ... mem_cgroup which the page is moved from.
> > + * @to   ... mem_cgroup which the page is moved to. @from != @to.
> 
> Bad kernel-doc format.  Use (e.g.)
>  * @pc: page_cgroup of the page
> 
Hmm, sorry.

> as was done in the function above.
> 
> > + *
> > + * The caller must confirm following.
> > + * 1. disable irq.
> > + * 2. lru_lock of old mem_cgroup(@from) should be held.
> > + *
> > + * returns 0 at success,
> > + * returns -EBUSY when lock is busy or "pc" is unstable.
> > + *
> > + * This function do "uncharge" from old cgroup but doesn't do "charge" to
> 
>                     does
> 
will fix.

> > + * new cgroup. It should be done by a caller.
> > + */
> > +
> > +static int mem_cgroup_move_account(struct page_cgroup *pc,
> > +	struct mem_cgroup *from, struct mem_cgroup *to)
> > +{
> ...
> > +}
> > +
> > Index: mmotm-2.6.27-rc7+/Documentation/controllers/memory.txt
> > ===================================================================
> > --- mmotm-2.6.27-rc7+.orig/Documentation/controllers/memory.txt
> > +++ mmotm-2.6.27-rc7+/Documentation/controllers/memory.txt
> > @@ -211,7 +211,9 @@ The memory.force_empty gives an interfac
> >  
> >  # echo 1 > memory.force_empty
> >  
> > -will drop all charges in cgroup. Currently, this is maintained for test.
> > +Will move account to parent. if parenet is full, will try to free pages.
> 
>                                 If parent
> 
Ah, sorry.

> > +If both of a parent and a child are busy, return -EBUSY;
> 
> maybe:
>    If both parent and child are busy, return -EBUSY.
> 
will fix.


> > +This file, memory.force_empty, is just for debug purpose.
> >  
> >  4. Testing
> >  
> > @@ -242,8 +244,10 @@ reclaimed.
> >  
> >  A cgroup can be removed by rmdir, but as discussed in sections 4.1 and 4.2, a
> >  cgroup might have some charge associated with it, even though all
> > -tasks have migrated away from it. Such charges are automatically dropped at
> > -rmdir() if there are no tasks.
> > +tasks have migrated away from it.
> > +Such charges are moved to its parent as mush as possible and freed if parent
> 
>                                            much
> 
will fix

> > +seems to be full. (see force_empty)
> 
> seems??  Is it questionable/unsure?
> 

It's unstable state. If someone frees some page, it's not full.
But "seems" is not good, I'll remove "seems".

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
