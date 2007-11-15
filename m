Date: Thu, 15 Nov 2007 10:13:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 06/17] SLUB: Slab defrag core
Message-Id: <20071115101324.3c00e47d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071114221020.940981964@sgi.com>
References: <20071114220906.206294426@sgi.com>
	<20071114221020.940981964@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Nov 2007 14:09:12 -0800
Christoph Lameter <clameter@sgi.com> wrote:

> void kick(struct kmem_cache *, int nr, void **objects, void *get_result)
> 
> 	After SLUB has established references to the objects in a
> 	slab it will then drop all locks and use kick() to move objects out
> 	of the slab. The existence of the object is guaranteed by virtue of
> 	the earlier obtained references via get(). The callback may perform
> 	any slab operation since no locks are held at the time of call.
> 
> 	The callback should remove the object from the slab in some way. This
> 	may be accomplished by reclaiming the object and then running
> 	kmem_cache_free() or reallocating it and then running
> 	kmem_cache_free(). Reallocation is advantageous because the partial
> 	slabs were just sorted to have the partial slabs with the most objects
> 	first. Reallocation is likely to result in filling up a slab in
> 	addition to freeing up one slab. A filled up slab can also be removed
> 	from the partial list. So there could be a double effect.
> 

I think shrink_slab()? is called under memory shortage and "re-allocation and
move" may require to allocate new page. Then, kick() should use GFP_ATOMIC if
they want to do reallocation. Right ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
