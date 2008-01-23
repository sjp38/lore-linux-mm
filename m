Date: Wed, 23 Jan 2008 10:51:32 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Fix boot problem in situations where the boot CPU is
 running on a memoryless node
In-Reply-To: <Pine.LNX.4.64.0801231906520.1028@sbz-30.cs.Helsinki.FI>
Message-ID: <Pine.LNX.4.64.0801231036440.11430@schroedinger.engr.sgi.com>
References: <20080122214505.GA15674@aepfle.de>
 <Pine.LNX.4.64.0801221417480.1912@schroedinger.engr.sgi.com>
 <20080123075821.GA17713@aepfle.de> <20080123105044.GD21455@csn.ul.ie>
 <20080123121459.GA18631@aepfle.de> <20080123125236.GA18876@aepfle.de>
 <20080123135513.GA14175@csn.ul.ie> <Pine.LNX.4.64.0801231611160.20050@sbz-30.cs.Helsinki.FI>
 <Pine.LNX.4.64.0801231626320.21475@sbz-30.cs.Helsinki.FI>
 <Pine.LNX.4.64.0801231648140.23343@sbz-30.cs.Helsinki.FI>
 <20080123155655.GB20156@csn.ul.ie> <Pine.LNX.4.64.0801231906520.1028@sbz-30.cs.Helsinki.FI>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, hanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lee.schermerhorn@hp.com, Linux MM <linux-mm@kvack.org>, Olaf Hering <olaf@aepfle.de>
List-ID: <linux-mm.kvack.org>

On Wed, 23 Jan 2008, Pekka J Enberg wrote:

> Fine. But, why are we hitting fallback_alloc() in the first place? It's 
> definitely not because of missing ->nodelists as we do:
> 
>         cache_cache.nodelists[node] = &initkmem_list3[CACHE_CACHE];
> 
> before attempting to set up kmalloc caches. Now, if I understood 
> correctly, we're booting off a memoryless node so kmem_getpages() will 
> return NULL thus forcing us to fallback_alloc() which is unavailable at 
> this point.
> 
> As far as I can tell, there are two ways to fix this:
> 
>   (1) don't boot off a memoryless node (why are we doing this in the first 
>       place?)

Right. That is the solution that I would prefer.

>   (2) initialize cache_cache.nodelists with initmem_list3 equivalents
>       for *each node hat has normal memory*

Or simply do it for all. SLAB bootstrap is very complex thing though.

> 
> I am still wondering why this worked before, though.

I doubt it did ever work for SLAB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
