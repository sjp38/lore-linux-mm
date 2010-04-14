Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E241D6B021D
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 02:52:27 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3E6qMEC017526
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 14 Apr 2010 15:52:23 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C1BE45DE50
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 15:52:22 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E14445DE4C
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 15:52:22 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 30E701DB8016
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 15:52:22 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CE58A1DB8014
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 15:52:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
In-Reply-To: <20100413202021.GZ13327@think>
References: <20100413193428.GI25756@csn.ul.ie> <20100413202021.GZ13327@think>
Message-Id: <20100414155211.D14D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 14 Apr 2010 15:52:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

> On Tue, Apr 13, 2010 at 08:34:29PM +0100, Mel Gorman wrote:
> > > This problem is not a filesystem recursion problem which is, as I
> > > understand it, what GFP_NOFS is used to prevent. It's _any_ kernel
> > > code that uses signficant stack before trying to allocate memory
> > > that is the problem. e.g a select() system call:
> > > 
> > >        Depth    Size   Location    (47 entries)
> > >        -----    ----   --------
> > >  0)     7568      16   mempool_alloc_slab+0x16/0x20
> > >  1)     7552     144   mempool_alloc+0x65/0x140
> > >  2)     7408      96   get_request+0x124/0x370
> > >  3)     7312     144   get_request_wait+0x29/0x1b0
> > >  4)     7168      96   __make_request+0x9b/0x490
> > >  5)     7072     208   generic_make_request+0x3df/0x4d0
> > >  6)     6864      80   submit_bio+0x7c/0x100
> > >  7)     6784      96   _xfs_buf_ioapply+0x128/0x2c0 [xfs]
> > > ....
> > > 32)     3184      64   xfs_vm_writepage+0xab/0x160 [xfs]
> > > 33)     3120     384   shrink_page_list+0x65e/0x840
> > > 34)     2736     528   shrink_zone+0x63f/0xe10
> > > 35)     2208     112   do_try_to_free_pages+0xc2/0x3c0
> > > 36)     2096     128   try_to_free_pages+0x77/0x80
> > > 37)     1968     240   __alloc_pages_nodemask+0x3e4/0x710
> > > 38)     1728      48   alloc_pages_current+0x8c/0xe0
> > > 39)     1680      16   __get_free_pages+0xe/0x50
> > > 40)     1664      48   __pollwait+0xca/0x110
> > > 41)     1616      32   unix_poll+0x28/0xc0
> > > 42)     1584      16   sock_poll+0x1d/0x20
> > > 43)     1568     912   do_select+0x3d6/0x700
> > > 44)      656     416   core_sys_select+0x18c/0x2c0
> > > 45)      240     112   sys_select+0x4f/0x110
> > > 46)      128     128   system_call_fastpath+0x16/0x1b
> > > 
> > > There's 1.6k of stack used before memory allocation is called, 3.1k
> > > used there before ->writepage is entered, XFS used 3.5k, and
> > > if the mempool needed to allocate a page it would have blown the
> > > stack. If there was any significant storage subsystem (add dm, md
> > > and/or scsi of some kind), it would have blown the stack.
> > > 
> > > Basically, there is not enough stack space available to allow direct
> > > reclaim to enter ->writepage _anywhere_ according to the stack usage
> > > profiles we are seeing here....
> > > 
> > 
> > I'm not denying the evidence but how has it been gotten away with for years
> > then? Prevention of writeback isn't the answer without figuring out how
> > direct reclaimers can queue pages for IO and in the case of lumpy reclaim
> > doing sync IO, then waiting on those pages.
> 
> So, I've been reading along, nodding my head to Dave's side of things
> because seeks are evil and direct reclaim makes seeks.  I'd really loev
> for direct reclaim to somehow trigger writepages on large chunks instead
> of doing page by page spatters of IO to the drive.
> 
> But, somewhere along the line I overlooked the part of Dave's stack trace
> that said:
> 
> 43)     1568     912   do_select+0x3d6/0x700
> 
> Huh, 912 bytes...for select, really?  From poll.h:
> 
> /* ~832 bytes of stack space used max in sys_select/sys_poll before allocating
>    additional memory. */
> #define MAX_STACK_ALLOC 832
> #define FRONTEND_STACK_ALLOC    256
> #define SELECT_STACK_ALLOC      FRONTEND_STACK_ALLOC
> #define POLL_STACK_ALLOC        FRONTEND_STACK_ALLOC
> #define WQUEUES_STACK_ALLOC     (MAX_STACK_ALLOC - FRONTEND_STACK_ALLOC)
> #define N_INLINE_POLL_ENTRIES   (WQUEUES_STACK_ALLOC / sizeof(struct poll_table_entry))
> 
> So, select is intentionally trying to use that much stack.  It should be using
> GFP_NOFS if it really wants to suck down that much stack...if only the
> kernel had some sort of way to dynamically allocate ram, it could try
> that too.

Yeah, Of cource much. I would propse to revert 70674f95c0.
But I doubt GFP_NOFS solve our issue.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
