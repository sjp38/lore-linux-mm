Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A2FDE6B0047
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 22:59:15 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o063xCIi023625
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 6 Jan 2010 12:59:12 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 206FD45DE58
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 12:59:12 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E1D5F45DE51
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 12:59:11 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B82E31DB8042
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 12:59:11 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D4A631DB803F
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 12:59:10 +0900 (JST)
Date: Wed, 6 Jan 2010 12:56:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mm] Shared Page accounting for memory cgroup (v2)
Message-Id: <20100106125601.ef573c61.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100106034934.GK3059@balbir.in.ibm.com>
References: <20100105185226.GG3059@balbir.in.ibm.com>
	<20100106090708.f3ec9fd8.kamezawa.hiroyu@jp.fujitsu.com>
	<20100106030752.GI3059@balbir.in.ibm.com>
	<20100106121836.40f3b3c0.kamezawa.hiroyu@jp.fujitsu.com>
	<20100106034934.GK3059@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 6 Jan 2010 09:19:34 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-01-06 12:18:36]:
> 
> > On Wed, 6 Jan 2010 08:37:52 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-01-06 09:07:08]:
> > > 
> > > > On Wed, 6 Jan 2010 00:22:26 +0530
> > > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > 
> > > > > Hi, All,
> > > > > 
> > > > > No major changes from v1, except for the use of get_mm_rss().
> > > > > Kamezawa-San felt that this can be done in user space and I responded
> > > > > to him with my concerns of doing it in user space. The thread
> > > > > can be found at http://thread.gmane.org/gmane.linux.kernel.mm/42367.
> > > > > 
> > > > > If there are no major objections, can I ask for a merge into -mm.
> > > > > Andrew, the patches are against mmotm 10 December 2009, if there
> > > > > are some merge conflicts, please let me know, I can rebase after
> > > > > you release the next mmotm.
> > > > > 
> > > > 
> > > > The problem is that this isn't "shared" uasge but "considered to be shared"
> > > > usage. Okay ?
> > > >
> > > 
> > > Could you give me your definition of "shared". From the mem cgroup
> > > perspective, total_rss (which is accumulated) subtracted from the
> > > count of pages in the LRU which are RSS and FILE_MAPPED is shared, no?
> > 
> > You consider only "mapped" pages are shared page. That's wrong.
> > And let's think about your "total_rss - RSS+MAPPED"
> > 
> > In this typical case,
> > 	fork()  ---- process(A)
> > 	-> fork() --- process(B)
> > 	  -> process(C)
> > 
> > total_rss = rss(A) + rss(B) + rss(C) = 3 * rss(A)
> > Then, 
> > 
> > total_rss - RSS_MAPPED = 2 * rss(A).
> > 
> > How we call this number ? Is this "shared usage" ? I think no.
> 
> Why not? The pages in LRU is rss(A) and the total usage is 3*rss(A),
> shared does not imply shared outside the cgroup. Why do you say it is
> not shared?
> 
If "shared" means "shared with other cgroup", I'll say "Oh, this is really
helpful". Usual novice user will think "shared" means "shared with other
cgroup".

Again, "shared of cgroup" should be "shared between cgroup" not
"shared between process".

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
