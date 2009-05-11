Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9163E6B003D
	for <linux-mm@kvack.org>; Mon, 11 May 2009 08:01:59 -0400 (EDT)
Date: Mon, 11 May 2009 14:01:38 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] tracing/mm: add page frame snapshot trace
Message-ID: <20090511120138.GD4748@elte.hu>
References: <20090508114742.GB17129@elte.hu> <20090508124433.GB15949@localhost> <20090509062758.GB21354@elte.hu> <20090509091325.GA7994@localhost> <20090509100137.GC20941@elte.hu> <20090509105742.GA8398@localhost> <20090509110513.GD16138@elte.hu> <20090509122309.GC8940@localhost> <20090509140512.GA22000@elte.hu> <20090510083517.GB5794@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090510083517.GB5794@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: =?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Wu Fengguang <fengguang.wu@intel.com> wrote:

> On Sat, May 09, 2009 at 10:05:12PM +0800, Ingo Molnar wrote:
> > 
> > * Wu Fengguang <fengguang.wu@intel.com> wrote:
> > 
> > > > ( End even for tasks, which are perhaps the hardest to iterate, we
> > > >   can still do the /proc method of iterating up to the offset by 
> > > >   counting. It wastes some time for each separate thread as it has 
> > > >   to count up to its offset, but it still allows the dumping itself
> > > >   to be parallelised. Or we could dump blocks of the PID hash array. 
> > > >   That distributes tasks well, and can be iterated very easily with 
> > > >   low/zero contention. The result will come out unordered in any 
> > > >   case. )
> > > 
> > > For task/file based page walking, the best parallelism unit can be 
> > > the task/file, instead of page segments inside them.
> > > 
> > > And there is the sparse file problem. There will be large holes in 
> > > the address space of file and process(and even physical memory!).
> > 
> > If we want to iterate in the file offset space then we should use 
> > the find_get_pages() trick: use the page radix tree and do gang 
> > lookups in ascending order. Holes will be skipped over in a natural 
> > way in the tree.
> 
> Right. I actually have code doing this, very neat trick.
> 
> > Regarding iterators, i think the best way would be to expose a 
> > number of 'natural iterators' in the object collection directory. 
> > The current dump_range could be changed to "pfn_index" (it's really 
> > a 'physical page number' index and iterator), and we could introduce 
> > a couple of other indices as well:
> > 
> >     /debug/tracing/objects/mm/pages/pfn_index
> >     /debug/tracing/objects/mm/pages/filename_index
> >     /debug/tracing/objects/mm/pages/task_index
> >     /debug/tracing/objects/mm/pages/sb_index
> 
> How about 
> 
>      /debug/tracing/objects/mm/pages/walk-pfn
>      /debug/tracing/objects/mm/pages/walk-file
>      /debug/tracing/objects/mm/pages/walk-task
> 
>      /debug/tracing/objects/mm/pages/walk-fs
>      (fs may be a more well known name than sb?)
> 
> They begin with a verb, because they are verbs when we echo some
> parameters into them ;-)

yeah, good idea :) I saw the _index naming ugliness but couldnt 
think of a better strategy straight away. 'Use verbs for iterators, 
dummy' is the answer ;-)

> > "filename_index" would take a file name (a string), and would dump 
> > all pages of that inode - perhaps with an additional index/range 
> > parameter as well. For example:
> > 
> >     echo "/home/foo/bar.txt 0 1000" > filename_index
> 
> Better to use
> 
>      "0 1000 /home/foo/bar.txt"
> 
> because there will be files named "/some/file 001".

ok, good point!

> But then echo will append an additional '\n' to filename and we 
> are faced with the question whether to ignore the trailing '\n'.

Yeah, we should ignore the first trailing \n, thus \n can be forced 
in a filename by trailing it with \n\n. Btw., is there any 
legitimate software that generates \n into pathnames?

> > Would look up that file and dump any pages in the page cache related 
> > to that file, in the 0..1000 pages offset range.
> > 
> > ( We could support the 'batching' of such requests too, so 
> >   multi-line strings can be used to request multiple files, via a 
> >   single system call.
> 
> Yes, I'd expect it to make some difference in efficiency, when 
> there are many small files.

yeah.

> >   We could perhaps even support directories and do 
> >   directory-and-all-child-dentries/inodes recursive lookups. )
> 
> Maybe, could do this when there comes such a need.
> 
> > Other indices/iterators would work like this:
> > 
> >     echo "/var" > sb_index
> > 
> > Would try to find the superblock associated to /var, and output 
> > all pages that relate to that superblock. (it would iterate over 
> > all inodes and look them all up in the pagecache and dump any 
> > matches)
> 
> Can we buffer so much outputs in kernel? Even if ftrace has no 
> such limitations, it may not be a good idea to pin too many pages 
> in the ring buffer.

Yes, we can even avoid the ring-buffer and create a small (but 
reasonably sized), dedicated one for each iterator.

It is a question whether we want to have multiple, parallel sessions 
of output pairs. It would be nice to allow it, but that needs some 
extra handshaking or ugly unix domain socket tricks.

Perhaps one simple thing would allow this: output to the same fd 
that gives the input? Not sure how scriptable this would be though, 
as the read() has to block until all output has been generated.

> I do need this feature. But it sounds like a mixture of
> "files-inside-sb" walker and "pages-inside-file" walker. 
> It's unclear how it will duplicate functions with the
> "files object collection" to be added in:
> 
>         /debug/tracing/objects/mm/files/*
> 
> For example,
> 
>         /debug/tracing/objects/mm/files/walk-fs
>         /debug/tracing/objects/mm/files/walk-dirty
>         /debug/tracing/objects/mm/files/walk-global
> and some filtering options, like size, cached_size, etc.

the walkers themselves will one-off functions for sure. This is 
inevitable, unless we convert the kernel to C++ ;-)

But that's not a big issue: each walker will be useful and the 
walking part will be relatively simple. As long as the rest of the 
infrastructure around it is librarized to the max, it will all look 
tidy and supportable.

And it sure beats having to keep:

 /proc
 /files-dirty
 /files-all
 /filesystems
 /pages

convoluted directory hierarchies just to walk along each index.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
