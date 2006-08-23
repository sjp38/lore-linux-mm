Received: from midway.site ([71.117.233.155]) by xenotime.net for <linux-mm@kvack.org>; Wed, 23 Aug 2006 12:02:57 -0700
Date: Wed, 23 Aug 2006 12:06:07 -0700
From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH] radix-tree:  cleanup radix_tree_deref_slot() and
 _lookup_slot() comments
Message-Id: <20060823120607.9c24ff42.rdunlap@xenotime.net>
In-Reply-To: <1156359008.5159.36.camel@localhost>
References: <1156278772.5622.23.camel@localhost>
	<20060823105144.eccd3cbf.rdunlap@xenotime.net>
	<1156359008.5159.36.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@osdl.org>, "Paul E. McKenney" <paulmck@us.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 23 Aug 2006 14:50:08 -0400 Lee Schermerhorn wrote:

> How about the attached patch?  Applies atop my previous 2 radix tree
> patches [fix and cleanup].  Addresses Christoph's comment, as well.

Yes, that's fine on the kernel-doc side.  Thanks.


> Lee
> 
> Cleanup radix_tree_{deref|replace}_slot() calling conventions.
> 
> Adopt Christoph's suggestion to change calling conventions
> of radix_tree_replace_slot().  Make similar change to
> radix_tree_defer_slot().  
> 
> Both now take a 'void **pslot' argument.  Not only does this
> simplify the code of these two functions, but the arg type
> now matches the return type of radix_tree_lookup_slot().
> 
> Tested with reverted page migration, but I don't know that I
> was exercising any direct pointers.
> 
> Note: this will require changes to migrate_page_move_mapping()
> to avoid compiler warnings if/when we back out the work around
> patch for the problem in '_replace_slot() fixed by a prior patch.
> The migrate code is [will then be] the only user of the direct
> slot replacement APIs.
> 
> Also, fix '_deref_slot() and '_lookup_slot() return comments
> for Randy.
> 
> Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
> 
>  include/linux/radix-tree.h |   14 ++++++--------
>  lib/radix-tree.c           |    4 ++--
>  2 files changed, 8 insertions(+), 10 deletions(-)
> 
> Index: linux-2.6.18-rc4-mm2/include/linux/radix-tree.h
> ===================================================================
> --- linux-2.6.18-rc4-mm2.orig/include/linux/radix-tree.h	2006-08-23 11:28:37.000000000 -0400
> +++ linux-2.6.18-rc4-mm2/include/linux/radix-tree.h	2006-08-23 14:08:59.000000000 -0400
> @@ -122,17 +122,16 @@ do {									\
>  /**
>   * radix_tree_deref_slot	- dereference a slot
>   * @pslot:	pointer to slot, returned by radix_tree_lookup_slot
> - * @returns:	item that was stored in that slot with any direct pointer flag
> + * Returns:	item that was stored in that slot with any direct pointer flag
>   *		removed.
>   *
>   * For use with radix_tree_lookup_slot().  Caller must hold tree at least read
>   * locked across slot lookup and dereference.  More likely, will be used with
>   * radix_tree_replace_slot(), as well, so caller will hold tree write locked.
>   */
> -static inline void *radix_tree_deref_slot(void *pslot)
> +static inline void *radix_tree_deref_slot(void **pslot)
>  {
> -	void *slot = *(void **)pslot;
> -	return radix_tree_direct_to_ptr(slot);
> +	return radix_tree_direct_to_ptr(*pslot);
>  }
>  /**
>   * radix_tree_replace_slot	- replace item in a slot
> @@ -142,13 +141,12 @@ static inline void *radix_tree_deref_slo
>   * For use with radix_tree_lookup_slot().  Caller must hold tree write locked
>   * across slot lookup and replacement.
>   */
> -static inline void radix_tree_replace_slot(void *pslot, void *item)
> +static inline void radix_tree_replace_slot(void **pslot, void *item)
>  {
> -	void *slot = *(void **)pslot;
>  	BUG_ON(radix_tree_is_direct_ptr(item));
> -	rcu_assign_pointer(*(void **)pslot,
> +	rcu_assign_pointer(*pslot,
>  		(void *)((unsigned long)item |
> -			((unsigned long)slot & RADIX_TREE_DIRECT_PTR)));
> +			((unsigned long)*pslot & RADIX_TREE_DIRECT_PTR)));
>  }
>  
>  int radix_tree_insert(struct radix_tree_root *, unsigned long, void *);
> Index: linux-2.6.18-rc4-mm2/lib/radix-tree.c
> ===================================================================
> --- linux-2.6.18-rc4-mm2.orig/lib/radix-tree.c	2006-08-22 14:51:38.000000000 -0400
> +++ linux-2.6.18-rc4-mm2/lib/radix-tree.c	2006-08-23 14:12:41.000000000 -0400
> @@ -332,8 +332,8 @@ EXPORT_SYMBOL(radix_tree_insert);
>   *	@root:		radix tree root
>   *	@index:		index key
>   *
> - *	Lookup the slot corresponding to the position @index in the radix tree
> - *	@root. This is useful for update-if-exists operations.
> + *	Returns:  the slot corresponding to the position @index in the
> + *	radix tree @root. This is useful for update-if-exists operations.
>   *
>   *	This function cannot be called under rcu_read_lock, it must be
>   *	excluded from writers, as must the returned slot for subsequent

---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
