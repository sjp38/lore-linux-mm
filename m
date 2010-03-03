Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3C65E6B004D
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 19:38:26 -0500 (EST)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o230cMbC021230
	for <linux-mm@kvack.org>; Wed, 3 Mar 2010 00:38:23 GMT
Received: from pzk29 (pzk29.prod.google.com [10.243.19.157])
	by wpaz17.hot.corp.google.com with ESMTP id o230cLBs019748
	for <linux-mm@kvack.org>; Tue, 2 Mar 2010 16:38:21 -0800
Received: by pzk29 with SMTP id 29so487445pzk.27
        for <linux-mm@kvack.org>; Tue, 02 Mar 2010 16:38:21 -0800 (PST)
Date: Tue, 2 Mar 2010 16:38:16 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm v2 04/10] oom: remove special handling for pagefault
 ooms
In-Reply-To: <20100303092210.a730a903.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1003021634030.18535@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002261549290.30830@chino.kir.corp.google.com> <alpine.DEB.2.00.1002261551030.30830@chino.kir.corp.google.com> <20100301052306.GG19665@balbir.in.ibm.com> <alpine.DEB.2.00.1003010159420.26824@chino.kir.corp.google.com>
 <20100302085532.ff9d3cf4.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1003021600020.11946@chino.kir.corp.google.com> <20100303092210.a730a903.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Mar 2010, KAMEZAWA Hiroyuki wrote:

> > This patch causes a regression???  You never said that in any of your 
> > reviews and I have no idea what you're talking about, this patch simply 
> > cleans up the code and closes a race where VM_FAULT_OOM could needlessly 
> > kill tasks in parallel oom conditions.
> > 
> try_set_system_oom() is not called in memory_cgroup_out_of_memory() path.
> Then, oom kill twice.
> 

So how does this cause a regression AT ALL?  Calling try_set_system_oom() 
in pagefault_out_of_memory() protects against concurrent out_of_memory() 
from the page allocator before a task is actually killed.  So this patch 
closes that race entirely.  So it most certainly does not introduce a 
regression.

You said earlier that mem_cgroup_out_of_memory() need not serialize 
against parallel oom killings because in that scenario we must kill 
something anyway, memory freeing from other ooms won't help if a memcg is 
over its limit.  So, yeah, we may kill two tasks if both the system and a 
memcg are oom in parallel and neither have actually killed a task yet, but 
that's much more jusitiable since we shouldn't rely on a memcg oom to free 
memory for the entire system.

So, again, there's absolutely no regression introduced by this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
