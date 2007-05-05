Date: Sat, 5 May 2007 08:35:38 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 2/3] SLUB: Implement targeted reclaim and partial list
 defragmentation
In-Reply-To: <20070505053211.GZ19966@holomorphy.com>
Message-ID: <Pine.LNX.4.64.0705050833310.26574@schroedinger.engr.sgi.com>
References: <20070504221555.642061626@sgi.com> <20070504221708.596112123@sgi.com>
 <20070505053211.GZ19966@holomorphy.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Eric Dumazet <dada1@cosmosbay.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, 4 May 2007, William Lee Irwin III wrote:

> kick_object() doesn't return an indicator of success, which might be
> helpful for determining whether an object was successfully removed. The
> later-added kick_dentry_object(), for instance, can't remove dentries
> where reference counts are still held.
> 
> I suppose one could check to see if the ->inuse counter decreased, too.

Yes that is exactly what is done. The issue is that concurrent frees may 
occur. So we just kick them all and see if all objects are gone at the 
end.
 
> In either event, it would probably be helpful to abort the operation if
> there was a reclamation failure for an object within the slab.

Hmmm... The failure may be because another process is attempting 
a kmem_cache_free on an object. But we are holding the lock. The free
will succeed when we drop it.

> This is a relatively minor optimization concern. I think this patch
> series is great and a significant foray into the problem of slab
> reclaim vs. fragmentation.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
