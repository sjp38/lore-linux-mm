Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3F7906B0087
	for <linux-mm@kvack.org>; Sat, 20 Nov 2010 19:55:30 -0500 (EST)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id oAL0tSS5011363
	for <linux-mm@kvack.org>; Sat, 20 Nov 2010 16:55:28 -0800
Received: from gyh3 (gyh3.prod.google.com [10.243.50.195])
	by hpaq14.eem.corp.google.com with ESMTP id oAL0tQdh024369
	for <linux-mm@kvack.org>; Sat, 20 Nov 2010 16:55:26 -0800
Received: by gyh3 with SMTP id 3so3805004gyh.14
        for <linux-mm@kvack.org>; Sat, 20 Nov 2010 16:55:26 -0800 (PST)
Date: Sat, 20 Nov 2010 16:55:22 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slub: operate cache name memory same to slab and slob
In-Reply-To: <1290119265.26343.814.camel@calx>
Message-ID: <alpine.DEB.2.00.1011201650120.10618@chino.kir.corp.google.com>
References: <1290049259-20108-1-git-send-email-b32542@freescale.com> <1290114908.26343.721.camel@calx> <alpine.DEB.2.00.1011181333160.26680@chino.kir.corp.google.com> <1290119265.26343.814.camel@calx>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: b32542@freescale.com, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, tytso@mit.edu, linux-kernel@vger.kernel.org, Zeng Zhaoming <zengzm.kernel@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, 18 Nov 2010, Matt Mackall wrote:

> > The leak in ext4_mb_init() above is because it is using kstrdup() to 
> > allocate the string itself and then on destroy uses kmem_cache_name() to 
> > attain the slub allocator's pointer to the name, not the memory the ext4 
> > layer allocated itself.
> 
> And Pekka says:
> 
> > The kstrdup() is there because of SLUB cache merging. See commit 
> > 84c1cf62465e2fb0a692620dcfeb52323ab03d48 ("SLUB: Fix merged slab 
> > cache names") for details.
> 
> I see. So we can either:
> 
> - force anyone using dynamically-allocated names to track their own damn
> pointer
> - implement kstrdup in the other allocators and fix all callers (the
> bulk of which use static names!)
> - eliminate dynamically-allocated names (mostly useless when we start
> merging slabs!)
> - add an indirection layer for slub that holds the unmerged details
> - stop pretending we track slab names and show only generic names based
> on size in /proc
> 

I agree that we should force each user to track its own memory, and this 
is really what the issue is about (it doesn't matter if that memory is the 
cache's name).  This particular issue is an ext4 memory leak and not the 
responsibility of any allocator.

> kmem_cache_name() is also a highly suspect function in a
> post-merged-slabs kernel. As ext4 is the only user in the kernel, and it
> got it wrong, perhaps it's time to rip it out.
> 

Yes, I think kmem_cache_name() should be removed since it shouldn't be 
used for anything other than the internal slabinfo/slabtop display as the 
slub allocator actually specifies in include/linux/slub_def.h.  The only 
user is ext4 to track this dynamically allocated pointer, so we can 
eliminate it if we leave it to track its own memory allocations (a slab 
allocator shouldn't be carrying a metadata payload).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
