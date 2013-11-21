Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 96E196B0031
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 22:36:06 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id rq2so8794277pbb.2
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 19:36:06 -0800 (PST)
Received: from psmtp.com ([74.125.245.176])
        by mx.google.com with SMTP id n5si15755026pav.98.2013.11.20.19.36.04
        for <linux-mm@kvack.org>;
        Wed, 20 Nov 2013 19:36:05 -0800 (PST)
Received: by mail-yh0-f49.google.com with SMTP id z20so3575895yhz.8
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 19:36:03 -0800 (PST)
Date: Wed, 20 Nov 2013 19:36:00 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: user defined OOM policies
In-Reply-To: <CAA25o9S5EQBvyk=HP3obdCaXKjoUVtzeb4QsNmoLMq6NnOYifA@mail.gmail.com>
Message-ID: <alpine.DEB.2.02.1311201933420.7167@chino.kir.corp.google.com>
References: <20131119131400.GC20655@dhcp22.suse.cz> <20131119134007.GD20655@dhcp22.suse.cz> <alpine.DEB.2.02.1311192352070.20752@chino.kir.corp.google.com> <20131120152251.GA18809@dhcp22.suse.cz>
 <CAA25o9S5EQBvyk=HP3obdCaXKjoUVtzeb4QsNmoLMq6NnOYifA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Joern Engel <joern@logfs.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, 20 Nov 2013, Luigi Semenzato wrote:

> Chrome OS uses a custom low-memory notification to minimize OOM kills.
>  When the notifier triggers, the Chrome browser tries to free memory,
> including by shutting down processes, before the full OOM occurs.  But
> OOM kills cannot always be avoided, depending on the speed of
> allocation and how much CPU the freeing tasks are able to use
> (certainly they could be given higher priority, but it get complex).
> 
> We may end up using memcg so we can use the cgroup
> memory.pressure_level file instead of our own notifier, but we have no
> need for finer control over OOM kills beyond the very useful kill
> priority.  One process at a time is good enough for us.
> 

Even with your own custom low-memory notifier or memory.pressure_level, 
it's still possible that all memory is depleted and you run into an oom 
kill before your userspace had a chance to wakeup and prevent it.  I think 
what you'll want is either your custom notifier of memory.pressure_level 
to do pre-oom freeing but fallback to a userspace oom handler that 
prevents kernel oom kills until it ensures userspace did everything it 
could to free unneeded memory, do any necessary logging, etc, and do so 
over a grace period of memory.oom_delay_millisecs before the kernel 
eventually steps in and kills.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
