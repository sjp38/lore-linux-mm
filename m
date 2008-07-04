Date: Fri, 4 Jul 2008 19:40:59 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mm 4/5] swapcgroup (v3): modify vm_swap_full()
Message-Id: <20080704194059.efa7d0ed.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080704185845.0baaca76.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080704151536.e5384231.nishimura@mxp.nes.nec.co.jp>
	<20080704152244.7fc2ccd1.nishimura@mxp.nes.nec.co.jp>
	<20080704185845.0baaca76.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Hugh Dickins <hugh@veritas.com>, IKEDA Munehiro <m-ikeda@ds.jp.nec.com>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Hi, Kamezawa-san.

On Fri, 4 Jul 2008 18:58:45 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 4 Jul 2008 15:22:44 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> >  /* Swap 50% full? Release swapcache more aggressively.. */
> > -#define vm_swap_full() (nr_swap_pages*2 < total_swap_pages)
> > +#define vm_swap_full(memcg) ((nr_swap_pages*2 < total_swap_pages) \
> > +				|| swap_cgroup_vm_swap_full(memcg))
> > +
> >  
> Maybe nitpick but I like 
> ==
>   vm_swap_full(page)	((nr_swap_pages *2 < total_swap_pages)
> 				|| swap_cgroup_vm_swap_full_page(page))
> ==
> rather than vm_swap_full(memcg)
> 
Well, I used "page" in v2, but Kosaki-san said vm_swap_full()
is not page-granularity operation so it should be changed.
 
And more,

> > @@ -1317,7 +1317,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
> >  			__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
> >  			pgmoved = 0;
> >  			spin_unlock_irq(&zone->lru_lock);
> > -			if (vm_swap_full())
> > +			if (vm_swap_full(sc->mem_cgroup))
> >  				pagevec_swap_free(&pvec);
> >  			__pagevec_release(&pvec);
> >  			spin_lock_irq(&zone->lru_lock);
> > @@ -1328,7 +1328,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
> >  	__count_zone_vm_events(PGREFILL, zone, pgscanned);
> >  	__count_vm_events(PGDEACTIVATE, pgdeactivate);
> >  	spin_unlock_irq(&zone->lru_lock);
> > -	if (vm_swap_full())
> > +	if (vm_swap_full(sc->mem_cgroup))
> >  		pagevec_swap_free(&pvec);
> >  
> >  	pagevec_release(&pvec);

"page" cannot be determined in those places.
I don't want to change pagevec_swap_free(), so I changed
the argument of vm_swap_full().

> And could you change this to inline funcition ?
> 
Of course.
I think it would be better.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
