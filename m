Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6AA7B600374
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 03:06:35 -0400 (EDT)
Date: Wed, 14 Apr 2010 17:06:25 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100414070625.GJ2493@dastard>
References: <20100414135945.2b0a1e0d.kamezawa.hiroyu@jp.fujitsu.com>
 <20100414054144.GH2493@dastard>
 <20100414145056.D147.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100414145056.D147.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 02:54:14PM +0900, KOSAKI Motohiro wrote:
> > On Wed, Apr 14, 2010 at 01:59:45PM +0900, KAMEZAWA Hiroyuki wrote:
> > > On Wed, 14 Apr 2010 11:40:41 +1000
> > > Dave Chinner <david@fromorbit.com> wrote:
> > > 
> > > >  50)     3168      64   xfs_vm_writepage+0xab/0x160 [xfs]
> > > >  51)     3104     384   shrink_page_list+0x65e/0x840
> > > >  52)     2720     528   shrink_zone+0x63f/0xe10
> > > 
> > > A bit OFF TOPIC.
> > > 
> > > Could you share disassemble of shrink_zone() ?
> > > 
> > > In my environ.
> > > 00000000000115a0 <shrink_zone>:
> > >    115a0:       55                      push   %rbp
> > >    115a1:       48 89 e5                mov    %rsp,%rbp
> > >    115a4:       41 57                   push   %r15
> > >    115a6:       41 56                   push   %r14
> > >    115a8:       41 55                   push   %r13
> > >    115aa:       41 54                   push   %r12
> > >    115ac:       53                      push   %rbx
> > >    115ad:       48 83 ec 78             sub    $0x78,%rsp
> > >    115b1:       e8 00 00 00 00          callq  115b6 <shrink_zone+0x16>
> > >    115b6:       48 89 75 80             mov    %rsi,-0x80(%rbp)
> > > 
> > > disassemble seems to show 0x78 bytes for stack. And no changes to %rsp
> > > until retrun.
> > 
> > I see the same. I didn't compile those kernels, though. IIUC,
> > they were built through the Ubuntu build infrastructure, so there is
> > something different in terms of compiler, compiler options or config
> > to what we are both using. Most likely it is the compiler inlining,
> > though Chris's patches to prevent that didn't seem to change the
> > stack usage.
> > 
> > I'm trying to get a stack trace from the kernel that has shrink_zone
> > in it, but I haven't succeeded yet....
> 
> I also got 0x78 byte stack usage. Umm.. Do we discussed real issue now?

Ok, so here's a trace at the top of the stack from a kernel with a
the above shrink_zone disassembly:

$ cat /sys/kernel/debug/tracing/stack_trace
        Depth    Size   Location    (49 entries)
        -----    ----   --------
  0)     6152     112   force_qs_rnp+0x58/0x150
  1)     6040      48   force_quiescent_state+0x1a7/0x1f0
  2)     5992      48   __call_rcu+0x13d/0x190
  3)     5944      16   call_rcu_sched+0x15/0x20
  4)     5928      16   call_rcu+0xe/0x10
  5)     5912     240   radix_tree_delete+0x14a/0x2d0
  6)     5672      32   __remove_from_page_cache+0x21/0x110
  7)     5640      64   __remove_mapping+0x86/0x100
  8)     5576     272   shrink_page_list+0x2fd/0x5a0
  9)     5304     400   shrink_inactive_list+0x313/0x730
 10)     4904     176   shrink_zone+0x3d1/0x490
 11)     4728     128   do_try_to_free_pages+0x2b6/0x380
 12)     4600     112   try_to_free_pages+0x5e/0x60
 13)     4488     272   __alloc_pages_nodemask+0x3fb/0x730
 14)     4216      48   alloc_pages_current+0x87/0xd0
 15)     4168      32   __page_cache_alloc+0x67/0x70
 16)     4136      80   find_or_create_page+0x4f/0xb0
 17)     4056     160   _xfs_buf_lookup_pages+0x150/0x390
.....

So the differences are most likely from the compiler doing
automatic inlining of static functions...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
