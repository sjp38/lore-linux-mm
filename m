Received: from oscar.casa.dyndns.org ([65.92.167.49])
          by tomts9-srv.bellnexxia.net
          (InterMail vM.5.01.04.19 201-253-122-122-119-20020516) with ESMTP
          id <20020902154022.IJLU14397.tomts9-srv.bellnexxia.net@oscar.casa.dyndns.org>
          for <linux-mm@kvack.org>; Mon, 2 Sep 2002 11:40:22 -0400
Received: from oscar (localhost [127.0.0.1])
	by oscar.casa.dyndns.org (Postfix) with ESMTP id C957A1907A
	for <linux-mm@kvack.org>; Mon,  2 Sep 2002 11:38:34 -0400 (EDT)
Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Fwd: Re: slablru for 2.5.32-mm1
Date: Mon, 2 Sep 2002 11:38:34 -0400
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200209021138.34183.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On September 2, 2002 02:50 am, Andrew Morton wrote:
> hm.  Doing a bit more testing...
>
> mem=512m, then build the inode and dentry caches up a bit:
>
>   ext2_inode_cache:    20483KB    20483KB  100.0
>        buffer_head:     6083KB     6441KB   94.43
>       dentry_cache:     4885KB     4885KB  100.0
>
> (using wli's bloatmeter, attached here).
>
> Now,
>
> 	dd if=/dev/zero of=foo bs=1M count=2000
>
>   ext2_inode_cache:     3789KB     8148KB   46.50
>        buffer_head:     6469KB     6503KB   99.47
>           size-512:     1450KB     1500KB   96.66
>
> this took quite a long time to start dropping, and the machine
> still has 27 megabytes in slab.

What do you see in proc/slabinfo?  Bet the cache has been trimmed, but
pages are still busy.  It can and does take a while before we can start
freeing pages.  We can have lots of free space in a slab but not be able
to free any pages...

How far we have to go before pages can be free is probably related to
fn(pages in slab, slabs per page).  If we understood this function better
we could apply more pressure to caches as required.  So far I do not really
think this complexity is needed.

> Which kinda surprises me, given my (probably wrong) description of the
> algorithm.  I'd have expected the caches to be pruned a lot faster and
> further than this.  Not that it's necessarily a bad thing, but maybe we
> should be shrinking a little faster.  What are your thoughts on this?

I would leave it as is.  We _are_ now balance re the rest of the box.
Try to second guess at this point is probably not that good an idea.

> Also, I note that age_dcache_memory is being called for lots of
> tiny little shrinkings:
>
> Breakpoint 1, age_dcache_memory (cachep=0xc1911e48, entries=1,
> gfp_mask=464) at dcache.c:585 Breakpoint 1, age_dcache_memory
> (cachep=0xc1911e48, entries=2, gfp_mask=464) at dcache.c:585 Breakpoint 1,
> age_dcache_memory (cachep=0xc1911e48, entries=4, gfp_mask=464) at
> dcache.c:585 Breakpoint 1, age_dcache_memory (cachep=0xc1911e48,
> entries=12, gfp_mask=464) at dcache.c:585 Breakpoint 1, age_dcache_memory
> (cachep=0xc1911e48, entries=21, gfp_mask=464) at dcache.c:585 Breakpoint 1,
> age_dcache_memory (cachep=0xc1911e48, entries=42, gfp_mask=464) at
> dcache.c:585 Breakpoint 1, age_dcache_memory (cachep=0xc1911e48,
> entries=10, gfp_mask=464) at dcache.c:585
>
> I'd suggest that we batch these up a bit: call the pruner less
> frequently, but with larger request sizes, save a few cycles.

We could move the call into try_to_free_pages...  I do they its better where
 it is now. Think the idea adding a boolean would be more effective though. 
 We are probably aging more than just dcache entries in kmem_do_prunes.  My
 though was if we have the sem lets do all the work we can.

Ed

-------------------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
