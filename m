Date: Tue, 10 Oct 2006 09:30:10 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: bug in set_page_dirty_buffers
Message-ID: <20061010073010.GC14557@wotan.suse.de>
References: <20061010035851.GK15822@wotan.suse.de> <20061009211404.ad112128.akpm@osdl.org> <20061010042144.GM15822@wotan.suse.de> <20061009213806.b158ea82.akpm@osdl.org> <20061010044745.GA24600@wotan.suse.de> <20061009220127.c4721d2d.akpm@osdl.org> <20061010052248.GB24600@wotan.suse.de> <1160462936.27479.4.camel@taijtu> <20061010065927.GA14557@wotan.suse.de> <1160464263.27479.13.camel@taijtu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1160464263.27479.13.camel@taijtu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Linux Memory Management List <linux-mm@kvack.org>, Greg KH <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 10, 2006 at 09:11:03AM +0200, Peter Zijlstra wrote:
> On Tue, 2006-10-10 at 08:59 +0200, Nick Piggin wrote:
> > 
> > What's your problem with zap_pte_range?
> 
> well, not only zap_pte_range, also page_remove_rmap and
> try_to_unmap_cluster etc.. Basically all those who fiddle with the page
> without holding the page lock.

Fiddle with the page -- as in setting it dirty? Because there is a
huge amount of other stuff that fiddles with the page without taking
the lock ;)

> Because with concurrent pagecache, there is no tree lock anymore to
> protect/pin the whole mapping, I need to go pin individual pages.
> Perhaps having an inner page bit-spinlock (PG_pin) isn't a bad thing,
> I'd just raised the issue to see if it would be doable/a-good-thing to
> try and merge these two.

It does seem attractive, but at the moment I can't see how it would
be done. One of the main problems is that truncate / invalidate need
to hold the page locked while traversing the rmaps (which require
i_mmap_lock, ptl locks, etc).

There are other things too, like the swapcache, which uses PG_locked
as an outer lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
