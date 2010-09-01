Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7A4546B0078
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 20:36:16 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o810aEn7011911
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 1 Sep 2010 09:36:14 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 04F9545DE5B
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 09:36:14 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C0FC045DE4E
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 09:36:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 72BE71DB8048
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 09:36:13 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B9E2E38004
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 09:36:12 +0900 (JST)
Date: Wed, 1 Sep 2010 09:31:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/5] memcg: lockless update of file stat with
 move-account safe method
Message-Id: <20100901093114.0bdef189.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100831125118.fa01f0c2.nishimura@mxp.nes.nec.co.jp>
References: <20100825170435.15f8eb73.kamezawa.hiroyu@jp.fujitsu.com>
	<20100825171050.1574ba7c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100831125118.fa01f0c2.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 31 Aug 2010 12:51:18 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Wed, 25 Aug 2010 17:10:50 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > At accounting file events per memory cgroup, we need to find memory cgroup
> > via page_cgroup->mem_cgroup. Now, we use lock_page_cgroup().
> > 
> > But, considering the context which page-cgroup for files are accessed,
> > we can use alternative light-weight mutual execusion in the most case.
> > At handling file-caches, the only race we have to take care of is "moving"
> > account, IOW, overwriting page_cgroup->mem_cgroup. Because file status
> > update is done while the page-cache is in stable state, we don't have to
> > take care of race with charge/uncharge.
> > 
> > Unlike charge/uncharge, "move" happens not so frequently. It happens only when
> > rmdir() and task-moving (with a special settings.)
> > This patch adds a race-checker for file-cache-status accounting v.s. account
> > moving. The new per-cpu-per-memcg counter MEM_CGROUP_ON_MOVE is added.
> > The routine for account move 
> >   1. Increment it before start moving
> >   2. Call synchronize_rcu()
> >   3. Decrement it after the end of moving.
> > By this, file-status-counting routine can check it needs to call
> > lock_page_cgroup(). In most case, I doesn't need to call it.
> > 
> > Changelog: 20100825
> >  - added a comment about mc.lock
> >  - fixed bad lock.
> > Changelog: 20100804
> >  - added a comment for possible optimization hint.
> > Changelog: 20100730
> >  - some cleanup.
> > Changelog: 20100729
> >  - replaced __this_cpu_xxx() with this_cpu_xxx
> >    (because we don't call spinlock)
> >  - added VM_BUG_ON().
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> (snip)
> 
> > @@ -1505,29 +1551,36 @@ void mem_cgroup_update_file_mapped(struc
> >  {
> >  	struct mem_cgroup *mem;
> >  	struct page_cgroup *pc;
> > +	bool need_lock = false;
> >  
> >  	pc = lookup_page_cgroup(page);
> >  	if (unlikely(!pc))
> >  		return;
> > -
> > -	lock_page_cgroup(pc);
> > +	rcu_read_lock();
> >  	mem = id_to_memcg(pc->mem_cgroup, true);
> It doesn't cause any problem, but I think it would be better to change this to
> "id_to_memcg(..., false)". It's just under rcu_read_lock(), not under page_cgroup
> lock anymore.
> 
ok, I'll apply your suggestion.

> Otherwise, it looks good to me.
> 
> Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 

Thanks!
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
