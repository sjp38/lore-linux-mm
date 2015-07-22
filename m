Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 98AA96B0261
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 21:23:05 -0400 (EDT)
Received: by pdbbh15 with SMTP id bh15so83787985pdb.1
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 18:23:05 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id f6si47184948pds.59.2015.07.21.18.23.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 18:23:04 -0700 (PDT)
Message-ID: <1437528180.16792.4.camel@ellerman.id.au>
Subject: Re: [PATCH] mm: rename and document alloc_pages_exact_node
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Wed, 22 Jul 2015 11:23:00 +1000
In-Reply-To: <1437486951-19898-1-git-send-email-vbabka@suse.cz>
References: <1437486951-19898-1-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar
 K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Gleb Natapov <gleb@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Cliff Whickman <cpw@sgi.com>, Robin Holt <robinmholt@gmail.com>

On Tue, 2015-07-21 at 15:55 +0200, Vlastimil Babka wrote:
> The function alloc_pages_exact_node() was introduced in 6484eb3e2a81 ("page
> allocator: do not check NUMA node ID when the caller knows the node is valid")
> as an optimized variant of alloc_pages_node(), that doesn't allow the node id
> to be -1. Unfortunately the name of the function can easily suggest that the
> allocation is restricted to the given node. In truth, the node is only
> preferred, unless __GFP_THISNODE is among the gfp flags.
> 
> The misleading name has lead to mistakes in the past, see 5265047ac301 ("mm,
> thp: really limit transparent hugepage allocation to local node") and
> b360edb43f8e ("mm, mempolicy: migrate_to_node should only migrate to node").
> 
> To prevent further mistakes, this patch renames the function to
> alloc_pages_prefer_node() and documents it together with alloc_pages_node().
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
 
>  I'm CC'ing also maintainers of the callsites so they can verify that the
>  callsites that don't pass __GFP_THISNODE are really not intended to restrict
>  allocation to the given node. I went through them myself and each looked like
>  it's better off if it can successfully allocate on a fallback node rather
>  than fail. DavidR checked them also I think, but it's better if maintainers
>  can verify that. I'm not completely sure about all the usages in sl*b due to
>  multiple layers through which gfp flags are being passed.


> diff --git a/arch/powerpc/platforms/cell/ras.c b/arch/powerpc/platforms/cell/ras.c
> index e865d74..646a310 100644
> --- a/arch/powerpc/platforms/cell/ras.c
> +++ b/arch/powerpc/platforms/cell/ras.c
> @@ -123,7 +123,7 @@ static int __init cbe_ptcal_enable_on_node(int nid, int order)
>  
>  	area->nid = nid;
>  	area->order = order;
> -	area->pages = alloc_pages_exact_node(area->nid,
> +	area->pages = alloc_pages_prefer_node(area->nid,
>  						GFP_KERNEL|__GFP_THISNODE,
>  						area->order);

Yeah that looks right to me.

This code enables some firmware memory calibration so I think it really does
want to get memory on the specified node, or else fail.

Acked-by: Michael Ellerman <mpe@ellerman.id.au>

cheers


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
