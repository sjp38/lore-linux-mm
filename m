Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 747F36B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 02:13:08 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id rp2so244546pbb.34
        for <linux-mm@kvack.org>; Thu, 21 Feb 2013 23:13:07 -0800 (PST)
Message-ID: <51271A7D.6020305@gmail.com>
Date: Fri, 22 Feb 2013 15:13:01 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/7] ksm: treat unstable nid like in stable tree
References: <alpine.LNX.2.00.1302210013120.17843@eggly.anvils> <alpine.LNX.2.00.1302210019390.17843@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1302210019390.17843@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/21/2013 04:20 PM, Hugh Dickins wrote:
> An inconsistency emerged in reviewing the NUMA node changes to KSM:
> when meeting a page from the wrong NUMA node in a stable tree, we say
> that it's okay for comparisons, but not as a leaf for merging; whereas
> when meeting a page from the wrong NUMA node in an unstable tree, we
> bail out immediately.

IIUC
- ksm page from the wrong NUMA node will be add to current node's stable 
tree
- normal page from the wrong NUMA node will be merged to current node's 
stable tree  <- where I miss here? I didn't see any special handling in 
function stable_tree_search for this case.
- normal page from the wrong NUMA node will compare but not as a leaf 
for merging after the patch

>
> Now, it might be that a wrong NUMA node in an unstable tree is more
> likely to correlate with instablility (different content, with rbnode
> now misplaced) than page migration; but even so, we are accustomed to
> instablility in the unstable tree.
>
> Without strong evidence for which strategy is generally better, I'd
> rather be consistent with what's done in the stable tree: accept a page
> from the wrong NUMA node for comparison, but not as a leaf for merging.
>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
>   mm/ksm.c |   19 +++++++++----------
>   1 file changed, 9 insertions(+), 10 deletions(-)
>
> --- mmotm.orig/mm/ksm.c	2013-02-20 22:28:23.584001392 -0800
> +++ mmotm/mm/ksm.c	2013-02-20 22:28:27.288001480 -0800
> @@ -1340,16 +1340,6 @@ struct rmap_item *unstable_tree_search_i
>   			return NULL;
>   		}
>   
> -		/*
> -		 * If tree_page has been migrated to another NUMA node, it
> -		 * will be flushed out and put into the right unstable tree
> -		 * next time: only merge with it if merge_across_nodes.
> -		 */
> -		if (!ksm_merge_across_nodes && page_to_nid(tree_page) != nid) {
> -			put_page(tree_page);
> -			return NULL;
> -		}
> -
>   		ret = memcmp_pages(page, tree_page);
>   
>   		parent = *new;
> @@ -1359,6 +1349,15 @@ struct rmap_item *unstable_tree_search_i
>   		} else if (ret > 0) {
>   			put_page(tree_page);
>   			new = &parent->rb_right;
> +		} else if (!ksm_merge_across_nodes &&
> +			   page_to_nid(tree_page) != nid) {
> +			/*
> +			 * If tree_page has been migrated to another NUMA node,
> +			 * it will be flushed out and put in the right unstable
> +			 * tree next time: only merge with it when across_nodes.
> +			 */
> +			put_page(tree_page);
> +			return NULL;
>   		} else {
>   			*tree_pagep = tree_page;
>   			return tree_rmap_item;
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
