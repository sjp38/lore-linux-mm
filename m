Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 18A5D5F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 08:55:43 -0500 (EST)
Subject: Re: [BUG??] Deadlock between kswapd and
 sys_inotify_add_watch(lockdep  report)
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <28c262360902020543we62e394kb21c16f599824552@mail.gmail.com>
References: <20090202101735.GA12757@barrios-desktop>
	 <28c262360902020225w6419089ft2dda30da9dfb32a9@mail.gmail.com>
	 <1233571202.4787.124.camel@laptop> <20090202112721.GA13532@barrios-desktop>
	 <1233575085.4787.140.camel@laptop> <20090202115627.GB13532@barrios-desktop>
	 <1233580147.4787.207.camel@laptop>
	 <28c262360902020543we62e394kb21c16f599824552@mail.gmail.com>
Content-Type: text/plain
Date: Mon, 02 Feb 2009 14:55:37 +0100
Message-Id: <1233582937.4787.217.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: Nick Piggin <npiggin@suse.de>, linux kernel <linux-kernel@vger.kernel.org>, linux mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-02-02 at 22:43 +0900, MinChan Kim wrote:
> On Mon, Feb 2, 2009 at 10:09 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> > On Mon, 2009-02-02 at 20:56 +0900, MinChan Kim wrote:
> >> Thanks for kind explanation. :)
> >> Unfortunately, I still have a question. :(
> >
> > No problem :-)
> >
> >> > > I think if reclaim context which have GFP_FS already have lock A and then
> >> > > do pageout, if writepage need the lock A, we have to catch such a case.
> >> > > I thought Nick's patch's goal catchs such a case.
> >> >
> >> > Correct, it exactly does that.
> >>
> >> But, I think such a case can be caught by lockdep of recursive detection
> >> which is existed long time ago by making you.
> >
> > (Ingo wrote that code)
> >
> >> what's difference Nick's patch and recursive lockdep ?
> >
> > Very good question indeed. Every time I started to write an answer I
> > realize its wrong.
> >
> > The below is half the answer:
> >
> > /*
> >  * Check whether we are holding such a class already.
> >  *
> >  * (Note that this has to be done separately, because the graph cannot
> >  * detect such classes of deadlocks.)
> >  *
> >  * Returns: 0 on deadlock detected, 1 on OK, 2 on recursive read
> >  */
> > static int
> > check_deadlock(struct task_struct *curr, struct held_lock *next,
> >               struct lockdep_map *next_instance, int read)
> >
> > So in order for the reclaim report to trigger we have to actually hit
> > that code path that has the recursion in it. The reclaim context
> > annotation by Nick ensures we detect such cases without having to do
> > that.
> 
> In my case and Nick's patch's example hit code path that has the
> recursion in it.
> then reported it.
> 
> Do I miss something ?

I'm not sure I fully understand your question, but let me try and
explain more clearly.

Without Nick's patch you'd have to hit the following path:

  mutex_lock()  <--- inotify_mutex
  inotify_inode_is_dead()
  dentry_iput()
  d_kill()
  __shrink_dcache_sb()
  shrink_dcache_memory()
  shrink_slab()
  try_to_free_page() <-- direct reclaim
  alloc_pages()
  alloc_slab_page()
  allocate_slab()
  new_slab()
  __slab_alloc()
  kmem_cache_alloc()
  idr_pre_get()
  inotify_handle_get_wd()
  inotify_add_watch() <-- inotify_mutex
  sys_inotify_add_watch()
  syscall_call

before the recursive check would actually produce a warning.

This path is very unlikely, as it would have to enter direct reclaim
from exactly the right allocation.

With Nick's patch, we get notified about this possibility without ever
having had to actually hit this.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
