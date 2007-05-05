Date: Fri, 4 May 2007 22:32:11 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [RFC 2/3] SLUB: Implement targeted reclaim and partial list defragmentation
Message-ID: <20070505053211.GZ19966@holomorphy.com>
References: <20070504221555.642061626@sgi.com> <20070504221708.596112123@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070504221708.596112123@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Eric Dumazet <dada1@cosmosbay.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, May 04, 2007 at 03:15:57PM -0700, clameter@sgi.com wrote:
> 2. kick_object(void *)
> After SLUB has established references to the remaining objects in a slab it
> will drop all locks and then use kick_object on each of the objects for which
> we obtained a reference. The existence of the objects is guaranteed by
> virtue of the earlier obtained reference. The callback may perform any
> slab operation since no locks are held at the time of call.
> The callback should remove the object from the slab in some way. This may
> be accomplished by reclaiming the object and then running kmem_cache_free()
> or reallocating it and then running kmem_cache_free(). Reallocation
> is advantageous at this point because it will then allocate from the partial
> slabs with the most objects because we have just finished slab shrinking.
> NOTE: This patch is for conceptual review. I'd appreciate any feedback
> especially on the locking approach taken here. It will be critical to
> resolve the locking issue for this approach to become feasable.
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

kick_object() doesn't return an indicator of success, which might be
helpful for determining whether an object was successfully removed. The
later-added kick_dentry_object(), for instance, can't remove dentries
where reference counts are still held.

I suppose one could check to see if the ->inuse counter decreased, too.

In either event, it would probably be helpful to abort the operation if
there was a reclamation failure for an object within the slab.

This is a relatively minor optimization concern. I think this patch
series is great and a significant foray into the problem of slab
reclaim vs. fragmentation.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
