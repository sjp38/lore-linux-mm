Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7C26C6B0078
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 04:52:41 -0500 (EST)
Date: Wed, 17 Feb 2010 20:52:21 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
Message-ID: <20100217095221.GQ5723@laptop>
References: <alpine.DEB.2.00.1002161623190.11952@chino.kir.corp.google.com>
 <20100217094137.a0d26fbb.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1002161648570.31753@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1002161756100.15079@chino.kir.corp.google.com>
 <20100217111319.d342f10e.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1002161825280.2768@chino.kir.corp.google.com>
 <20100217113430.9528438d.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1002161850540.3106@chino.kir.corp.google.com>
 <20100217122106.31e12398.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1002170052410.30931@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1002170052410.30931@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 17, 2010 at 01:11:30AM -0800, David Rientjes wrote:
> On Wed, 17 Feb 2010, KAMEZAWA Hiroyuki wrote:
> > quick glance around core codes...
> >  - HUGEPAGE at el. should return some VM_FAULT_NO_RESOUECE rather than VM_FAULT_OOM.
> 
> We can detect this with is_vm_hugetlb_page() if we pass the vma into 
> pagefault_out_of_memory() without adding another VM_FAULT flag.

The real question is, what to do when returning to userspace. I don't
think there's a lot of options. SIGBUS is traditionally used for "no
resource".


> >  - filemap.c's VM_FAULT_OOM shoudn't call page_fault_oom_kill because it has already
> >    called oom_killer if it can. 
> 
> See below.
> 
> >  - about relayfs, is VM_FAULT_OOM should be BUG_ON()...
> 
> That looks appropriate at first glance.
> 
> >  - filemap_xip.c return VM_FAULT_OOM....but it doesn't seem to be OOM..
> >    just like VM_FAULT_NO_VALID_PAGE_FOUND. (But I'm not familiar with this area.)

SIGBUS, probably, yes. I questioned this as well but it mustn't
have been resolved.


> >  - fs/buffer.c 's VM_FAULT_OOM is returned oom-killer is called.
> >  - shmem.c's VM_FAULT_OOM is retuned oom-killer is called.
> > 
> 
> The filemap, shmem, and block_prepare_write() cases will call the oom 
> killer but, depending on the gfp mask, they will retry their allocations 
> after the oom killer is called so we should never return VM_FAULT_OOM 
> because they return -ENOMEM.  They fail from either small objsize slab 
> allocations or with orders less than PAGE_ALLOC_COSTLY_ORDER which by 
> default continues to retry even if direct reclaim fails.  If we're 
> returning with VM_FAULT_OOM from these handlers, it should only be because 
> of GFP_NOFS | __GFP_NORETRY or current has been oom killed and still can't 
> find memory (so we don't care if the oom killer is called again since it 
> won't kill anything else).

Yep. And yes you are right that we prefer to do the oom killing at the
allocation point where we know all the context, however the fact is that
VM_FAULT_OOM is an allowed part of the fault API so we have to handle it
somehow.

It can theoretically be called for valid reasons say if a driver or
arch page table has a high order allocation, or if the page allocator
implementation were to be changed.

We can't rightly just kill the task at this point, even if it has
invoked the oom killer, because it could have been marked as unkillable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
