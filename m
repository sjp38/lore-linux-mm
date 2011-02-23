Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6CCBB8D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 23:56:06 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id F0DB43EE0C2
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 13:56:01 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D13A945DE57
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 13:56:01 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B7B1F45DE52
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 13:56:01 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A26761DB8042
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 13:56:01 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 640561DB8037
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 13:56:01 +0900 (JST)
Date: Wed, 23 Feb 2011 13:49:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/5] page_cgroup: make page tracking available for blkio
Message-Id: <20110223134910.abbdc931.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110222233718.GF23723@linux.develer.com>
References: <1298394776-9957-1-git-send-email-arighi@develer.com>
	<1298394776-9957-4-git-send-email-arighi@develer.com>
	<20110222130145.37cb151e@bike.lwn.net>
	<20110222230146.GB23723@linux.develer.com>
	<20110222230630.GL28269@redhat.com>
	<20110222233718.GF23723@linux.develer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <arighi@develer.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Greg Thelen <gthelen@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Gui Jianfeng <guijianfeng@cn.fujitsu.com>, Ryo Tsuruta <ryov@valinux.co.jp>, Hirokazu Takahashi <taka@valinux.co.jp>, Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 23 Feb 2011 00:37:18 +0100
Andrea Righi <arighi@develer.com> wrote:

> On Tue, Feb 22, 2011 at 06:06:30PM -0500, Vivek Goyal wrote:
> > On Wed, Feb 23, 2011 at 12:01:47AM +0100, Andrea Righi wrote:
> > > On Tue, Feb 22, 2011 at 01:01:45PM -0700, Jonathan Corbet wrote:
> > > > On Tue, 22 Feb 2011 18:12:54 +0100
> > > > Andrea Righi <arighi@develer.com> wrote:
> > > > 
> > > > > The page_cgroup infrastructure, currently available only for the memory
> > > > > cgroup controller, can be used to store the owner of each page and
> > > > > opportunely track the writeback IO. This information is encoded in
> > > > > the upper 16-bits of the page_cgroup->flags.
> > > > > 
> > > > > A owner can be identified using a generic ID number and the following
> > > > > interfaces are provided to store a retrieve this information:
> > > > > 
> > > > >   unsigned long page_cgroup_get_owner(struct page *page);
> > > > >   int page_cgroup_set_owner(struct page *page, unsigned long id);
> > > > >   int page_cgroup_copy_owner(struct page *npage, struct page *opage);
> > > > 
> > > > My immediate observation is that you're not really tracking the "owner"
> > > > here - you're tracking an opaque 16-bit token known only to the block
> > > > controller in a field which - if changed by anybody other than the block
> > > > controller - will lead to mayhem in the block controller.  I think it
> > > > might be clearer - and safer - to say "blkcg" or some such instead of
> > > > "owner" here.
> > > > 
> > > 
> > > Basically the idea here was to be as generic as possible and make this
> > > feature potentially available also to other subsystems, so that cgroup
> > > subsystems may represent whatever they want with the 16-bit token.
> > > However, no more than a single subsystem may be able to use this feature
> > > at the same time.
> > > 
> > > > I'm tempted to say it might be better to just add a pointer to your
> > > > throtl_grp structure into struct page_cgroup.  Or maybe replace the
> > > > mem_cgroup pointer with a single pointer to struct css_set.  Both of
> > > > those ideas, though, probably just add unwanted extra overhead now to gain
> > > > generality which may or may not be wanted in the future.
> > > 
> > > The pointer to css_set sounds good, but it would add additional space to
> > > the page_cgroup struct. Now, page_cgroup is 40 bytes (in 64-bit arch)
> > > and all of them are allocated at boot time. Using unused bits in
> > > page_cgroup->flags is a choice with no overhead from this point of view.
> > 
> > I think John suggested replacing mem_cgroup pointer with css_set so that
> > size of the strcuture does not increase but it leads extra level of 
> > indirection.
> 
> OK, got it sorry.
> 
> So, IIUC we save css_set pointer and get a struct cgroup as following:
> 
>   struct cgroup *cgrp = css_set->subsys[subsys_id]->cgroup;
> 
> Then, for example to get the mem_cgroup reference:
> 
>   struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> 
> It seems a lot of indirections, but I may have done something wrong or
> there could be a simpler way to do it.
> 


Then, page_cgroup should have reference count on css_set and make tons of
atomic ops.

BTW, bits of pc->flags are used for storing sectionID or nodeID.
Please clarify your 16bit never breaks that information. And please keep
more 4-5 flags for dirty_ratio support of memcg.

I wonder I can make pc->mem_cgroup to be pc->memid(16bit), then, 
==
static inline struct mem_cgroup *get_memcg_from_pc(struct page_cgroup *pc)
{
    struct cgroup_subsys_state *css = css_lookup(&mem_cgroup_subsys, pc->memid);
    return container_of(css, struct mem_cgroup, css);
}
==
Overhead will be seen at updating file statistics and LRU management.

But, hmm, can't you do that tracking without page_cgroup ?
Because the number of dirty/writeback pages are far smaller than total pages,
chasing I/O with dynamic structure is not very bad..

prepareing [pfn -> blkio] record table and move that information to struct bio
in dynamic way is very difficult ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
