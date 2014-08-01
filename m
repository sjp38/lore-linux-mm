Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 843246B0038
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 06:05:36 -0400 (EDT)
Received: by mail-qg0-f50.google.com with SMTP id q108so5299177qgd.37
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 03:05:36 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id p1si14685878qak.64.2014.08.01.03.05.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 01 Aug 2014 03:05:32 -0700 (PDT)
Message-ID: <1406887459.4935.236.camel@pasglop>
Subject: Re: [RFC PATCH] mm: Add helpers for locked_vm
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 01 Aug 2014 20:04:19 +1000
In-Reply-To: <1406716282.9336.16.camel@buesod1.americas.hpqcorp.net>
References: <1406712493-9284-1-git-send-email-aik@ozlabs.ru>
	 <1406716282.9336.16.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Alexey Kardashevskiy <aik@ozlabs.ru>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, =?ISO-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alex Williamson <alex.williamson@redhat.com>, Alexander Graf <agraf@suse.de>, Michael Ellerman <michael@ellerman.id.au>

On Wed, 2014-07-30 at 03:31 -0700, Davidlohr Bueso wrote:

> It doesn't strike me that this is the place for this. It would seem that
> it would be the caller's responsibility to make sure of this (and not
> sure how !current can happen...).
> 
> > +
> > +	down_write(&current->mm->mmap_sem);
> > +	locked = current->mm->locked_vm + npages;
> > +	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
> 
> nit: please set locked and lock_limit before taking the mmap_sem.

Won't it be racy to read current->mm->locked_vm without the sem ?

> > +	if (locked > lock_limit && !capable(CAP_IPC_LOCK)) {
> > +		pr_warn("RLIMIT_MEMLOCK (%ld) exceeded\n",
> > +				rlimit(RLIMIT_MEMLOCK));
> > +		ret = -ENOMEM;
> > +	} else {
> 
> It would be nicer to have it the other way around, leave the #else for
> ENOMEM. It reads better, imho.
> 
> > +		current->mm->locked_vm += npages;
> 
> More importantly just setting locked_vm is not enough. You'll need to
> call do_mlock() here (again, addr granularity ;). This also applies to
> your decrement_locked_vm().

Do we need to actually do mlock ? Basically this is VFIO doing
get_user_pages on a pile of guest/user memory, we are trying to account
for it, but I don't think we need the whole mlock business on top of it

Also address granularity cannot work. We basically predictively account
how much the guest can lock, but we won't know how much it actually
locks until he actually does DMA mappings which is a fairly fast path.

In some cases, I think (Alexey, correct me if I'm wrong), we are trying
to account for kernel memory allocated on behalf of the guest, which is
not necessarily mapped as normal VMAs, it's mostly a way to prevent
a stray KVM/qemu guest from causing the kernel to allocate a ton of
pinned memory by accounting it as part of the locked memory limits.

Ben.

> Thanks,
> Davidlohr
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
