Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7B9F66B00C6
	for <linux-mm@kvack.org>; Sat,  9 May 2009 10:05:39 -0400 (EDT)
Date: Sat, 9 May 2009 16:05:12 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] tracing/mm: add page frame snapshot trace
Message-ID: <20090509140512.GA22000@elte.hu>
References: <20090508105320.316173813@intel.com> <20090508111031.020574236@intel.com> <20090508114742.GB17129@elte.hu> <20090508124433.GB15949@localhost> <20090509062758.GB21354@elte.hu> <20090509091325.GA7994@localhost> <20090509100137.GC20941@elte.hu> <20090509105742.GA8398@localhost> <20090509110513.GD16138@elte.hu> <20090509122309.GC8940@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090509122309.GC8940@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: =?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Wu Fengguang <fengguang.wu@intel.com> wrote:

> > ( End even for tasks, which are perhaps the hardest to iterate, we
> >   can still do the /proc method of iterating up to the offset by 
> >   counting. It wastes some time for each separate thread as it has 
> >   to count up to its offset, but it still allows the dumping itself
> >   to be parallelised. Or we could dump blocks of the PID hash array. 
> >   That distributes tasks well, and can be iterated very easily with 
> >   low/zero contention. The result will come out unordered in any 
> >   case. )
> 
> For task/file based page walking, the best parallelism unit can be 
> the task/file, instead of page segments inside them.
> 
> And there is the sparse file problem. There will be large holes in 
> the address space of file and process(and even physical memory!).

If we want to iterate in the file offset space then we should use 
the find_get_pages() trick: use the page radix tree and do gang 
lookups in ascending order. Holes will be skipped over in a natural 
way in the tree.

Regarding iterators, i think the best way would be to expose a 
number of 'natural iterators' in the object collection directory. 
The current dump_range could be changed to "pfn_index" (it's really 
a 'physical page number' index and iterator), and we could introduce 
a couple of other indices as well:

    /debug/tracing/objects/mm/pages/pfn_index
    /debug/tracing/objects/mm/pages/filename_index
    /debug/tracing/objects/mm/pages/sb_index
    /debug/tracing/objects/mm/pages/task_index

"filename_index" would take a file name (a string), and would dump 
all pages of that inode - perhaps with an additional index/range 
parameter as well. For example:

    echo "/home/foo/bar.txt 0 1000" > filename_index

Would look up that file and dump any pages in the page cache related 
to that file, in the 0..1000 pages offset range.

( We could support the 'batching' of such requests too, so 
  multi-line strings can be used to request multiple files, via a 
  single system call.

  We could perhaps even support directories and do 
  directory-and-all-child-dentries/inodes recursive lookups. )

Other indices/iterators would work like this:

    echo "/var" > sb_index

Would try to find the superblock associated to /var, and output all 
pages that relate to that superblock. (it would iterate over all 
inodes and look them all up in the pagecache and dump any matches)

Alternatively, we could do a reverse look up for the inode from the 
pfn, and output that name. That would bloat the records a bit, and 
would be more costly as well.

The 'task_index' would output based on a PID, it would find the mm 
of that task and dump all pages associated to that mm. Offset/range 
info would be virtual address page index based.

Are these things close to what you had in mind?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
