Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 737C96B01F0
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 04:27:42 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3N8Rd0J022647
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 23 Apr 2010 17:27:40 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A825045DE51
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 17:27:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 857DC45DE4F
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 17:27:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 704991DB8040
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 17:27:39 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 220B31DB803C
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 17:27:39 +0900 (JST)
Date: Fri, 23 Apr 2010 17:23:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][BUGFIX][PATCH 2/2] memcg: fix file mapped underflow at
 migration (v3)
Message-Id: <20100423172341.802c2213.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100423170846.d18c88bd.nishimura@mxp.nes.nec.co.jp>
References: <20100413134207.f12cdc9c.nishimura@mxp.nes.nec.co.jp>
	<20100415120516.3891ce46.kamezawa.hiroyu@jp.fujitsu.com>
	<20100415120652.c577846f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100416193143.5807d114.kamezawa.hiroyu@jp.fujitsu.com>
	<20100419124225.91f3110b.nishimura@mxp.nes.nec.co.jp>
	<20100419131817.f263d93c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100419170701.3864992e.nishimura@mxp.nes.nec.co.jp>
	<20100419172629.dbf65e18.kamezawa.hiroyu@jp.fujitsu.com>
	<20100420132050.3477a717.nishimura@mxp.nes.nec.co.jp>
	<20100420181925.ed881e7a.kamezawa.hiroyu@jp.fujitsu.com>
	<20100423170846.d18c88bd.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 23 Apr 2010 17:08:46 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> I'm sorry for my late reply.
> 
> On Tue, 20 Apr 2010 18:19:25 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 20 Apr 2010 13:20:50 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > > It will have no meanings for migrating
> > > > file caches, but it may have some meanings for easy debugging. 
> > > > I think "mark it always but it's used only for anonymous page" is reasonable
> > > > (if it causes no bug.)
> > > > 
> > > Anyway, I don't have any strong objection.
> > > It's all right for me as long as it is well documented or commented.
> > > 
> > Okay, before posting as v4, here is draft version.
> > 
> Thank you for adding good comments about what it does and why we need it.
> I like the direction that we set MIGRATION flags only on the old page.
> And this patch looks good to me, except that checkpatch warns some problems
> about indent :)
> 
(--;

I'm sorry that this patch is delayed. I have to fix migration itself
for testing this. I'd like to post this before long holidayes in the next week.

> I have one question.
> 
> >  /* remove redundant charge if migration failed*/
> >  void mem_cgroup_end_migration(struct mem_cgroup *mem,
> > -		struct page *oldpage, struct page *newpage)
> > +	struct page *oldpage, struct page *newpage)
> >  {
> > -	struct page *target, *unused;
> > +	struct page *used, *unused;
> >  	struct page_cgroup *pc;
> > -	enum charge_type ctype;
> >  
> >  	if (!mem)
> >  		return;
> > +	/* blocks rmdir() */
> >  	cgroup_exclude_rmdir(&mem->css);
> >  	/* at migration success, oldpage->mapping is NULL. */
> >  	if (oldpage->mapping) {
> > -		target = oldpage;
> > -		unused = NULL;
> > +		used = oldpage;
> > +		unused = newpage;
> >  	} else {
> > -		target = newpage;
> > +		used = newpage;
> >  		unused = oldpage;
> >  	}
> > -
> > -	if (PageAnon(target))
> > -		ctype = MEM_CGROUP_CHARGE_TYPE_MAPPED;
> > -	else if (page_is_file_cache(target))
> > -		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
> > -	else
> > -		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
> > -
> > -	/* unused page is not on radix-tree now. */
> > -	if (unused)
> > -		__mem_cgroup_uncharge_common(unused, ctype);
> > -
> > -	pc = lookup_page_cgroup(target);
> >  	/*
> > -	 * __mem_cgroup_commit_charge() check PCG_USED bit of page_cgroup.
> > -	 * So, double-counting is effectively avoided.
> > +	 * We disallowed uncharge of pages under migration because mapcount
> > +	 * of the page goes down to zero, temporarly.
> > +	 * Clear the flag and check the page should be charged.
> >  	 */
> > -	__mem_cgroup_commit_charge(mem, pc, ctype);
> > -
> > +	pc = lookup_page_cgroup(unused);
> > +	/* This flag itself is not racy, so, check it before lock */
> > +	if (PageCgroupMigration(pc)) {
> > +		lock_page_cgroup(pc);
> > +		ClearPageCgroupMigration(pc);
> > +		unlock_page_cgroup(pc);
> > +	}
> The reason why "This flag itself is not racy" is that we update the flag only
> while the page is isolated ?
yes and no.
It's not racy because a page is only under a migration thread, not under a few of
migration threads. And only the migration thread mark this MIGRATION.

> Then, we doesn't need page_cgroup lock, do we ? PCG_USED bit will avoid
> double-uncharge.
> 
no. there is a chance to update FILE_MAPPED etc..and any other races. I guess.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
