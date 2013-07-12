Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 593EE6B0034
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 04:44:11 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id c1so6084044eek.4
        for <linux-mm@kvack.org>; Fri, 12 Jul 2013 01:44:09 -0700 (PDT)
Date: Fri, 12 Jul 2013 10:44:06 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 2/2] mm: add a field to store names for private anonymous
 memory
Message-ID: <20130712084406.GB4328@gmail.com>
References: <1373596462-27115-1-git-send-email-ccross@android.com>
 <1373596462-27115-2-git-send-email-ccross@android.com>
 <51DF9682.9040301@kernel.org>
 <20130712081348.GM25631@dyad.programming.kicks-ass.net>
 <20130712081717.GN25631@dyad.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130712081717.GN25631@dyad.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Pekka Enberg <penberg@kernel.org>, Colin Cross <ccross@android.com>, linux-kernel@vger.kernel.org, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Dave Hansen <dave.hansen@intel.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Dave Jones <davej@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Oleg Nesterov <oleg@redhat.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>


* Peter Zijlstra <peterz@infradead.org> wrote:

> On Fri, Jul 12, 2013 at 10:13:48AM +0200, Peter Zijlstra wrote:
> > On Fri, Jul 12, 2013 at 08:39:14AM +0300, Pekka Enberg wrote:
> > > On 07/12/2013 05:34 AM, Colin Cross wrote:
> > > >Userspace processes often have multiple allocators that each do
> > > >anonymous mmaps to get memory.  When examining memory usage of
> > > >individual processes or systems as a whole, it is useful to be
> > > >able to break down the various heaps that were allocated by
> > > >each layer and examine their size, RSS, and physical memory
> > > >usage.
> > > >
> > > >This patch adds a user pointer to the shared union in
> > > >vm_area_struct that points to a null terminated string inside
> > > >the user process containing a name for the vma.  vmas that
> > > >point to the same address will be merged, but vmas that
> > > >point to equivalent strings at different addresses will
> > > >not be merged.
> > > >
> > > >Userspace can set the name for a region of memory by calling
> > > >prctl(PR_SET_VMA, PR_SET_VMA_ANON_NAME, start, len, (unsigned long)name);
> > > >Setting the name to NULL clears it.
> > > >
> > > >The names of named anonymous vmas are shown in /proc/pid/maps
> > > >as [anon:<name>] and in /proc/pid/smaps in a new "Name" field
> > > >that is only present for named vmas.  If the userspace pointer
> > > >is no longer valid all or part of the name will be replaced
> > > >with "<fault>".
> > > >
> > > >The idea to store a userspace pointer to reduce the complexity
> > > >within mm (at the expense of the complexity of reading
> > > >/proc/pid/mem) came from Dave Hansen.  This results in no
> > > >runtime overhead in the mm subsystem other than comparing
> > > >the anon_name pointers when considering vma merging.  The pointer
> > > >is stored in a union with fieds that are only used on file-backed
> > > >mappings, so it does not increase memory usage.
> > > >
> > > >Signed-off-by: Colin Cross <ccross@android.com>
> > > 
> > > Ingo, PeterZ, is this something worthwhile for replacing our
> > > current JIT symbol hack with perf?
> > 
> > I really don't see the point of this stuff; in fact I intensely 
> > dislike it as I don't think this is something the kernel needs to do 
> > at all.
> > 
> > Why can't these allocators Collin talks about use file maps and/or 
> > write their own meta-data to file? He is after all only interested in 
> > Android and they have complete control over the entire userspace 
> > stack.
> 
> In fact, nowhere in his entire Changelog does he explain why this needs 
> be in the kernel; _why_ can't userspace do this?
> 
> He needs to go change his allocators to use the new madv syscall anyway, 
> he might as well change them to write the stuff to a local file and be 
> done with it.
> 
> what gives?

It makes tons of sense.

Just like we have a task's cmd-name it makes a lot of sense to name 
objects in a human readable fashion, to help debugging, instrumentation, 
performance analysis, etc.

Yes, in theory user-space could do all that. That's not the point: the 
point is to make it fast, easy enough and to have a central version (the 
kernel).

Doing it via temporary files has various disadvantages:

 - many tools really like to be filesystem invariant (not touch any files 
   even in tmpfs, be able to run in a readonly environment, etc.)

 - the overhead of opening, writing to and closing a file is an order of
   magnitude larger than a single prctl() call. [I'd even argue for such
   user-space tags to be attached to do_mmap(), unfortunately the mmap
   system call argument space is already pretty full. ]

 - stray files hang around (even in tmpfs). Point of instrumentation is to 
   be non-intrusive and as fool-proof as possible. When we are
   debugging problems the last thing we want are extra problems
   and unreliable instrumentation introduced by a fragile temporary file
   solution...

 - user space also tends to get the security model of temporary files
   wrong. static linking makes the user-space version iteration of such
   facilities harder. etc. etc. - there's other disadvantages as well.

So using temporary files is an instrumentation and debugging nightmare 
really. A simple self-contained prctl() variant, with the info stored by 
the kernel is as convenient as it gets.

I guess the real question is not whether it's useful, I think it clearly 
is. The question should be: are there real downsides? Does the addition to 
the anon mmap field blow up the size of vma_struct by a pointer, or is 
there still space?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
