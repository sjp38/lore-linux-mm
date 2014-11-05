Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5543C6B0074
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 08:31:04 -0500 (EST)
Received: by mail-lb0-f177.google.com with SMTP id z12so629310lbi.22
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 05:31:03 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 6si6035697lav.119.2014.11.05.05.31.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Nov 2014 05:31:02 -0800 (PST)
Date: Wed, 5 Nov 2014 14:31:00 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/4] OOM, PM: OOM killed task shouldn't escape PM suspend
Message-ID: <20141105133100.GC4527@dhcp22.suse.cz>
References: <1413876435-11720-1-git-send-email-mhocko@suse.cz>
 <2156351.pWp6MNRoWm@vostro.rjw.lan>
 <20141021141159.GE9415@dhcp22.suse.cz>
 <4766859.KSKPTm3b0x@vostro.rjw.lan>
 <20141021142939.GG9415@dhcp22.suse.cz>
 <20141104192705.GA22163@htj.dyndns.org>
 <20141105124620.GB4527@dhcp22.suse.cz>
 <20141105130247.GA14386@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141105130247.GA14386@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Wed 05-11-14 08:02:47, Tejun Heo wrote:
> Hello, Michal.
> 
> On Wed, Nov 05, 2014 at 01:46:20PM +0100, Michal Hocko wrote:
> > As I've said I wasn't entirely happy with this half solution but it helped
> > the current situation at the time. The full solution would require to
> 
> I don't think this helps the situation.  It just makes the bug more
> obscure and the race window while reduced is still pretty big and
> there seems to be an actual not too low chance of the bug triggering
> out in the wild.  How does this level of obscuring help anything?  In
> addition to making the bug more difficult to reproduce, it also adds a
> bunch of code which *pretends* to address the issue but ultimately
> just lowers visibility into what's going on and hinders tracking down
> the issue when something actually goes wrong.  This is *NOT* making
> the situation better.  The patch is net negative.

The patch was a compromise. It was needed to catch the most common
OOM conditions while the tasks are getting frozen. The race window
between the counter increment and the check in the PM path is negligible
compared to the freezing process. And it is safe from OOM point of view
because nothing can block it away.

> > I think the patch below should be safe. Would you prefer this solution
> > instead? It is race free but there is the risk that exposing a lock which
> 
> Yes, this is an a lot saner approach in general.
> 
> > completely blocks OOM killer from the allocation path will kick us
> > later.
> 
> Can you please spell it out?  How would it kick us?  We already have
> oom_killer_disable/enable(), how is this any different in terms of
> correctness from them? 

As already said in the part of email you haven't quoted.
oom_killer_disable will cause allocations to _fail_. With the lock you are
_blocking_ OOM killer completely. This is error prone because no part of
system should be able to block the last resort memory shortage actions.

> Also, why isn't this part of
> oom_killer_disable/enable()?  The way they're implemented is really
> silly now.  It just sets a flag and returns whether there's a
> currently running instance or not.  How were these even useful? 
> Why can't you just make disable/enable to what they were supposed to
> do from the beginning?

Because then we would block all the potential allocators coming from
workqueues or kernel threads which are not frozen yet rather than fail
the allocation. I am not familiar with the PM code and all the paths
this might get called from enough to tell whether failing the allocation
is better approach than failing the suspend operation on a timeout.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
