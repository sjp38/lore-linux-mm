Received: by py-out-1112.google.com with SMTP id f47so742700pye.20
        for <linux-mm@kvack.org>; Thu, 17 Jan 2008 04:31:23 -0800 (PST)
Message-ID: <84144f020801170431l2d6d0d63i1fb7ebc5145539f4@mail.gmail.com>
Date: Thu, 17 Jan 2008 14:31:22 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [BUG] at mm/slab.c:3320
In-Reply-To: <Pine.LNX.4.64.0801091601080.14723@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080107102301.db52ab64.kamezawa.hiroyu@jp.fujitsu.com>
	 <Pine.LNX.4.64.0801072131350.28725@schroedinger.engr.sgi.com>
	 <20080109065015.GG7602@us.ibm.com>
	 <Pine.LNX.4.64.0801090949440.10163@schroedinger.engr.sgi.com>
	 <20080109185859.GD11852@skywalker>
	 <Pine.LNX.4.64.0801091122490.11317@schroedinger.engr.sgi.com>
	 <20080109214707.GA26941@us.ibm.com>
	 <Pine.LNX.4.64.0801091349430.12505@schroedinger.engr.sgi.com>
	 <20080109221315.GB26941@us.ibm.com>
	 <Pine.LNX.4.64.0801091601080.14723@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Nishanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, lee.schermerhorn@hp.com, bob.picco@hp.com, mel@skynet.ie, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On Jan 10, 2008 2:02 AM, Christoph Lameter <clameter@sgi.com> wrote:
> New patch that also checks in alternate_node_alloc if the node has normal
> memory because we cannot call ____cache_alloc_node with an invalid node.

[snip]

> @@ -3439,8 +3442,14 @@ __do_cache_alloc(struct kmem_cache *cach
>          * We may just have run out of memory on the local node.
>          * ____cache_alloc_node() knows how to locate memory on other nodes
>          */
> -       if (!objp)
> -               objp = ____cache_alloc_node(cache, flags, numa_node_id());
> +       if (!objp) {
> +               int node_id = numa_node_id();
> +               if (likely(cache->nodelists[node_id])) /* fast path */
> +                       objp = ____cache_alloc_node(cache, flags, node_id);
> +               else /* this function can do good fallback */
> +                       objp = __cache_alloc_node(cache, flags, node_id,
> +                                       __builtin_return_address(0));
> +       }

But __cache_alloc_node() will call fallback_alloc() that does
cache_grow() for the node that doesn't have N_NORMAL_MEMORY, no?

Shouldn't we just revert 04231b3002ac53f8a64a7bd142fde3fa4b6808c6 for
2.6.24 as this is a clear regression from 2.6.23?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
