Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9BCA76B0031
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 20:17:37 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id un15so1104841pbc.41
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 17:17:37 -0800 (PST)
Received: from psmtp.com ([74.125.245.147])
        by mx.google.com with SMTP id bf6si10882049pad.19.2013.11.18.17.17.35
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 17:17:36 -0800 (PST)
Received: by mail-yh0-f48.google.com with SMTP id f10so3834100yha.21
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 17:17:34 -0800 (PST)
Date: Mon, 18 Nov 2013 17:17:31 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, vmscan: abort futile reclaim if we've been oom
 killed
In-Reply-To: <20131118164107.GC3556@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1311181712080.4292@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1311121801200.18803@chino.kir.corp.google.com> <20131113152412.GH707@cmpxchg.org> <alpine.DEB.2.02.1311131400300.23211@chino.kir.corp.google.com> <20131114000043.GK707@cmpxchg.org> <alpine.DEB.2.02.1311131639010.6735@chino.kir.corp.google.com>
 <20131118164107.GC3556@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 18 Nov 2013, Johannes Weiner wrote:

> > Um, no, those processes are going through a repeated loop of direct 
> > reclaim, calling the oom killer, iterating the tasklist, finding an 
> > existing oom killed process that has yet to exit, and looping.  They 
> > wouldn't loop for too long if we can reduce the amount of time that it 
> > takes for that oom killed process to exit.
> 
> I'm not talking about the big loop in the page allocator.  The victim
> is going through the same loop.  This patch is about the victim being
> in a pointless direct reclaim cycle when it could be exiting, all I'm
> saying is that the other tasks doing direct reclaim at that moment
> should also be quitting and retrying the allocation.
> 

"All other tasks" would be defined as though sharing the same mempolicy 
context as the oom kill victim or the same set of cpuset mems, I'm not 
sure what type of method for determining reclaim eligiblity you're 
proposing to avoid pointlessly spinning without making progress.  Until an 
alternative exists, my patch avoids the needless spinning and expedites 
the exit, so I'll ask that it be merged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
