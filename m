Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4A8126B0047
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 05:24:43 -0400 (EDT)
Date: Tue, 28 Apr 2009 11:24:54 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
Message-ID: <20090428092454.GB21085@elte.hu>
References: <20090428010907.912554629@intel.com> <20090428014920.769723618@intel.com> <20090428065507.GA2024@elte.hu> <20090428083320.GB17038@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090428083320.GB17038@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, =?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Larry Woodman <lwoodman@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Wu Fengguang <fengguang.wu@intel.com> wrote:

> On Tue, Apr 28, 2009 at 08:55:07AM +0200, Ingo Molnar wrote:
> > 
> > * Wu Fengguang <fengguang.wu@intel.com> wrote:
> > 
> > > Export 9 page flags in /proc/kpageflags, and 8 more for kernel developers.
> > > 
> > > 1) for kernel hackers (on CONFIG_DEBUG_KERNEL)
> > >    - all available page flags are exported, and
> > >    - exported as is
> > > 2) for admins and end users
> > >    - only the more `well known' flags are exported:
> > > 	11. KPF_MMAP		(pseudo flag) memory mapped page
> > > 	12. KPF_ANON		(pseudo flag) memory mapped page (anonymous)
> > > 	13. KPF_SWAPCACHE	page is in swap cache
> > > 	14. KPF_SWAPBACKED	page is swap/RAM backed
> > > 	15. KPF_COMPOUND_HEAD	(*)
> > > 	16. KPF_COMPOUND_TAIL	(*)
> > > 	17. KPF_UNEVICTABLE	page is in the unevictable LRU list
> > > 	18. KPF_HWPOISON	hardware detected corruption
> > > 	19. KPF_NOPAGE		(pseudo flag) no page frame at the address
> > > 
> > > 	(*) For compound pages, exporting _both_ head/tail info enables
> > > 	    users to tell where a compound page starts/ends, and its order.
> > > 
> > >    - limit flags to their typical usage scenario, as indicated by KOSAKI:
> > > 	- LRU pages: only export relevant flags
> > > 		- PG_lru
> > > 		- PG_unevictable
> > > 		- PG_active
> > > 		- PG_referenced
> > > 		- page_mapped()
> > > 		- PageAnon()
> > > 		- PG_swapcache
> > > 		- PG_swapbacked
> > > 		- PG_reclaim
> > > 	- no-IO pages: mask out irrelevant flags
> > > 		- PG_dirty
> > > 		- PG_uptodate
> > > 		- PG_writeback
> > > 	- SLAB pages: mask out overloaded flags:
> > > 		- PG_error
> > > 		- PG_active
> > > 		- PG_private
> > > 	- PG_reclaim: mask out the overloaded PG_readahead
> > > 	- compound flags: only export huge/gigantic pages
> > > 
> > > Here are the admin/linus views of all page flags on a newly booted nfs-root system:
> > > 
> > > # ./page-types # for admin
> > >          flags  page-count       MB  symbolic-flags                     long-symbolic-flags
> > > 0x000000000000      491174     1918  ____________________________                
> > > 0x000000000020           1        0  _____l______________________       lru      
> > > 0x000000000028        2543        9  ___U_l______________________       uptodate,lru
> > > 0x00000000002c        5288       20  __RU_l______________________       referenced,uptodate,lru
> > > 0x000000004060           1        0  _____lA_______b_____________       lru,active,swapbacked
> > 
> > I think i have to NAK this kind of ad-hoc instrumentation of kernel 
> > internals and statistics until we clear up why such instrumentation 
> > measures are being accepted into the MM while other, more dynamic 
> > and more flexible MM instrumentation are being resisted by Andrew.
> 
> An unexpected NAK - to throw away an orange because we are to have an apple? ;-)
> 
> Anyway here are the missing rationals.
> 
> 1) FAST
> 
> It takes merely 0.2s to scan 4GB pages:
> 
>         ./page-types  0.02s user 0.20s system 99% cpu 0.216 total
> 
> 2) SIMPLE
> 
> /proc/kpageflags will be a *long standing* hack we have to live 
> with - it was originally introduced by Matt to do shared memory 
> accounting and a facility to analyze applications' memory 
> consumptions, with the hope it will also help kernel developers 
> someday.
> 
> So why not extend and embrace it, in a straightforward way?
> 
> 3) USE CASES
> 
> I have/will take advantage of the above page-types command in a number ways:
> - to help track down memory leak (the recent trace/ring_buffer.c case)
> - to estimate the system wide readahead miss ratio
> - Andi want to examine the major page types in different workloads
>   (for the hwpoison work)
> - Me too, for fun of learning: read/write/lock/whatever a lot of pages
>   and examine their flags, to get an idea of some random kernel behaviors.
>   (the dynamic tracing tools can be more helpful, as a different view)
> 
> 4) COMPLEMENTARITY
> 
> In some cases the dynamic tracing tool is not enough (or too complex)
> to rebuild the current status view.
> 
> I myself have a dynamic readahead tracing tool(very useful!). At 
> the same time I also use readahead accounting numbers, and the 
> /proc/filecache tool(frequently!), and the above page-types tool. 
> I simply need them all - they are handy for different cases.

Well, the main counter argument here is that statistics is _derived_ 
from events. In their simplest form the 'counts' are the integral of 
events over time.

So if we capture all interesting events, and do that with low 
overhead (and in fact can even collect and integrate them in-kernel, 
today), we _dont have_ to maintain various overlapping counters all 
around the kernel. This is really a general instrumentation design 
observation.

Every time we add yet another /proc hack we splinter Linux 
instrumentation, in a hard to reverse way.

So your single-purpose /proc hack could be made multi-purpose and 
could help a much broader range of people, with just a little bit of 
effort i believe. Pekka already wrote the page tracking patch for 
example, that would be a good starting point.

Does it mean more work to do? You bet ;-)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
