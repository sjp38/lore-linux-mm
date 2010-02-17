Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B14EC6B0078
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 04:11:41 -0500 (EST)
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id o1H9BbRU014820
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 09:11:37 GMT
Received: from pzk42 (pzk42.prod.google.com [10.243.19.170])
	by spaceape11.eur.corp.google.com with ESMTP id o1H9As7P026219
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 01:11:36 -0800
Received: by pzk42 with SMTP id 42so5367149pzk.8
        for <linux-mm@kvack.org>; Wed, 17 Feb 2010 01:11:34 -0800 (PST)
Date: Wed, 17 Feb 2010 01:11:30 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
In-Reply-To: <20100217122106.31e12398.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002170052410.30931@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com> <20100216092311.86bceb0c.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002160058470.17122@chino.kir.corp.google.com> <20100217084239.265c65ea.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1002161550550.11952@chino.kir.corp.google.com> <20100217090124.398769d5.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161623190.11952@chino.kir.corp.google.com> <20100217094137.a0d26fbb.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1002161648570.31753@chino.kir.corp.google.com> <alpine.DEB.2.00.1002161756100.15079@chino.kir.corp.google.com> <20100217111319.d342f10e.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161825280.2768@chino.kir.corp.google.com>
 <20100217113430.9528438d.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161850540.3106@chino.kir.corp.google.com> <20100217122106.31e12398.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Feb 2010, KAMEZAWA Hiroyuki wrote:

> > The hugetlb case seems to be the only misuse of VM_FAULT_OOM where it 
> > doesn't mean we simply don't have the memory to handle the page fault, 
> > i.e. your earlier "memory is exhausted" definition.  That was handled well 
> > before calling out_of_memory() by simply killing current since we know it 
> > is faulting hugetlb pages and its resource is limited.
> > 
> > We could pass the vma to pagefault_out_of_memory() and simply kill current 
> > if its killable and is_vm_hugetlb_page(vma).
> > 
> 
> No. hugepage is not only case.
> You may not read but we annoyed i915's driver bug recently and it was clearly
> misuse of VM_FAULT_OOM. Then, we got many reports of OOM killer in these months.
> (thanks to Kosaki about this.)
> 

That's been fixed, right?

> quick glance around core codes...
>  - HUGEPAGE at el. should return some VM_FAULT_NO_RESOUECE rather than VM_FAULT_OOM.

We can detect this with is_vm_hugetlb_page() if we pass the vma into 
pagefault_out_of_memory() without adding another VM_FAULT flag.

>  - filemap.c's VM_FAULT_OOM shoudn't call page_fault_oom_kill because it has already
>    called oom_killer if it can. 

See below.

>  - about relayfs, is VM_FAULT_OOM should be BUG_ON()...

That looks appropriate at first glance.

>  - filemap_xip.c return VM_FAULT_OOM....but it doesn't seem to be OOM..
>    just like VM_FAULT_NO_VALID_PAGE_FOUND. (But I'm not familiar with this area.)
>  - fs/buffer.c 's VM_FAULT_OOM is returned oom-killer is called.
>  - shmem.c's VM_FAULT_OOM is retuned oom-killer is called.
> 

The filemap, shmem, and block_prepare_write() cases will call the oom 
killer but, depending on the gfp mask, they will retry their allocations 
after the oom killer is called so we should never return VM_FAULT_OOM 
because they return -ENOMEM.  They fail from either small objsize slab 
allocations or with orders less than PAGE_ALLOC_COSTLY_ORDER which by 
default continues to retry even if direct reclaim fails.  If we're 
returning with VM_FAULT_OOM from these handlers, it should only be because 
of GFP_NOFS | __GFP_NORETRY or current has been oom killed and still can't 
find memory (so we don't care if the oom killer is called again since it 
won't kill anything else).

So like I said, I don't really see a need where VM_FAULT_NO_RESOURCE would 
be helpful in any case other than hugetlb which we can already detect by 
passing the vma into the pagefault oom handler.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
