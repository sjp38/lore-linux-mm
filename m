Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 29B9C6B01DC
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 10:39:20 -0400 (EDT)
Date: Mon, 15 Mar 2010 10:38:41 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v6)
Message-ID: <20100315143841.GE21127@redhat.com>
References: <1268175636-4673-1-git-send-email-arighi@develer.com> <20100311093913.07c9ca8a.kamezawa.hiroyu@jp.fujitsu.com> <20100311101726.f58d24e9.kamezawa.hiroyu@jp.fujitsu.com> <1268298865.5279.997.camel@twins> <20100311182500.0f3ba994.kamezawa.hiroyu@jp.fujitsu.com> <20100311150307.GC29246@redhat.com> <20100312084230.850f331d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100312084230.850f331d.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 12, 2010 at 08:42:30AM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 11 Mar 2010 10:03:07 -0500
> Vivek Goyal <vgoyal@redhat.com> wrote:
> 
> > On Thu, Mar 11, 2010 at 06:25:00PM +0900, KAMEZAWA Hiroyuki wrote:
> > > On Thu, 11 Mar 2010 10:14:25 +0100
> > > Peter Zijlstra <peterz@infradead.org> wrote:
> > > 
> > > > On Thu, 2010-03-11 at 10:17 +0900, KAMEZAWA Hiroyuki wrote:
> > > > > On Thu, 11 Mar 2010 09:39:13 +0900
> > > > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > > > > The performance overhead is not so huge in both solutions, but the impact on
> > > > > > > performance is even more reduced using a complicated solution...
> > > > > > > 
> > > > > > > Maybe we can go ahead with the simplest implementation for now and start to
> > > > > > > think to an alternative implementation of the page_cgroup locking and
> > > > > > > charge/uncharge of pages.
> > > > 
> > > > FWIW bit spinlocks suck massive.
> > > > 
> > > > > > 
> > > > > > maybe. But in this 2 years, one of our biggest concerns was the performance.
> > > > > > So, we do something complex in memcg. But complex-locking is , yes, complex.
> > > > > > Hmm..I don't want to bet we can fix locking scheme without something complex.
> > > > > > 
> > > > > But overall patch set seems good (to me.) And dirty_ratio and dirty_background_ratio
> > > > > will give us much benefit (of performance) than we lose by small overheads.
> > > > 
> > > > Well, the !cgroup or root case should really have no performance impact.
> > > > 
> > > > > IIUC, this series affects trgger for background-write-out.
> > > > 
> > > > Not sure though, while this does the accounting the actual writeout is
> > > > still !cgroup aware and can definately impact performance negatively by
> > > > shrinking too much.
> > > > 
> > > 
> > > Ah, okay, your point is !cgroup (ROOT cgroup case.)
> > > I don't think accounting these file cache status against root cgroup is necessary.
> > > 
> > 
> > I think what peter meant was that with memory cgroups created we will do
> > writeouts much more aggressively.
> > 
> > In balance_dirty_pages()
> > 
> > 	if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
> > 		break;
> > 
> > Now with Andrea's patches, we are calculating bdi_thres per memory cgroup
> > (almost)
> hmm.
> 
> > 
> > bdi_thres ~= per_memory_cgroup_dirty * bdi_fraction
> > 
> > But bdi_nr_reclaimable and bdi_nr_writeback stats are still global.
> > 
> Why bdi_thresh of ROOT cgroup doesn't depend on global number ?
> 

I think in current implementation ROOT cgroup bdi_thres is always same
as global number. It is only for other child groups where it is different
from global number because of reduced dirytable_memory() limit. And we
don't seem to be allowing any control on root group. 

But I am wondering, what happens in following case.

IIUC, with use_hierarhy=0, if I create two test groups test1 and test2, then
hierarchy looks as follows.

			root  test1  test2

Now root group's DIRTYABLE is still system wide but test1 and test2's
dirtyable will be reduced based on RES_LIMIT in those groups.

Conceptually, per cgroup dirty ratio is like fixing page cache share of
each group. So effectively we are saying that these limits apply to only
child group of root but not to root as such?
 
> > So for the same number of dirty pages system wide on this bdi, we will be
> > triggering writeouts much more aggressively if somebody has created few
> > memory cgroups and tasks are running in those cgroups.
> > 
> > I guess it might cause performance regressions in case of small file
> > writeouts because previously one could have written the file to cache and
> > be done with it but with this patch set, there are higher changes that
> > you will be throttled to write the pages back to disk.
> > 
> > I guess we need two pieces to resolve this.
> > 	- BDI stats per cgroup.
> > 	- Writeback of inodes from same cgroup.
> > 
> > I think BDI stats per cgroup will increase the complextiy.
> > 
> Thank you for clarification. IIUC, dirty_limit implemanation shoul assume
> there is I/O resource controller, maybe usual users will use I/O resource
> controller and memcg at the same time.
> Then, my question is what happens when used with I/O resource controller ?
> 

Currently IO resource controller keep all the async IO queues in root
group so we can't measure exactly. But my guess is until and unless we
at least implement "writeback inodes from same cgroup" we will not see
increased flow of writes from one cgroup over other cgroup.

Thanks
Vivek

> 
> > I am still setting up the system to test whether we see any speedup in
> > writeout of large files with-in a memory cgroup with small memory limits.
> > I am assuming that we are expecting a speedup because we will start
> > writeouts early and background writeouts probably are faster than direct
> > reclaim?
> > 
> Yes. I think so. 
> 
> Thanks,
> -Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
