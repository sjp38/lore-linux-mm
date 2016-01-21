Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 28F4C6B0005
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 04:15:19 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id cy9so20225499pac.0
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 01:15:19 -0800 (PST)
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com. [209.85.220.45])
        by mx.google.com with ESMTPS id mk9si739365pab.101.2016.01.21.01.15.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jan 2016 01:15:18 -0800 (PST)
Received: by mail-pa0-f45.google.com with SMTP id ho8so20155409pac.2
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 01:15:18 -0800 (PST)
Date: Thu, 21 Jan 2016 10:15:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 1/3] oom, sysrq: Skip over oom victims and killed tasks
Message-ID: <20160121091515.GC29520@dhcp22.suse.cz>
References: <1452632425-20191-2-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1601121639450.28831@chino.kir.corp.google.com>
 <20160113093046.GA28942@dhcp22.suse.cz>
 <alpine.DEB.2.10.1601131633550.3406@chino.kir.corp.google.com>
 <20160114110037.GC29943@dhcp22.suse.cz>
 <alpine.DEB.2.10.1601141347220.16227@chino.kir.corp.google.com>
 <20160115101218.GB14112@dhcp22.suse.cz>
 <alpine.DEB.2.10.1601191454160.7346@chino.kir.corp.google.com>
 <20160120094938.GB14187@dhcp22.suse.cz>
 <alpine.DEB.2.10.1601201550060.18155@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1601201550060.18155@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Wed 20-01-16 16:01:54, David Rientjes wrote:
> On Wed, 20 Jan 2016, Michal Hocko wrote:
> 
> > No, I do not have a specific load in mind. But let's be realistic. There
> > will _always_ be corner cases where the VM cannot react properly or in a
> > timely fashion.
> > 
> 
> Then let's identify it and fix it, like we do with any other bug?  I'm 99% 
> certain you are not advocating that human intervention is the ideal 
> solution to prevent lengthy stalls or livelocks.

I didn't claim that! Please read what I have written. I consider sysrq+f
as a _last resort_ emergency tool when the system doesn't behave in the
expected way.

> I can't speak for all possible configurations and workloads; the only 
> thing we use sysrq+f for is automated testing of the oom killer itself.  

That is your use case and it is not the one why the this functionality
has been introduced. This is _not a debuggin_ tool. Back in 2005 it has
been added precisely to allow for an immediate intervention while the
system was trashing heavily.

> It would help to know of any situations when people actually need to use 
> this to solve issues and then fix those issues rather than insisting that 
> this is the ideal solution.

I fully agree that such an issues should be investigated and fixed. That
is nothing against having the emergency tool and allow the admin to
intervene right away when it happens.

> > To be honest I really fail to understand your line of argumentation
> > here. Just that you think that sysrq+f might be not helpful in large
> > datacenters which you seem to care about, doesn't mean that it is not
> > helpful in other setups.
> > 
> 
> This type of message isn't really contributing anything.  You don't have a 
> specific load in mind, you can't identify a pending bug that people have 
> complained about, you presumably can't show a testcase that demonstrates 
> how it's required, yet you're arguing that we should keep a debugging tool 
> around because you think somebody somewhere sometime might use it.

Look, I am getting tired of this discussion. You seem to completely
ignore the emergency aspect of sysrq+f just because it doesn't seem to
fit in _your_ particular usecase. I have seen admins using sysrq+f when
a large application got crazy and started trashing to the point when
even ssh to the machine took ages and sysrq+f over serial console was
the only deterministic way to make the system usable. Such things are
still real. Just look at linux-mm ML (just off hand
http://lkml.kernel.org/r/20151221123557.GE3060%40orkisz). You can argue
we should fix them, and I agree but swap/page cache trashing are real
for ages and those are hard problems and very likely to be with us for
some more. Until our MM subsystem and all others that might interfere
are perfect we need a sledge hammer. And if we have a hammer then we
should really make sure it hits something when used rather than hitting
the thin air.

The patch proposed here doesn't make the code more complicated or harder
to maintain. It even doesn't have any side effects outside of sysrq+f
triggered OOM. Your only argument so far was:
"
: It certainly would get TIF_MEMDIE set if it needs to allocate memory
: itself and it calls the oom killer.  That doesn't mean that we should
: kill a different process, though, when the killed process should exit
: and free its memory.  So NACK to the fatal_signal_pending() check here.
"

And that argument is fundamentally broken because killed process is not
guaranteed to exit and free its memory. Moreover sysrq+f is by
definition an async action which might race by passing killed task and
that should deactivate it. The race is quite unlikely but emergency
tools should be as robust/reliable as possible. You also have ignored
my question about what kind of regression would such a change cause.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
