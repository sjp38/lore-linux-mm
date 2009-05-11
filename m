Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3C1546B003D
	for <linux-mm@kvack.org>; Mon, 11 May 2009 18:03:34 -0400 (EDT)
Date: Mon, 11 May 2009 15:00:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] lib : do code optimization for radix_tree_lookup() and
 radix_tree_lookup_slot()
Message-Id: <20090511150045.4cc376db.akpm@linux-foundation.org>
In-Reply-To: <4A0787B5.8060103@gmail.com>
References: <4A0787B5.8060103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: nickpiggin@yahoo.com.au, clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 May 2009 10:04:37 +0800
Huang Shijie <shijie8@gmail.com> wrote:

>  I think radix_tree_lookup() and radix_tree_lookup_slot() have too much 
> same code except the return value.
>  I introduce the function radix_tree_lookup_element() to do the real work.

Fair enough.

The patch was badly wordwrapped and had all its tabs replaced with
spaces.  Please fix your email client before sending any further
patches.

Please also use scripts/checkpatch.pl to check for small stylistic
errors.  This patch introduced several of them.

> --- a/lib/radix-tree.c~lib-do-code-optimization-for-radix_tree_lookup-and-radix_tree_lookup_slot
> +++ a/lib/radix-tree.c
> @@ -351,20 +351,12 @@ int radix_tree_insert(struct radix_tree_
>  }
>  EXPORT_SYMBOL(radix_tree_insert);
>  
> -/**
> - *	radix_tree_lookup_slot    -    lookup a slot in a radix tree
> - *	@root:		radix tree root
> - *	@index:		index key
> - *
> - *	Returns:  the slot corresponding to the position @index in the
> - *	radix tree @root. This is useful for update-if-exists operations.
> - *
> - *	This function can be called under rcu_read_lock iff the slot is not
> - *	modified by radix_tree_replace_slot, otherwise it must be called
> - *	exclusive from other writers. Any dereference of the slot must be done
> - *	using radix_tree_deref_slot.
> +/*
> + * is_slot == 1 : search for the slot.
> + * is_slot == 0 : search for the node.
>   */
> -void **radix_tree_lookup_slot(struct radix_tree_root *root, unsigned long index)
> +static void * radix_tree_lookup_element(struct radix_tree_root *root,
> +					unsigned long index, int is_slot)
>  {
>  	unsigned int height, shift;
>  	struct radix_tree_node *node, **slot;
> @@ -376,7 +368,7 @@ void **radix_tree_lookup_slot(struct rad
>  	if (!radix_tree_is_indirect_ptr(node)) {
>  		if (index > 0)
>  			return NULL;
> -		return (void **)&root->rnode;
> +		return is_slot ? (void *)&root->rnode : node;
>  	}
>  	node = radix_tree_indirect_to_ptr(node);
>  
> @@ -397,7 +389,25 @@ void **radix_tree_lookup_slot(struct rad
>  		height--;
>  	} while (height > 0);
>  
> -	return (void **)slot;
> +	return is_slot ? (void *)slot : node;

hm, yes, the cast is needed to prevent "warning: pointer type mismatch
in conditional expression".  Stupid gcc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
