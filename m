Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9B4946B0087
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 16:36:18 -0500 (EST)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id oAILaDJ0022793
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 13:36:13 -0800
Received: from yxd5 (yxd5.prod.google.com [10.190.1.197])
	by kpbe20.cbf.corp.google.com with ESMTP id oAILaAYt020370
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 13:36:12 -0800
Received: by yxd5 with SMTP id 5so2367471yxd.20
        for <linux-mm@kvack.org>; Thu, 18 Nov 2010 13:36:12 -0800 (PST)
Date: Thu, 18 Nov 2010 13:36:08 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slub: operate cache name memory same to slab and slob
In-Reply-To: <1290114908.26343.721.camel@calx>
Message-ID: <alpine.DEB.2.00.1011181333160.26680@chino.kir.corp.google.com>
References: <1290049259-20108-1-git-send-email-b32542@freescale.com> <1290114908.26343.721.camel@calx>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: b32542@freescale.com, linux-mm@kvack.org, cl@linux-foundation.org, penberg@cs.helsinki.fi, tytso@mit.edu, linux-kernel@vger.kernel.org, Zeng Zhaoming <zengzm.kernel@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, 18 Nov 2010, Matt Mackall wrote:

> > Get a memory leak complaint about ext4:
> >   comm "mount", pid 1159, jiffies 4294904647 (age 6077.804s)
> >   hex dump (first 32 bytes):
> >     65 78 74 34 5f 67 72 6f 75 70 69 6e 66 6f 5f 31  ext4_groupinfo_1
> >     30 00 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  0.kkkkkkkkkkkkk.
> >   backtrace:
> >     [<c068ade3>] kmemleak_alloc+0x93/0xd0
> >     [<c024e54c>] __kmalloc_track_caller+0x30c/0x380
> >     [<c02269d3>] kstrdup+0x33/0x60
> >     [<c0318a70>] ext4_mb_init+0x4e0/0x550
> >     [<c0304e0e>] ext4_fill_super+0x1e6e/0x2f60
> >     [<c0261140>] mount_bdev+0x1c0/0x1f0
> >     [<c02fc00f>] ext4_mount+0x1f/0x30
> >     [<c02603d8>] vfs_kern_mount+0x78/0x250
> >     [<c026060e>] do_kern_mount+0x3e/0x100
> >     [<c027b4c2>] do_mount+0x2e2/0x780
> >     [<c027ba04>] sys_mount+0xa4/0xd0
> >     [<c010429f>] sysenter_do_call+0x12/0x38
> >     [<ffffffff>] 0xffffffff
> > 
> > It is cause by slub manage the cache name different from slab and slob.
> > In slab and slob, only reference to name, alloc and reclaim the memory
> > is the duty of the code that invoked kmem_cache_create().
> > 
> > In slub, cache name duplicated when create. This ambiguity will cause
> > some memory leaks and double free if kmem_cache_create() pass a
> > dynamic malloc cache name.
> 
> I don't get it.
> 
> Caller allocates X, passes X to slub, slub duplicates X as X', and
> properly frees X', then caller frees X. Yes, that's silly, but where's
> the leak?
> 

The leak in ext4_mb_init() above is because it is using kstrdup() to 
allocate the string itself and then on destroy uses kmem_cache_name() to 
attain the slub allocator's pointer to the name, not the memory the ext4 
layer allocated itself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
