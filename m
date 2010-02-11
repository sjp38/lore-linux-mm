Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7424C6B0047
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 18:12:14 -0500 (EST)
Date: Thu, 11 Feb 2010 15:11:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 4/7 -mm] oom: badness heuristic rewrite
Message-Id: <20100211151135.91586cd1.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1002111437060.21107@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002100228540.8001@chino.kir.corp.google.com>
	<4B73833D.5070008@redhat.com>
	<alpine.DEB.2.00.1002102332200.22152@chino.kir.corp.google.com>
	<20100211134343.4886499c.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1002111346050.8809@chino.kir.corp.google.com>
	<20100211143105.dea3861a.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1002111437060.21107@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Feb 2010 14:42:39 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Thu, 11 Feb 2010, Andrew Morton wrote:
> 
> > > Sigh, this is going to require the amount of system memory to be 
> > > partitioned into OOM_ADJUST_MAX, 15, chunks and that's going to be the 
> > > granularity at which we'll be able to either bias or discount memory usage 
> > > of individual tasks by: instead of being able to do this with 0.1% 
> > > granularity we'll now be limited to 100 / 15, or ~7%.  That's ~9GB on my 
> > > 128GB system just because this was originally a bitshift.  The upside is 
> > > that it's now linear and not exponential.
> > 
> > Can you add newly-named knobs (rather than modifying the existing
> > ones), deprecate the old ones and then massage writes to the old ones
> > so that they talk into the new framework?
> > 
> 
> That's what I was thinking, add /proc/pid/oom_score_adj that is just added 
> into the badness score (and is then exported with /proc/pid/oom_score) 
> like this patch did with oom_adj and then scale it into oom_adj units for 
> that tunable.  A write to either oom_adj or oom_score_adj would change the 
> other,

How ugly is all this?

> the same thing I did for /proc/sys/vm/dirty_{bytes,ratio} and
> /proc/sys/vm/dirty_background_{bytes,ratio} which I guess we have to 
> support forever since the predecessors are part of the ABI and there's no 
> way to deprecate them since they'll never be removed for that reason.

Ah, OK, I was trying to remember where we did that ;)

There _are_ things we can do though.  Detect a write to the old file and
emit a WARN_ON_ONCE("you suck").  Wait a year, turn it into
WARN_ON("you really suck").  Wait a year, then remove it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
