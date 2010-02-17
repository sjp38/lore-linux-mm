Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C320A6B007B
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 19:05:59 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1H06Ydd000913
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 17 Feb 2010 09:06:34 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E58545DE53
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 09:06:34 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D53DE45DE4E
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 09:06:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BA94CE08001
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 09:06:33 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 672EA1DB8038
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 09:06:33 +0900 (JST)
Date: Wed, 17 Feb 2010 09:03:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm 8/9 v2] oom: avoid oom killer for lowmem allocations
Message-Id: <20100217090303.6bd64209.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1002161555170.11952@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002151419260.26927@chino.kir.corp.google.com>
	<20100216085706.c7af93e1.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002151606320.14484@chino.kir.corp.google.com>
	<20100216064402.GC5723@laptop>
	<alpine.DEB.2.00.1002152334260.7470@chino.kir.corp.google.com>
	<20100216075330.GJ5723@laptop>
	<alpine.DEB.2.00.1002160024370.15201@chino.kir.corp.google.com>
	<20100217084858.fd72ec4f.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002161555170.11952@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Feb 2010 16:03:23 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 17 Feb 2010, KAMEZAWA Hiroyuki wrote:
> 
> > > > > I'll add this check to __alloc_pages_may_oom() for the !(gfp_mask & 
> > > > > __GFP_NOFAIL) path since we're all content with endlessly looping.
> > > > 
> > > > Thanks. Yes endlessly looping is far preferable to randomly oopsing
> > > > or corrupting memory.
> > > > 
> > > 
> > > Here's the new patch for your consideration.
> > > 
> > 
> > Then, can we take kdump in this endlessly looping situaton ?
> > 
> > panic_on_oom=always + kdump can do that. 
> > 
> 
> The endless loop is only helpful if something is going to free memory 
> external to the current page allocation: either another task with 
> __GFP_WAIT | __GFP_FS that invokes the oom killer, a task that frees 
> memory, or a task that exits.
> 
> The most notable endless loop in the page allocator is the one when a task 
> has been oom killed, gets access to memory reserves, and then cannot find 
> a page for a __GFP_NOFAIL allocation:
> 
> 	do {
> 		page = get_page_from_freelist(gfp_mask, nodemask, order,
> 			zonelist, high_zoneidx, ALLOC_NO_WATERMARKS,
> 			preferred_zone, migratetype);
> 
> 		if (!page && gfp_mask & __GFP_NOFAIL)
> 			congestion_wait(BLK_RW_ASYNC, HZ/50);
> 	} while (!page && (gfp_mask & __GFP_NOFAIL));
> 
> We don't expect any such allocations to happen during the exit path, but 
> we could probably find some in the fs layer.
> 
> I don't want to check sysctl_panic_on_oom in the page allocator because it 
> would start panicking the machine unnecessarily for the integrity 
> metadata GFP_NOIO | __GFP_NOFAIL allocation, for any 
> order > PAGE_ALLOC_COSTLY_ORDER, or for users who can't lock the zonelist 
> for oom kill that wouldn't have panicked before.
> 

Then, why don't you check higzone_idx in oom_kill.c

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
