Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1F05F6B005A
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 23:25:14 -0400 (EDT)
Date: Wed, 12 Aug 2009 11:34:30 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: Help Resource Counters Scale better (v4)
Message-Id: <20090812113430.f69e7be9.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090811163159.ddc5f5fd.akpm@linux-foundation.org>
References: <20090811144405.GW7176@balbir.in.ibm.com>
	<20090811163159.ddc5f5fd.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: balbir@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, menage@google.com, prarit@redhat.com, andi.kleen@intel.com, xemul@openvz.org, lizf@cn.fujitsu.com, nishimura@mxp.nes.nec.co.jp, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 11 Aug 2009 16:31:59 -0700, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Tue, 11 Aug 2009 20:14:05 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > Enhancement: Remove the overhead of root based resource counter accounting
> > 
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > 
> > This patch reduces the resource counter overhead (mostly spinlock)
> > associated with the root cgroup. This is a part of the several
> > patches to reduce mem cgroup overhead. I had posted other
> > approaches earlier (including using percpu counters). Those
> > patches will be a natural addition and will be added iteratively
> > on top of these.
> > 
> > The patch stops resource counter accounting for the root cgroup.
> > The data for display is derived from the statisitcs we maintain
> > via mem_cgroup_charge_statistics (which is more scalable).
> > 
> > The tests results I see on a 24 way show that
> > 
> > 1. The lock contention disappears from /proc/lock_stats
> > 2. The results of the test are comparable to running with
> >    cgroup_disable=memory.
> > 
> > Please test/review.
> 
> I don't get it.
> 
> The patch apepars to skip accounting altogether for the root memcgroup
> and then adds some accounting back in for swap.  Or something like
> that.  How come?  Do we actually not need the root memcgroup
> accounting?
> 
IIUC, this patch doesn't remove the root memcgroup accounting, it just changes
the counter for root memcgroup accounting from res_counter to cpustat[cpu] to reduce
the lock congestion of res_counter especially on a big platform.
Using res_counter(lock, check limit, charge) for root memcgroup would be overkill
because root memcgroup has no limit now(by memcg-remove-the-overhead-associated-with-the-root-cgroup.patch).
And, MEM_CGROUP_STAT_SWAPOUT would be needed to show memsw.usage_in_bytes of root
memcgroup. We didn't have cpustat[cpu] counter for swap accounting so far.

> IOW, the changelog sucks ;)
> 
> Is this an alternative approach to using percpu_counters, or do we do
> both or do we choose one or the other?  res_counter_charge() really is
> quite sucky.
> 
> The patch didn't have a signoff.
> 
> It would be nice to finalise those performance testing results and
> include them in the new, improved patch description.
> 
agreed.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
