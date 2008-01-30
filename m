Date: Tue, 29 Jan 2008 16:34:16 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address ranges
In-Reply-To: <20080129234353.GZ7233@v2.random>
Message-ID: <Pine.LNX.4.64.0801291622510.28027@schroedinger.engr.sgi.com>
References: <20080128202840.974253868@sgi.com> <20080128202923.849058104@sgi.com>
 <20080129162004.GL7233@v2.random> <20080129182831.GS7233@v2.random>
 <Pine.LNX.4.64.0801291219030.25629@schroedinger.engr.sgi.com>
 <20080129213604.GW7233@v2.random> <Pine.LNX.4.64.0801291343530.26824@schroedinger.engr.sgi.com>
 <20080129223503.GY7233@v2.random> <Pine.LNX.4.64.0801291440170.27327@schroedinger.engr.sgi.com>
 <20080129234353.GZ7233@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jan 2008, Andrea Arcangeli wrote:

> > A user space spinlock plays into this??? That is irrelevant to the kernel. 
> > And we are discussing "your" placement of the invalidate_range not mine.
> 
> With "my" code, invalidate_range wasn't placed there at all, my
> modification to ptep_clear_flush already covered it in a automatic
> way, grep from the word fremap in my latest patch you won't find it,
> like you won't find any change to do_wp_page. Not sure why you keep
> thinking I added those invalidate_range when infact you did.

Well you moved the code at minimum. Hmmm... according 
http://marc.info/?l=linux-kernel&m=120114755620891&w=2 it was Robin.

> The user space spinlock plays also in declaring rdtscp unworkable to
> provide a monotone vgettimeofday w/o kernel locking.

No idea what you are talking about.

> My patch by calling invalidate_page inside ptep_clear_flush guaranteed
> that both the thread writing through sptes and the thread writing
> through linux ptes, couldn't possibly simultaneously write to two
> different physical pages.

But then the ptep_clear_flush will issue invalidate_page() for ranges 
that were already covered by invalidate_range(). There are multiple calls 
to clear the same spte.
>
> Your patch allows the thread writing through linux-pte to write to a
> new populated page while the old thread writing through sptes still
> writes to the old page. Is that safe? I don't know for sure. The fact
> the physical page backing the virtual address could change back and
> forth, perhaps invalidates the theory that somebody could possibly do
> some useful locking out of it relaying on all threads seeing the same
> physical page at the same time.

This is referrring to the remap issue not do_wp_page right?

> Actually above I was describing remap_file_pages not do_wp_page.

Ok.

The serialization of remap_file_pages does not seem that critical since we 
only take a read lock on mmap_sem here. There may already be concurrent 
access to pages from other processors while the ptes are remapped. So 
there is already some overlap.

We could take mmap_sem there writably and keep it writably for the case 
that we have an mmu notifier in the mm.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
