Date: Sun, 4 Feb 2007 03:15:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 9/9] mm: fix pagecache write deadlocks
Message-Id: <20070204031549.203f7b47.akpm@linux-foundation.org>
In-Reply-To: <20070204110317.GA9034@wotan.suse.de>
References: <20070204063707.23659.20741.sendpatchset@linux.site>
	<20070204063833.23659.55105.sendpatchset@linux.site>
	<20070204014445.88e6c8c7.akpm@linux-foundation.org>
	<20070204101529.GA22004@wotan.suse.de>
	<20070204023055.2583fd65.akpm@linux-foundation.org>
	<20070204104609.GA29943@wotan.suse.de>
	<20070204025602.a5f8c53a.akpm@linux-foundation.org>
	<20070204110317.GA9034@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 4 Feb 2007 12:03:17 +0100 Nick Piggin <npiggin@suse.de> wrote:

> On Sun, Feb 04, 2007 at 02:56:02AM -0800, Andrew Morton wrote:
> > On Sun, 4 Feb 2007 11:46:09 +0100 Nick Piggin <npiggin@suse.de> wrote:
> > 
> > > On Sun, Feb 04, 2007 at 02:30:55AM -0800, Andrew Morton wrote:
> > > > On Sun, 4 Feb 2007 11:15:29 +0100 Nick Piggin <npiggin@suse.de> wrote:
> > > > 
> > > > > The write path is broken. I prefer my kernels slow, than buggy.
> > > > 
> > > > That won't fly.
> > > 
> > > What won't fly?
> > 
> > I suspect the performance cost of this approach would force us to redo it
> > all.
> 
> That's the idea. But at least in the meantime we're correct.

There's no way I'd support merging a change which we know we'll have to
redo only we have no clue how.

> > If that recollection is right, I think we could afford to reintroduce that
> > problem, frankly.  Especially as it only happens in the incredibly rare
> > case of that get_user()ed page getting unmapped under our feet.
> 
> Dang. I was hoping to fix it without introducing data corruption.

Well.  It's a compromise.  Being practical about it, I reeeealy doubt that
anyone will hit this combination of circumstances.

> > > > > but you introduce the theoretical memory deadlock
> > > > > where a task cannot reclaim its own memory.
> > > > 
> > > > Nah, that'll never happen - both pages are already allocated.
> > > 
> > > Both pages? I don't get it.
> > > 
> > > You set the don't-reclaim vma flag, then run get_user, which takes a
> > > page fault and potentially has to allocate N pages for pagetables,
> > > pagecache readahead, buffers and fs private data and pagecache radix
> > > tree nodes for all of the pages read in.
> > 
> > Oh, OK.  Need to do the get_user() twice then.  Once before taking that new
> > rwsem.
> 
> Race condition remains.

No, not in a million years.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
