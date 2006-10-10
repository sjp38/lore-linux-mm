Date: Tue, 10 Oct 2006 05:58:51 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: bug in set_page_dirty_buffers
Message-ID: <20061010035851.GK15822@wotan.suse.de>
References: <20061010023654.GD15822@wotan.suse.de> <Pine.LNX.4.64.0610091951350.3952@g5.osdl.org> <20061009202039.b6948a93.akpm@osdl.org> <20061010033412.GH15822@wotan.suse.de> <20061009205030.e247482e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061009205030.e247482e.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linus Torvalds <torvalds@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, Greg KH <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 09, 2006 at 08:50:30PM -0700, Andrew Morton wrote:
> On Tue, 10 Oct 2006 05:34:12 +0200
> Nick Piggin <npiggin@suse.de> wrote:
> > > page->mapping to page_mapping().
> > 
> > I did the switch because that is that its callers and
> > the other spd functions are using to find the mapping.
> 
> Maybe they're wrong?

Well swapcache pages and anonymous pages can have set_page_dirty run
against them. Granted in the current setup, those won't reach
set_page_dirty_buffers, so maybe it isn't needed.

> > the problem is that page_mapping is still free to go NULL at any
> > time, and __set_page_dirty_buffers wasn't checking for that.
> > 
> > If there is another race, then it must be because the buffer code
> > cannot cope with dirty buffers against a truncated page. It is
> > kind of spaghetti, though. What stops set_page_dirty_buffers from
> > racing with block_invalidatepage, for example?
> 
> Nothing that I can think of.  We keep on adding calls to set_page_dirty()
> against unlocked pages.  It would have been better to fix that one case in
> the pte-unmapping path rather than adding heaps more.

I haven't been adding any, so I would love to ;) I think there are
a whole lot more problems than just the unmapping path, though. Direct
IO comes to mind.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
