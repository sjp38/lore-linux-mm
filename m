Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 44C486B01F0
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 03:59:29 -0400 (EDT)
Message-ID: <4C6A408C.6040203@kernel.org>
Date: Tue, 17 Aug 2010 09:55:56 +0200
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [S+Q3 00/23] SLUB: The Unified slab allocator (V3)
References: <20100804024514.139976032@linux.com> <alpine.DEB.2.00.1008032138160.20049@chino.kir.corp.google.com> <alpine.DEB.2.00.1008041115500.11084@router.home> <alpine.DEB.2.00.1008050136340.30889@chino.kir.corp.google.com> <alpine.DEB.2.00.1008051231400.6787@router.home> <alpine.DEB.2.00.1008151627450.27137@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1008151627450.27137@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hello,

On 08/17/2010 06:56 AM, David Rientjes wrote:
> I'm adding Tejun Heo to the cc because of another thing that may be 
> problematic: alloc_percpu() allocates GFP_KERNEL memory, so when we try to 
> allocate kmem_cache_cpu for a DMA cache we may be returning memory from a 
> node that doesn't include lowmem so there will be no affinity between the 
> struct and the slab.  I'm wondering if it would be better for the percpu 
> allocator to be extended for kzalloc_node(), or vmalloc_node(), when 
> allocating memory after the slab layer is up.

Hmmm... do you mean adding @gfp_mask to percpu allocation function?
I've been thinking about adding it for atomic allocations (Christoph,
do you still want it?).  I've been sort of against it because I
primarily don't really like atomic allocations (it often just pushes
error handling complexities elsewhere where it becomes more complex)
and it would also require making vmalloc code do atomic allocations.

Most of percpu use cases seem pretty happy with GFP_KERNEL allocation,
so I'm still quite reluctant to change that.  We can add a semi
internal interface w/ @gfp_mask but w/o GFP_ATOMIC support, which is a
bit ugly.  How important would this be?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
