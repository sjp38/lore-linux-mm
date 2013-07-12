Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id BF0DD6B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 16:51:53 -0400 (EDT)
Received: by mail-vb0-f52.google.com with SMTP id f12so1887146vbg.39
        for <linux-mm@kvack.org>; Fri, 12 Jul 2013 13:51:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130712094957.GS25631@dyad.programming.kicks-ass.net>
References: <1373596462-27115-1-git-send-email-ccross@android.com>
	<1373596462-27115-2-git-send-email-ccross@android.com>
	<51DF9682.9040301@kernel.org>
	<20130712081348.GM25631@dyad.programming.kicks-ass.net>
	<20130712081717.GN25631@dyad.programming.kicks-ass.net>
	<20130712084406.GB4328@gmail.com>
	<20130712090046.GP25631@dyad.programming.kicks-ass.net>
	<20130712091506.GA5315@gmail.com>
	<20130712092707.GR25631@dyad.programming.kicks-ass.net>
	<20130712094044.GD5315@gmail.com>
	<20130712094957.GS25631@dyad.programming.kicks-ass.net>
Date: Fri, 12 Jul 2013 13:51:52 -0700
Message-ID: <CAMbhsRR+ws-psQ8UA9ufekUo9J15cRQE=X-b2+fmfCcCoHQ2tg@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: add a field to store names for private anonymous memory
From: Colin Cross <ccross@android.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>, Pekka Enberg <penberg@kernel.org>, lkml <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Dave Hansen <dave.hansen@intel.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Dave Jones <davej@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Oleg Nesterov <oleg@redhat.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Fri, Jul 12, 2013 at 2:49 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Fri, Jul 12, 2013 at 11:40:44AM +0200, Ingo Molnar wrote:
>> * Peter Zijlstra <peterz@infradead.org> wrote:
>>
>> > On Fri, Jul 12, 2013 at 11:15:06AM +0200, Ingo Molnar wrote:
>> > >
>> > > * Peter Zijlstra <peterz@infradead.org> wrote:
>> > >
>> > > > We need those files anyway.. The current proposal is that the entire VMA
>> > > > has a single userspace pointer in it. Or rather a 64bit value.
>> > >
>> > > Yes but accessible via /proc/<PID>/mem or so?
>> >
>> > *shudder*.. yes. But you're again opening two files. The only advantage
>> > of this over userspace writing its own files is that the kernel cleans
>> > things up for you.
>>
>> Opening of the files only occurs in the instrumentation case, which is
>> rare. But temporary files would be forced upon the regular usecase when no
>> instrumentation goes on.
>
> Well, Colin didn't describe the intended use, but I can imagine a case where
> its not all that rare. System health monitors might frequently want to update
> this.
>
>> > However from what I understood android runs apps as individual users,
>> > and I think we can do per user tmpfs mounts. So app dies, user exits,
>> > mount goes *poof*.
>>
>> Yes, user-space could be smarter about temporary files.
>>
>> Just like big banks could be less risk happy.
>>
>> Yet the reality is that if left alone both apps and banks mess up, I don't
>> think libertarianism works for policy: we are better off offering a
>> framework that is simple, robust, self-contained, low risk and hard to
>> mess up?
>
> Fair enough; but I still want Colin to tell me why he can't do this in
> userspace. And what all he wants to go do with this information etc.
>
> He's basically not told us much at all.

I covered it a little in the thread on the previous version of the
patch, but I'll try to give more detail (and include it in a patch
stack description if I post another version).

In many userspace applications, and especially in VM based
applications like Android uses heavily, there are multiple different
allocators in use.  At a minimum there is libc malloc and the stack,
and in many cases there are libc malloc, the stack, direct syscalls to
mmap anonymous memory, and multiple VM heaps (one for small objects,
one for big objects, etc.).  Each of these layers usually has its own
tools to inspect its usage; malloc by compiling a debug version, the
VM through heap inspection tools, and for direct syscalls there is
usually no way to track them.

On Android we heavily use a set of tools that use an extended version
of the logic covered in Documentation/vm/pagemap.txt to walk all pages
mapped in userspace and slice their usage by process, shared (COW) vs.
unique mappings, backing, etc.  This can account for real physical
memory usage even in cases like fork without exec (which Android uses
heavily to share as many private COW pages as possible between
processes), Kernel SamePage Merging, and clean zero pages.  It
produces a measurement of the pages that only exist in that process
(USS, for unique), and a measurement of the physical memory usage of
that process with the cost of shared pages being evenly split between
processes that share them (PSS).  We need the feature to be efficient
enough to be left on at all times because app developers and end users
can use similar tools exposed through system reports and bugreports to
determine the memory usage of apps

If all anonymous memory is indistinguishable then figuring out the
real physical memory usage of each heap requires either a pagemap
walking tool that can understand the heap debugging of every layer, or
for every layer's heap debugging tools to implement the pagemap
walking logic, in which case it is hard to get a consistent view of
memory across the whole system.

Tracking the information in userspace leads to all sorts of problems.
It either needs to be stored inside the process, which means every
process has to have an API to export its current heap information upon
request, or it has to be stored externally in a filesystem that
somebody needs to clean up on crashes.  It needs to be readable while
the process is still running, so it has to have some sort of
synchronization with every layer of userspace.  Efficiently tracking
the ranges requires reimplementing something like the kernel vma
trees, and linking to it from every layer of userspace.  It requires
more memory, more syscalls, more runtime cost, and more complexity to
separately track regions that the kernel is already tracking.

This feature is considered critical enough that Dalvik (Android's VM)
uses ashmem, which is effectively deleted tmpfs files, solely to name
their heaps.   I'd like to get rid of as much ashmem use within
Android as possible, with an eye towards deprecating it.  ashmem heaps
work reasonably well for a VM, which is likely to want a single
contiguous region of address space that it will manage on its own, but
falls apart for malloc, which often wants small kernel-allocated
address space regions that may or may not merge with adjacent regions.
 Blindly using ashmem/deleted tmpfs files instead of anonymous mmaps
in malloc doubled the number of vmas in our main system process and
was worse for the GLBenchmark process.

As a concrete example of its usefulness (which should not be
considered the extent of its usefulness, it's just what I happened to
be looking at), I was recently tracking down why we were seeing many
dirty private pages that were all zeroes being merged by KSM.  Using a
mixture of ashmem naming and an early version of this patch, I could
slice the the number of KSM merged pages per process and per heap,
which then told me which heap debugging tools I should use to find who
was dirtying large regions of zeroes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
