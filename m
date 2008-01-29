Date: Wed, 30 Jan 2008 00:43:53 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address
	ranges
Message-ID: <20080129234353.GZ7233@v2.random>
References: <20080128202840.974253868@sgi.com> <20080128202923.849058104@sgi.com> <20080129162004.GL7233@v2.random> <20080129182831.GS7233@v2.random> <Pine.LNX.4.64.0801291219030.25629@schroedinger.engr.sgi.com> <20080129213604.GW7233@v2.random> <Pine.LNX.4.64.0801291343530.26824@schroedinger.engr.sgi.com> <20080129223503.GY7233@v2.random> <Pine.LNX.4.64.0801291440170.27327@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801291440170.27327@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2008 at 02:55:56PM -0800, Christoph Lameter wrote:
> On Tue, 29 Jan 2008, Andrea Arcangeli wrote:
> 
> > But now I think there may be an issue with a third thread that may
> > show unsafe the removal of invalidate_page from ptep_clear_flush.
> > 
> > A third thread writing to a page through the linux-pte and the guest
> > VM writing to the same page through the sptes, will be writing on the
> > same physical page concurrently and using an userspace spinlock w/o
> > ever entering the kernel. With your patch that invalidate_range after
> > dropping the PT lock, the third thread may start writing on the new
> > page, when the guest is still writing to the old page through the
> > sptes. While this couldn't happen with my patch.
> 
> A user space spinlock plays into this??? That is irrelevant to the kernel. 
> And we are discussing "your" placement of the invalidate_range not mine.

With "my" code, invalidate_range wasn't placed there at all, my
modification to ptep_clear_flush already covered it in a automatic
way, grep from the word fremap in my latest patch you won't find it,
like you won't find any change to do_wp_page. Not sure why you keep
thinking I added those invalidate_range when infact you did.

The user space spinlock plays also in declaring rdtscp unworkable to
provide a monotone vgettimeofday w/o kernel locking.

My patch by calling invalidate_page inside ptep_clear_flush guaranteed
that both the thread writing through sptes and the thread writing
through linux ptes, couldn't possibly simultaneously write to two
different physical pages.

Your patch allows the thread writing through linux-pte to write to a
new populated page while the old thread writing through sptes still
writes to the old page. Is that safe? I don't know for sure. The fact
the physical page backing the virtual address could change back and
forth, perhaps invalidates the theory that somebody could possibly do
some useful locking out of it relaying on all threads seeing the same
physical page at the same time.

Anyway as long as invalidate_page/range happens after ptep_clear_flush
things are mostly ok.

> This is the scenario that I described before. You just need two threads.
> One thread is in do_wp_page and the other is writing through the spte. 
> We are in do_wp_page. Meaning the page is not writable. The writer will 

Actually above I was describing remap_file_pages not do_wp_page.

> have to take fault which will properly serialize access. It a bug if the 
> spte would allow write.

In that scenario because write is forbidden (unlike remap_file_pages)
like you said things should be ok. The spte reader will eventually see
the updates happening in the new page, as long as the spte invalidate
happens after ptep_clear_flush (i.e. with my incremental fix applied
to your code, or with my latest patch).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
