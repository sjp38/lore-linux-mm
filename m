Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8A1EA6008E4
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 23:48:53 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o733rNRQ022370
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 3 Aug 2010 12:53:23 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E410645DE4D
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 12:53:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BD47C45DE50
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 12:53:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 98C501DB8053
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 12:53:22 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 424371DB8055
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 12:53:22 +0900 (JST)
Date: Tue, 3 Aug 2010 12:48:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mm 2/5] use ID in page cgroup
Message-Id: <20100803124831.8cd5976f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100803034513.GF3863@balbir.in.ibm.com>
References: <20100802191113.05c982e4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100802191410.cbf03d67.kamezawa.hiroyu@jp.fujitsu.com>
	<20100803034513.GF3863@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, vgoyal@redhat.com, m-ikeda@ds.jp.nec.com, gthelen@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Aug 2010 09:15:13 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-08-02 19:14:10]:
> 
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
> > Changelog: 20100730
> >  - fixed some garbage added by debug code in early stage
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  include/linux/page_cgroup.h |    3 ++-
> >  mm/memcontrol.c             |   32 +++++++++++++++++++-------------
> >  mm/page_cgroup.c            |    2 +-
> >  3 files changed, 22 insertions(+), 15 deletions(-)
> > 
> > Index: mmotm-0727/include/linux/page_cgroup.h
> > ===================================================================
> > --- mmotm-0727.orig/include/linux/page_cgroup.h
> > +++ mmotm-0727/include/linux/page_cgroup.h
> > @@ -12,7 +12,8 @@
> >   */
> >  struct page_cgroup {
> >  	unsigned long flags;
> > -	struct mem_cgroup *mem_cgroup;
> > +	unsigned short mem_cgroup;	/* ID of assigned memory cgroup */
> > +	unsigned short blk_cgroup;	/* Not Used..but will be. */
> >  	struct page *page;
> >  	struct list_head lru;		/* per cgroup LRU list */
> >  };
> 
> Can I recommend that on 64 bit systems, we merge the flag, mem_cgroup
> and blk_cgroup into one 8 byte value. We could use
> __attribute("packed") and do something like this
> 

It's a next step.

> struct page_cgroup {
>         unsigned int flags;
>         unsigned short mem_cgroup;
>         unsigned short blk_cgroup;
>         ...
> } __attribute(("packed"));
> 
> Then we need to make sure we don't use more that 32 bits for flags,
> which is very much under control at the moment.
> 
set_bit() requires "long" as its argument. more some trick is required.

 And, IIUC, packing implies
	pc->mem_cgroup = mem_cgroup_id; or
	pc->blk_cgroup = blk_cgroup_id; will have race with
	set/clear_bit(BIT_XXXX, &pc->flags)
 
 This "packing" is not very easy. we have to consider all possible combinations
 of operations.

> This will save us 8 bytes in total on 64 bit systems and nothing on 32
> bit systems, but will enable blkio cgroup to co-exist.
> 

yes. But I have cocnerns of race condition. to do that, we need
patch 3-5. (But patch 5 adds spinlock, then no 8bytes reduce.)

Let me go step by step. I'm _really_ afraid of race conditions.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
