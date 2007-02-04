Date: Sun, 4 Feb 2007 11:46:09 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 9/9] mm: fix pagecache write deadlocks
Message-ID: <20070204104609.GA29943@wotan.suse.de>
References: <20070204063707.23659.20741.sendpatchset@linux.site> <20070204063833.23659.55105.sendpatchset@linux.site> <20070204014445.88e6c8c7.akpm@linux-foundation.org> <20070204101529.GA22004@wotan.suse.de> <20070204023055.2583fd65.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070204023055.2583fd65.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Feb 04, 2007 at 02:30:55AM -0800, Andrew Morton wrote:
> On Sun, 4 Feb 2007 11:15:29 +0100 Nick Piggin <npiggin@suse.de> wrote:
> 
> > The write path is broken. I prefer my kernels slow, than buggy.
> 
> That won't fly.

What won't fly?

> 
> > > There's a build error in filemap_xip.c btw.
> 
> ?

Thanks?

> > > What happened to the idea of doing an atomic copy into the non-uptodate
> > > page and handling it somehow?
> > 
> > That was my second idea.
> 
> Coulda sworn it was mine ;) I thought you ended up deciding it wasn't
> practical because of the games we needed to play with ->commit_write.

Maybe I misunderstood what you meant, above. I have an alterative fix
where a temporary page is allocated if the write enncounters a non
uptodate page. The usercopy then goes into that page, and from there
into the target page after we have opened the prepare_write().

My *first* idea to fix this was to do the atomic copy into a non-uptodate
page and then calling a zero-length commit_write if it failed. I pretty
carefully constructed all these good arguments as to why each case works
properly, but in the end it just didn't fly because it broke lots of
filesystems.

> > > Another option might be to effectively pin the whole mm during the copy:
> > > 
> > > 	down_read(&current->mm->unpaging_lock);
> > > 	get_user(addr);		/* Fault the page in */
> > > 	...
> > > 	copy_from_user()
> > > 	up_read(&current->mm->unpaging_lock);
> > > 
> > > then, anyone who wants to unmap pages from this mm requires
> > > write_lock(unpaging_lock).  So we know the results of that get_user()
> > > cannot be undone.
> > 
> > Fugly.
> 
> I invited you to think different - don't just fixate on one random
> tossed-out-there suggestion.

I've thought. Quite a lot. I have 2 other approaches that don't require
mmap_sem, and 1 which is actually possible to implement without breaking
filesystems.

> > but you introduce the theoretical memory deadlock
> > where a task cannot reclaim its own memory.
> 
> Nah, that'll never happen - both pages are already allocated.

Both pages? I don't get it.

You set the don't-reclaim vma flag, then run get_user, which takes a
page fault and potentially has to allocate N pages for pagetables,
pagecache readahead, buffers and fs private data and pagecache radix
tree nodes for all of the pages read in.

> It's better than taking mmap_sem and walking pagetables...

I'm not convinced.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
