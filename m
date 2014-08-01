Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f177.google.com (mail-vc0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id C549E6B0035
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 07:05:19 -0400 (EDT)
Received: by mail-vc0-f177.google.com with SMTP id hy4so6159808vcb.36
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 04:05:19 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id io2si6885835vcb.84.2014.08.01.04.05.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 01 Aug 2014 04:05:17 -0700 (PDT)
Message-ID: <1406887682.4935.239.camel@pasglop>
Subject: Re: [RFC PATCH] mm: Add helpers for locked_vm
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 01 Aug 2014 20:08:02 +1000
In-Reply-To: <20140730124748.GK19379@twins.programming.kicks-ass.net>
References: <1406712493-9284-1-git-send-email-aik@ozlabs.ru>
	 <1406716282.9336.16.camel@buesod1.americas.hpqcorp.net>
	 <53D8E578.7060303@ozlabs.ru>
	 <20140730124748.GK19379@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Alexey Kardashevskiy <aik@ozlabs.ru>, Davidlohr Bueso <davidlohr@hp.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, "Jo\"rn Engel" <joern@logfs.org>, "Paul E
 . McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alex Williamson <alex.williamson@redhat.com>, Alexander Graf <agraf@suse.de>, Michael Ellerman <michael@ellerman.id.au>

On Wed, 2014-07-30 at 14:47 +0200, Peter Zijlstra wrote:
> On Wed, Jul 30, 2014 at 10:30:48PM +1000, Alexey Kardashevskiy wrote:
> > 
> > No, this is not my intention here. Here I only want to increment the counter.
> 
> Full and hard nack on that. It should always be tied to actual pages, we
> should not detach this and make it 'a number'.

But this is the only way. We *cannot* go through the whole per-page
locking logic every time the guest puts a translation into the IOMMU,
this will completely kill guest performances for pass-through devices.

Worse, for performances, because populating the iommu is a hypercall,
we want to do it in "real mode" (special MMU-off environment) where we
cannot rely on most normal kernel services such as normal locks, vmalloc
space isn't accessible etc...

So we don't have a choice. Either we let guests randomly pin arbitrary
amounts of system memory, or we have a way to predictively account for
the maximum that *can* be mapped/pinned in the iommu table to enable
the fast path.

Another problem with the mlock logic is that it doesn't refcount how
many time a page has been locked, while the guest can map a given page
multiple time in the iommu.

Ben.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
