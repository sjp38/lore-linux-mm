Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5AF2A6B0047
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 16:49:07 -0500 (EST)
Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id o14Ln2Yj016366
	for <linux-mm@kvack.org>; Thu, 4 Feb 2010 21:49:02 GMT
Received: from pxi17 (pxi17.prod.google.com [10.243.27.17])
	by spaceape10.eur.corp.google.com with ESMTP id o14Ln1WT003161
	for <linux-mm@kvack.org>; Thu, 4 Feb 2010 13:49:01 -0800
Received: by pxi17 with SMTP id 17so8660690pxi.30
        for <linux-mm@kvack.org>; Thu, 04 Feb 2010 13:49:00 -0800 (PST)
Date: Thu, 4 Feb 2010 13:48:59 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Improving OOM killer
In-Reply-To: <4B6A1241.60009@redhat.com>
Message-ID: <alpine.DEB.2.00.1002041339220.6071@chino.kir.corp.google.com>
References: <201002012302.37380.l.lunak@suse.cz> <20100203170127.GH19641@balbir.in.ibm.com> <alpine.DEB.2.00.1002031021190.14088@chino.kir.corp.google.com> <201002032355.01260.l.lunak@suse.cz> <alpine.DEB.2.00.1002031600490.27918@chino.kir.corp.google.com>
 <4B6A1241.60009@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Lubos Lunak <l.lunak@suse.cz>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Feb 2010, Rik van Riel wrote:

> > Do you have any comments about the forkbomb detector or its threshold that
> > I've put in my heuristic?  I think detecting these scenarios is still an
> > important issue that we need to address instead of simply removing it from
> > consideration entirely.
> 
> I believe that malicious users are best addressed in person,
> or preemptively through cgroups and rlimits.
> 

Forkbombs need not be the result of malicious users.

> Having a process with over 500 children is quite possible
> with things like apache, Oracle, postgres and other forking
> daemons.
> 

It's clear that the forkbomb threshold would need to be definable from 
userspace and probably default to something high such as 1000.

Keep in mind that we're in the oom killer here, though.  So we're out of 
memory and we need to kill something; should Apache, Oracle, and postgres 
not be penalized for their cost of running by factoring in something like 
this?

	(lowest rss size of children) * (# of first-generation children) / 
			(forkbomb threshold)

> Killing the parent process can result in the service
> becoming unavailable, and in some cases even data
> corruption.
> 

There's only one possible rememdy for that, which is OOM_DISABLE; the oom 
killer cannot possibly predict data corruption as the result of killing a 
process and this is no different.  Everything besides init, kthreads, 
OOM_DISABLE threads, and threads that do not share the same cpuset, memcg, 
or set of allowed mempolicy nodes are candidates for oom kill.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
