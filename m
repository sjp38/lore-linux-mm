Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E67DA6B00E9
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 06:35:08 -0500 (EST)
Date: Mon, 24 Jan 2011 12:34:58 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/7] memcg : comment, style fixes for recent patch of
 move_parent
Message-ID: <20110124113458.GX2232@cmpxchg.org>
References: <20110121153431.191134dd.kamezawa.hiroyu@jp.fujitsu.com>
 <20110121153726.54f4a159.kamezawa.hiroyu@jp.fujitsu.com>
 <20110124101402.GT2232@cmpxchg.org>
 <20110124191535.514ef2d9.kamezawa.hiroyu@jp.fujitsu.com>
 <20110124104510.GW2232@cmpxchg.org>
 <AANLkTi=sg5HpCTdXgEVYS5rCqtoVVho6dxn8giwZ4kmY@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTi=sg5HpCTdXgEVYS5rCqtoVVho6dxn8giwZ4kmY@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 24, 2011 at 08:14:22PM +0900, Hiroyuki Kamezawa wrote:
> 2011/1/24 Johannes Weiner <hannes@cmpxchg.org>:
> > On Mon, Jan 24, 2011 at 07:15:35PM +0900, KAMEZAWA Hiroyuki wrote:
> >> On Mon, 24 Jan 2011 11:14:02 +0100
> >> Johannes Weiner <hannes@cmpxchg.org> wrote:
> >>
> >> > On Fri, Jan 21, 2011 at 03:37:26PM +0900, KAMEZAWA Hiroyuki wrote:
> >> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >> > >
> >> > > A fix for 987eba66e0e6aa654d60881a14731a353ee0acb4
> >> > >
> >> > > A clean up for mem_cgroup_move_parent().
> >> > >  - remove unnecessary initialization of local variable.
> >> > >  - rename charge_size -> page_size
> >> > >  - remove unnecessary (wrong) comment.
> >> > >
> >> > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >> > > ---
> >> > >  mm/memcontrol.c |   17 +++++++++--------
> >> > >  1 file changed, 9 insertions(+), 8 deletions(-)
> >> > >
> >> > > Index: mmotm-0107/mm/memcontrol.c
> >> > > ===================================================================
> >> > > --- mmotm-0107.orig/mm/memcontrol.c
> >> > > +++ mmotm-0107/mm/memcontrol.c
> >> > > @@ -2265,7 +2265,7 @@ static int mem_cgroup_move_parent(struct
> >> > >   struct cgroup *cg = child->css.cgroup;
> >> > >   struct cgroup *pcg = cg->parent;
> >> > >   struct mem_cgroup *parent;
> >> > > - int charge = PAGE_SIZE;
> >> > > + int page_size;
> >> > >   unsigned long flags;
> >> > >   int ret;
> >> > >
> >> > > @@ -2278,22 +2278,23 @@ static int mem_cgroup_move_parent(struct
> >> > >           goto out;
> >> > >   if (isolate_lru_page(page))
> >> > >           goto put;
> >> > > - /* The page is isolated from LRU and we have no race with splitting */
> >> > > - charge = PAGE_SIZE << compound_order(page);
> >> > > +
> >> > > + page_size = PAGE_SIZE << compound_order(page);
> >> >
> >> > Okay, so you remove the wrong comment, but that does not make the code
> >> > right.  What protects compound_order from reading garbage because the
> >> > page is currently splitting?
> >> >
> >>
> >> ==
> >> static int mem_cgroup_move_account(struct page_cgroup *pc,
> >>                 struct mem_cgroup *from, struct mem_cgroup *to,
> >>                 bool uncharge, int charge_size)
> >> {
> >>         int ret = -EINVAL;
> >>         unsigned long flags;
> >>
> >>         if ((charge_size > PAGE_SIZE) && !PageTransHuge(pc->page))
> >>                 return -EBUSY;
> >> ==
> >>
> >> This is called under compound_lock(). Then, if someone breaks THP,
> >> -EBUSY and retry.
> >
> > This charge_size contains exactly the garbage you just read from an
> > unprotected compound_order().  It could be anything if the page is
> > split concurrently.
> 
> Then, my recent fix to LRU accounting which use compound_order() is racy, too ?

In lru add/delete/move/rotate?  No, that should be safe because we
have the lru lock there and __split_huge_page_refcount() takes the
lock as well.

> I'll replace compound_order() with
>   if (PageTransHuge(page))
>       size = HPAGE_SIZE.
> 
> Does this work ?

Yes, I think this should work.  This gives a sane size for try_charge
and we still catch a split under the compound_lock later in
move_account as you described above.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
