Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B2A876B0085
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 04:28:45 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2B9ShmP006996
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 11 Mar 2010 18:28:43 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AA1D245DE5D
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 18:28:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 757DF45DE51
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 18:28:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3323DE38003
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 18:28:42 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C50141DB803C
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 18:28:41 +0900 (JST)
Date: Thu, 11 Mar 2010 18:25:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v6)
Message-Id: <20100311182500.0f3ba994.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1268298865.5279.997.camel@twins>
References: <1268175636-4673-1-git-send-email-arighi@develer.com>
	<20100311093913.07c9ca8a.kamezawa.hiroyu@jp.fujitsu.com>
	<20100311101726.f58d24e9.kamezawa.hiroyu@jp.fujitsu.com>
	<1268298865.5279.997.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Mar 2010 10:14:25 +0100
Peter Zijlstra <peterz@infradead.org> wrote:

> On Thu, 2010-03-11 at 10:17 +0900, KAMEZAWA Hiroyuki wrote:
> > On Thu, 11 Mar 2010 09:39:13 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > The performance overhead is not so huge in both solutions, but the impact on
> > > > performance is even more reduced using a complicated solution...
> > > > 
> > > > Maybe we can go ahead with the simplest implementation for now and start to
> > > > think to an alternative implementation of the page_cgroup locking and
> > > > charge/uncharge of pages.
> 
> FWIW bit spinlocks suck massive.
> 
> > > 
> > > maybe. But in this 2 years, one of our biggest concerns was the performance.
> > > So, we do something complex in memcg. But complex-locking is , yes, complex.
> > > Hmm..I don't want to bet we can fix locking scheme without something complex.
> > > 
> > But overall patch set seems good (to me.) And dirty_ratio and dirty_background_ratio
> > will give us much benefit (of performance) than we lose by small overheads.
> 
> Well, the !cgroup or root case should really have no performance impact.
> 
> > IIUC, this series affects trgger for background-write-out.
> 
> Not sure though, while this does the accounting the actual writeout is
> still !cgroup aware and can definately impact performance negatively by
> shrinking too much.
> 

Ah, okay, your point is !cgroup (ROOT cgroup case.)
I don't think accounting these file cache status against root cgroup is necessary.


BTW, in other thread, I'm now proposing this style. 
==
+void mem_cgroup_update_stat(struct page *page, int idx, bool charge)
+{
+	struct page_cgroup *pc;
+
+	pc = lookup_page_cgroup(page);
+	if (unlikely(!pc))
+		return;
+
+	if (trylock_page_cgroup(pc)) {
+		__mem_cgroup_update_stat(pc, idx, charge);
+		unlock_page_cgroup(pc);
+	}
+	return;
==

Then, it's not problem that check pc->mem_cgroup is root cgroup or not
without spinlock.
==
void mem_cgroup_update_stat(struct page *page, int idx, bool charge)
{
	pc = lookup_page_cgroup(page);
	if (unlikely(!pc) || mem_cgroup_is_root(pc->mem_cgroup))
		return;	
	...
}
==
This can be handle in the same logic of "lock failure" path.
And we just do ignore accounting.

There are will be no spinlocks....to do more than this,
I think we have to use "struct page" rather than "struct page_cgroup".

Thanks,
-Kame








--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
