Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1687A6B0083
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 17:04:51 -0500 (EST)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id o1HM4ldx016814
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 22:04:47 GMT
Received: from pxi14 (pxi14.prod.google.com [10.243.27.14])
	by kpbe12.cbf.corp.google.com with ESMTP id o1HM4heh004406
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 14:04:45 -0800
Received: by pxi14 with SMTP id 14so2899752pxi.15
        for <linux-mm@kvack.org>; Wed, 17 Feb 2010 14:04:43 -0800 (PST)
Date: Wed, 17 Feb 2010 14:04:40 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
In-Reply-To: <20100217095221.GQ5723@laptop>
Message-ID: <alpine.DEB.2.00.1002171345330.6217@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002161623190.11952@chino.kir.corp.google.com> <20100217094137.a0d26fbb.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161648570.31753@chino.kir.corp.google.com> <alpine.DEB.2.00.1002161756100.15079@chino.kir.corp.google.com>
 <20100217111319.d342f10e.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161825280.2768@chino.kir.corp.google.com> <20100217113430.9528438d.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161850540.3106@chino.kir.corp.google.com>
 <20100217122106.31e12398.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002170052410.30931@chino.kir.corp.google.com> <20100217095221.GQ5723@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Feb 2010, Nick Piggin wrote:

> > > quick glance around core codes...
> > >  - HUGEPAGE at el. should return some VM_FAULT_NO_RESOUECE rather than VM_FAULT_OOM.
> > 
> > We can detect this with is_vm_hugetlb_page() if we pass the vma into 
> > pagefault_out_of_memory() without adding another VM_FAULT flag.
> 
> The real question is, what to do when returning to userspace. I don't
> think there's a lot of options. SIGBUS is traditionally used for "no
> resource".
> 

For is_vm_hugetlb_page() in the pagefault oom handler, I think it should 
default to killing current as we did previously until that's worked out 
(and as some architectures like ia64 and powerpc still do).  In fact, 
pagefault ooms should probably always default to killing current if its 
killable.

> > The filemap, shmem, and block_prepare_write() cases will call the oom 
> > killer but, depending on the gfp mask, they will retry their allocations 
> > after the oom killer is called so we should never return VM_FAULT_OOM 
> > because they return -ENOMEM.  They fail from either small objsize slab 
> > allocations or with orders less than PAGE_ALLOC_COSTLY_ORDER which by 
> > default continues to retry even if direct reclaim fails.  If we're 
> > returning with VM_FAULT_OOM from these handlers, it should only be because 
> > of GFP_NOFS | __GFP_NORETRY or current has been oom killed and still can't 
> > find memory (so we don't care if the oom killer is called again since it 
> > won't kill anything else).
> 
> Yep. And yes you are right that we prefer to do the oom killing at the
> allocation point where we know all the context, however the fact is that
> VM_FAULT_OOM is an allowed part of the fault API so we have to handle it
> somehow.
> 
> It can theoretically be called for valid reasons say if a driver or
> arch page table has a high order allocation, or if the page allocator
> implementation were to be changed.
> 
> We can't rightly just kill the task at this point, even if it has
> invoked the oom killer, because it could have been marked as unkillable.
> 

That's easy to test in the oom handler, we can default to killing current 
but then kill another task if it is unkillable:

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -696,15 +696,23 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 }
 
 /*
- * The pagefault handler calls here because it is out of memory, so kill a
- * memory-hogging task.  If a populated zone has ZONE_OOM_LOCKED set, a parallel
- * oom killing is already in progress so do nothing.  If a task is found with
- * TIF_MEMDIE set, it has been killed so do nothing and allow it to exit.
+ * The pagefault handler calls here because it is out of memory, so kill current
+ * by default.  If it's unkillable, then fallback to killing a memory-hogging
+ * task.  If a populated zone has ZONE_OOM_LOCKED set, a parallel oom killing is
+ * already in progress so do nothing.  If a task is found with TIF_MEMDIE set,
+ * it has been killed so do nothing and allow it to exit.
  */
 void pagefault_out_of_memory(void)
 {
+	unsigned long totalpages;
+	int err;
+
 	if (!try_set_system_oom())
 		return;
-	out_of_memory(NULL, 0, 0, NULL);
+	constrained_alloc(NULL, 0, NULL, &totalpages);
+	err = oom_kill_process(current, 0, 0, 0, totalpages, NULL,
+				"Out of memory (pagefault)"))
+	if (err)
+		out_of_memory(NULL, 0, 0, NULL);
 	clear_system_oom();
 }

We'll need to convert the architectures that still only issue a SIGKILL to 
current to use pagefault_out_of_memory() before OOM_DISABLE is fully 
respected across the kernel, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
