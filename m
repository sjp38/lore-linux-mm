Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 492EB6B0036
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 17:54:36 -0400 (EDT)
Date: Thu, 6 Jun 2013 17:54:25 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/2] memcg: do not sleep on OOM waitqueue with full
 charge context
Message-ID: <20130606215425.GM15721@cmpxchg.org>
References: <1370488193-4747-1-git-send-email-hannes@cmpxchg.org>
 <1370488193-4747-2-git-send-email-hannes@cmpxchg.org>
 <alpine.DEB.2.02.1306052058340.25115@chino.kir.corp.google.com>
 <20130606053315.GB9406@cmpxchg.org>
 <20130606173355.GB27226@cmpxchg.org>
 <alpine.DEB.2.02.1306061308320.9493@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1306061308320.9493@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jun 06, 2013 at 01:11:32PM -0700, David Rientjes wrote:
> On Thu, 6 Jun 2013, Johannes Weiner wrote:
> 
> > > If the killing task or one of the sleeping tasks is holding a lock
> > > that the selected victim needs in order to exit no progress can be
> > > made.
> > > 
> > > The report we had a few months ago was that a task held the i_mutex
> > > when trying to charge a page cache page and then invoked the OOM
> > > handler and looped on CHARGE_RETRY.  Meanwhile, the selected victim
> > > was just entering truncate() and now stuck waiting for the i_mutex.
> > > 
> > > I'll add this scenario to the changelog, hopefully it will make the
> > > rest a little clearer.
> > 
> > David, is the updated patch below easier to understand?
> > 
> 
> I don't understand why memcg is unique in this regard and it doesn't 
> affect the page allocator as well on system oom conditions.  Ignoring 
> memecg, all allocating processes will loop forever in the page allocator 
> unless there are atypical gfp flags waiting for memory to be available, 
> only one will call the oom killer at a time, a process is selected and 
> killed, and the oom killer defers until that process exists because it 
> finds TIF_MEMDIE.  Why is memcg charging any different?

The allocator wakes up kswapd, global OOMs are rarer, with physical
memory the line to OOM is blurrier than with the memcg hard limit?

Anyway, I'm not aware of bug reports in the global case, but there are
bug reports for the memcg case and we have a decent understanding of
those deadlocks.  So can we stay focussed and fix this, please?

> > Reported-by: Reported-by: azurIt <azurit@pobox.sk>
> > Debugged-by: Michal Hocko <mhocko@suse.cz>
> > Reported-by: David Rientjes <rientjes@google.com>
> 
> What exactly did I report?  This isn't at all what 
> memory.oom_delay_millisecs is about, which is a failure of userspace to 
> respond to the condition and react in time, not because it's stuck on any 
> lock.  We still need that addition regardless of what you're doing here.

Oh, tell me how getting stuck indefinitely on a lock will not result
in "a failure to react in time".  This is some seriously misguided
pedantry.

And yes, you talked about deadlocking potential other than the handler
itself OOMing, I quote from
<alpine.DEB.2.02.1305301338430.20389@chino.kir.corp.google.com>:

"Unresponsiveness isn't necessarily only because of memory
 constraints, you may have your oom notifier in a parent cgroup that
 isn't oom.  If a process is stuck on mm->mmap_sem in the oom cgroup,
 though, the oom notifier may not be able to scrape /proc/pid and
 attain necessary information in making an oom kill decision."

These are your words, and my patch sets out to fix the described
problem, so I figured the Reported-by: might be appropriate.  But I
can remove it if you like.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
