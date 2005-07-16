Date: Sat, 16 Jul 2005 04:01:41 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: [NUMA] Display and modify the memory policy of a process through /proc/<pid>/numa_policy
Message-ID: <20050716020141.GO15783@wotan.suse.de>
References: <20050715214700.GJ15783@wotan.suse.de> <Pine.LNX.4.62.0507151450570.11656@schroedinger.engr.sgi.com> <20050715220753.GK15783@wotan.suse.de> <Pine.LNX.4.62.0507151518580.12160@schroedinger.engr.sgi.com> <20050715223756.GL15783@wotan.suse.de> <Pine.LNX.4.62.0507151544310.12371@schroedinger.engr.sgi.com> <20050715225635.GM15783@wotan.suse.de> <Pine.LNX.4.62.0507151602390.12530@schroedinger.engr.sgi.com> <20050715234402.GN15783@wotan.suse.de> <Pine.LNX.4.62.0507151647300.12832@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0507151647300.12832@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andi Kleen <ak@suse.de>, Paul Jackson <pj@sgi.com>, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> One always needs control over what is migrated. Ideally one would be able 
> to specify that only the vma containing the huge amount of sparsely 
> accessed data is to be migrated if memory becomes tight but the process 
> continues to run on the same node. The stack and text segments and 
> libraries should stay on the node.

There is no way to do sane locking from user space 
for such external manipulation of arbitary mappings.  You need
to do it in the kernel.

BTW all your talking about VMAs is useless here anyways because
NUMA policies don't necessarily match VMAs and neither does
allocated memory. 

> Are you willing to allow us to control memory placement? Or will it be 

> automatically? If automatically then maybe you need to get rid of libnuma 
> and numactl and put it all in the scheduler. Otherwise please full control 
> and not some half-way measures.

Without my NUMA policy code you wouldn't have any usable NUMA policy today,
But my goal is definitely to keep the kernel interfaces for this
clean. And what you're proposing is *not* clean. 

I think the per VMA approach is fundamentally wrong because
virtual addresses are nothing an external user can safely
access.  Doing it on higher level objects allows better interfaces
and better locking, and as far as I can see process/shm segment/file
are the only useful objects for this. 

It should basically work like swapping without the need to SIGSTOP
the target.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
