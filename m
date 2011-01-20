Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 15C2D8D003A
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 20:01:10 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 1BE983EE0BC
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 10:01:07 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0559745DE60
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 10:01:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DB99D45DE5B
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 10:01:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CC9B0E78003
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 10:01:06 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 94DC0E78002
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 10:01:06 +0900 (JST)
Date: Thu, 20 Jan 2011 09:55:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/4] memcg: fix USED bit handling at uncharge in THP
Message-Id: <20110120095503.74dea304.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110119121043.GB2232@cmpxchg.org>
References: <20110118113528.fd24928f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110118114049.5ffdf5da.kamezawa.hiroyu@jp.fujitsu.com>
	<20110119121043.GB2232@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 19 Jan 2011 13:10:43 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> Hello KAMEZAWA-san,
> 
> On Tue, Jan 18, 2011 at 11:40:49AM +0900, KAMEZAWA Hiroyuki wrote:
> > +void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail)
> > +{
> > +	struct page_cgroup *head_pc = lookup_page_cgroup(head);
> > +	struct page_cgroup *tail_pc = lookup_page_cgroup(tail);
> > +	unsigned long flags;
> > +
> > +	/*
> > +	 * We have no races witch charge/uncharge but will have races with
> > +	 * page state accounting.
> > +	 */
> > +	move_lock_page_cgroup(head_pc, &flags);
> > +
> > +	tail_pc->mem_cgroup = head_pc->mem_cgroup;
> > +	smp_wmb(); /* see __commit_charge() */
> 
> I thought the barriers were needed because charging does not hold the
> lru lock.  But here we do, and all the 'lockless' read-sides do so as
> well.  Am I missing something or can this barrier be removed?
> 

Hmm. I think this can be removed. But it's just because there is only one
referer of lockless access to pc->mem_cgroup. I think it's ok to remove
this but it should be done by independent patch with enough patch
clarification. IOW, I'll do later in another patch.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
