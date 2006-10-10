Date: Tue, 10 Oct 2006 08:19:58 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: bug in set_page_dirty_buffers
Message-ID: <20061010061958.GA25500@wotan.suse.de>
References: <20061010035851.GK15822@wotan.suse.de> <20061009211404.ad112128.akpm@osdl.org> <20061010042144.GM15822@wotan.suse.de> <20061009213806.b158ea82.akpm@osdl.org> <20061010044745.GA24600@wotan.suse.de> <20061009220127.c4721d2d.akpm@osdl.org> <20061010052248.GB24600@wotan.suse.de> <20061009222905.ddd270a6.akpm@osdl.org> <20061010054832.GC24600@wotan.suse.de> <20061009230832.7245814e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061009230832.7245814e.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linus Torvalds <torvalds@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, Greg KH <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 09, 2006 at 11:08:32PM -0700, Andrew Morton wrote:
> On Tue, 10 Oct 2006 07:48:33 +0200
> Nick Piggin <npiggin@suse.de> wrote:
> > 
> > Am I missing something?
> 
> Well it's a matter of reviewing all codepaths in the kernel which
> manipulate internal page state and see if they're racy against their
> ->set_page_dirty().  All because of zap_pte_range().

And page_remove_rmap.

> The page lock protects internal page state.  It'd be better to fix
> zap_pte_range().
> 
> How about we trylock the page and if that fails, back out and drop locks
> and lock the page then dirty it and then resume the zap?  Negligible
> overhead, would be nice and simple apart from that i_mmap_lock thing.

What about page_remove_rmap?

I don't see why. This has been the documented behaviour for ages, and
it seems to be made fairly clear in comments around mm/ and filesystems.
Considering the only nontrivial ->spds are those which set PageChecked
as well, I don't see why there is much to audit (other than fs/buffer.c).

Not that I think it would be a bad idea for filesystems writers to audit
carefully against truncate, because that's been screwed up in the VM for
so long...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
