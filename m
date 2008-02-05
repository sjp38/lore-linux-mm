Date: Tue, 5 Feb 2008 21:55:19 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH] mmu notifiers #v5
Message-ID: <20080205205519.GF7441@v2.random>
References: <20080131234101.GS7185@v2.random> <Pine.LNX.4.64.0801311738570.24297@schroedinger.engr.sgi.com> <20080201120955.GX7185@v2.random> <Pine.LNX.4.64.0802011118060.18163@schroedinger.engr.sgi.com> <20080203021704.GC7185@v2.random> <Pine.LNX.4.64.0802041106370.9656@schroedinger.engr.sgi.com> <20080205052525.GD7441@v2.random> <Pine.LNX.4.64.0802042206200.6739@schroedinger.engr.sgi.com> <20080205180802.GE7441@v2.random> <Pine.LNX.4.64.0802051013440.11705@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802051013440.11705@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Tue, Feb 05, 2008 at 10:17:41AM -0800, Christoph Lameter wrote:
> The other approach will not have any remote ptes at that point. Why would 
> there be a coherency issue?

It never happens that two threads writes to two different physical
pages by working on the same process virtual address. This is an issue
only for KVM which is probably ok with it but certainly you can't
consider the dependency on the page-pin less fragile or less complex
than my PT lock approach.

> No. It only has to lock the affected range. Remote page faults can occur 
> while another part of the address space is being invalidated. The 
> complexity of locking is up to the user of the mmu notifier. A simple 
> implementation is satisfactory for the GRU right now. Should it become a 
> problem then the lock granularity can be refined without changing the API.

That will make the follow_page fast path even slower if it has to
lookup a rbtree or a list of locked ranges. Still not comparable to
the PT lock that 1) it's zero cost and 2) it'll provide an even more
granular scalability.

> Still not sure what we are talking about here.

The apps using GRU/KVM never trigger large
munmap/mremap/do_exit. You're optimizing for the irrelevant workload,
by requiring unnecessary new locking in the GRU fast path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
