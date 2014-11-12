Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 75E4F6B00F7
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 23:10:55 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id y10so11441202pdj.40
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 20:10:55 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id nx7si21748507pbb.70.2014.11.11.20.10.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 20:10:54 -0800 (PST)
Message-Id: <201411120408.sAC48tTa029031@www262.sakura.ne.jp>
Subject: Re: [Bug 87891] New: kernel BUG at mm/slab.c:2625!
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Date: Wed, 12 Nov 2014 13:08:55 +0900
References: <bug-87891-27@https.bugzilla.kernel.org/> <alpine.DEB.2.11.1411111833220.8762@gentwo.org> <20141111164913.3616531c21c91499871c46de@linux-foundation.org> <201411120054.04651.luke@dashjr.org> <20141111170243.c24ce5fdb5efaf0814071847@linux-foundation.org> <20141112012244.GA21576@js1304-P5Q-DELUXE> <20141111174412.ba0ac86f.akpm@linux-foundation.org>
In-Reply-To: <20141111174412.ba0ac86f.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-2022-JP"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Luke Dashjr <luke@dashjr.org>, Christoph Lameter <cl@linux.com>, Ming Lei <ming.lei@canonical.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Pauli Nieminen <suokkos@gmail.com>, Dave Airlie <airlied@linux.ie>, bugzilla-daemon@bugzilla.kernel.org, luke-jr+linuxbugs@utopios.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Andrew Morton wrote:
> Poor ttm guys - this is a bit of a trap we set for them.

Commit a91576d7916f6cce (\"drm/ttm: Pass GFP flags in order to avoid deadlock.\")
changed to use sc->gfp_mask rather than GFP_KERNEL.

-       pages_to_free = kmalloc(npages_to_free * sizeof(struct page *),
-                       GFP_KERNEL);
+       pages_to_free = kmalloc(npages_to_free * sizeof(struct page *), gfp);

But this bug is caused by sc->gfp_mask containing some flags which are not
in GFP_KERNEL, right? Then, I think

-       pages_to_free = kmalloc(npages_to_free * sizeof(struct page *), gfp);
+       pages_to_free = kmalloc(npages_to_free * sizeof(struct page *), gfp & GFP_KERNEL);

would hide this bug.

But I think we should use GFP_ATOMIC (or drop __GFP_WAIT flag) for
two reasons when __alloc_pages_nodemask() is called from shrinker functions.

(1) Stack usage by __alloc_pages_nodemask() is large. If we unlimitedly allow
    recursive __alloc_pages_nodemask() calls, kernel stack could overflow
    under extreme memory pressure.

(2) Some shrinker functions are using sleepable locks which could make kswapd
    sleep for unpredictable duration. If kswapd is unexpectedly blocked inside
    shrinker functions and somebody is expecting that kswapd is running for
    reclaiming memory, it is a memory allocation deadlock.

Speak of ttm module, commit 22e71691fd54c637 (\"drm/ttm: Use mutex_trylock() to
avoid deadlock inside shrinker functions.\") prevents unlimited recursive
__alloc_pages_nodemask() calls.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
