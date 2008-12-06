Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id mB68KBiN018138
	for <linux-mm@kvack.org>; Sat, 6 Dec 2008 19:20:11 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB68JBbg051626
	for <linux-mm@kvack.org>; Sat, 6 Dec 2008 19:19:12 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mB68JBVm009844
	for <linux-mm@kvack.org>; Sat, 6 Dec 2008 19:19:11 +1100
Date: Sat, 6 Dec 2008 13:48:59 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH -mmotm 1/4] memcg: don't trigger oom at page
	migration
Message-ID: <20081206081859.GC7582@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20081205212208.31d904e0.nishimura@mxp.nes.nec.co.jp> <20081205212304.f7018ea1.nishimura@mxp.nes.nec.co.jp> <20081205133925.GA10004@balbir.in.ibm.com> <20081206114757.c323c63b.d-nishimura@mtf.biglobe.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20081206114757.c323c63b.d-nishimura@mtf.biglobe.ne.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nishimura@mxp.nes.nec.co.jp
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, d-nishimura@mtf.biglobe.ne.jp
List-ID: <linux-mm.kvack.org>

* Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> [2008-12-06 11:47:57]:

> On Fri, 5 Dec 2008 19:09:26 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> [2008-12-05 21:23:04]:
> > 
> > > I think triggering OOM at mem_cgroup_prepare_migration would be just a bit
> > > overkill.
> > > Returning -ENOMEM would be enough for mem_cgroup_prepare_migration.
> > > The caller would handle the case anyway.
> > > 
> > > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > > ---
> > >  mm/memcontrol.c |    2 +-
> > >  1 files changed, 1 insertions(+), 1 deletions(-)
> > > 
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index 4dbce1d..50ee1be 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -1330,7 +1330,7 @@ int mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr)
> > >  	unlock_page_cgroup(pc);
> > > 
> > >  	if (mem) {
> > > -		ret = mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem);
> > > +		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false);
> > >  		css_put(&mem->css);
> > >  	}
> > >  	*ptr = mem;
> > >
> > 
> > Seems reasonable to me. A comment indicating or adding a noreclaim
> > wrapper around __mem_cgroup_try_charge to indicate that no reclaim
> > will take place will be nice.
> > 
> Ah.. this flag to __mem_cgroup_try_charge doesn't mean "don't reclaim"
> but "don't cause oom after it tried to free memory but couldn't
> free enough memory after all".

Thanks, I mistook the parameter. Thanks for clarifying!

> 
> Thanks,
> Daisuke Nishimura.
> 
> > Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com> 
> > 
> > -- 
> > 	Balbir
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 
> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
