Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1C2A96B007B
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 05:06:57 -0500 (EST)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o1CA6qGc010466
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 02:06:53 -0800
Received: from pxi39 (pxi39.prod.google.com [10.243.27.39])
	by wpaz21.hot.corp.google.com with ESMTP id o1CA6p8m007540
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 02:06:51 -0800
Received: by pxi39 with SMTP id 39so1250950pxi.2
        for <linux-mm@kvack.org>; Fri, 12 Feb 2010 02:06:51 -0800 (PST)
Date: Fri, 12 Feb 2010 02:06:49 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 6/7 -mm] oom: avoid oom killer for lowmem allocations
In-Reply-To: <20100212102841.fa148baf.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002120200050.22883@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com> <alpine.DEB.2.00.1002100229410.8001@chino.kir.corp.google.com> <20100212102841.fa148baf.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Feb 2010, KAMEZAWA Hiroyuki wrote:

> From viewpoint of panic-on-oom lover, this patch seems to cause regression.
> please do this check after sysctl_panic_on_oom == 2 test.
> I think it's easy. So, temporary Nack to this patch itself.
> 
> 
> And I think calling notifier is not very bad in the situation.
> ==
> void out_of_memory()
>  ..snip..
>   blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
> 
> 
> So,
> 
>         if (sysctl_panic_on_oom == 2) {
>                 dump_header(NULL, gfp_mask, order, NULL);
>                 panic("out of memory. Compulsory panic_on_oom is selected.\n");
>         }
> 
> 	if (gfp_zone(gfp_mask) < ZONE_NORMAL) /* oom-kill is useless if lowmem is exhausted. */
> 		return;
> 
> is better. I think.
> 

I can't agree with that assessment, I don't think it's a desired result to 
ever panic the machine regardless of what /proc/sys/vm/panic_on_oom is set 
to because a lowmem page allocation fails especially considering, as 
mentioned in the changelog, these allocations are never __GFP_NOFAIL and 
returning NULL is acceptable.

I've always disliked panicking the machine when a cpuset or mempolicy 
allocation fails and panic_on_oom is set to 2.  Since both such 
constraints now force an iteration of the tasklist when oom_kill_quick is 
not enabled and we strictly prohibit the consideration of tasks with 
disjoint cpuset mems or mempolicy nodes, I think I'll take this 
opportunity to get rid of the panic_on_oom == 2 behavior and ask that 
users who really do want to panic the entire machine for cpuset or 
mempolicy constrained ooms to simply set all such tasks to OOM_DISABLE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
