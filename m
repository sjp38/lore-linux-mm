Date: Wed, 6 Feb 2008 00:47:42 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH] mmu notifiers #v5
Message-ID: <20080205234742.GI7441@v2.random>
References: <20080203021704.GC7185@v2.random> <Pine.LNX.4.64.0802041106370.9656@schroedinger.engr.sgi.com> <20080205052525.GD7441@v2.random> <Pine.LNX.4.64.0802042206200.6739@schroedinger.engr.sgi.com> <20080205180802.GE7441@v2.random> <Pine.LNX.4.64.0802051013440.11705@schroedinger.engr.sgi.com> <20080205205519.GF7441@v2.random> <Pine.LNX.4.64.0802051400200.14665@schroedinger.engr.sgi.com> <20080205222657.GG7441@v2.random> <Pine.LNX.4.64.0802051504450.16261@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802051504450.16261@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Tue, Feb 05, 2008 at 03:10:52PM -0800, Christoph Lameter wrote:
> On Tue, 5 Feb 2008, Andrea Arcangeli wrote:
> 
> > > You can avoid the page-pin and the pt lock completely by zapping the 
> > > mappings at _start and then holding off new references until _end.
> > 
> > "holding off new references until _end" = per-range mutex less scalar
> > and more expensive than the PT lock that has to be taken anyway.
> 
> You can of course setup a 2M granularity lock to get the same granularity 
> as the pte lock. That would even work for the cases where you have to page 
> pin now.

If you set a 2M granularity lock, the _start callback would need to
do:

	for_each_2m_lock()
		mutex_lock()

so you'd run zillon of mutex_lock in a row, you're the one with the
million of operations argument.

> The size of the mmap is relevant if you have to perform callbacks on 
> every mapped page that involved take mmu specific locks. That seems to be 
> the case with this approach.

mmap should never trigger any range_start/_end callback unless it's
overwriting an older mapping which is definitely not the interesting
workload for those apps including kvm.

> Optimizing do_exit by taking a single lock to zap all external references 
> instead of 1 mio callbacks somehow leads to slowdown?

It can if the application runs for more than a couple of seconds,
i.e. not a fork flood in which you care about do_exit speed. Keep in
mind if you had 1mio invalidate_pages callback it means you previously
called follow_page 1 mio of times too...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
