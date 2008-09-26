Date: Fri, 26 Sep 2008 11:05:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 9/12] memcg allocate all page_cgroup at boot
Message-Id: <20080926110550.2292287b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080926104336.d96ab5bd.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
	<20080925153206.281243dc.kamezawa.hiroyu@jp.fujitsu.com>
	<20080926100022.8bfb8d4d.nishimura@mxp.nes.nec.co.jp>
	<20080926104336.d96ab5bd.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Fri, 26 Sep 2008 10:43:36 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > -	/*
> > > -	 * Check if our page_cgroup is valid
> > > -	 */
> > > -	lock_page_cgroup(page);
> > > -	pc = page_get_page_cgroup(page);
> > > -	if (unlikely(!pc))
> > > -		goto unlock;
> > > -
> > > -	VM_BUG_ON(pc->page != page);
> > > +	pc = lookup_page_cgroup(page);
> > > +	if (unlikely(!pc || !PageCgroupUsed(pc)))
> > > +		return;
> > > +	preempt_disable();
> > > +	lock_page_cgroup(pc);
> > > +	if (unlikely(page_mapped(page))) {
> > > +		unlock_page_cgroup(pc);
> > > +		preempt_enable();
> > > +		return;
> > > +	}
> > Just for clarification, in what sequence will the page be mapped here?
> > mem_cgroup_uncharge_page checks whether the page is mapped.
> > 
> Please think about folloing situation.
> 
>    There is a SwapCache which is referred from 2 process, A, B.
>    A maps it.
>    B doesn't maps it.
> 
>    And now, process A exits.
> 
> 	CPU0(process A)				CPU1 (process B)
>  
>     zap_pte_range()
>     => page remove from rmap			=> charge() (do_swap_page)
> 	=> set page->mapcount->0          	
> 		=> uncharge()			=> set page->mapcount=1
> 
> This race is what patch 12/12 is fixed.
> This only happens on cursed SwapCache.
> 
Sorry, my brain seems to be sleeping.. above page_mapped() check doesn't
help this situation. Maybe this page_mapped() check is not necessary
because it's of no use.

I think this kind of problem will not be fixed until we handle SwapCache.


Thanks,
-Kame












--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
