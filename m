Date: Thu, 14 Aug 2008 15:52:05 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch] mm: dirty page accounting race fix
Message-ID: <20080814135204.GB29727@wotan.suse.de>
References: <20080814094537.GA741@wotan.suse.de> <Pine.LNX.4.64.0808141210200.4398@blonde.site> <1218718149.10800.224.camel@twins> <Pine.LNX.4.64.0808141421550.14452@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0808141421550.14452@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 14, 2008 at 02:39:02PM +0100, Hugh Dickins wrote:
> On Thu, 14 Aug 2008, Peter Zijlstra wrote:
> > On Thu, 2008-08-14 at 12:55 +0100, Hugh Dickins wrote:
> > 
> > > But holding the page table lock on one pte of the
> > > page doesn't guarantee much about the integrity of the whole dance:
> > > do_wp_page does its set_page_dirty_balance for this case, you'd
> > > need to spell out the bad sequence more to convince me.
> >  
> > Now you're confusing me... are you saying ptes can be changed from under
> > your feet even while holding the pte_lock?
> 
> Well, yes, dirty and accessed can be changed from another thread in
> userspace while we hold pt lock in the kernel.  (But dirty could only
> be changed if the pte is writable, and in dirty balancing cases that
> should be being prevented.)
> 
> But no, that isn't what I was thinking of.  pt lock better be enough
> to secure against kernel modifications to the pte.  I was just thinking
> there are (potentially) all those other ptes of the page, and this pte
> may be modified the next instant, it wasn't obvious to me that missing
> the one is so terrible.

If I may... perhaps I didn't explain the race well enough. I'll try to
shed further light on it (or prove myself wrong):

It is true that there are other ptes, and any of those others at any
time may be modified when we don't hold their particular ptl.

But after we clean them, they'll require a page fault to dirty them again,
and we're blocking out page faults (effectively -- see the comments in
clear_page_dirty_for_io and wait_on_page_locked in do_wp_page) by holding
the page lock over the call to clear_page_dirty_for_io.

So if we find and clean a dirty/writable pte, we guarantee it won't get
to the set_page_dirty part of the fault handler until clear_page_dirty_for_io
has done its TestClearPageDirty.

The problem is in the transiently-cleared-but-actually-dirty ptes that may
be seen if not holding ptl will not be made readonly at all. TestClearPageDirty
will clean the page, but we've still got a dirty pte.

HTH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
