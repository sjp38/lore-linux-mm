Date: Wed, 3 Sep 2008 15:23:14 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 14/14]memcg: mem+swap accounting
Message-Id: <20080903152314.95bc4dac.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080902204053.d3635bc8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
	<20080822204455.922f87dc.kamezawa.hiroyu@jp.fujitsu.com>
	<20080901161501.2cba948e.nishimura@mxp.nes.nec.co.jp>
	<20080901165827.e21f9104.kamezawa.hiroyu@jp.fujitsu.com>
	<20080901175302.737bca2e.nishimura@mxp.nes.nec.co.jp>
	<20080901185347.cfbc1817.kamezawa.hiroyu@jp.fujitsu.com>
	<20080902200905.cb18cce0.nishimura@mxp.nes.nec.co.jp>
	<20080902204053.d3635bc8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2 Sep 2008 20:40:53 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 2 Sep 2008 20:09:05 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Mon, 1 Sep 2008 18:53:47 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > On Mon, 1 Sep 2008 17:53:02 +0900
> > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > 
> > > > On Mon, 1 Sep 2008 16:58:27 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > > On Mon, 1 Sep 2008 16:15:01 +0900
> > > > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > > > 
> > > > > > Hi, Kamezawa-san.
> > > > > > 
> > > > > > I'm testing these patches on mmotm-2008-08-29-01-08
> > > > > > (with some trivial fixes I've reported and some debug codes),
> > > > This problem happens on the kernel without debug codes I added.
> > > > 
> > > > > > but swap_in_bytes sometimes becomes very huge(it seems that
> > > > > > over uncharge is happening..) and I can see OOM
> > > > > > if I've set memswap_limit.
> > > > > > 
> > > > > > I'm digging this now, but have you also ever seen it?
> > > > > > 
> > > > > I didn't see that.
> > > > I see, thanks.
> > > > 
> > > > > But, as you say, maybe over-uncharge. Hmm..
> > > > > What kind of test ? Just use swap ? and did you use shmem or tmpfs ?
> > > > > 
> > > > I don't do anything special, and this can happen without shmem/tmpfs
> > > > (can happen with shmem/tmpfs, too).
> > > > 
> > > > For example:
> > > > 
> > > > - make swap out/in activity for a while(I used page01 of ltp).
> > > > - stop the test.
> > > > 
> > > > [root@localhost ~]# cat /cgroup/memory/01/memory.swap_in_bytes
> > > > 4096
> > > > 
> > > > - swapoff
> > > > 
> > > > [root@localhost ~]# swapoff -a
> > > > [root@localhost ~]# cat /cgroup/memory/01/memory.swap_in_bytes
> > > > 18446744073709395968
> > > > 
> > > > 
> > > Hmm ? can happen without swapoff ?
> > > It seems "accounted" flag is on by mistake.
> > > 
> > I found the cause of this problem.
> > 
> > If __mem_cgroup_uncharge_common() in __swap_cgroup_delete_swapcache() fails,
> > res.swaps would not be incremented while the swap_cgroup.count remains on.
> > This causes over-uncharging of res.swaps.
> > 
> > This patch fixes this problem(it works well so far).
> > 
> Oh, thanks. But it seems unexpected situation...hmm
> I think I misunderstand some calling sequence...
> 
> maybe like this.
> swap_cgroup_set_account()
>    -> mem_cgroup_uncharge()
>         -> the page is mapped ..no uncharge here.
>               -> then, res.page, res.swaps is not changed.
>                  -> we should mark swap account as false.
> 
> Anyway, thank you! I'll consider this again.
> 
I add some debug code to show why the uncharge fails there.

It showed that the cause of uncharge failure at swapoff was that
it tried to free a mapped page, as you said.

I think this can happen in the sequence below:

  try_to_unuse()
    unuse_mm()
      ...
      unuse_pte()
        mem_cgroup_charge()
          swap_cgroup_delete_account()
            - swap_cgroup->count is turned off.
        page_add_anon_rmap()
          - map page.
    ...
    delete_from_swap_cache()
      swap_cgroup_delete_swapcache()
        - turns swap_cgroup->count on again.
        - tries to uncharge a mapped page.

And I think deleting a swapcache of a mapped page can also happen
in other sequences(e.g. do_swap_page()->remove_exclusive_swap_cache()).

OTOH, as for shmem/tmpfs, swap_cgroup_delete_swapcache() tries to
uncharge a page which is on radix tree(that's why I saw over-uncharging),
because shmem_getpage() calls add_to_page_cache() before
delete_from_swap_cache().


So, I think current implementation should be changed anyway.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
