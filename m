Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id BE7DC6B0032
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 20:02:34 -0400 (EDT)
Date: Thu, 6 Jun 2013 20:02:22 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/2] memcg: do not sleep on OOM waitqueue with full
 charge context
Message-ID: <20130607000222.GT15576@cmpxchg.org>
References: <1370488193-4747-1-git-send-email-hannes@cmpxchg.org>
 <1370488193-4747-2-git-send-email-hannes@cmpxchg.org>
 <alpine.DEB.2.02.1306052058340.25115@chino.kir.corp.google.com>
 <20130606053315.GB9406@cmpxchg.org>
 <20130606173355.GB27226@cmpxchg.org>
 <alpine.DEB.2.02.1306061308320.9493@chino.kir.corp.google.com>
 <20130606215425.GM15721@cmpxchg.org>
 <alpine.DEB.2.02.1306061507330.15503@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1306061507330.15503@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jun 06, 2013 at 03:18:37PM -0700, David Rientjes wrote:
> On Thu, 6 Jun 2013, Johannes Weiner wrote:
> 
> > > I don't understand why memcg is unique in this regard and it doesn't 
> > > affect the page allocator as well on system oom conditions.  Ignoring 
> > > memecg, all allocating processes will loop forever in the page allocator 
> > > unless there are atypical gfp flags waiting for memory to be available, 
> > > only one will call the oom killer at a time, a process is selected and 
> > > killed, and the oom killer defers until that process exists because it 
> > > finds TIF_MEMDIE.  Why is memcg charging any different?
> > 
> > The allocator wakes up kswapd, global OOMs are rarer, with physical
> > memory the line to OOM is blurrier than with the memcg hard limit?
> > 
> > Anyway, I'm not aware of bug reports in the global case, but there are
> > bug reports for the memcg case and we have a decent understanding of
> > those deadlocks.  So can we stay focussed and fix this, please?
> > 
> 
> Could you point me to those bug reports?  As far as I know, we have never 
> encountered them so it would be surprising to me that we're running with a 
> potential landmine and have seemingly never hit it.

Sure thing: https://lkml.org/lkml/2012/11/21/497

During that thread Michal pinned down the problem to i_mutex being
held by the OOM invoking task, which the selected victim is trying to
acquire.

> > > > Reported-by: Reported-by: azurIt <azurit@pobox.sk>
> > > > Debugged-by: Michal Hocko <mhocko@suse.cz>
> > > > Reported-by: David Rientjes <rientjes@google.com>
> > > 
> > > What exactly did I report?  This isn't at all what 
> > > memory.oom_delay_millisecs is about, which is a failure of userspace to 
> > > respond to the condition and react in time, not because it's stuck on any 
> > > lock.  We still need that addition regardless of what you're doing here.
> > 
> > Oh, tell me how getting stuck indefinitely on a lock will not result
> > in "a failure to react in time".  This is some seriously misguided
> > pedantry.
> > 
> 
> It certainly would, but it's not the point that memory.oom_delay_millisecs 
> was intended to address.  memory.oom_delay_millisecs would simply delay 
> calling mem_cgroup_out_of_memory() unless userspace can't free memory or 
> increase the memory limit in time.  Obviously that delay isn't going to 
> magically address any lock dependency issues.

The delayed fallback would certainly resolve the issue of the
userspace handler getting stuck, be it due to memory shortness or due
to locks.

However, it would not solve the part of the problem where the OOM
killing kernel task is holding locks that the victim requires to exit.

We are definitely looking at multiple related issues, that's why I'm
trying to fix them step by step.

> > And yes, you talked about deadlocking potential other than the handler
> > itself OOMing, I quote from
> > <alpine.DEB.2.02.1305301338430.20389@chino.kir.corp.google.com>:
> > 
> > "Unresponsiveness isn't necessarily only because of memory
> >  constraints, you may have your oom notifier in a parent cgroup that
> >  isn't oom.  If a process is stuck on mm->mmap_sem in the oom cgroup,
> >  though, the oom notifier may not be able to scrape /proc/pid and
> >  attain necessary information in making an oom kill decision."
> > 
> > These are your words, and my patch sets out to fix the described
> > problem,
> 
> I can review this patch apart from memory.oom_delay_millisecs using the 
> examples in your changelog, but this isn't the problem statement for my 
> patch.  The paragraph above is describing one way that an oom handler may 
> encounter issues, it's not the only way and it's not a way that we have 
> ever faced on our production servers with memcg.  I just didn't think the 
> above was me reporting a bug, perhaps you took it that way.

Please do consider this fix individually.  It's good to know that you
didn't run into this particular issue on your machines so far, but
since you described the problem you must have arrived at the same
conclusion by just reading the code, which was good enough for me.
Again, I can just remove your Reported-by: if you don't think it's
justified.

> The point I'm trying to make is that your patch doesn't reduce our need 
> for memory.oom_delay_millisecs as described in the thread for that patch.

It does not.  But it does fix a problem that came up during the
discussion and it does fix a problem that you may hit at a random
point in time regardless of the memory.oom_delay_millisecs patch.

I'm sorry for the confusion this created, but yes, it's a separate
albeit related issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
