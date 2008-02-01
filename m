Date: Thu, 31 Jan 2008 17:44:24 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mmu notifiers #v5
In-Reply-To: <20080131234101.GS7185@v2.random>
Message-ID: <Pine.LNX.4.64.0801311738570.24297@schroedinger.engr.sgi.com>
References: <20080131045750.855008281@sgi.com> <20080131171806.GN7185@v2.random>
 <Pine.LNX.4.64.0801311207540.25477@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0801311508080.23624@schroedinger.engr.sgi.com>
 <20080131234101.GS7185@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, 1 Feb 2008, Andrea Arcangeli wrote:

> GRU. Thanks to the PT lock this remains a totally obviously safe
> design and it requires zero additional locking anywhere (nor linux VM,
> nor in the mmu notifier methods, nor in the KVM/GRU page fault).

Na. I would not be so sure about having caught all the issues yet...

> Sure you can do invalidate_range_start/end for more than 2M(/4M on
> 32bit) max virtual ranges. But my approach that averages the fixed
> mmu_lock cost already over 512(/1024) ptes will make any larger
> "range" improvement not strongly measurable anymore given to do that
> you have to add locking as well and _surely_ decrease the GRU
> scalability with tons of threads and tons of cpus potentially making
> GRU a lot slower _especially_ on your numa systems.

The trouble is that the invalidates are much more expensive if you have to 
send theses to remote partitions (XPmem). And its really great if you can 
simple tear down everything. Certainly this is a significant improvement 
over the earlier approach but you still have the invalidate_page calls in 
ptep_clear_flush. So they fire needlessly?

Serializing access in the device driver makes sense and comes with 
additional possiblity of not having to increment page counts all the time. 
So you trade one cacheline dirtying for many that are necessary if you 
always increment the page count.

How does KVM insure the consistency of the shadow page tables? Atomic ops?

The GRU has no page table on its own. It populates TLB entries on demand 
using the linux page table. There is no way it can figure out when to 
drop page counts again. The invalidate calls are turned directly into tlb 
flushes.

 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
