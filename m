Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B47DA6B0085
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 00:47:19 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o984lHA2030461
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 8 Oct 2010 13:47:17 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D3EA45DE4F
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 13:47:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A095345DE52
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 13:47:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 733431DB803C
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 13:47:16 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 121A7E08001
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 13:47:16 +0900 (JST)
Date: Fri, 8 Oct 2010 13:41:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: lock-free clear page writeback (Was Re: [PATCH
 04/10] memcg: disable local interrupts in lock_page_cgroup()
Message-Id: <20101008134157.bf2d42c7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTi=kBnrtb5KkFQE3tNwVh1dWeUVBepWjec7ReVL0@mail.gmail.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
	<1286175485-30643-5-git-send-email-gthelen@google.com>
	<20101005160332.GB9515@barrios-desktop>
	<xr93wrpwkypv.fsf@ninji.mtv.corp.google.com>
	<AANLkTikKXNx-Cj2UY+tJj8ifC+Je5WDbS=eR6xsKM1uU@mail.gmail.com>
	<20101007093545.429fe04a.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007105456.d86d8092.nishimura@mxp.nes.nec.co.jp>
	<20101007111743.322c3993.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007152111.df687a62.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007152422.c5919517.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=kBnrtb5KkFQE3tNwVh1dWeUVBepWjec7ReVL0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 8 Oct 2010 08:35:30 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Hi Kame,
> 
> On Thu, Oct 7, 2010 at 3:24 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Greg, I think clear_page_writeback() will not require _any_ locks with this patch.
> > But set_page_writeback() requires it...
> > (Maybe adding a special function for clear_page_writeback() is better rather than
> > A adding some complex to switch() in update_page_stat())
> >
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >
> > Now, at page information accounting, we do lock_page_cgroup() if pc->mem_cgroup
> > points to a cgroup where someone is moving charges from.
> >
> > At supporing dirty-page accounting, one of troubles is writeback bit.
> > In general, writeback can be cleared via IRQ context. To update writeback bit
> > with lock_page_cgroup() in safe way, we'll have to disable IRQ.
> > ....or do something.
> >
> > This patch waits for completion of writeback under lock_page() and do
> > lock_page_cgroup() in safe way. (We never got end_io via IRQ context.)
> >
> > By this, writeback-accounting will never see race with account_move() and
> > it can trust pc->mem_cgroup always _without_ any lock.
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> > A mm/memcontrol.c | A  18 ++++++++++++++++++
> > A 1 file changed, 18 insertions(+)
> >
> > Index: mmotm-0928/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-0928.orig/mm/memcontrol.c
> > +++ mmotm-0928/mm/memcontrol.c
> > @@ -2183,17 +2183,35 @@ static void __mem_cgroup_move_account(st
> > A /*
> > A * check whether the @pc is valid for moving account and call
> > A * __mem_cgroup_move_account()
> > + * Don't call this under pte_lock etc...we'll do lock_page() and wait for
> > + * the end of I/O.
> > A */
> > A static int mem_cgroup_move_account(struct page_cgroup *pc,
> > A  A  A  A  A  A  A  A struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
> > A {
> > A  A  A  A int ret = -EINVAL;
> > +
> > + A  A  A  /*
> > + A  A  A  A * We move severl flags and accounting information here. So we need to
> > + A  A  A  A * avoid the races with update_stat routines. For most of routines,
> > + A  A  A  A * lock_page_cgroup() is enough for avoiding race. But we need to take
> > + A  A  A  A * care of IRQ context. If flag updates comes from IRQ context, This
> > + A  A  A  A * "move account" will be racy (and cause deadlock in lock_page_cgroup())
> > + A  A  A  A *
> > + A  A  A  A * Now, the only race we have is Writeback flag. We wait for it cleared
> > + A  A  A  A * before starting our jobs.
> > + A  A  A  A */
> > +
> > + A  A  A  lock_page(pc->page);
> > + A  A  A  wait_on_page_writeback(pc->page);
> > +
> > A  A  A  A lock_page_cgroup(pc);
> > A  A  A  A if (PageCgroupUsed(pc) && pc->mem_cgroup == from) {
> > A  A  A  A  A  A  A  A __mem_cgroup_move_account(pc, from, to, uncharge);
> > A  A  A  A  A  A  A  A ret = 0;
> > A  A  A  A }
> > A  A  A  A unlock_page_cgroup(pc);
> > + A  A  A  unlock_page(pc->page);
> > A  A  A  A /*
> > A  A  A  A  * check events
> > A  A  A  A  */
> >
> >
> 
> Looks good to me.
> But let me ask a question.
> Why do only move_account need this logic?

Because charge/uncharge (add/remove to radix-tree or swapcache)
never happens while a page is PG_writeback.

> Is deadlock candidate is only this place?
yes.

> How about mem_cgroup_prepare_migration?
> 
> unmap_and_move
> lock_page
> mem_cgroup_prepare_migration
> lock_page_cgroup
> ...
> softirq happen
> lock_page_cgroup
> 
> 
Nice cactch. I'll move prepare_migraon after wait_on_page_writeback()

> If race happens only where move_account and writeback, please describe
> it as comment.
> It would help to review the code in future.
> 

Sure, updates are necessary.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
