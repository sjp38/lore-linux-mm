Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4613A6B0105
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 23:38:30 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id hl2so2288099igb.10
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 20:38:29 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id nk7si34754297icb.61.2014.11.11.20.38.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Nov 2014 20:38:29 -0800 (PST)
Date: Tue, 11 Nov 2014 20:38:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 87891] New: kernel BUG at mm/slab.c:2625!
Message-Id: <20141111203859.3c578f5d.akpm@linux-foundation.org>
In-Reply-To: <201411120408.sAC48tTa029031@www262.sakura.ne.jp>
References: <bug-87891-27@https.bugzilla.kernel.org/>
	<alpine.DEB.2.11.1411111833220.8762@gentwo.org>
	<20141111164913.3616531c21c91499871c46de@linux-foundation.org>
	<201411120054.04651.luke@dashjr.org>
	<20141111170243.c24ce5fdb5efaf0814071847@linux-foundation.org>
	<20141112012244.GA21576@js1304-P5Q-DELUXE>
	<20141111174412.ba0ac86f.akpm@linux-foundation.org>
	<201411120408.sAC48tTa029031@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Luke Dashjr <luke@dashjr.org>, Christoph Lameter <cl@linux.com>, Ming Lei <ming.lei@canonical.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Pauli Nieminen <suokkos@gmail.com>, Dave Airlie <airlied@linux.ie>, bugzilla-daemon@bugzilla.kernel.org, luke-jr+linuxbugs@utopios.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed, 12 Nov 2014 13:08:55 +0900 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> wrote:

> Andrew Morton wrote:
> > Poor ttm guys - this is a bit of a trap we set for them.
> 
> Commit a91576d7916f6cce (\"drm/ttm: Pass GFP flags in order to avoid deadlock.\")
> changed to use sc->gfp_mask rather than GFP_KERNEL.
> 
> -       pages_to_free = kmalloc(npages_to_free * sizeof(struct page *),
> -                       GFP_KERNEL);
> +       pages_to_free = kmalloc(npages_to_free * sizeof(struct page *), gfp);
> 
> But this bug is caused by sc->gfp_mask containing some flags which are not
> in GFP_KERNEL, right? Then, I think
> 
> -       pages_to_free = kmalloc(npages_to_free * sizeof(struct page *), gfp);
> +       pages_to_free = kmalloc(npages_to_free * sizeof(struct page *), gfp & GFP_KERNEL);
> 
> would hide this bug.
> 
> But I think we should use GFP_ATOMIC (or drop __GFP_WAIT flag)

Well no - ttm_page_pool_free() should stop calling kmalloc altogether. 
Just do

	struct page *pages_to_free[16];

and rework the code to free 16 pages at a time.  Easy.

Apart from all the other things we're discussing here, it should do
this because kmalloc() isn't very reliable within a shrinker.


> for
> two reasons when __alloc_pages_nodemask() is called from shrinker functions.
> 
> (1) Stack usage by __alloc_pages_nodemask() is large. If we unlimitedly allow
>     recursive __alloc_pages_nodemask() calls, kernel stack could overflow
>     under extreme memory pressure.
> 
> (2) Some shrinker functions are using sleepable locks which could make kswapd
>     sleep for unpredictable duration. If kswapd is unexpectedly blocked inside
>     shrinker functions and somebody is expecting that kswapd is running for
>     reclaiming memory, it is a memory allocation deadlock.
> 
> Speak of ttm module, commit 22e71691fd54c637 (\"drm/ttm: Use mutex_trylock() to
> avoid deadlock inside shrinker functions.\") prevents unlimited recursive
> __alloc_pages_nodemask() calls.

Yes, there are such problems.

Shrinkers do all sorts of surprising things - some of the filesystem
ones do disk writes!  And these involve all sorts of locking and memory
allocations.  But they won't be directly using scan_control.gfp_mask. 
They may be using open-coded __GFP_NOFS for the allocations.  The
complicated ones pass the IO over to kernel threads and wait for them
to complete, which addresses the stack consumption concerns (at least).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
