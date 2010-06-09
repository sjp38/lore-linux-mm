Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6EE106B0071
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 19:31:26 -0400 (EDT)
Date: Wed, 9 Jun 2010 16:30:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] radix-tree: Implement function
 radix_tree_gang_tag_if_tagged
Message-Id: <20100609163045.797ae621.akpm@linux-foundation.org>
In-Reply-To: <1275676854-15461-2-git-send-email-jack@suse.cz>
References: <1275676854-15461-1-git-send-email-jack@suse.cz>
	<1275676854-15461-2-git-send-email-jack@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@kernel.org, npiggin@suse.de, david@fromorbit.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri,  4 Jun 2010 20:40:53 +0200
Jan Kara <jack@suse.cz> wrote:

> Implement function for setting one tag if another tag is set
> for each item in given range.
> 
>
> ...
>
>  /**
> + * radix_tree_gang_tag_if_tagged - for each item in given range set given
> + *				   tag if item has another tag set
> + * @root:		radix tree root
> + * @first_index:	starting index of a range to scan
> + * @last_index:		last index of a range to scan
> + * @iftag: 		tag index to test
> + * @settag:		tag index to set if tested tag is set
> + *
> + * This function scans range of radix tree from first_index to last_index.
> + * For each item in the range if iftag is set, the function sets also
> + * settag.
> + *
> + * The function returns number of leaves where the tag was set.
> + */
> +unsigned long radix_tree_gang_tag_if_tagged(struct radix_tree_root *root,
> +                unsigned long first_index, unsigned long last_index,
> +                unsigned int iftag, unsigned int settag)

This is kind of a misuse of the term "gang".

First we had radix_tree_lookup(), which returned a single page.

That was a bit inefficient, so then we added radix_tree_gang_lookup(),
which retuned a "gang" of pages.

But radix_tree_gang_tag_if_tagged() doesn't return a gang of anything
(it has no `void **results' argument).

radix_tree_range_tag_if_tagged()?


> +{
> +	unsigned int height = root->height, shift;
> +	unsigned long tagged = 0, index = first_index;
> +	struct radix_tree_node *open_slots[height], *slot;
> +
> +	last_index = min(last_index, radix_tree_maxindex(height));
> +	if (first_index > last_index)
> +		return 0;
> +	if (!root_tag_get(root, iftag))
> +		return 0;
> +	if (height == 0) {
> +		root_tag_set(root, settag);
> +		return 1;
> +	}
> +
> +	shift = (height - 1) * RADIX_TREE_MAP_SHIFT;
> +	slot = radix_tree_indirect_to_ptr(root->rnode);
> +
> +	for (;;) {
> +		int offset;
> +
> +		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
> +		if (!slot->slots[offset])
> +			goto next;
> +		if (!tag_get(slot, iftag, offset))
> +			goto next;
> +		tag_set(slot, settag, offset);
> +		if (height == 1) {
> +			tagged++;
> +			goto next;
> +		}
> +		/* Go down one level */
> +		height--;
> +		shift -= RADIX_TREE_MAP_SHIFT;
> +		open_slots[height] = slot;
> +		slot = slot->slots[offset];
> +		continue;
> +next:
> +		/* Go to next item at level determined by 'shift' */
> +		index = ((index >> shift) + 1) << shift;
> +		if (index > last_index)
> +			break;
> +		while (((index >> shift) & RADIX_TREE_MAP_MASK) == 0) {
> +			/*
> +			 * We've fully scanned this node. Go up. Because
> +			 * last_index is guaranteed to be in the tree, what
> +			 * we do below cannot wander astray.
> +			 */
> +			slot = open_slots[height];
> +			height++;
> +			shift += RADIX_TREE_MAP_SHIFT;
> +		}
> +	}
> +	/*
> +	 * The iftag must have been set somewhere because otherwise
> +	 * we would return immediated at the beginning of the function
> +	 */
> +	root_tag_set(root, settag);
> +
> +	return tagged;
> +}
> +EXPORT_SYMBOL(radix_tree_gang_tag_if_tagged);

Wouldn't this be a lot simpler if it used __lookup_tag()?  Along the
lines of

	do {
		slot *slots[N];

		n = __lookup_tag(.., slots, ...);
		for (i = 0; i < n; i++)
			tag_set(slots[i], ...);
	} while (something);

?

That's still one cache miss per slot and misses on the slots will
preponderate, so the performance won't be much different.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
