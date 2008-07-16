Message-ID: <487DF5D4.9070101@linux-foundation.org>
Date: Wed, 16 Jul 2008 08:21:24 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC] slub: increasing order reduces memory usage of some
 key caches
References: <1216211371.3122.46.camel@castor.localdomain>
In-Reply-To: <1216211371.3122.46.camel@castor.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: penberg@cs.helsinki.fi, mpm@selenic.com, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Richard Kennedy wrote:


> on my amd64 3 gb ram desktop typical numbers :-
> 
> [kernel,objects,pages/slab,slabs,total pages,diff]
> radix_tree_node
> 2.6.26 33922,2,2423 	4846
> +patch 33541,4,1165	4660,-186
> dentry
> 2.6.26	82136,1,4323	4323
> +patch	79482,2,2038	4076,-247
> the extra dentries would use 136 pages but that still leaves a saving of
> 111 pages.

Good numbers....

> Can anyone suggest any other tests that would be useful to run?
> & Is there any way to measure what impact this is having on
> fragmentation?

Mel would be able to tell you that but I think we better figure out what went wrong first.


> diff --git a/mm/slub.c b/mm/slub.c
> index 315c392..c365b04 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2301,6 +2301,14 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
>  	if (order < 0)
>  		return 0;
>  
> +	if (order < slub_max_order ) {
> +		unsigned long waste = (PAGE_SIZE << order) % size;
> +		if ( waste *2 >= size ) {
> +			order++;
> +			printk ( KERN_INFO "SLUB: increasing order %s->[%d] [%ld]\n",s->name,order,size);
> +		}
> +	}
> +
>  	s->allocflags = 0;
>  	if (order)
>  		s->allocflags |= __GFP_COMP;

The order and waste calculation occurs in slab_order(). If modifications are needed then they need to occur in that function.

Looks like the existing code is not doing the best thing for dentries on your box?

On my 64 bit box dentries are 208 bytes long, 39 objects per page and 84 bytes
are lost per order 1 page. So this would not trigger your patch at all. There must be something special to your configuration.


/linux-2.6$ slabinfo dentry

Slabcache: dentry                Aliases:  0 Order :  1 Objects: 554209
** Reclaim accounting active

Sizes (bytes)     Slabs              Debug                Memory
------------------------------------------------------------------------
Object :     208  Total  :   14215   Sanity Checks : Off  Total: 116449280
SlabObj:     208  Full   :   14179   Redzoning     : Off  Used : 115275472
SlabSiz:    8192  Partial:      32   Poisoning     : Off  Loss : 1173808
Loss   :       0  CpuSlab:       4   Tracking      : Off  Lalig:       0
Align  :       8  Objects:      39   Tracing       : Off  Lpadd: 1137200


Can you post the slabinfo information about the caches that you are concerned with? Please a before and after state.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
