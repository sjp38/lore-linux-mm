Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EB61B6B0069
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 05:46:16 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 47A543EE0BD
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 19:46:13 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2667F45DEB9
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 19:46:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C38E45DEB2
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 19:46:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id F1A7E1DB8041
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 19:46:12 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B955C1DB803B
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 19:46:12 +0900 (JST)
Date: Mon, 21 Nov 2011 19:44:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] fix mem_cgroup_split_huge_fixup to work efficiently.
Message-Id: <20111121194452.01c8e93d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111121104250.GI1770@cmpxchg.org>
References: <20111117103308.063f78df.kamezawa.hiroyu@jp.fujitsu.com>
	<20111121104250.GI1770@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mhocko@suse.cz, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <bsingharora@gmail.com>

On Mon, 21 Nov 2011 11:42:50 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Thu, Nov 17, 2011 at 10:33:08AM +0900, KAMEZAWA Hiroyuki wrote:
> > 
> > I'll send this again when mm is shipped.
> > I sometimes see mem_cgroup_split_huge_fixup() in perf report and noticed
> > it's very slow. This fixes it. Any comments are welcome.
> > 
> > ==
> > Subject: [PATCH] fix mem_cgroup_split_huge_fixup to work efficiently.
> > 
> > at split_huge_page(), mem_cgroup_split_huge_fixup() is called to
> > handle page_cgroup modifcations. It takes move_lock_page_cgroup()
> > and modify page_cgroup and LRU accounting jobs and called
> > HPAGE_PMD_SIZE - 1 times.
> > 
> > But thinking again,
> >   - compound_lock() is held at move_accout...then, it's not necessary
> >     to take move_lock_page_cgroup().
> >   - LRU is locked and all tail pages will go into the same LRU as
> >     head is now on.
> >   - page_cgroup is contiguous in huge page range.
> > 
> > This patch fixes mem_cgroup_split_huge_fixup() as to be called once per
> > hugepage and reduce costs for spliting.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> I agree with the changes, but since you are resending it anyway: I
> think removing the move_lock and switching the hook to take care of
> all tail pages in one go are two logical steps.  Would you mind
> breaking it up into separate patches?
> 
> In any case,
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Ok, I'll break this into 2 patches at resending.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
