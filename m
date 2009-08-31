Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8BC946B005A
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 06:43:17 -0400 (EDT)
Date: Mon, 31 Aug 2009 19:43:15 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: page allocator regression on nommu
Message-ID: <20090831104315.GB30264@linux-sh.org>
References: <20090831074842.GA28091@linux-sh.org> <20090831103056.GA29627@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090831103056.GA29627@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, Dave Hansen <dave@linux.vnet.ibm.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 31, 2009 at 11:30:56AM +0100, Mel Gorman wrote:
> On Mon, Aug 31, 2009 at 04:48:43PM +0900, Paul Mundt wrote:
> > Hi Mel,
> > 
> > It seems we've managed to trigger a fairly interesting conflict between
> > the anti-fragmentation disabling code and the nommu region rbtree. I've
> > bisected it down to:
> > 
> > commit 49255c619fbd482d704289b5eb2795f8e3b7ff2e
> > Author: Mel Gorman <mel@csn.ul.ie>
> > Date:   Tue Jun 16 15:31:58 2009 -0700
> > 
> >     page allocator: move check for disabled anti-fragmentation out of fastpath
> > 
> >     On low-memory systems, anti-fragmentation gets disabled as there is
> >     nothing it can do and it would just incur overhead shuffling pages between
> >     lists constantly.  Currently the check is made in the free page fast path
> >     for every page.  This patch moves it to a slow path.  On machines with low
> >     memory, there will be small amount of additional overhead as pages get
> >     shuffled between lists but it should quickly settle.
> > 
> > which causes death on unpacking initramfs on my nommu board. With this
> > reverted, everything works as expected. Note that this blows up with all of
> > SLOB/SLUB/SLAB.
> > 
> > I'll continue debugging it, and can post my .config if it will be helpful, but
> > hopefully you have some suggestions on what to try :-)
> > 
> 
> Based on the output you have given me, it would appear the real
> underlying cause is that fragmentation caused the allocation to fail.
> The following patch might fix the problem.
>
Unfortunately this has no impact, the same issue occurs.

Note that with 49255c619fbd482d704289b5eb2795f8e3b7ff2e reverted, show_mem()
shows the following:

alloc order 7 for 49000: pages 0c21c000
Mem-Info:
Normal per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Active_anon:0 active_file:2 inactive_anon:0
 inactive_file:320 unevictable:0 dirty:0 writeback:0 unstable:0
 free:2782 slab:0 mapped:0 pagetables:0 bounce:0
Normal free:11128kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:8kB inactive_file:1280kB unevictable:0kB present:16256kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0
Normal: 0*4kB 1*8kB 1*16kB 1*32kB 1*64kB 0*128kB 1*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB 1*8192kB 0*16384kB 0*32768kB = 11128kB
323 total pagecache pages
4096 pages RAM
662 pages reserved
227 pages shared
289 pages non-shared
0 pages in pagetable cache

while with it applied, consistently:

alloc order 7 for 49000:
modprobe: page allocation failure. order:7, mode:0xd0
...
Mem-Info:
Normal per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Active_anon:0 active_file:0 inactive_anon:0
 inactive_file:0 unevictable:323 dirty:0 writeback:0 unstable:0
 free:2910 slab:0 mapped:0 pagetables:0 bounce:0
Normal free:11640kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:1292kB present:16256kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0
Normal: 252*4kB 245*8kB 238*16kB 152*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB 0*8192kB 0*16384kB 0*32768kB = 11640kB
323 total pagecache pages
4096 pages RAM
662 pages reserved
226 pages shared
289 pages non-shared
0 pages in pagetable cache
-ENOMEM

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
