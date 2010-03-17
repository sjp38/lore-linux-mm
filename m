Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id CEE95600368
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 18:32:27 -0400 (EDT)
Date: Wed, 17 Mar 2010 23:32:22 +0100
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v6)
Message-ID: <20100317223222.GA8467@linux.develer.com>
References: <1268175636-4673-1-git-send-email-arighi@develer.com>
 <20100311093913.07c9ca8a.kamezawa.hiroyu@jp.fujitsu.com>
 <20100311101726.f58d24e9.kamezawa.hiroyu@jp.fujitsu.com>
 <1268298865.5279.997.camel@twins>
 <20100311182500.0f3ba994.kamezawa.hiroyu@jp.fujitsu.com>
 <20100311150307.GC29246@redhat.com>
 <20100312084230.850f331d.kamezawa.hiroyu@jp.fujitsu.com>
 <20100315143841.GE21127@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100315143841.GE21127@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Vivek Goyal <vgoyal@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 15, 2010 at 10:38:41AM -0400, Vivek Goyal wrote:
> > > 
> > > bdi_thres ~= per_memory_cgroup_dirty * bdi_fraction
> > > 
> > > But bdi_nr_reclaimable and bdi_nr_writeback stats are still global.
> > > 
> > Why bdi_thresh of ROOT cgroup doesn't depend on global number ?
> > 
> 
> I think in current implementation ROOT cgroup bdi_thres is always same
> as global number. It is only for other child groups where it is different
> from global number because of reduced dirytable_memory() limit. And we
> don't seem to be allowing any control on root group. 
> 
> But I am wondering, what happens in following case.
> 
> IIUC, with use_hierarhy=0, if I create two test groups test1 and test2, then
> hierarchy looks as follows.
> 
> 			root  test1  test2
> 
> Now root group's DIRTYABLE is still system wide but test1 and test2's
> dirtyable will be reduced based on RES_LIMIT in those groups.
> 
> Conceptually, per cgroup dirty ratio is like fixing page cache share of
> each group. So effectively we are saying that these limits apply to only
> child group of root but not to root as such?

Correct. In this implementation root cgroup means "outside all cgroups".
I think this can be an acceptable behaviour since in general we don't
set any limit to the root cgroup.

>  
> > > So for the same number of dirty pages system wide on this bdi, we will be
> > > triggering writeouts much more aggressively if somebody has created few
> > > memory cgroups and tasks are running in those cgroups.
> > > 
> > > I guess it might cause performance regressions in case of small file
> > > writeouts because previously one could have written the file to cache and
> > > be done with it but with this patch set, there are higher changes that
> > > you will be throttled to write the pages back to disk.
> > > 
> > > I guess we need two pieces to resolve this.
> > > 	- BDI stats per cgroup.
> > > 	- Writeback of inodes from same cgroup.
> > > 
> > > I think BDI stats per cgroup will increase the complextiy.
> > > 
> > Thank you for clarification. IIUC, dirty_limit implemanation shoul assume
> > there is I/O resource controller, maybe usual users will use I/O resource
> > controller and memcg at the same time.
> > Then, my question is what happens when used with I/O resource controller ?
> > 
> 
> Currently IO resource controller keep all the async IO queues in root
> group so we can't measure exactly. But my guess is until and unless we
> at least implement "writeback inodes from same cgroup" we will not see
> increased flow of writes from one cgroup over other cgroup.

Agreed. And I plan to look a the "writeback inodes per cgroup" feature
soon. I'm sorry but I've some deadlines this week, so probably I'll
start working on this in the next weekend.

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
