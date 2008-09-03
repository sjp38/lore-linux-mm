Date: Wed, 3 Sep 2008 16:05:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 14/14]memcg: mem+swap accounting
Message-Id: <20080903160518.10ff3879.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080903152314.95bc4dac.nishimura@mxp.nes.nec.co.jp>
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
	<20080822204455.922f87dc.kamezawa.hiroyu@jp.fujitsu.com>
	<20080901161501.2cba948e.nishimura@mxp.nes.nec.co.jp>
	<20080901165827.e21f9104.kamezawa.hiroyu@jp.fujitsu.com>
	<20080901175302.737bca2e.nishimura@mxp.nes.nec.co.jp>
	<20080901185347.cfbc1817.kamezawa.hiroyu@jp.fujitsu.com>
	<20080902200905.cb18cce0.nishimura@mxp.nes.nec.co.jp>
	<20080902204053.d3635bc8.kamezawa.hiroyu@jp.fujitsu.com>
	<20080903152314.95bc4dac.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Sep 2008 15:23:14 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Tue, 2 Sep 2008 20:40:53 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > maybe like this.
> > swap_cgroup_set_account()
> >    -> mem_cgroup_uncharge()
> >         -> the page is mapped ..no uncharge here.
> >               -> then, res.page, res.swaps is not changed.
> >                  -> we should mark swap account as false.
> > 
> > Anyway, thank you! I'll consider this again.
> > 
> I add some debug code to show why the uncharge fails there.
> 
> It showed that the cause of uncharge failure at swapoff was that
> it tried to free a mapped page, as you said.
> 
> I think this can happen in the sequence below:
> 
>   try_to_unuse()
>     unuse_mm()
>       ...
>       unuse_pte()
>         mem_cgroup_charge()
>           swap_cgroup_delete_account()
>             - swap_cgroup->count is turned off.
>         page_add_anon_rmap()
>           - map page.
>     ...
>     delete_from_swap_cache()
>       swap_cgroup_delete_swapcache()
>         - turns swap_cgroup->count on again.
>         - tries to uncharge a mapped page.
> 
> And I think deleting a swapcache of a mapped page can also happen
> in other sequences(e.g. do_swap_page()->remove_exclusive_swap_cache()).
> 
> OTOH, as for shmem/tmpfs, swap_cgroup_delete_swapcache() tries to
> uncharge a page which is on radix tree(that's why I saw over-uncharging),
> because shmem_getpage() calls add_to_page_cache() before
> delete_from_swap_cache().
> 
> 
> So, I think current implementation should be changed anyway.
> 
Thank you for your investigation. I'll refine logic.

I think I have to tune lockless** series first. It's almost done.
mem+swap patch is also maintained but my usual 8cpu host is
still under maintaince. (and the newest mmtom doesn't work on 2cpu my machine.)
So, please be patient for a while if no updates from me.

Of course, if you have your own, please post. I think kmap_atomic()
logic in my patch is also benefial to your original version.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
