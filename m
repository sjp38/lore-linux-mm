Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 50C6F8D0039
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 19:04:33 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 02B3C3EE0AE
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 09:04:30 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DD0AB45DE5B
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 09:04:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C368245DE56
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 09:04:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B3F98E38008
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 09:04:29 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C459E38004
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 09:04:29 +0900 (JST)
Date: Thu, 24 Feb 2011 08:58:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/5] page_cgroup: make page tracking available for blkio
Message-Id: <20110224085805.14766e93.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110223085911.GC2174@linux.develer.com>
References: <1298394776-9957-1-git-send-email-arighi@develer.com>
	<1298394776-9957-4-git-send-email-arighi@develer.com>
	<20110222130145.37cb151e@bike.lwn.net>
	<20110222230146.GB23723@linux.develer.com>
	<20110222230630.GL28269@redhat.com>
	<20110222233718.GF23723@linux.develer.com>
	<20110223134910.abbdc931.kamezawa.hiroyu@jp.fujitsu.com>
	<20110223085911.GC2174@linux.develer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <arighi@develer.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Greg Thelen <gthelen@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Gui Jianfeng <guijianfeng@cn.fujitsu.com>, Ryo Tsuruta <ryov@valinux.co.jp>, Hirokazu Takahashi <taka@valinux.co.jp>, Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 23 Feb 2011 09:59:11 +0100
Andrea Righi <arighi@develer.com> wrote:

> > 
> > I wonder I can make pc->mem_cgroup to be pc->memid(16bit), then, 
> > ==
> > static inline struct mem_cgroup *get_memcg_from_pc(struct page_cgroup *pc)
> > {
> >     struct cgroup_subsys_state *css = css_lookup(&mem_cgroup_subsys, pc->memid);
> >     return container_of(css, struct mem_cgroup, css);
> > }
> > ==
> > Overhead will be seen at updating file statistics and LRU management.
> > 
> > But, hmm, can't you do that tracking without page_cgroup ?
> > Because the number of dirty/writeback pages are far smaller than total pages,
> > chasing I/O with dynamic structure is not very bad..
> > 
> > prepareing [pfn -> blkio] record table and move that information to struct bio
> > in dynamic way is very difficult ?
> 
> This would be ok for dirty pages, but consider that we're also tracking
> anonymous pages. So, if we want to control the swap IO we actually need
> to save this information for a lot of pages and at the end I think we'll
> basically duplicate the page_cgroup code.
> 

swap io is always started with bio and the task/mm_struct.
So, if we can record information in bio, no page tracking is required.
You can record information to bio just by reading mm->owner.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
