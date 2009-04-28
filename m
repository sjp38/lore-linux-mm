Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4986B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 17:26:33 -0400 (EDT)
Date: Tue, 28 Apr 2009 14:17:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
Message-Id: <20090428141738.77e599f4.akpm@linux-foundation.org>
In-Reply-To: <12c511ca0904281111r10f37a5coe5a2750f4dbfbcda@mail.gmail.com>
References: <20090428010907.912554629@intel.com>
	<20090428014920.769723618@intel.com>
	<20090428065507.GA2024@elte.hu>
	<20090428083320.GB17038@localhost>
	<12c511ca0904281111r10f37a5coe5a2750f4dbfbcda@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Tony Luck <tony.luck@gmail.com>
Cc: fengguang.wu@intel.com, mingo@elte.hu, rostedt@goodmis.org, fweisbec@gmail.com, lwoodman@redhat.com, a.p.zijlstra@chello.nl, penberg@cs.helsinki.fi, eduard.munteanu@linux360.ro, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, andi@firstfloor.org, mpm@selenic.com, adobriyan@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Apr 2009 11:11:52 -0700
Tony Luck <tony.luck@gmail.com> wrote:

> On Tue, Apr 28, 2009 at 1:33 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > 1) FAST
> >
> > It takes merely 0.2s to scan 4GB pages:
> >
> > __ __ __ __./page-types __0.02s user 0.20s system 99% cpu 0.216 total
> 
> OK on a tiny system ... but sounds painful on a big
> server. 0.2s for 4G scales up to 3 minutes 25 seconds
> on a 4TB system (4TB systems were being sold two
> years ago ... so by now the high end will have moved
> up to 8TB or perhaps 16TB).
> 
> Would the resulting output be anything but noise on
> a big system (a *lot* of pages can change state in
> 3 minutes)?
> 

Reading the state of all of memory in this fashion would be a somewhat
peculiar thing to do.  Bear in mind that kpagemap and friends are also
designed to allow userspace to inspect the state of a particular
process's memory.

Documentation/vm/pagemap.txt describes it nicely:

: The general procedure for using pagemap to find out about a process' memory
: usage goes like this:
: 
:  1. Read /proc/pid/maps to determine which parts of the memory space are
:     mapped to what.
:  2. Select the maps you are interested in -- all of them, or a particular
:     library, or the stack or the heap, etc.
:  3. Open /proc/pid/pagemap and seek to the pages you would like to examine.
:  4. Read a u64 for each page from pagemap.
:  5. Open /proc/kpagecount and/or /proc/kpageflags.  For each PFN you just
:     read, seek to that entry in the file, and read the data you want.

although I expect that this is not the use case when the feature is
being used to debug/tune readahead.

But yes, if you have huge amounts of memory and you decide to write an
application which inspects the state of every physical page in the
machine, you can expect it to take a long time!

Of course, the VM does also accumulate bulk aggregated page statistics
and presents them in /proc/meminfo, /proc/vmstat and probably other
places.  These numbers are maintained at runtime and the cost of doing
this is significant.

I don't _think_ there are presently any such counters which are
accumulated simply for instrumentation purposes - the kernel needs to
maintain them anyway for various reasons and it's a simple (and useful)
matter to make them available to userspace.


Generally, I think that pagemap is another of those things where we've
failed on the follow-through.  There's a nice and powerful interface
for inspecting the state of a process's VM, but nobody knows about it
and there are no tools for accessing it and nobody is using it.

(Or maybe I'm wrong about that - I expect I'd have bugged Matt about
this and I expect that he'd have done something.  Brain failed).

Either way, I think we'd serve the world better if we were to have some
nice little userspace tools which users could use to access this
information.  Documentation/vm already has a Makefile!

Fengguang, you mention an executable called "page-types".  Perhaps you
could "productise" that sometime?

A model here is Documentation/accounting/getdelays.c - that proved
quite useful and successful in the development of taskstats and I know
that several people are actually using getdelays.c as-is in serious
production environments.  If we hadn't provided and maintained that
code in the kernel tree, it's unlikely that taskstats would have proved
as useful to users.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
