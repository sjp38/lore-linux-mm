Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BADD56B007B
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 17:31:21 -0500 (EST)
Date: Thu, 11 Feb 2010 14:31:05 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 4/7 -mm] oom: badness heuristic rewrite
Message-Id: <20100211143105.dea3861a.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1002111346050.8809@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002100228540.8001@chino.kir.corp.google.com>
	<4B73833D.5070008@redhat.com>
	<alpine.DEB.2.00.1002102332200.22152@chino.kir.corp.google.com>
	<20100211134343.4886499c.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1002111346050.8809@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Feb 2010 13:51:36 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Thu, 11 Feb 2010, Andrew Morton wrote:
> 
> > > Changing any value that may have a tendency to be hardcoded elsewhere is 
> > > always controversial, but I think the nature of /proc/pid/oom_adj allows 
> > > us to do so for two specific reasons:
> > > 
> > >  - hardcoded values tend not the fall within a range, they tend to either
> > >    always prefer a certain task for oom kill first or disable oom killing
> > >    entirely.  The current implementation uses this as a bitshift on a
> > >    seemingly unpredictable and unscientific heuristic that is very 
> > >    difficult to predict at runtime.  This means that fewer and fewer
> > >    applications would hardcode a value of '8', for example, because its 
> > >    semantics depends entirely on RAM capacity of the system to begin with
> > >    since badness() scores are only useful when used in comparison with
> > >    other tasks.
> > 
> > You'd be amazed what dumb things applications do.  Get thee to
> > http://google.com/codesearch?hl=en&lr=&q=[^a-z]oom_adj[^a-z]&sbtn=Search
> > and start reading.  All 641 matches ;)
> > 
> > Here's one which which writes -16:
> > http://google.com/codesearch/p?hl=en#eN5TNOm7KtI/trunk/wlan/vendor/asus/eeepc/init.rc&q=[^a-z]oom_adj[^a-z]&sa=N&cd=70&ct=rc
> > 
> > Let's not change the ABI please.
> > 
> 
> Sigh, this is going to require the amount of system memory to be 
> partitioned into OOM_ADJUST_MAX, 15, chunks and that's going to be the 
> granularity at which we'll be able to either bias or discount memory usage 
> of individual tasks by: instead of being able to do this with 0.1% 
> granularity we'll now be limited to 100 / 15, or ~7%.  That's ~9GB on my 
> 128GB system just because this was originally a bitshift.  The upside is 
> that it's now linear and not exponential.

Can you add newly-named knobs (rather than modifying the existing
ones), deprecate the old ones and then massage writes to the old ones
so that they talk into the new framework?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
