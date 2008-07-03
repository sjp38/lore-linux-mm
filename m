Date: Thu, 3 Jul 2008 18:25:25 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [-mm] BUG: sleeping function called from invalid context at
 include/linux/pagemap.h:290
In-Reply-To: <486C9FBD.9000800@cn.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0807031747470.14783@blonde.site>
References: <486C74B1.3000007@cn.fujitsu.com> <20080703183913.D6DF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
 <486C9FBD.9000800@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik Van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jul 2008, Li Zefan wrote:
> KOSAKI Motohiro wrote:
> >> Seems the problematic patch is :
> >> mmap-handle-mlocked-pages-during-map-remap-unmap.patch
> >>
> >> I'm using mmotm uploaded yesterday by Andrew, so I guess this bug
> >> has not been fixed ?
> >>
> >> BUG: sleeping function called from invalid context at include/linux/pagemap.h:290
> >> in_atomic():1, irqs_disabled():0
> >> no locks held by gpg-agent/2134.
> > 
> > Li-san, I tested 2.6.26-rc8-mm1 on x86_64.
> > but I can't reproduce it.
> > 
> > Could you explain detail of reproduce way?
> > 
> 
> Nothing special. I booted the system up, and entered KDE, and opened xterm,
> and typed "dmesg".
> 
> .config attached.

The reason you're seeing it and others not is because your
CONFIG_HIGHPTE=y
is making the issue visible.

__munlock_pte_handler is trying to lock_page (or migration_entry_wait)
while using the per-cpu kmap_atomic from walk_pte_range's pte_offset_map.
Sleeping functions called from atomic context.

There's quite a lot to worry about there.

That page table walker was originally written to gather some info
for /proc display, not to act upon the page table contents in any
serious way.  So it's just doing pte_offset_map when every(?) other
page table walk would be required to pte_offset_map_lock.  If it
were doing pte_offset_map_lock, then lots more people would have
seen the problem sooner.

Does this usage need to pte_offset_map_lock?  I think to the extent
that it needs to lock_page, it needs to pte_offset_map_lock: both
are because file truncation (or more commonly reclaim, but without
looking into it too carefully, I dare say reclaim isn't a problem
in this context) could interfere with page->mapping and pte at any
instant.

Conveniently, we have not one but two attempts at a generic page
walker (sigh!): the other one, apply_to_page_range in mm/memory.c,
does do the lock; it also allocates a page table if it's not there,
I guess that aspect wouldn't be a problem on an mlocked area.  Maybe
using apply_to_page_range would be better here, and sidestep the
issue of not having CONFIG_PAGE_WALKER.

But if it does pte_offset_map_lock, look, migration_entry_wait does
so too; well, never mind the lock, it'll kunmap_atomic 
Obviously that part cries out for refactoring.

And how do you manage the lock_page?  Offhand, I don't know, I'm
just reporting on the obvious.  Would trylocking be good enough?

(I do dislike "generic page walkers" because they encourage this
kind of oversight; and I hate to think of the latency problems
they might be introducing - no sign of a cond_resched in either.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
