Date: Wed, 23 Jan 2008 16:18:19 +0200 (EET)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] Fix boot problem in situations where the boot CPU is
 running on a memoryless node
In-Reply-To: <20080123135513.GA14175@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0801231611160.20050@sbz-30.cs.Helsinki.FI>
References: <20080118213011.GC10491@csn.ul.ie>
 <Pine.LNX.4.64.0801181414200.8924@schroedinger.engr.sgi.com>
 <20080118225713.GA31128@aepfle.de> <20080122195448.GA15567@csn.ul.ie>
 <20080122214505.GA15674@aepfle.de> <Pine.LNX.4.64.0801221417480.1912@schroedinger.engr.sgi.com>
 <20080123075821.GA17713@aepfle.de> <20080123105044.GD21455@csn.ul.ie>
 <20080123121459.GA18631@aepfle.de> <20080123125236.GA18876@aepfle.de>
 <20080123135513.GA14175@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, hanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lee.schermerhorn@hp.com, Linux MM <linux-mm@kvack.org>, Olaf Hering <olaf@aepfle.de>
List-ID: <linux-mm.kvack.org>

Hi Mel,

On Wed, 23 Jan 2008, Mel Gorman wrote:
> diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc8-005-revert-memoryless-slab/mm/slab.c linux-2.6.24-rc8-010_handle_missing_l3/mm/slab.c
> --- linux-2.6.24-rc8-005-revert-memoryless-slab/mm/slab.c	2008-01-22 17:46:32.000000000 +0000
> +++ linux-2.6.24-rc8-010_handle_missing_l3/mm/slab.c	2008-01-22 18:42:53.000000000 +0000
> @@ -2775,6 +2775,11 @@ static int cache_grow(struct kmem_cache 
>  	/* Take the l3 list lock to change the colour_next on this node */
>  	check_irq_off();
>  	l3 = cachep->nodelists[nodeid];
> +	if (!l3) {
> +		nodeid = numa_node_id();
> +		l3 = cachep->nodelists[nodeid];
> +	}
> +	BUG_ON(!l3);
>  	spin_lock(&l3->list_lock);
>  
>  	/* Get colour for the slab, and cal the next value. */
> @@ -3317,6 +3322,10 @@ static void *____cache_alloc_node(struct
>  	int x;
>  
>  	l3 = cachep->nodelists[nodeid];
> +	if (!l3) {
> +		nodeid = numa_node_id();
> +		l3 = cachep->nodelists[nodeid];
> +	}

What guarantees that current node ->nodelists is never NULL?

I still think Christoph's kmem_getpages() patch is correct (to fix 
cache_grow() oops) but I overlooked the fact that none the callers of 
____cache_alloc_node() deal with bootstrapping (with the exception of 
__cache_alloc_node() that even has a comment about it).

But what I am really wondering about is, why wasn't the 
N_NORMAL_MEMORY revert enough? I assume this used to work before so what 
more do we need to revert for 2.6.24?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
