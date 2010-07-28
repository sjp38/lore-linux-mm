Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id EEF896B024D
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 22:48:55 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6S2mqCw014219
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Jul 2010 11:48:53 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A55AB45DE4E
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 11:48:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 79AE645DE4D
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 11:48:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 61A051DB804D
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 11:48:52 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C5BC1DB804B
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 11:48:49 +0900 (JST)
Date: Wed, 28 Jul 2010 11:44:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 4/7][memcg] memcg use ID in page_cgroup
Message-Id: <20100728114402.571b8ec6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100728023904.GE12642@redhat.com>
References: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100727165629.6f98145c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100728023904.GE12642@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Vivek Goyal <vgoyal@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Jul 2010 22:39:04 -0400
Vivek Goyal <vgoyal@redhat.com> wrote:

> On Tue, Jul 27, 2010 at 04:56:29PM +0900, KAMEZAWA Hiroyuki wrote:
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Now, addresses of memory cgroup can be calculated by their ID without complex.
> > This patch relplaces pc->mem_cgroup from a pointer to a unsigned short.
> > On 64bit architecture, this offers us more 6bytes room per page_cgroup.
> > Use 2bytes for blkio-cgroup's page tracking. More 4bytes will be used for
> > some light-weight concurrent access.
> > 
> > We may able to move this id onto flags field but ...go step by step.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  include/linux/page_cgroup.h |    3 ++-
> >  mm/memcontrol.c             |   40 +++++++++++++++++++++++++---------------
> >  mm/page_cgroup.c            |    2 +-
> >  3 files changed, 28 insertions(+), 17 deletions(-)
> > 
> > Index: mmotm-0719/include/linux/page_cgroup.h
> > ===================================================================
> > --- mmotm-0719.orig/include/linux/page_cgroup.h
> > +++ mmotm-0719/include/linux/page_cgroup.h
> > @@ -12,7 +12,8 @@
> >   */
> >  struct page_cgroup {
> >  	unsigned long flags;
> > -	struct mem_cgroup *mem_cgroup;
> > +	unsigned short mem_cgroup;	/* ID of assigned memory cgroup */
> > +	unsigned short blk_cgroup;	/* Not Used..but will be. */
> 
> So later I shall have to use virtually indexed arrays in blkio controller?
> Or you are just using virtually indexed arrays for lookup speed and
> I can continue to use css_lookup() and not worry about using virtually
> indexed arrays.
> 
yes. you can use css_lookup() even if it's slow.

> So the idea is that when a page is allocated, also store the blk_group
> id and once that page is submitted for writeback, we should be able
> to associate it to right blkio group?
> 
blk_cgroup id can be attached whenever you wants. please overwrite 
page_cgroup->blk_cgroup when it's necessary.
Did you read Ikeda's patch ? I myself doesn't have patches at this point. 
This is just for make a room for recording blkio-ID, which was requested
for a year.

Hmm, but page-allocation-time doesn't sound very good for me.

Thanks.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
