Date: Sun, 4 Feb 2007 12:03:17 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 9/9] mm: fix pagecache write deadlocks
Message-ID: <20070204110317.GA9034@wotan.suse.de>
References: <20070204063707.23659.20741.sendpatchset@linux.site> <20070204063833.23659.55105.sendpatchset@linux.site> <20070204014445.88e6c8c7.akpm@linux-foundation.org> <20070204101529.GA22004@wotan.suse.de> <20070204023055.2583fd65.akpm@linux-foundation.org> <20070204104609.GA29943@wotan.suse.de> <20070204025602.a5f8c53a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070204025602.a5f8c53a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Feb 04, 2007 at 02:56:02AM -0800, Andrew Morton wrote:
> On Sun, 4 Feb 2007 11:46:09 +0100 Nick Piggin <npiggin@suse.de> wrote:
> 
> > On Sun, Feb 04, 2007 at 02:30:55AM -0800, Andrew Morton wrote:
> > > On Sun, 4 Feb 2007 11:15:29 +0100 Nick Piggin <npiggin@suse.de> wrote:
> > > 
> > > > The write path is broken. I prefer my kernels slow, than buggy.
> > > 
> > > That won't fly.
> > 
> > What won't fly?
> 
> I suspect the performance cost of this approach would force us to redo it
> all.

That's the idea. But at least in the meantime we're correct.

> > > > That was my second idea.
> > > 
> > > Coulda sworn it was mine ;) I thought you ended up deciding it wasn't
> > > practical because of the games we needed to play with ->commit_write.
> > 
> > Maybe I misunderstood what you meant, above.
> 
> The original set of half-written patches I sent you.  Do an atomic copy_from_user()
> inside the page lock and if that fails, zero out the remainder of the page, run
> commit_write() and then redo the whole thing.

Oh that. Data corruption, transient zeroes.

> > I have an alterative fix
> > where a temporary page is allocated if the write enncounters a non
> > uptodate page. The usercopy then goes into that page, and from there
> > into the target page after we have opened the prepare_write().
> 
> Remember that a non-uptodate page is the common case.

Yes.

> 
> > My *first* idea to fix this was to do the atomic copy into a non-uptodate
> > page and then calling a zero-length commit_write if it failed. I pretty
> > carefully constructed all these good arguments as to why each case works
> > properly, but in the end it just didn't fly because it broke lots of
> > filesystems.
> 
> I forget the details now.  I think we did have a workable-looking solution
> based on the atomic copy_from_user() but it would have re-exposed the old
> problem wherein a page would fleetingly have a bunch of zeroes in the
> middle of it, if someone looked at it during the write.
> 
> If that recollection is right, I think we could afford to reintroduce that
> problem, frankly.  Especially as it only happens in the incredibly rare
> case of that get_user()ed page getting unmapped under our feet.

Dang. I was hoping to fix it without introducing data corruption.

> > > > but you introduce the theoretical memory deadlock
> > > > where a task cannot reclaim its own memory.
> > > 
> > > Nah, that'll never happen - both pages are already allocated.
> > 
> > Both pages? I don't get it.
> > 
> > You set the don't-reclaim vma flag, then run get_user, which takes a
> > page fault and potentially has to allocate N pages for pagetables,
> > pagecache readahead, buffers and fs private data and pagecache radix
> > tree nodes for all of the pages read in.
> 
> Oh, OK.  Need to do the get_user() twice then.  Once before taking that new
> rwsem.

Race condition remains.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
