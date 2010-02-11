Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1E67E62000E
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 17:42:48 -0500 (EST)
Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id o1BMgiN3024267
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 14:42:44 -0800
Received: from pzk27 (pzk27.prod.google.com [10.243.19.155])
	by spaceape10.eur.corp.google.com with ESMTP id o1BMgg5B029392
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 14:42:43 -0800
Received: by pzk27 with SMTP id 27so432003pzk.27
        for <linux-mm@kvack.org>; Thu, 11 Feb 2010 14:42:42 -0800 (PST)
Date: Thu, 11 Feb 2010 14:42:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 4/7 -mm] oom: badness heuristic rewrite
In-Reply-To: <20100211143105.dea3861a.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1002111437060.21107@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com> <alpine.DEB.2.00.1002100228540.8001@chino.kir.corp.google.com> <4B73833D.5070008@redhat.com> <alpine.DEB.2.00.1002102332200.22152@chino.kir.corp.google.com>
 <20100211134343.4886499c.akpm@linux-foundation.org> <alpine.DEB.2.00.1002111346050.8809@chino.kir.corp.google.com> <20100211143105.dea3861a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Feb 2010, Andrew Morton wrote:

> > Sigh, this is going to require the amount of system memory to be 
> > partitioned into OOM_ADJUST_MAX, 15, chunks and that's going to be the 
> > granularity at which we'll be able to either bias or discount memory usage 
> > of individual tasks by: instead of being able to do this with 0.1% 
> > granularity we'll now be limited to 100 / 15, or ~7%.  That's ~9GB on my 
> > 128GB system just because this was originally a bitshift.  The upside is 
> > that it's now linear and not exponential.
> 
> Can you add newly-named knobs (rather than modifying the existing
> ones), deprecate the old ones and then massage writes to the old ones
> so that they talk into the new framework?
> 

That's what I was thinking, add /proc/pid/oom_score_adj that is just added 
into the badness score (and is then exported with /proc/pid/oom_score) 
like this patch did with oom_adj and then scale it into oom_adj units for 
that tunable.  A write to either oom_adj or oom_score_adj would change the 
other, the same thing I did for /proc/sys/vm/dirty_{bytes,ratio} and
/proc/sys/vm/dirty_background_{bytes,ratio} which I guess we have to 
support forever since the predecessors are part of the ABI and there's no 
way to deprecate them since they'll never be removed for that reason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
