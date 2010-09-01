Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 80B316B0047
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 20:36:57 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o810atqf028435
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 1 Sep 2010 09:36:56 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A9A545DE6F
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 09:36:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4449C45DE4D
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 09:36:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 150641DB803E
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 09:36:55 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C58501DB8037
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 09:36:51 +0900 (JST)
Date: Wed, 1 Sep 2010 09:31:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/5] memcg: generic file stat accounting interface
Message-Id: <20100901093151.8d6cb0e8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100831133329.3c54b214.nishimura@mxp.nes.nec.co.jp>
References: <20100825170435.15f8eb73.kamezawa.hiroyu@jp.fujitsu.com>
	<20100825171140.69c1661a.kamezawa.hiroyu@jp.fujitsu.com>
	<20100831133329.3c54b214.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 31 Aug 2010 13:33:29 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Wed, 25 Aug 2010 17:11:40 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Preparing for adding new status arounf file caches.(dirty, writeback,etc..)
> > Using a unified macro and more generic names.
> > All counters will have the same rule for updating.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> one nitpick.
> 
> > @@ -2042,17 +2031,20 @@ static void __mem_cgroup_commit_charge(s
> >  static void __mem_cgroup_move_account(struct page_cgroup *pc,
> >  	struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
> >  {
> > +	int i;
> >  	VM_BUG_ON(from == to);
> >  	VM_BUG_ON(PageLRU(pc->page));
> >  	VM_BUG_ON(!PageCgroupLocked(pc));
> >  	VM_BUG_ON(!PageCgroupUsed(pc));
> >  	VM_BUG_ON(id_to_memcg(pc->mem_cgroup, true) != from);
> >  
> > -	if (PageCgroupFileMapped(pc)) {
> > +	for (i = MEM_CGROUP_FSTAT_BASE; i < MEM_CGROUP_FSTAT_END; ++i) {
> > +		if (!test_bit(fflag_idx(MEMCG_FSTAT_IDX(i)), &pc->flags))
> > +			continue;
> >  		/* Update mapped_file data for mem_cgroup */
> It might be better to update this comment too.
> 
> 	/* Update file-stat data for mem_cgroup */
> 
> or something ?
> 
Nice catch. I'll fix this.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
