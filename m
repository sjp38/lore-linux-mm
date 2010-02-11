Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id ADF5F6B0071
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 04:14:54 -0500 (EST)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id o1B9Emxi001684
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 09:14:48 GMT
Received: from pxi17 (pxi17.prod.google.com [10.243.27.17])
	by wpaz33.hot.corp.google.com with ESMTP id o1B9EkC1026948
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 01:14:46 -0800
Received: by pxi17 with SMTP id 17so671563pxi.30
        for <linux-mm@kvack.org>; Thu, 11 Feb 2010 01:14:46 -0800 (PST)
Date: Thu, 11 Feb 2010 01:14:43 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 4/7 -mm] oom: badness heuristic rewrite
In-Reply-To: <4B73833D.5070008@redhat.com>
Message-ID: <alpine.DEB.2.00.1002102332200.22152@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com> <alpine.DEB.2.00.1002100228540.8001@chino.kir.corp.google.com> <4B73833D.5070008@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 10 Feb 2010, Rik van Riel wrote:

> > OOM_ADJUST_MIN and OOM_ADJUST_MAX have been exported to userspace since
> > 2006 via include/linux/oom.h.  This alters their values from -16 to -1000
> > and from +15 to +1000, respectively.
> 
> That seems like a bad idea.  Google may have the luxury of
> being able to recompile all its in-house applications, but
> this will not be true for many other users of /proc/<pid>/oom_adj
> 

Changing any value that may have a tendency to be hardcoded elsewhere is 
always controversial, but I think the nature of /proc/pid/oom_adj allows 
us to do so for two specific reasons:

 - hardcoded values tend not the fall within a range, they tend to either
   always prefer a certain task for oom kill first or disable oom killing
   entirely.  The current implementation uses this as a bitshift on a
   seemingly unpredictable and unscientific heuristic that is very 
   difficult to predict at runtime.  This means that fewer and fewer
   applications would hardcode a value of '8', for example, because its 
   semantics depends entirely on RAM capacity of the system to begin with
   since badness() scores are only useful when used in comparison with
   other tasks.

 - the badness() heuristic is radically changed from what it is currently
   so this gives applications that hardcoded /proc/pid/oom_adj values into
   their software a reason to notice the change and adjust to the new
   semantics of the badness score.  Using /proc/pid/oom_adj as a bitshift
   has no real application to any sane heuristic that represents scores in
   units of meaning, so users should end up with a net benefit of the
   change by being able to better tune the oom killing behavior with a
   much more powerful and easier to understand heuristic that requires
   them to recalculate exactly what oom_adj should be for any given
   application in terms of real units and business goals.

As mentioned in the changelog, we've exported these minimum and maximum 
values via a kernel header file since at least 2006.  At what point do we 
assume they are going to be used and not hardcoded into applications?  
That was certainly the intention when making them user visible.

> > +/*
> > + * Tasks that fork a very large number of children with seperate address
> > spaces
> > + * may be the result of a bug, user error, or a malicious application.  The
> > oom
> > + * killer assesses a penalty equaling
> 
> It could also be the result of the system getting many client
> connections - think of overloaded mail, web or database servers.
> 

True, that's a great example of why child tasks should be sacrificed for 
the parent: if the oom killer is being called then we are truly overloaded 
and there's no shame in killing excessive client connections to recover, 
otherwise we might find the entire server becoming unresponsive.  The user 
can easily tune to /proc/sys/vm/oom_forkbomb_thres to define what 
"excessive" is to assess the penalty, if any.  I'll add that to the 
comment if we require a second revision.

Thanks for your speedy review of this patchset so far, Rik!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
