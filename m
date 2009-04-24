Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 42DA96B003D
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 02:24:34 -0400 (EDT)
Date: Fri, 24 Apr 2009 15:21:03 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH] fix swap entries is not reclaimed in proper way
 for mem+swap controller
Message-Id: <20090424152103.a5ee8d13.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090424133306.0d9fb2ce.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090421162121.1a1d15fe.kamezawa.hiroyu@jp.fujitsu.com>
	<20090422143833.2e11e10b.nishimura@mxp.nes.nec.co.jp>
	<20090424133306.0d9fb2ce.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Fri, 24 Apr 2009 13:33:06 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 22 Apr 2009 14:38:33 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> > >  extern void mem_cgroup_uncharge_swap(swp_entry_t ent);
> > > +extern void mem_cgroup_mark_swapcache_stale(struct page *page);
> > > +extern void mem_cgroup_fixup_swapcache(struct page *page);
> > >  #else
> > >  static inline void mem_cgroup_uncharge_swap(swp_entry_t ent)
> > >  {
> > >  }
> > > +static void mem_cgroup_check_mark_swapcache_stale(struct page *page)
> > > +{
> > > +}
> > > +static void mem_cgroup_fixup_swapcache(struct page *page)
> > > +{
> > > +}
> > >  #endif
> > >  
> > I think they should be defined in MEM_RES_CTLR case.
> > Exhausting swap entries problem is not depend on MEM_RES_CTLR_SWAP.
> > 
> Could you explain this more ? I can't understand.
> 
STALE(!PageCgroupUsed) SwapCache *without owner process* can be created by
the race between exit()..free_swap_and_cache() and read_swap_cache_async()(type-1)
or between exit()..page_remove_rmap() and shrink_page_list()(type-2).
(I don't think STALE SwapCache itself is problematic as long as there is
an actual user of the SwapCache.)

Those NOUSER STALE SwapCache are NOT depend on MEM_RES_CTLR_SWAP.

If total_swap_size is small enough not to trigger global LRU scan,
all swap space can be used up.
I confirmed before that all swap space were used up(and caused oom)
with mem.limit=32M/total_swap_size=50M.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
