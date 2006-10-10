Date: Tue, 10 Oct 2006 08:59:27 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: bug in set_page_dirty_buffers
Message-ID: <20061010065927.GA14557@wotan.suse.de>
References: <20061010033412.GH15822@wotan.suse.de> <20061009205030.e247482e.akpm@osdl.org> <20061010035851.GK15822@wotan.suse.de> <20061009211404.ad112128.akpm@osdl.org> <20061010042144.GM15822@wotan.suse.de> <20061009213806.b158ea82.akpm@osdl.org> <20061010044745.GA24600@wotan.suse.de> <20061009220127.c4721d2d.akpm@osdl.org> <20061010052248.GB24600@wotan.suse.de> <1160462936.27479.4.camel@taijtu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1160462936.27479.4.camel@taijtu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Linux Memory Management List <linux-mm@kvack.org>, Greg KH <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 10, 2006 at 08:48:56AM +0200, Peter Zijlstra wrote:
> On Tue, 2006-10-10 at 07:22 +0200, Nick Piggin wrote:
> > 
> > I disagree because it will lead to horrible hacks because many callers
> > can't sleep. If anything I would much prefer an innermost-spinlock in
> > page->flags that specifically excludes truncate. Actually tree_lock can
> > do that now, provided we pin mapping in all callers to set_page_dirty
> > (which we should do).
> 
> Yeah, but we're hard working to eradicate tree lock; I have ran into

Well yeah, but until then the tree_lock works.

> this problem before; that is, zap_pte_range and co. not being able to
> lock the page. I'd really like to see that fixed.

What's your problem with zap_pte_range?

> In my current concurrent pagecache patches I've abused your PG_nonewrefs
> and made it this page internal (bit)spinlock, but it just doesn't look
> nice to have both this lock and PG_locked.

Regardless of whether or not they spin, PG_locked is an outermost, and
set_page_dirty is called innermost. I don't see why we'd particularly
want to mush them together now, just because we're worried a filesystem
writer wrote buggy code.

It is all well and good to tell me I'm wrong unless I audit all
filesystems, but the fact is that I'm not a filesystem expert, and if
this is what it has come to then either the process has failed, or
we have a large number of filesystems to cull from the tree as
unmaintained.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
