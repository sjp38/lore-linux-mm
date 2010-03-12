Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 15E466B0109
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 19:33:37 -0500 (EST)
Date: Fri, 12 Mar 2010 01:33:32 +0100
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v6)
Message-ID: <20100312003331.GA4134@linux>
References: <1268175636-4673-1-git-send-email-arighi@develer.com>
 <20100311093913.07c9ca8a.kamezawa.hiroyu@jp.fujitsu.com>
 <20100311101726.f58d24e9.kamezawa.hiroyu@jp.fujitsu.com>
 <1268298865.5279.997.camel@twins>
 <20100311182500.0f3ba994.kamezawa.hiroyu@jp.fujitsu.com>
 <20100311150307.GC29246@redhat.com>
 <20100312084230.850f331d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100312084230.850f331d.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
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

Very true. mem_cgroup_has_dirty_limit() must always return false in case
of root cgroup, so that global numbers are used.

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
