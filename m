Date: Fri, 1 Feb 2008 00:41:01 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH] mmu notifiers #v5
Message-ID: <20080131234101.GS7185@v2.random>
References: <20080131045750.855008281@sgi.com> <20080131171806.GN7185@v2.random> <Pine.LNX.4.64.0801311207540.25477@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0801311508080.23624@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801311508080.23624@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2008 at 03:09:55PM -0800, Christoph Lameter wrote:
> On Thu, 31 Jan 2008, Christoph Lameter wrote:
> 
> > > pagefault against the main linux page fault, given we already have all
> > > needed serialization out of the PT lock. XPMEM is forced to do that
> > 
> > pt lock cannot serialize with invalidate_range since it is split. A range 
> > requires locking for a series of ptes not only individual ones.
> 
> Hmmm.. May be okay after all. I see that you are only doing it on the pte 
> level. This means the range callbacks are taking down a max of 512 
> entries. So you have a callback for each pmd. A callback for 2M of memory?

Exactly. The point of _pages is to reduce of an order of magnitude
(512, or 1024 times) the number of needed invalidate_page calls in a
few places where it's a strightforward optimization for both KVM and
GRU. Thanks to the PT lock this remains a totally obviously safe
design and it requires zero additional locking anywhere (nor linux VM,
nor in the mmu notifier methods, nor in the KVM/GRU page fault).

Sure you can do invalidate_range_start/end for more than 2M(/4M on
32bit) max virtual ranges. But my approach that averages the fixed
mmu_lock cost already over 512(/1024) ptes will make any larger
"range" improvement not strongly measurable anymore given to do that
you have to add locking as well and _surely_ decrease the GRU
scalability with tons of threads and tons of cpus potentially making
GRU a lot slower _especially_ on your numa systems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
