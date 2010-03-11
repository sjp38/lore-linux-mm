Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 465A16B00FD
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 18:46:12 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2BNk91I004747
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Mar 2010 08:46:09 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 191C745DE52
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 08:46:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E541A45DE51
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 08:46:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C4F2B1DB803E
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 08:46:08 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 607461DB803B
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 08:46:08 +0900 (JST)
Date: Fri, 12 Mar 2010 08:42:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v6)
Message-Id: <20100312084230.850f331d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100311150307.GC29246@redhat.com>
References: <1268175636-4673-1-git-send-email-arighi@develer.com>
	<20100311093913.07c9ca8a.kamezawa.hiroyu@jp.fujitsu.com>
	<20100311101726.f58d24e9.kamezawa.hiroyu@jp.fujitsu.com>
	<1268298865.5279.997.camel@twins>
	<20100311182500.0f3ba994.kamezawa.hiroyu@jp.fujitsu.com>
	<20100311150307.GC29246@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Mar 2010 10:03:07 -0500
Vivek Goyal <vgoyal@redhat.com> wrote:

> On Thu, Mar 11, 2010 at 06:25:00PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Thu, 11 Mar 2010 10:14:25 +0100
> > Peter Zijlstra <peterz@infradead.org> wrote:
> > 
> > > On Thu, 2010-03-11 at 10:17 +0900, KAMEZAWA Hiroyuki wrote:
> > > > On Thu, 11 Mar 2010 09:39:13 +0900
> > > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > > > The performance overhead is not so huge in both solutions, but the impact on
> > > > > > performance is even more reduced using a complicated solution...
> > > > > > 
> > > > > > Maybe we can go ahead with the simplest implementation for now and start to
> > > > > > think to an alternative implementation of the page_cgroup locking and
> > > > > > charge/uncharge of pages.
> > > 
> > > FWIW bit spinlocks suck massive.
> > > 
> > > > > 
> > > > > maybe. But in this 2 years, one of our biggest concerns was the performance.
> > > > > So, we do something complex in memcg. But complex-locking is , yes, complex.
> > > > > Hmm..I don't want to bet we can fix locking scheme without something complex.
> > > > > 
> > > > But overall patch set seems good (to me.) And dirty_ratio and dirty_background_ratio
> > > > will give us much benefit (of performance) than we lose by small overheads.
> > > 
> > > Well, the !cgroup or root case should really have no performance impact.
> > > 
> > > > IIUC, this series affects trgger for background-write-out.
> > > 
> > > Not sure though, while this does the accounting the actual writeout is
> > > still !cgroup aware and can definately impact performance negatively by
> > > shrinking too much.
> > > 
> > 
> > Ah, okay, your point is !cgroup (ROOT cgroup case.)
> > I don't think accounting these file cache status against root cgroup is necessary.
> > 
> 
> I think what peter meant was that with memory cgroups created we will do
> writeouts much more aggressively.
> 
> In balance_dirty_pages()
> 
> 	if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
> 		break;
> 
> Now with Andrea's patches, we are calculating bdi_thres per memory cgroup
> (almost)
hmm.

> 
> bdi_thres ~= per_memory_cgroup_dirty * bdi_fraction
> 
> But bdi_nr_reclaimable and bdi_nr_writeback stats are still global.
> 
Why bdi_thresh of ROOT cgroup doesn't depend on global number ?

> So for the same number of dirty pages system wide on this bdi, we will be
> triggering writeouts much more aggressively if somebody has created few
> memory cgroups and tasks are running in those cgroups.
> 
> I guess it might cause performance regressions in case of small file
> writeouts because previously one could have written the file to cache and
> be done with it but with this patch set, there are higher changes that
> you will be throttled to write the pages back to disk.
> 
> I guess we need two pieces to resolve this.
> 	- BDI stats per cgroup.
> 	- Writeback of inodes from same cgroup.
> 
> I think BDI stats per cgroup will increase the complextiy.
> 
Thank you for clarification. IIUC, dirty_limit implemanation shoul assume
there is I/O resource controller, maybe usual users will use I/O resource
controller and memcg at the same time.
Then, my question is what happens when used with I/O resource controller ?


> I am still setting up the system to test whether we see any speedup in
> writeout of large files with-in a memory cgroup with small memory limits.
> I am assuming that we are expecting a speedup because we will start
> writeouts early and background writeouts probably are faster than direct
> reclaim?
> 
Yes. I think so. 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
