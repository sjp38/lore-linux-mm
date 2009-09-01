Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 76A356B004F
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 20:46:29 -0400 (EDT)
Date: Tue, 1 Sep 2009 09:46:27 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: page allocator regression on nommu
Message-ID: <20090901004627.GA531@linux-sh.org>
References: <20090831074842.GA28091@linux-sh.org> <20090831103056.GA29627@csn.ul.ie> <20090831104315.GB30264@linux-sh.org> <20090831105952.GC29627@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090831105952.GC29627@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, Dave Hansen <dave@linux.vnet.ibm.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 31, 2009 at 11:59:52AM +0100, Mel Gorman wrote:
> On Mon, Aug 31, 2009 at 07:43:15PM +0900, Paul Mundt wrote:
> > On Mon, Aug 31, 2009 at 11:30:56AM +0100, Mel Gorman wrote:
> > > On Mon, Aug 31, 2009 at 04:48:43PM +0900, Paul Mundt wrote:
> > > > Hi Mel,
> > > > 
> > > > It seems we've managed to trigger a fairly interesting conflict between
> > > > the anti-fragmentation disabling code and the nommu region rbtree. I've
> > > > bisected it down to:
> > > > 
> > > > commit 49255c619fbd482d704289b5eb2795f8e3b7ff2e
> > > > Author: Mel Gorman <mel@csn.ul.ie>
> > > > Date:   Tue Jun 16 15:31:58 2009 -0700
> > > > 
> > > >     page allocator: move check for disabled anti-fragmentation out of fastpath
> > > > 
> > > >     On low-memory systems, anti-fragmentation gets disabled as there is
> > > >     nothing it can do and it would just incur overhead shuffling pages between
> > > >     lists constantly.  Currently the check is made in the free page fast path
> > > >     for every page.  This patch moves it to a slow path.  On machines with low
> > > >     memory, there will be small amount of additional overhead as pages get
> > > >     shuffled between lists but it should quickly settle.
> > > > 
> > > > which causes death on unpacking initramfs on my nommu board. With this
> > > > reverted, everything works as expected. Note that this blows up with all of
> > > > SLOB/SLUB/SLAB.
> > > > 
> > > > I'll continue debugging it, and can post my .config if it will be helpful, but
> > > > hopefully you have some suggestions on what to try :-)
> > > > 
> > > 
> > > Based on the output you have given me, it would appear the real
> > > underlying cause is that fragmentation caused the allocation to fail.
> > > The following patch might fix the problem.
> > >
> > Unfortunately this has no impact, the same issue occurs.
> > 
> 
> What is the output of the following debug patch?
> 

...
Inode-cache hash table entries: 1024 (order: 0, 4096 bytes)
------------[ cut here ]------------
Badness at mm/page_alloc.c:1046

Pid : 0, Comm:          swapper
CPU : 0                 Not tainted  (2.6.31-rc7 #2864)

PC is at free_hot_cold_page+0xa0/0x150
PR is at free_hot_cold_page+0x7e/0x150
PC  : 0c039804 SP  : 0c0f5fa0 SR  : 400000f0
R0  : 00000002 R1  : 00000001 R2  : 0c20eb20 R3  : 0c000000
R4  : 00000002 R5  : 00000024 R6  : 00000002 R7  : 0c079260
R8  : 0c103000 R9  : 0c21c360 R10 : 0c102fec R11 : ffffffff
R12 : 00000000 R13 : 0000d000 R14 : 00000000
MACH: 00000008 MACL: 0000000d GBR : 00000000 PR  : 0c0397e2

Call trace:
 [<0c1093a2>] free_all_bootmem_core+0xda/0x1bc
 [<0c106da2>] mem_init+0x22/0xe0
 [<0c0112dc>] printk+0x0/0x24
 [<0c108f5c>] __alloc_bootmem+0x0/0xc
 [<0c104480>] start_kernel+0xe8/0x4b8
 [<0c00201c>] _stext+0x1c/0x28
 [<0c002000>] _stext+0x0/0x28

Code:
  0c0397fe:  negc      r11, r1
  0c039800:  tst       r1, r1
  0c039802:  bt        0c039810
->0c039804:  trapa     #62
  0c039806:  tst       r1, r1
  0c039808:  bt        0c039810
  0c03980a:  mov       #1, r2
  0c03980c:  mov.l     0c0398ac <free_hot_cold_page+0x148/0x150>, r1  ! 0c20e9dc <0xc20e9dc>
  0c03980e:  mov.l     r2, @r1
...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
