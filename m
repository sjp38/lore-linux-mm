Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 365B86B02A9
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 04:03:56 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6M83sg2031760
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 22 Jul 2010 17:03:54 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 55D6545DE4F
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 17:03:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B61B45DE51
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 17:03:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C9361DB8053
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 17:03:54 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BF8D1DB8056
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 17:03:53 +0900 (JST)
Date: Thu, 22 Jul 2010 16:59:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/2][memcg] moving memcg's node info array to
 virtually contiguous array
Message-Id: <20100722165908.4fa6d418.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100722165425.a472cd88.nishimura@mxp.nes.nec.co.jp>
References: <20100721195831.6aa8dca5.kamezawa.hiroyu@jp.fujitsu.com>
	<20100722144356.b9681621.nishimura@mxp.nes.nec.co.jp>
	<20100722150445.19a4a701.kamezawa.hiroyu@jp.fujitsu.com>
	<20100722165425.a472cd88.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jul 2010 16:54:25 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Thu, 22 Jul 2010 15:04:45 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Thu, 22 Jul 2010 14:43:56 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > On Wed, 21 Jul 2010 19:58:31 +0900
> > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > 
> > > > These are just a _toy_ level patches yet. My final purpose is to use indexed array
> > > > for mem_cgroup itself, it has IDs.
> > > > 
> > > > Background:
> > > >   memory cgroup uses struct page_cgroup for tracking all used pages. It's defined as
> > > > ==
> > > > struct page_cgroup {
> > > >         unsigned long flags;
> > > >         struct mem_cgroup *mem_cgroup;
> > > >         struct page *page;
> > > >         struct list_head lru;           /* per cgroup LRU list */
> > > > };
> > > > ==
> > > >   and this increase the cost of per-page-objects dramatically. Now, we have
> > > >   troubles on this object.
> > > >   1.  Recently, a blkio-tracking guy wants to add "blockio-cgroup" information
> > > >       to page_cgroup. But our concern is extra 8bytes per page.
> > > >   2.  At tracking dirty page status etc...we need some trick for safe access
> > > >       to page_cgroup and memcgroup's information. For example, a small seqlock.
> > > > 
> > > > Now, each memory cgroup has its own ID (0-65535). So, if we can replace
> > > > 8byte of pointer "pc->mem_cgroup" with an ID, which is 2 bytes, we may able
> > > > to have another room. (Moreover, I think we can reduce the number of IDs...)
> > > > 
> > > > This patch is a trial for implement a virually-indexed on-demand array and
> > > > an example of usage. Any commetns are welcome.
> > > > 
> > 
> > Hi,
> > > So, your purpose is to:
> > > 
> > > - make the size of mem_croup small(by [2/2])
> > It's just an example to test virt-array. I don't convice it can
> > save memory or make something fast. and I found a bug in free routine.)
> > 
> > 
> > > - manage all the mem_cgroup in virt-array indexed by its ID(it would be faster
> > >   than using css_lookup)
> > yes.
> > 
> > > - replace pc->mem_cgroup by its ID and make the size of page_cgroup small
> > > 
> > yes.
> > 
> > Final style I'm thinking is
> > 	struct page_cgroup {
> > 		unsigned long flags;
> > 		spinlock_t	lock;  # for lock_page_cgroup()
> > 		unsigned short memcg;
> > 		unsigned short blkio;
> > 		struct page *page;
> > 		struct list_head list;
> > 	};
> > This will be benefical in 64bit. About 32bit, I may have to merge some fields.
> > Or I may have to add some "version" field for updating memcg's statistics
> > without locks. memcg field may be able to be moved onto high-bits of "flags"
> > because it's stable value unless it's not under move_charge. 
> > (IIUC, at move_charge, memcg is off-LRU and there are no race with AcctLRU bit
> >  v.s. pc->mem_cgroup field. With other flags, lock_page_cgroup() works enough.)
> > 
> > Anyway, race with move_charge() will be the last enemy for us to track 
> > dirty pages etc...at least, this kind of "make room" job is required, I feel.
> > 
> > There are many things to be considered, but I'm a bit in hurry. I'd like to do
> > some preparation before Mel at el rewrites memory-reclaim+writeback complelety.
> > 
> Thank you for clarifying your thought.
> 
> I have one comment for this patch.
> > +static int idx_used(const struct virt_array *v, int idx)
> > +{
> > +	return test_bit(idx, v->map);
> > +}
> > +
> Who set the bit ?
> Shouldn't we set it at alloc_varray_item() ?
> 

yes. That's bug. my host crashed ;(
and....clear_bit() is also lacked .

I'll prepare a patch for memory_cgroup_on_array _after_ tests ;)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
