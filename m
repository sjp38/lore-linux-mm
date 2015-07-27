Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 476B36B0254
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 11:39:39 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so144599443wic.0
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 08:39:38 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id n3si14624945wib.44.2015.07.27.08.39.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jul 2015 08:39:37 -0700 (PDT)
Date: Mon, 27 Jul 2015 11:39:00 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC v2 1/4] mm: make alloc_pages_exact_node pass __GFP_THISNODE
Message-ID: <20150727153900.GA31432@cmpxchg.org>
References: <1437749126-25867-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437749126-25867-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Fri, Jul 24, 2015 at 04:45:23PM +0200, Vlastimil Babka wrote:
> @@ -310,11 +326,18 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
>  	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
>  }
>  
> +/*
> + * Allocate pages, restricting the allocation to the node given as nid. The
> + * node must be valid and online. This is achieved by adding __GFP_THISNODE
> + * to gfp_mask.
> + */
>  static inline struct page *alloc_pages_exact_node(int nid, gfp_t gfp_mask,
>  						unsigned int order)
>  {
>  	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));
>  
> +	gfp_mask |= __GFP_THISNODE;
> +
>  	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
>  }

The "exact" name is currently ambiguous within the allocator API, and
it's bad that we have _exact_node() and _exact_nid() with entirely
different meanings. It'd be good to make "thisnode" refer to specific
and exclusive node requests, and "exact" to mean page allocation
chunks that are not in powers of two.

Would you consider renaming this function to alloc_pages_thisnode() as
part of this series?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
