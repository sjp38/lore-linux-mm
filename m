Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9FF6B0031
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 07:41:46 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fb1so8264458pad.38
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 04:41:46 -0800 (PST)
Received: from psmtp.com ([74.125.245.148])
        by mx.google.com with SMTP id do3si6042019pbc.172.2013.11.19.04.41.42
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 04:41:43 -0800 (PST)
Date: Tue, 19 Nov 2013 13:41:38 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/2] mm, memcg: add memory.oom_control notification for
 system oom
Message-ID: <20131119124138.GB20655@dhcp22.suse.cz>
References: <20131031054942.GA26301@cmpxchg.org>
 <alpine.DEB.2.02.1311131416460.23211@chino.kir.corp.google.com>
 <20131113233419.GJ707@cmpxchg.org>
 <alpine.DEB.2.02.1311131649110.6735@chino.kir.corp.google.com>
 <20131114032508.GL707@cmpxchg.org>
 <alpine.DEB.2.02.1311141447160.21413@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1311141525440.30112@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1311141526300.30112@chino.kir.corp.google.com>
 <20131118185213.GA12923@dhcp22.suse.cz>
 <alpine.DEB.2.02.1311181722380.4292@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1311181722380.4292@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon 18-11-13 17:25:13, David Rientjes wrote:
> On Mon, 18 Nov 2013, Michal Hocko wrote:
> 
> > > A subset of applications that wait on memory.oom_control don't disable
> > > the oom killer for that memcg and simply log or cleanup after the kernel
> > > oom killer kills a process to free memory.
> > > 
> > > We need the ability to do this for system oom conditions as well, i.e.
> > > when the system is depleted of all memory and must kill a process.  For
> > > convenience, this can use memcg since oom notifiers are already present.
> > 
> > Using the memcg interface for "read-only" interface without any plan for
> > the "write" is only halfway solution. We want to handle global OOM in a
> > more user defined ways but we have to agree on the proper interface
> > first. I do not want to end up with something half baked with memcg and
> > a different interface to do the real thing just because memcg turns out
> > to be unsuitable.
> > 
> 
> This patch isn't really a halfway solution, you can still determine if the 
> open(O_WRONLY) succeeds or not to determine if that feature has been 
> implemented. 

Let's say that we end up using loadable modules for the user policy
driven OOM killer. And that one would implement its own way of
notification or even no notification at all. How would an unrelated
check for open on a memcg file help?

> I'm concerned about disabling the oom killer entirely for 
> system oom conditions, though, so I didn't implement it to be writable.

I really do not like to use different interfaces to accomplish the two
parts of the process. OOM action and notification should be implemented
by the same "subsystem" (be it memcg, modules, foobar...).

> I don't think we should be doing anything special in terms of "write"
> behavior for the root memcg memory.oom_control, so I'd argue against
> doing anything other than disabling the oom killer.  That's scary.

But we need to have a way to describe user/admin policy for the global
OOM. Killing a task is just one of the policy and there are usecases (as
discussed at LSF2013) where e.g. killing the whole group of processes
makes much more sense. And there are many other possible policies. What
is the proper interface is a question and we should discuss that
properly. Memcg interface is one of the possible ways. We can also go
with kernel modules or a more generic filter like interface with
userspace defined rules.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
