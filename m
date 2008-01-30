Date: Wed, 30 Jan 2008 08:43:06 -0600
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address ranges
Message-ID: <20080130144305.GA25193@sgi.com>
References: <20080129162004.GL7233@v2.random> <Pine.LNX.4.64.0801291153520.25300@schroedinger.engr.sgi.com> <20080129211759.GV7233@v2.random> <Pine.LNX.4.64.0801291327330.26649@schroedinger.engr.sgi.com> <20080129220212.GX7233@v2.random> <Pine.LNX.4.64.0801291407380.27104@schroedinger.engr.sgi.com> <20080130000039.GA7233@v2.random> <Pine.LNX.4.64.0801291620170.28027@schroedinger.engr.sgi.com> <20080130002804.GA13840@sgi.com> <20080130133720.GM7233@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080130133720.GM7233@v2.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Christoph Lameter <clameter@sgi.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2008 at 02:37:20PM +0100, Andrea Arcangeli wrote:
> On Tue, Jan 29, 2008 at 06:28:05PM -0600, Jack Steiner wrote:
> > On Tue, Jan 29, 2008 at 04:20:50PM -0800, Christoph Lameter wrote:
> > > On Wed, 30 Jan 2008, Andrea Arcangeli wrote:
> > > 
> > > > > invalidate_range after populate allows access to memory for which ptes 
> > > > > were zapped and the refcount was released.
> > > > 
> > > > The last refcount is released by the invalidate_range itself.
> > > 
> > > That is true for your implementation and to address Robin's issues. Jack: 
> > > Is that true for the GRU?
> > 
> > I'm not sure I understand the question. The GRU never (currently) takes
> > a reference on a page. It has no mechanism for tracking pages that
> > were exported to the external TLBs.
> 
> If you don't have a pin, then things like invalidate_range in
> remap_file_pages can't be safe as writes through the external TLBs can
> keep going on pages in the freelist. For you to be safe w/o a
> page-pin, you need to return in the direction of invalidate_page
> inside ptep_clear_flush (or anyway before
> page_cache_release/__free_page/put_page...). You're generally not safe
> with any invalidate_range that may run after the page pointed by the
> pte has been freed (or can be freed by the VM anytime because of being
> unpinned cache).

Yuck....

I see what you mean. I need to review to mail to see why this changed
but in the original discussions with Christoph, the invalidate_range
callouts were suppose to be made BEFORE the pages were put on the freelist.


--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
