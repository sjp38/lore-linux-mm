Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 414E66B0047
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 11:39:30 -0500 (EST)
Date: Tue, 23 Feb 2010 08:39:26 -0800
From: Andy Isaacson <adi@hexapodia.org>
Subject: Re: [PATCH] fs: add fincore(2) (mincore(2) for file descriptors)
Message-ID: <20100223163926.GC18096@hexapodia.org>
References: <20100216181312.GA9700@frostnet.net> <20100221030238.GA26511@hexapodia.org> <20100221032533.GB14056@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100221032533.GB14056@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Chris Frost <chris@frostnet.net>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Benny Halevy <bhalevy@panasas.com>, "Andrew@firstfloor.org" <Andrew@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Steve VanDeBogart <vandebo-lkml@nerdbox.net>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Sun, Feb 21, 2010 at 11:25:33AM +0800, Wu Fengguang wrote:
> Andy and Chris,
> On Sun, Feb 21, 2010 at 11:02:38AM +0800, Andy Isaacson wrote:
> > On Tue, Feb 16, 2010 at 10:13:12AM -0800, Chris Frost wrote:
> > > Add the fincore() system call. fincore() is mincore() for file descriptors.
> > > 
> > > The functionality of fincore() can be emulated with an mmap(), mincore(),
> > > and munmap(), but this emulation requires more system calls and requires
> > > page table modifications. fincore() can provide a significant performance
> > > improvement for non-sequential in-core queries.
> > 
> > In addition to being expensive, mmap/mincore/munmap perturb the VM's
> > eviction algorithm -- a page is less likely to be evicted if it's
> > mmapped when being considered for eviction.
> > 
> > I frequently see this happen when using mincore(1) from
> > http://bitbucket.org/radii/mincore/ -- "watch mincore -v *.big" while
> > *.big are being sequentially read results in a significant number of
> > pages remaining in-core, whereas if I only run mincore after the
> > sequential read is complete, the large files will be nearly-completely
> > out of core (except for the tail of the last file, of course).
> > 
> > It's very interesting to watch
> > % watch --interval=.5 mincore -v *
> > 
> > while an IO-intensive process is happening, such as mke2fs on a
> > filesystem image.
> > 
> > So, I support the addition of fincore(2) and would use it if it were
> > merged.
> 
> I'd like to advocate the "pagecache object collections", a ftrace
> based alternative:
> 
>         http://lkml.org/lkml/2010/2/9/156
> 
> Which will provide much more information than fincore(). I'd really
> appreciate it if you can join and use the general "pagecache object
> collections" facility.

1. The ftrace alternative appears to require root.  That's a complete
   non-starter for my use case.

2. I can imagine advocating that other UNIXes adopt fincore.  It's
   unrealistic to pretend that other UNIXes will adopt our trace/
   infrastructure.  (If anything we should have adopted DTrace.)

3. It appears to expose a significantly more complicated userland API.
   (But this doesn't matter until (1) is addressed.)  Also, it looks
   like it'll be a lot more expensive for high-frequency queries.  Note
   that in the library-helper use case, the library implementation may
   be limited by its exposed API from leaving filedescriptors open
   across calls.  Does ftrace really require the kernel to format data
   to ASCII so that it can be fscanf()ed by userland?  I hope that's
   just a convenience and there's a binary output path.

4. How committed is the ftrace API and ABI?  Is it guaranteed to
   continue to be supported for the next 2 decades?

I'd much rather have the simple, supportible, explainable, performant
API that fits in well to the standard UNIX paradigm than to add
dependencies on Linux-specific APIs that appear to be in extreme flux.

My apologies if I've missed anything in the above, please let me know if
I'm wrong.

Thanks,
-andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
