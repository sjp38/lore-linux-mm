Message-ID: <3D730A3E.98F7386E@zip.com.au>
Date: Sun, 01 Sep 2002 23:50:38 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: slablru for 2.5.32-mm1
References: <200208261809.45568.tomlins@cam.org> <3D6AC0BB.FE65D5F7@zip.com.au> <200208281306.58776.tomlins@cam.org>
Content-Type: multipart/mixed;
 boundary="------------1A7072530548B8FD810E060F"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------1A7072530548B8FD810E060F
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

hm.  Doing a bit more testing...

mem=512m, then build the inode and dentry caches up a bit:

  ext2_inode_cache:    20483KB    20483KB  100.0 
       buffer_head:     6083KB     6441KB   94.43
      dentry_cache:     4885KB     4885KB  100.0 

(using wli's bloatmeter, attached here).

Now,

	dd if=/dev/zero of=foo bs=1M count=2000

  ext2_inode_cache:     3789KB     8148KB   46.50
       buffer_head:     6469KB     6503KB   99.47
          size-512:     1450KB     1500KB   96.66

this took quite a long time to start dropping, and the machine
still has 27 megabytes in slab.

Which kinda surprises me, given my (probably wrong) description of the
algorithm.  I'd have expected the caches to be pruned a lot faster and
further than this.  Not that it's necessarily a bad thing, but maybe we
should be shrinking a little faster.  What are your thoughts on this?

Also, I note that age_dcache_memory is being called for lots of
tiny little shrinkings:

Breakpoint 1, age_dcache_memory (cachep=0xc1911e48, entries=1, gfp_mask=464) at dcache.c:585
Breakpoint 1, age_dcache_memory (cachep=0xc1911e48, entries=2, gfp_mask=464) at dcache.c:585
Breakpoint 1, age_dcache_memory (cachep=0xc1911e48, entries=4, gfp_mask=464) at dcache.c:585
Breakpoint 1, age_dcache_memory (cachep=0xc1911e48, entries=12, gfp_mask=464) at dcache.c:585
Breakpoint 1, age_dcache_memory (cachep=0xc1911e48, entries=21, gfp_mask=464) at dcache.c:585
Breakpoint 1, age_dcache_memory (cachep=0xc1911e48, entries=42, gfp_mask=464) at dcache.c:585
Breakpoint 1, age_dcache_memory (cachep=0xc1911e48, entries=10, gfp_mask=464) at dcache.c:585

I'd suggest that we batch these up a bit: call the pruner less
frequently, but with larger request sizes, save a few cycles.
--------------1A7072530548B8FD810E060F
Content-Type: text/plain; charset=us-ascii;
 name="bloatmeter"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="bloatmeter"

#!/bin/sh
while true
do
	clear
	grep -v '^slabinfo' /proc/slabinfo	\
		| bloatmon			\
		| sort -r -n +2		\
		| head -22
	sleep 5
done

--------------1A7072530548B8FD810E060F
Content-Type: text/plain; charset=us-ascii;
 name="bloatmon"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="bloatmon"

#!/usr/bin/awk -f
BEGIN {
	printf "%18s    %8s %8s %8s\n", "cache", "active", "alloc", "%util";
}

{
	if ($3 != 0.0) {
		pct  = 100.0 * $2 / $3;
		frac = (10000.0 * $2 / $3) % 100;
	} else {
		pct  = 100.0;
		frac = 0.0;
	}
	active = ($2 * $4)/1024;
	alloc  = ($3 * $4)/1024;
	if ((alloc - active) < 1.0) {
		pct  = 100.0;
		frac = 0.0;
	}
	printf "%18s: %8dKB %8dKB  %3d.%-2d\n", $1, active, alloc, pct, frac;
}

--------------1A7072530548B8FD810E060F--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
