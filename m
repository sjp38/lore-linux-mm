Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A40C86B007B
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 17:01:22 -0500 (EST)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id o1FM1LgA019078
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 22:01:22 GMT
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by kpbe18.cbf.corp.google.com with ESMTP id o1FM1Ksg019031
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 14:01:20 -0800
Received: by pzk36 with SMTP id 36so6352838pzk.23
        for <linux-mm@kvack.org>; Mon, 15 Feb 2010 14:01:20 -0800 (PST)
Date: Mon, 15 Feb 2010 14:01:17 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 6/7 -mm] oom: avoid oom killer for lowmem allocations
In-Reply-To: <20100215090949.169f2819.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002151355000.26927@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com> <alpine.DEB.2.00.1002100229410.8001@chino.kir.corp.google.com> <20100212102841.fa148baf.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002120200050.22883@chino.kir.corp.google.com>
 <20100215090949.169f2819.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 Feb 2010, KAMEZAWA Hiroyuki wrote:

> > I can't agree with that assessment, I don't think it's a desired result to 
> > ever panic the machine regardless of what /proc/sys/vm/panic_on_oom is set 
> > to because a lowmem page allocation fails especially considering, as 
> > mentioned in the changelog, these allocations are never __GFP_NOFAIL and 
> > returning NULL is acceptable.
> > 
> please add
>   WARN_ON((high_zoneidx < ZONE_NORMAL) && (gfp_mask & __GFP_NOFAIL))
> somewhere. Then, it seems your patch makes sense.
> 

high_zoneidx < ZONE_NORMAL is not the only case where this exists: it 
exists for __GFP_NOFAIL allocations that are not __GFP_FS as well and has 
for years, no special handling is now needed.

There should be no cases of either (GFP_DMA | __GFP_NOFAIL, or
GFP_NOFS | __GFP_NOFAIL) in my audit of the kernel code.  And since 
__GFP_NOFAIL is not to be added anymore (see Andrew's dab48dab), there's 
no real reason to add a WARN_ON() here.

> I don't like the "possibility" of inifinte loops.
> 

The possibility of infinite loops has always existed in the page allocator 
for __GFP_NOFAIL allocations, that's precisely why it's deprecated and 
eventually we seek to remove it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
