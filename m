Date: Tue, 10 Oct 2006 05:42:14 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: bug in set_page_dirty_buffers
Message-ID: <20061010034214.GI15822@wotan.suse.de>
References: <20061010023654.GD15822@wotan.suse.de> <Pine.LNX.4.64.0610091951350.3952@g5.osdl.org> <20061009202039.b6948a93.akpm@osdl.org> <20061009203718.d6a8f803.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061009203718.d6a8f803.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linus Torvalds <torvalds@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, Greg KH <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 09, 2006 at 08:37:18PM -0700, Andrew Morton wrote:
> On Mon, 9 Oct 2006 20:20:39 -0700
> Andrew Morton <akpm@osdl.org> wrote:
> 
> > On Mon, 9 Oct 2006 20:06:05 -0700 (PDT)
> > Linus Torvalds <torvalds@osdl.org> wrote:
> > 
> > > On Tue, 10 Oct 2006, Nick Piggin wrote:
> > > >
> > > > This was triggered, but not the fault of, the dirty page accounting
> > > > patches. Suitable for -stable as well, after it goes upstream.
> > > 
> > > Applied. However, I wonder what protects "page_mapping()" here?
> > 
> > Nothing.  And I don't understand the (unchangelogged) switch from
> > page->mapping to page_mapping().
> > 
> > > I don't 
> > > think we hold the page lock anywhere, so "page->mapping" can change at any 
> > > time, no?
> > 
> > Yes.  The patch makes the race window a bit smaller.
> 
> OK, the address_space is protected from reclaim here by virtue of the
> caller's ref on vma->vm_file (needs a comment).

All callers are required to pin the the inode though. The comment is
on top of set_page_dirty_lock.

I guess you mean a comment in do_no_page? but I thought that was obvious:
zap_pte_range, access_process_vm, etc have been doing this forever.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
