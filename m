Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2C7698D0069
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 18:47:54 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B907D3EE0B3
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 08:47:51 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9DA4A45DE58
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 08:47:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BC4745DE56
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 08:47:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E41DE18001
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 08:47:51 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 38DCE1DB8037
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 08:47:51 +0900 (JST)
Date: Fri, 21 Jan 2011 08:41:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] memcg: fix rmdir, force_empty with THP
Message-Id: <20110121084151.4673c179.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110121083930.d803126f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110118113528.fd24928f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110118114348.9e1dba9b.kamezawa.hiroyu@jp.fujitsu.com>
	<20110120134108.GO2232@cmpxchg.org>
	<20110121083930.d803126f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jan 2011 08:39:30 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 20 Jan 2011 14:41:08 +0100
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > On Tue, Jan 18, 2011 at 11:43:48AM +0900, KAMEZAWA Hiroyuki wrote:
> > > 
> > > Now, when THP is enabled, memcg's rmdir() function is broken
> > > because move_account() for THP page is not supported.
> > > 
> > > This will cause account leak or -EBUSY issue at rmdir().
> > > This patch fixes the issue by supporting move_account() THP pages.
> > > 
> > > Changelog:
> > >  - style fix.
> > >  - add compound_lock for avoiding races.
> > > 
> > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > ---
> > >  mm/memcontrol.c |   37 ++++++++++++++++++++++++++-----------
> > >  1 file changed, 26 insertions(+), 11 deletions(-)
> > > 
> > > Index: mmotm-0107/mm/memcontrol.c
> > > ===================================================================
> > > --- mmotm-0107.orig/mm/memcontrol.c
> > > +++ mmotm-0107/mm/memcontrol.c
> > 
> > > @@ -2267,6 +2274,8 @@ static int mem_cgroup_move_parent(struct
> > >  	struct cgroup *cg = child->css.cgroup;
> > >  	struct cgroup *pcg = cg->parent;
> > >  	struct mem_cgroup *parent;
> > > +	int charge = PAGE_SIZE;
> > 
> > No need to initialize, you assign it unconditionally below.
> > 
> > It's also a bit unfortunate that the parameter/variable with this
> > meaning appears under a whole bunch of different names.  page_size,
> > charge_size, and now charge.  Could you stick with page_size?
> > 
> 
> charge_size != page_size.
> 
> Clean up as you like, later. I'll Ack.
> 
> > > @@ -2278,17 +2287,23 @@ static int mem_cgroup_move_parent(struct
> > >  		goto out;
> > >  	if (isolate_lru_page(page))
> > >  		goto put;
> > > +	/* The page is isolated from LRU and we have no race with splitting */
> > > +	charge = PAGE_SIZE << compound_order(page);
> > 
> > Why is LRU isolation preventing the splitting?
> > 
> 
> That's my mistake of comment, which was in the older patch.
> I use compound_lock now. I'll post clean up.
> 
It seems patches are sent to Linus's tree.

I'll post some clean up patches for memcontrol.c.
I hope that will not break other guy's works.

Thanks,
-kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
