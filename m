Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 80C2C6B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 08:33:38 -0500 (EST)
Received: by mail-io0-f175.google.com with SMTP id g203so62042228iof.2
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 05:33:38 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id m8si4246122igx.42.2016.03.04.05.33.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Mar 2016 05:33:37 -0800 (PST)
Message-ID: <56D98BDD.3060806@huawei.com>
Date: Fri, 4 Mar 2016 21:21:33 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] radix-tree: Fix race in gang lookup
References: <1453929472-25566-1-git-send-email-matthew.r.wilcox@intel.com> <1453929472-25566-2-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1453929472-25566-2-git-send-email-matthew.r.wilcox@intel.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Ohad Ben-Cohen <ohad@wizery.com>, Matthew Wilcox <willy@linux.intel.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On 2016/1/28 5:17, Matthew Wilcox wrote:
> From: Matthew Wilcox <willy@linux.intel.com>
>
> If the indirect_ptr bit is set on a slot, that indicates we need to
> redo the lookup.  Introduce a new function radix_tree_iter_retry()
> which forces the loop to retry the lookup by setting 'slot' to NULL and
> turning the iterator back to point at the problematic entry.
>
> This is a pretty rare problem to hit at the moment; the lookup has to
> race with a grow of the radix tree from a height of 0.  The consequences
> of hitting this race are that gang lookup could return a pointer to a
> radix_tree_node instead of a pointer to whatever the user had inserted
> in the tree.
>
> Fixes: cebbd29e1c2f ("radix-tree: rewrite gang lookup using iterator")
> Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
> Cc: stable@vger.kernel.org
> ---
>  include/linux/radix-tree.h | 16 ++++++++++++++++
>  lib/radix-tree.c           | 12 ++++++++++--
>  2 files changed, 26 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> index f9a3da5bf892..db0ed595749b 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -387,6 +387,22 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
>  			     struct radix_tree_iter *iter, unsigned flags);
>  
>  /**
> + * radix_tree_iter_retry - retry this chunk of the iteration
> + * @iter:	iterator state
> + *
> + * If we iterate over a tree protected only by the RCU lock, a race
> + * against deletion or creation may result in seeing a slot for which
> + * radix_tree_deref_retry() returns true.  If so, call this function
> + * and continue the iteration.
> + */
> +static inline __must_check
> +void **radix_tree_iter_retry(struct radix_tree_iter *iter)
> +{
> +	iter->next_index = iter->index;
> +	return NULL;
> +}
> +
> +/**
>   * radix_tree_chunk_size - get current chunk size
>   *
>   * @iter:	pointer to radix tree iterator
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index a25f635dcc56..65422ac17114 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -1105,9 +1105,13 @@ radix_tree_gang_lookup(struct radix_tree_root *root, void **results,
>  		return 0;
>  
>  	radix_tree_for_each_slot(slot, root, &iter, first_index) {
> -		results[ret] = indirect_to_ptr(rcu_dereference_raw(*slot));
> +		results[ret] = rcu_dereference_raw(*slot);
>  		if (!results[ret])
>  			continue;
> +		if (radix_tree_is_indirect_ptr(results[ret])) {
> +			slot = radix_tree_iter_retry(&iter);
> +			continue;
> +		}
>  		if (++ret == max_items)
>  			break;
>  	}
according to your patch, after  A race occur,  slot equals to null.  radix_tree_next_slot() will continue
to work. Therefore, it will not return the problematic entry. 
> @@ -1184,9 +1188,13 @@ radix_tree_gang_lookup_tag(struct radix_tree_root *root, void **results,
>  		return 0;
>  
>  	radix_tree_for_each_tagged(slot, root, &iter, first_index, tag) {
> -		results[ret] = indirect_to_ptr(rcu_dereference_raw(*slot));
> +		results[ret] = rcu_dereference_raw(*slot);
>  		if (!results[ret])
>  			continue;
> +		if (radix_tree_is_indirect_ptr(results[ret])) {
> +			slot = radix_tree_iter_retry(&iter);
> +			continue;
> +		}
>  		if (++ret == max_items)
>  			break;
>  	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
