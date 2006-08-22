Date: Tue, 22 Aug 2006 14:06:00 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] radix-tree:  fix radix_tree_replace_slot
In-Reply-To: <1156278317.5622.14.camel@localhost>
Message-ID: <Pine.LNX.4.64.0608221401520.25753@schroedinger.engr.sgi.com>
References: <1156278317.5622.14.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@osdl.org>, "Paul E. McKenney" <paulmck@us.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 22 Aug 2006, Lee Schermerhorn wrote:

>   * @item:	new item to store in the slot.
> + *
> + * For use with radix_tree_lookup_slot().  Caller must hold tree write locked
> + * across slot lookup and replacement.
>   */
>  static inline void radix_tree_replace_slot(void *pslot, void *item)
>  {
>  	void *slot = *(void **)pslot;
>  	BUG_ON(radix_tree_is_direct_ptr(item));
> -	rcu_assign_pointer(slot,
> +	rcu_assign_pointer(*(void **)pslot,
>  		(void *)((unsigned long)item |
>  			((unsigned long)slot & RADIX_TREE_DIRECT_PTR)));
                                        ^^^^ Is this a legit use of slot?

>  }
> 

Would it not be better to change the calling conventions of 
radix_tree_replace_slot? It should get passsed a void **pslot right?

static inline void radix_tree_replace_slot(void **pslot, void *item)
{
	BUG_ON(radix_tree_is_direct_ptr(item));
	rcu_assign_pointer(*pslot,
		(void *)((unsigned long)item |
			((unsigned long)*pslot & RADIX_TREE_DIRECT_PTR)));
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
