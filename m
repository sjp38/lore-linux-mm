Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 023726B005A
	for <linux-mm@kvack.org>; Tue, 26 May 2009 17:31:04 -0400 (EDT)
Date: Tue, 26 May 2009 14:30:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] lib : provide a more precise
 radix_tree_gang_lookup_slot
Message-Id: <20090526143058.c59e6dc1.akpm@linux-foundation.org>
In-Reply-To: <1243223635-3449-1-git-send-email-shijie8@gmail.com>
References: <1243223635-3449-1-git-send-email-shijie8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 May 2009 11:53:55 +0800
Huang Shijie <shijie8@gmail.com> wrote:

> 	The origin radix_tree_gang_lookup_slot() tries to
> lookup max_items slots.But there are maybe holes for
> find_get_pages_contig() which will only use the contiguous part.
> 
> 	So a more precise radix_tree_gang_lookup_slot() is needed
> to avoid unneccessary search work.
> 

OK..

> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> index 355f6e8..03e25f4 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -164,7 +164,8 @@ radix_tree_gang_lookup(struct radix_tree_root *root, void **results,
>  			unsigned long first_index, unsigned int max_items);
>  unsigned int
>  radix_tree_gang_lookup_slot(struct radix_tree_root *root, void ***results,
> -			unsigned long first_index, unsigned int max_items);
> +			unsigned long first_index, unsigned int max_items,
> +			int contig);

Variable `contig' could have the type `bool'.  Did you consider and
reject that option, or just didn't think of it?


> ...
> +			if (contig)
> +				goto out;
> +
> +		} else if (contig) {
> +			index--;
> +			goto out;
> +
> +		if (contig) {
> +			if (slots_found == 0)
> +				break;
> +			if (next_index & RADIX_TREE_MAP_MASK)
> +				break;
> +		}
> -				(void ***)pages, start, nr_pages);
> +				(void ***)pages, start, nr_pages, 0);
> -				(void ***)pages, index, nr_pages);
> +				(void ***)pages, index, nr_pages, 1);

The patch adds cycles in some cases and saves them in others.

Does the saving exceed the adding?  How do we know that the patch is a
net benefit?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
