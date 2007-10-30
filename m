Date: Tue, 30 Oct 2007 11:38:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 07/10] SLUB: Avoid referencing kmem_cache structure in
 __slab_alloc
Message-Id: <20071030113848.930471e6.akpm@linux-foundation.org>
In-Reply-To: <20071028033259.992768446@sgi.com>
References: <20071028033156.022983073@sgi.com>
	<20071028033259.992768446@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: matthew@wil.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

On Sat, 27 Oct 2007 20:32:03 -0700
Christoph Lameter <clameter@sgi.com> wrote:

> There is the need to use the objects per slab in the first part of
> __slab_alloc() which is still pretty hot. Copy the number of objects
> per slab into the kmem_cache_cpu structure. That way we can get the
> value from a cache line that we already need to touch. This brings
> the kmem_cache_cpu structure up to 4 even words.
> 
> There is no increase in the size of kmem_cache_cpu since the size of object
> is rounded to the next word.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  include/linux/slub_def.h |    1 +
>  mm/slub.c                |    3 ++-
>  2 files changed, 3 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6/include/linux/slub_def.h
> ===================================================================
> --- linux-2.6.orig/include/linux/slub_def.h	2007-10-26 19:09:16.000000000 -0700
> +++ linux-2.6/include/linux/slub_def.h	2007-10-27 07:55:12.000000000 -0700
> @@ -17,6 +17,7 @@ struct kmem_cache_cpu {
>  	int node;
>  	unsigned int offset;
>  	unsigned int objsize;
> +	unsigned int objects;
>  };

mutter.  nr_objects would be a better name, but then one should rename
kmem_cache.objects too.

Better would be to comment the field.  Please devote extra care to commenting
data structures.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
