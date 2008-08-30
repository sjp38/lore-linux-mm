Date: Sat, 30 Aug 2008 16:30:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/14] memcg: rewrite force_empty
Message-Id: <20080830163005.416bb559.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080829204549.5150f351.nishimura@mxp.nes.nec.co.jp>
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
	<20080822203114.bf6f08e4.kamezawa.hiroyu@jp.fujitsu.com>
	<20080829204549.5150f351.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 29 Aug 2008 20:45:49 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> >  /*
> > - * This routine traverse page_cgroup in given list and drop them all.
> > - * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
> > + * This routine moves all account to root cgroup.
> >   */
> > -#define FORCE_UNCHARGE_BATCH	(128)
> >  static void mem_cgroup_force_empty_list(struct mem_cgroup *mem,
> >  			    struct mem_cgroup_per_zone *mz,
> >  			    enum lru_list lru)
> >  {
> >  	struct page_cgroup *pc;
> >  	struct page *page;
> > -	int count = FORCE_UNCHARGE_BATCH;
> >  	unsigned long flags;
> >  	struct list_head *list;
> >  
> > @@ -853,22 +892,28 @@ static void mem_cgroup_force_empty_list(
> >  		pc = list_entry(list->prev, struct page_cgroup, lru);
> >  		page = pc->page;
> >  		get_page(page);
> > -		spin_unlock_irqrestore(&mz->lru_lock, flags);
> > -		/*
> > -		 * Check if this page is on LRU. !LRU page can be found
> > -		 * if it's under page migration.
> > -		 */
> > -		if (PageLRU(page)) {
> > -			__mem_cgroup_uncharge_common(page,
> > -					MEM_CGROUP_CHARGE_TYPE_FORCE);
> > +		if (!trylock_page(page)) {
> > +			list_move(&pc->lru, list);
> > +			put_page(page):
>                                      ^^^
>                                     s/:/;
> 
> Just to make sure :)
> 
Oh, thanks.

-Kame


> 
> Thanks,
> Daisuke Nishimura.
> 
> 
> > +			spin_unlock_irqrestore(&mz->lru_lock, flags);
> > +			yield();
> > +			spin_lock_irqsave(&mz->lru_lock, flags);
> > +			continue;
> > +		}
> > +		if (mem_cgroup_move_account(page, pc, mem, &init_mem_cgroup)) {
> > +			/* some confliction */
> > +			list_move(&pc->lru, list);
> > +			unlock_page(page);
> >  			put_page(page);
> > -			if (--count <= 0) {
> > -				count = FORCE_UNCHARGE_BATCH;
> > -				cond_resched();
> > -			}
> > -		} else
> > -			cond_resched();
> > -		spin_lock_irqsave(&mz->lru_lock, flags);
> > +			spin_unlock_irqrestore(&mz->lru_lock, flags);
> > +			yield();
> > +			spin_lock_irqsave(&mz->lru_lock, flags);
> > +		} else {
> > +			unlock_page(page);
> > +			put_page(page);
> > +		}
> > +		if (atomic_read(&mem->css.cgroup->count) > 0)
> > +			break;
> >  	}
> >  	spin_unlock_irqrestore(&mz->lru_lock, flags);
> >  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
