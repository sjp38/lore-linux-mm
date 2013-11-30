Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f54.google.com (mail-yh0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7DEAF6B0035
	for <linux-mm@kvack.org>; Sat, 30 Nov 2013 17:12:56 -0500 (EST)
Received: by mail-yh0-f54.google.com with SMTP id z12so7636631yhz.41
        for <linux-mm@kvack.org>; Sat, 30 Nov 2013 14:12:56 -0800 (PST)
Received: from mail-yh0-x22b.google.com (mail-yh0-x22b.google.com [2607:f8b0:4002:c01::22b])
        by mx.google.com with ESMTPS id y62si40989862yhc.219.2013.11.30.14.12.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 30 Nov 2013 14:12:54 -0800 (PST)
Received: by mail-yh0-f43.google.com with SMTP id a41so7190548yho.30
        for <linux-mm@kvack.org>; Sat, 30 Nov 2013 14:12:54 -0800 (PST)
Date: Sat, 30 Nov 2013 14:12:51 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [merged] mm-memcg-handle-non-error-oom-situations-more-gracefully.patch
 removed from -mm tree
In-Reply-To: <20131130155542.GO3556@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1311301400100.18027@chino.kir.corp.google.com>
References: <20131127233353.GH3556@cmpxchg.org> <alpine.DEB.2.02.1311271622330.10617@chino.kir.corp.google.com> <20131128021809.GI3556@cmpxchg.org> <alpine.DEB.2.02.1311271826001.5120@chino.kir.corp.google.com> <20131128031313.GK3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271914460.5120@chino.kir.corp.google.com> <20131128035218.GM3556@cmpxchg.org> <alpine.DEB.2.02.1311291546370.22413@chino.kir.corp.google.com> <20131130033536.GL22729@cmpxchg.org> <alpine.DEB.2.02.1311300226070.29602@chino.kir.corp.google.com>
 <20131130155542.GO3556@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, azurit@pobox.sk, mm-commits@vger.kernel.org, stable@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 30 Nov 2013, Johannes Weiner wrote:

> > The oom killer requires a tasklist scan, or an iteration over the set of 
> > processes attached to the memcg for the memcg case, to find a victim.  It 
> > already defers if it finds eligible threads with TIF_MEMDIE set.
> 
> And now you say that this race does not really exist and repeat the
> same ramblings about last-minute checks to avoid unnecessary kills
> again.  And again without any supporting data that I already asked
> for.
> 

The race does exist, perhaps you don't understand what the race is?  This 
race occurs when process (A) declares oom and enters the oom killer, 
meanwhile an already oom killed victim (B) frees its memory and exits, and 
the process (A) oom kills another process even though the memcg is below 
its limit because of process (B).

When doing something expensive in the kernel like oom killing, it usually 
doesn't cause so much hassle when the suggestion is:

	<declare an action is necessary>
	<do something expensive>
	<select an action>
	if (!<action is still necessary>)
		abort
	<perform the action>

That type of check is fairly straight forward and makes sense.  It 
prevents unnecessary oom killing (although it can't guarantee it in all 
conditions) and prevents customers from reporting oom kills when the log 
shows there is memory available for their memcg.

When using memcg on a large scale to enforce memory isolation for user 
jobs, these types of scenarios happen often and there is no downside to 
adding such a check.  The oom killer is not a hotpath, it's not 
performance sensitive to the degree that we cannot add a simple 
conditional that checks the current limit, it prevents unnecessary oom 
kills, and prevents user confusion.

Without more invasive synchronization that would touch hotpaths, this is 
the best we can do: check if the oom kill is really necessary just before 
issuing the kill.  Having the kernel actually kill a user process is a 
serious matter and we should strive to ensure it is prevented whenever 
possible.

> The more I talk to you, the less sense this all makes.  Why do you
> insist we merge this patch when you have apparently no idea why and
> how it works, and can't demonstrate that it works in the first place?
> 

I'm not insisting anything, I don't make demands of others or maintainers 
like you do to merge or not merge anything.  I also haven't even formally 
proposed the patch with a changelog that would explain the motivation.

> I only followed you around in circles because I'm afraid that my
> shutting up would be interpreted as agreement again and Andrew would
> merge this anyway.  But this is unsustainable, the burden of proof
> should be on you, not me.  I'm going to stop replying until you
> provide the information I asked for.
> 

Andrew can't merge a patch that hasn't been proposed for merge.

Have a nice weekend.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
