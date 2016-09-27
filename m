Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 09A4D280252
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 05:52:16 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id o21so24664798itb.2
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 02:52:16 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id t205si2687046iod.210.2016.09.27.02.52.14
        for <linux-mm@kvack.org>;
        Tue, 27 Sep 2016 02:52:15 -0700 (PDT)
Date: Tue, 27 Sep 2016 18:52:06 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: page_waitqueue() considered harmful
Message-ID: <20160927095206.GA12598@bbox>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
 <20160927073055.GM2794@worktop>
 <20160927085412.GD2838@techsingularity.net>
 <20160927091117.GA23640@node.shutemov.name>
MIME-Version: 1.0
In-Reply-To: <20160927091117.GA23640@node.shutemov.name>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Tue, Sep 27, 2016 at 12:11:17PM +0300, Kirill A. Shutemov wrote:
> On Tue, Sep 27, 2016 at 09:54:12AM +0100, Mel Gorman wrote:
> > On Tue, Sep 27, 2016 at 09:30:55AM +0200, Peter Zijlstra wrote:
> > > > Also, if those bitlock ops had a different bit that showed contention,
> > > > we could actually skip *all* of this, and just see that "oh, nobody is
> > > > waiting on this page anyway, so there's no point in looking up those
> > > > wait queues". We don't have that many "__wait_on_bit()" users, maybe
> > > > we could say that the bitlocks do have to haev *two* bits: one for the
> > > > lock bit itself, and one for "there is contention".
> > > 
> > > That would be fairly simple to implement, the difficulty would be
> > > actually getting a page-flag to use for this. We're running pretty low
> > > in available bits :/
> > 
> > Simple is relative unless I drastically overcomplicated things and it
> > wouldn't be the first time. 64-bit only side-steps the page flag issue
> > as long as we can live with that.
> 
> Looks like we don't ever lock slab pages. Unless I miss something.
> 
> We can try to use PG_locked + PG_slab to indicate contation.
> 
> I tried to boot kernel with CONFIG_SLUB + BUG_ON(PageSlab()) in
> trylock/unlock_page() codepath. Works fine, but more inspection is
> required.

SLUB used bit_spin_lock via slab_lock instead of trylock/unlock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
