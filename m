Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 168236B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 17:27:51 -0500 (EST)
Subject: Re: [PATCH] slub: operate cache name memory same to slab and slob
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <alpine.DEB.2.00.1011181333160.26680@chino.kir.corp.google.com>
References: <1290049259-20108-1-git-send-email-b32542@freescale.com>
	 <1290114908.26343.721.camel@calx>
	 <alpine.DEB.2.00.1011181333160.26680@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 18 Nov 2010 16:27:45 -0600
Message-ID: <1290119265.26343.814.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: b32542@freescale.com, linux-mm@kvack.org, cl@linux-foundation.org, penberg@cs.helsinki.fi, tytso@mit.edu, linux-kernel@vger.kernel.org, Zeng Zhaoming <zengzm.kernel@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-11-18 at 13:36 -0800, David Rientjes wrote:
> On Thu, 18 Nov 2010, Matt Mackall wrote:
> 
> > > Get a memory leak complaint about ext4:
> > >   comm "mount", pid 1159, jiffies 4294904647 (age 6077.804s)
> > >   hex dump (first 32 bytes):
> > >     65 78 74 34 5f 67 72 6f 75 70 69 6e 66 6f 5f 31  ext4_groupinfo_1
> > >     30 00 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  0.kkkkkkkkkkkkk.
> > >   backtrace:
> > >     [<c068ade3>] kmemleak_alloc+0x93/0xd0
> > >     [<c024e54c>] __kmalloc_track_caller+0x30c/0x380
> > >     [<c02269d3>] kstrdup+0x33/0x60
> > >     [<c0318a70>] ext4_mb_init+0x4e0/0x550
> > >     [<c0304e0e>] ext4_fill_super+0x1e6e/0x2f60
> > >     [<c0261140>] mount_bdev+0x1c0/0x1f0
> > >     [<c02fc00f>] ext4_mount+0x1f/0x30
> > >     [<c02603d8>] vfs_kern_mount+0x78/0x250
> > >     [<c026060e>] do_kern_mount+0x3e/0x100
> > >     [<c027b4c2>] do_mount+0x2e2/0x780
> > >     [<c027ba04>] sys_mount+0xa4/0xd0
> > >     [<c010429f>] sysenter_do_call+0x12/0x38
> > >     [<ffffffff>] 0xffffffff
> > > 
> > > It is cause by slub manage the cache name different from slab and slob.
> > > In slab and slob, only reference to name, alloc and reclaim the memory
> > > is the duty of the code that invoked kmem_cache_create().
> > > 
> > > In slub, cache name duplicated when create. This ambiguity will cause
> > > some memory leaks and double free if kmem_cache_create() pass a
> > > dynamic malloc cache name.
> > 
> > I don't get it.
> > 
> > Caller allocates X, passes X to slub, slub duplicates X as X', and
> > properly frees X', then caller frees X. Yes, that's silly, but where's
> > the leak?
> > 
> 
> The leak in ext4_mb_init() above is because it is using kstrdup() to 
> allocate the string itself and then on destroy uses kmem_cache_name() to 
> attain the slub allocator's pointer to the name, not the memory the ext4 
> layer allocated itself.

And Pekka says:

> The kstrdup() is there because of SLUB cache merging. See commit 
> 84c1cf62465e2fb0a692620dcfeb52323ab03d48 ("SLUB: Fix merged slab 
> cache names") for details.

I see. So we can either:

- force anyone using dynamically-allocated names to track their own damn
pointer
- implement kstrdup in the other allocators and fix all callers (the
bulk of which use static names!)
- eliminate dynamically-allocated names (mostly useless when we start
merging slabs!)
- add an indirection layer for slub that holds the unmerged details
- stop pretending we track slab names and show only generic names based
on size in /proc

kmem_cache_name() is also a highly suspect function in a
post-merged-slabs kernel. As ext4 is the only user in the kernel, and it
got it wrong, perhaps it's time to rip it out.

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
