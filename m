Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DCCEB6B0047
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 16:43:51 -0500 (EST)
Date: Thu, 11 Feb 2010 13:43:43 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 4/7 -mm] oom: badness heuristic rewrite
Message-Id: <20100211134343.4886499c.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1002102332200.22152@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002100228540.8001@chino.kir.corp.google.com>
	<4B73833D.5070008@redhat.com>
	<alpine.DEB.2.00.1002102332200.22152@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Feb 2010 01:14:43 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 10 Feb 2010, Rik van Riel wrote:
> 
> > > OOM_ADJUST_MIN and OOM_ADJUST_MAX have been exported to userspace since
> > > 2006 via include/linux/oom.h.  This alters their values from -16 to -1000
> > > and from +15 to +1000, respectively.
> > 
> > That seems like a bad idea.  Google may have the luxury of
> > being able to recompile all its in-house applications, but
> > this will not be true for many other users of /proc/<pid>/oom_adj
> > 
> 
> Changing any value that may have a tendency to be hardcoded elsewhere is 
> always controversial, but I think the nature of /proc/pid/oom_adj allows 
> us to do so for two specific reasons:
> 
>  - hardcoded values tend not the fall within a range, they tend to either
>    always prefer a certain task for oom kill first or disable oom killing
>    entirely.  The current implementation uses this as a bitshift on a
>    seemingly unpredictable and unscientific heuristic that is very 
>    difficult to predict at runtime.  This means that fewer and fewer
>    applications would hardcode a value of '8', for example, because its 
>    semantics depends entirely on RAM capacity of the system to begin with
>    since badness() scores are only useful when used in comparison with
>    other tasks.

You'd be amazed what dumb things applications do.  Get thee to
http://google.com/codesearch?hl=en&lr=&q=[^a-z]oom_adj[^a-z]&sbtn=Search
and start reading.  All 641 matches ;)

Here's one which which writes -16:
http://google.com/codesearch/p?hl=en#eN5TNOm7KtI/trunk/wlan/vendor/asus/eeepc/init.rc&q=[^a-z]oom_adj[^a-z]&sa=N&cd=70&ct=rc

Let's not change the ABI please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
