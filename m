Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D02506B0044
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 04:13:42 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0G9Dea2004710
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 16 Jan 2009 18:13:40 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C502345DD75
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 18:13:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9849A45DD74
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 18:13:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 747151DB803E
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 18:13:39 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 220181DB8042
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 18:13:39 +0900 (JST)
Date: Fri, 16 Jan 2009 18:12:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUG] memcg: panic when rmdir()
Message-Id: <20090116181235.320d372b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090116172651.3e11fb0c.nishimura@mxp.nes.nec.co.jp>
References: <497025E8.8050207@cn.fujitsu.com>
	<20090116170724.d2ad8344.kamezawa.hiroyu@jp.fujitsu.com>
	<20090116172651.3e11fb0c.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Fri, 16 Jan 2009 17:26:51 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Fri, 16 Jan 2009 17:07:24 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Now, at swapoff, even while try_charge() fails, commit is executed.
> > This is bug and make refcnt of cgroup_subsys_state minus, finally.
> > 
> Nice catch!
> 
> I think this bug can explain this problem I've seen.
> Commiting on trycharge failure will add the pc to the lru
> without a corresponding charge and refcnt.
> And rmdir uncharges the pc(so we get WARNING: at kernel/res_counter.c:71)
> and decrements the refcnt(so we get BUG at kernel/cgroup.c:2517).
> 
> Even if the problem cannot be fixed by this patch, this patch is valid and needed.
> 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> I'll test it.
> 
> 
I finally get how-to-reprocuce and confirmed this fixes the problem.

How-to-reproduce.

In shell-A
  #mount -t cgroup none /opt/cgroup
  #mkdir /opt/cgroup/xxx/
  #echo 0 > /opt/cgroup/xxx/tasks
  #Run malloc 100M on this and sleep. ---(*)

In shell-B.
  #echo 40M > /opt/cgroup/xxx/memory.limit_in_bytes.
  Then, you'll see 60M of swap.
  #/sbin/swapoff -a 
  Then, you'll see OOM-Kill against (*)
  #echo shell-A > /opt/cgroup/tasks
  make /opt/cgroup/xxx/ empty
  #rmdir /opt/cgroup/xxx

=> panics.

I'll add this swap-off test to memcg-debug.txt later.

BTW, OOM against (*) itself seems also probelmatic.
But simply disable oom-at-swapoff cannot be a workaround...


-Kame

















> Thanks,
> Daisuke Nishimura.
> 
> > ---
> > Index: mmotm-2.6.29-Jan14/mm/swapfile.c
> > ===================================================================
> > --- mmotm-2.6.29-Jan14.orig/mm/swapfile.c
> > +++ mmotm-2.6.29-Jan14/mm/swapfile.c
> > @@ -698,8 +698,10 @@ static int unuse_pte(struct vm_area_stru
> >  	pte_t *pte;
> >  	int ret = 1;
> >  
> > -	if (mem_cgroup_try_charge_swapin(vma->vm_mm, page, GFP_KERNEL, &ptr))
> > +	if (mem_cgroup_try_charge_swapin(vma->vm_mm, page, GFP_KERNEL, &ptr)) {
> >  		ret = -ENOMEM;
> > +		goto out_nolock;
> > +	}
> >  
> >  	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> >  	if (unlikely(!pte_same(*pte, swp_entry_to_pte(entry)))) {
> > @@ -723,6 +725,7 @@ static int unuse_pte(struct vm_area_stru
> >  	activate_page(page);
> >  out:
> >  	pte_unmap_unlock(pte, ptl);
> > +out_nolock:
> >  	return ret;
> >  }
> >  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
