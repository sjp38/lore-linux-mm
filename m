Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D56816B004D
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 15:56:01 -0500 (EST)
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id o1MKu5UQ021649
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 20:56:06 GMT
Received: from pzk11 (pzk11.prod.google.com [10.243.19.139])
	by spaceape11.eur.corp.google.com with ESMTP id o1MKtQ35030731
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 12:56:04 -0800
Received: by pzk11 with SMTP id 11so296631pzk.9
        for <linux-mm@kvack.org>; Mon, 22 Feb 2010 12:56:04 -0800 (PST)
Date: Mon, 22 Feb 2010 12:55:57 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
In-Reply-To: <20100222151513.0605d69e.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002221250540.14426@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com> <alpine.DEB.2.00.1002151610380.14484@chino.kir.corp.google.com> <20100216092311.86bceb0c.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002160058470.17122@chino.kir.corp.google.com>
 <20100217084239.265c65ea.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161550550.11952@chino.kir.corp.google.com> <20100217090124.398769d5.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161623190.11952@chino.kir.corp.google.com>
 <20100217094137.a0d26fbb.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161648570.31753@chino.kir.corp.google.com> <alpine.DEB.2.00.1002161756100.15079@chino.kir.corp.google.com> <20100217111319.d342f10e.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1002161825280.2768@chino.kir.corp.google.com> <20100217113430.9528438d.kamezawa.hiroyu@jp.fujitsu.com> <20100222143151.9e362c88.nishimura@mxp.nes.nec.co.jp> <20100222151513.0605d69e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 Feb 2010, KAMEZAWA Hiroyuki wrote:

> Essential fix is better. The best fix is don't call oom-killer in
> pagefault_out_of_memory. So, returning other than VM_FAULT_OOM is
> the best, I think. But hmm...we don't have VM_FAULT_AGAIN etc..
> So, please avoid quick fix. 
> 

The last patch in my oom killer series defaults pagefault_out_of_memory() 
to always kill current first, if it's killable.  If it is unsuccessful, we 
fallback to scanning the entire tasklist.

For tasks that are constrained by a memcg, we could probably use 
mem_cgroup_from_task(current) and if it's non-NULL and non-root, call 
mem_cgroup_out_of_memory() with a gfp_mask of 0.  That would at least 
penalize the same memcg instead of invoking a global oom and would try the 
additional logic that you plan on adding to avoid killing any task at all 
in such conditions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
