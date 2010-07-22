Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1E84E6B02A9
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 04:01:30 -0400 (EDT)
Date: Thu, 22 Jul 2010 16:54:25 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 1/2][memcg] moving memcg's node info array to
 virtually contiguous array
Message-Id: <20100722165425.a472cd88.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100722150445.19a4a701.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100721195831.6aa8dca5.kamezawa.hiroyu@jp.fujitsu.com>
	<20100722144356.b9681621.nishimura@mxp.nes.nec.co.jp>
	<20100722150445.19a4a701.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jul 2010 15:04:45 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 22 Jul 2010 14:43:56 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Wed, 21 Jul 2010 19:58:31 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > These are just a _toy_ level patches yet. My final purpose is to use indexed array
> > > for mem_cgroup itself, it has IDs.
> > > 
> > > Background:
> > >   memory cgroup uses struct page_cgroup for tracking all used pages. It's defined as
> > > ==
> > > struct page_cgroup {
> > >         unsigned long flags;
> > >         struct mem_cgroup *mem_cgroup;
> > >         struct page *page;
> > >         struct list_head lru;           /* per cgroup LRU list */
> > > };
> > > ==
> > >   and this increase the cost of per-page-objects dramatically. Now, we have
> > >   troubles on this object.
> > >   1.  Recently, a blkio-tracking guy wants to add "blockio-cgroup" information
> > >       to page_cgroup. But our concern is extra 8bytes per page.
> > >   2.  At tracking dirty page status etc...we need some trick for safe access
> > >       to page_cgroup and memcgroup's information. For example, a small seqlock.
> > > 
> > > Now, each memory cgroup has its own ID (0-65535). So, if we can replace
> > > 8byte of pointer "pc->mem_cgroup" with an ID, which is 2 bytes, we may able
> > > to have another room. (Moreover, I think we can reduce the number of IDs...)
> > > 
> > > This patch is a trial for implement a virually-indexed on-demand array and
> > > an example of usage. Any commetns are welcome.
> > > 
> 
> Hi,
> > So, your purpose is to:
> > 
> > - make the size of mem_croup small(by [2/2])
> It's just an example to test virt-array. I don't convice it can
> save memory or make something fast. and I found a bug in free routine.)
> 
> 
> > - manage all the mem_cgroup in virt-array indexed by its ID(it would be faster
> >   than using css_lookup)
> yes.
> 
> > - replace pc->mem_cgroup by its ID and make the size of page_cgroup small
> > 
> yes.
> 
> Final style I'm thinking is
> 	struct page_cgroup {
> 		unsigned long flags;
> 		spinlock_t	lock;  # for lock_page_cgroup()
> 		unsigned short memcg;
> 		unsigned short blkio;
> 		struct page *page;
> 		struct list_head list;
> 	};
> This will be benefical in 64bit. About 32bit, I may have to merge some fields.
> Or I may have to add some "version" field for updating memcg's statistics
> without locks. memcg field may be able to be moved onto high-bits of "flags"
> because it's stable value unless it's not under move_charge. 
> (IIUC, at move_charge, memcg is off-LRU and there are no race with AcctLRU bit
>  v.s. pc->mem_cgroup field. With other flags, lock_page_cgroup() works enough.)
> 
> Anyway, race with move_charge() will be the last enemy for us to track 
> dirty pages etc...at least, this kind of "make room" job is required, I feel.
> 
> There are many things to be considered, but I'm a bit in hurry. I'd like to do
> some preparation before Mel at el rewrites memory-reclaim+writeback complelety.
> 
Thank you for clarifying your thought.

I have one comment for this patch.
> +static int idx_used(const struct virt_array *v, int idx)
> +{
> +	return test_bit(idx, v->map);
> +}
> +
Who set the bit ?
Shouldn't we set it at alloc_varray_item() ?

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
