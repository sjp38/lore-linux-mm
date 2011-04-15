Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0F960900087
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 00:23:07 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D222C3EE0C0
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 13:23:04 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B675B45DE6D
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 13:23:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 91F0345DE67
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 13:23:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F989E08004
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 13:23:04 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 397831DB803A
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 13:23:04 +0900 (JST)
Date: Fri, 15 Apr 2011 13:16:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V4 01/10] Add kswapd descriptor
Message-Id: <20110415131617.91b0485c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTikE6dyLJVebk65-6A8RdF-fpTFQ+g@mail.gmail.com>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
	<1302821669-29862-2-git-send-email-yinghan@google.com>
	<20110415090445.4578f987.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikE6dyLJVebk65-6A8RdF-fpTFQ+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, 14 Apr 2011 20:35:00 -0700
Ying Han <yinghan@google.com> wrote:

> On Thu, Apr 14, 2011 at 5:04 PM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Thu, 14 Apr 2011 15:54:20 -0700
> > Ying Han <yinghan@google.com> wrote:
> >
> > > There is a kswapd kernel thread for each numa node. We will add a
> > different
> > > kswapd for each memcg. The kswapd is sleeping in the wait queue headed at
> > > kswapd_wait field of a kswapd descriptor. The kswapd descriptor stores
> > > information of node or memcg and it allows the global and per-memcg
> > background
> > > reclaim to share common reclaim algorithms.
> > >
> > > This patch adds the kswapd descriptor and moves the per-node kswapd to
> > use the
> > > new structure.
> > >
> >
> > No objections to your direction but some comments.
> >
> > > changelog v2..v1:
> > > 1. dynamic allocate kswapd descriptor and initialize the wait_queue_head
> > of pgdat
> > > at kswapd_run.
> > > 2. add helper macro is_node_kswapd to distinguish per-node/per-cgroup
> > kswapd
> > > descriptor.
> > >
> > > changelog v3..v2:
> > > 1. move the struct mem_cgroup *kswapd_mem in kswapd sruct to later patch.
> > > 2. rename thr in kswapd_run to something else.
> > >
> > > Signed-off-by: Ying Han <yinghan@google.com>
> > > ---
> > >  include/linux/mmzone.h |    3 +-
> > >  include/linux/swap.h   |    7 ++++
> > >  mm/page_alloc.c        |    1 -
> > >  mm/vmscan.c            |   95
> > ++++++++++++++++++++++++++++++++++++------------
> > >  4 files changed, 80 insertions(+), 26 deletions(-)
> > >
> > > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > > index 628f07b..6cba7d2 100644
> > > --- a/include/linux/mmzone.h
> > > +++ b/include/linux/mmzone.h
> > > @@ -640,8 +640,7 @@ typedef struct pglist_data {
> > >       unsigned long node_spanned_pages; /* total size of physical page
> > >                                            range, including holes */
> > >       int node_id;
> > > -     wait_queue_head_t kswapd_wait;
> > > -     struct task_struct *kswapd;
> > > +     wait_queue_head_t *kswapd_wait;
> > >       int kswapd_max_order;
> > >       enum zone_type classzone_idx;
> >
> > I think pg_data_t should include struct kswapd in it, as
> >
> >        struct pglist_data {
> >        .....
> >                struct kswapd   kswapd;
> >        };
> > and you can add a macro as
> >
> > #define kswapd_waitqueue(kswapd)        (&(kswapd)->kswapd_wait)
> > if it looks better.
> >
> > Why I recommend this is I think it's better to have 'struct kswapd'
> > on the same page of pg_data_t or struct memcg.
> > Do you have benefits to kmalloc() struct kswapd on damand ?
> >
> 
> So we don't end of have kswapd struct on memcgs' which doesn't have
> per-memcg kswapd enabled. I don't see one is strongly better than the other
> for the two approaches. If ok, I would like to keep as it is for this
> verion. Hope this is ok for now.
> 

My intension is to remove kswapd_spinlock. Can we remove it with
dynamic allocation ? IOW, static allocation still requires spinlock ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
