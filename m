Date: Mon, 9 Oct 2006 21:38:06 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch] mm: bug in set_page_dirty_buffers
Message-Id: <20061009213806.b158ea82.akpm@osdl.org>
In-Reply-To: <20061010042144.GM15822@wotan.suse.de>
References: <20061010023654.GD15822@wotan.suse.de>
	<Pine.LNX.4.64.0610091951350.3952@g5.osdl.org>
	<20061009202039.b6948a93.akpm@osdl.org>
	<20061010033412.GH15822@wotan.suse.de>
	<20061009205030.e247482e.akpm@osdl.org>
	<20061010035851.GK15822@wotan.suse.de>
	<20061009211404.ad112128.akpm@osdl.org>
	<20061010042144.GM15822@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, Greg KH <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Oct 2006 06:21:44 +0200
Nick Piggin <npiggin@suse.de> wrote:

> On Mon, Oct 09, 2006 at 09:14:04PM -0700, Andrew Morton wrote:
> > Can we convert set_page_dirty_balance() to call set_page_dirty_lock()?
> 
> I think so. You can't in zap_pte_range though because you're under
> spinlocks.

There we're screwed.

> Same with try_to_unmap_{one|cluster}, and page_remove_rmap.

There we can trylock all the pages and bale if any fail.


> > And make set_page_dirty_lock() return if the page is already dirty?
> > 
> > > I think there are
> > > a whole lot more problems than just the unmapping path, though. Direct
> > > IO comes to mind.
> > 
> > Why?  direct-io locks the pages while invalidating them, and while marking
> > them dirty.
> 
> Uh, mistaken about dio. Point still stands.

But where?  locking the page is the preferred way to solve this stuff. 
(Well, locking the buffers might work, but isn't needed, and locking the
page covers other stuff)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
