Date: Thu, 14 Aug 2008 20:09:11 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [rfc][patch] mm: dirty page accounting race fix
In-Reply-To: <20080814135204.GB29727@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0808141957440.21555@blonde.site>
References: <20080814094537.GA741@wotan.suse.de> <Pine.LNX.4.64.0808141210200.4398@blonde.site>
 <1218718149.10800.224.camel@twins> <Pine.LNX.4.64.0808141421550.14452@blonde.site>
 <20080814135204.GB29727@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 14 Aug 2008, Nick Piggin wrote:
> 
> If I may...

You're very welcome...

> perhaps I didn't explain the race well enough. I'll try to
> shed further light on it (or prove myself wrong):
> 
> It is true that there are other ptes, and any of those others at any
> time may be modified when we don't hold their particular ptl.
> 
> But after we clean them, they'll require a page fault to dirty them again,
> and we're blocking out page faults (effectively -- see the comments in
> clear_page_dirty_for_io and wait_on_page_locked in do_wp_page) by holding
> the page lock over the call to clear_page_dirty_for_io.

Yes, that's the part of the protocol I was forgetting.  Not exactly
relevant to the mprotect case where your hole opens up, but exactly
the part of it that synchronizes all the ptes with the struct page,
which was worrying me there.

I really ought to read all those private messages to Virginia.
Who is she?  A friend of Paige McWright, perhaps?

> 
> So if we find and clean a dirty/writable pte, we guarantee it won't get
> to the set_page_dirty part of the fault handler until clear_page_dirty_for_io
> has done its TestClearPageDirty.
> 
> The problem is in the transiently-cleared-but-actually-dirty ptes that may
> be seen if not holding ptl will not be made readonly at all.
> TestClearPageDirty will clean the page, but we've still got a dirty pte.

Yes.  The pte is still marked dirty and writable (after briefly being
absent) and the page may be modified by userspace without entering the
accounting; it will eventually get picked up and written out, but if
we're taking the accounting seriously we ought to fix the hole.

> 
> HTH

Very much so: thank you.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
