Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 300756B0035
	for <linux-mm@kvack.org>; Wed, 21 May 2014 03:41:06 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id x10so1138915pdj.38
        for <linux-mm@kvack.org>; Wed, 21 May 2014 00:41:05 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id xv9si28017280pab.2.2014.05.21.00.41.04
        for <linux-mm@kvack.org>;
        Wed, 21 May 2014 00:41:05 -0700 (PDT)
Date: Wed, 21 May 2014 16:43:41 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 00/10] clean-up and remove lockdep annotation in SLAB
Message-ID: <20140521074340.GA3271@js1304-P5Q-DELUXE>
References: <1399442780-28748-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1399442780-28748-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, May 07, 2014 at 03:06:10PM +0900, Joonsoo Kim wrote:
> This patchset does some clean-up and tries to remove lockdep annotation.
> 
> Patches 1~3 are just for really really minor improvement.
> Patches 4~10 are for clean-up and removing lockdep annotation.
> 
> There are two cases that lockdep annotation is needed in SLAB.
> 1) holding two node locks
> 2) holding two array cache(alien cache) locks
> 
> I looked at the code and found that we can avoid these cases without
> any negative effect.
> 
> 1) occurs if freeing object makes new free slab and we decide to
> destroy it. Although we don't need to hold the lock during destroying
> a slab, current code do that. Destroying a slab without holding the lock
> would help the reduction of the lock contention. To do it, I change the
> implementation that new free slab is destroyed after releasing the lock.
> 
> 2) occurs on similar situation. When we free object from non-local node,
> we put this object to alien cache with holding the alien cache lock.
> If alien cache is full, we try to flush alien cache to proper node cache,
> and, in this time, new free slab could be made. Destroying it would be
> started and we will free metadata object which comes from another node.
> In this case, we need another node's alien cache lock to free object.
> This forces us to hold two array cache locks and then we need lockdep
> annotation although they are always different locks and deadlock cannot
> be possible. To prevent this situation, I use same way as 1).
> 
> In this way, we can avoid 1) and 2) cases, and then, can remove lockdep
> annotation. As short stat noted, this makes SLAB code much simpler.
> 
> Many of this series get Ack from Christoph Lameter on previous iteration,
> but 1, 2, 9 and 10 need to get Ack. There is no big change from previous
> iteration. It is just rebased on current linux-next.
> 
> Thanks.
> 
> Joonsoo Kim (10):
>   slab: add unlikely macro to help compiler
>   slab: makes clear_obj_pfmemalloc() just return masked value
>   slab: move up code to get kmem_cache_node in free_block()
>   slab: defer slab_destroy in free_block()
>   slab: factor out initialization of arracy cache
>   slab: introduce alien_cache
>   slab: use the lock on alien_cache, instead of the lock on array_cache
>   slab: destroy a slab without holding any alien cache lock
>   slab: remove a useless lockdep annotation
>   slab: remove BAD_ALIEN_MAGIC
> 
>  mm/slab.c |  391 ++++++++++++++++++++++---------------------------------------
>  mm/slab.h |    2 +-
>  2 files changed, 140 insertions(+), 253 deletions(-)

Hello, Andrew.

Pekka seems to be busy.
Could you manage this patchset?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
