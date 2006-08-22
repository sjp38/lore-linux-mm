Subject: Re: [PATCH] radix-tree:  fix radix_tree_replace_slot
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0608221401520.25753@schroedinger.engr.sgi.com>
References: <1156278317.5622.14.camel@localhost>
	 <Pine.LNX.4.64.0608221401520.25753@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 22 Aug 2006 17:24:03 -0400
Message-Id: <1156281844.5622.39.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, "Paul E. McKenney" <paulmck@us.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-08-22 at 14:06 -0700, Christoph Lameter wrote:
> On Tue, 22 Aug 2006, Lee Schermerhorn wrote:
> 
> >   * @item:	new item to store in the slot.
> > + *
> > + * For use with radix_tree_lookup_slot().  Caller must hold tree write locked
> > + * across slot lookup and replacement.
> >   */
> >  static inline void radix_tree_replace_slot(void *pslot, void *item)
> >  {
> >  	void *slot = *(void **)pslot;
> >  	BUG_ON(radix_tree_is_direct_ptr(item));
> > -	rcu_assign_pointer(slot,
> > +	rcu_assign_pointer(*(void **)pslot,
> >  		(void *)((unsigned long)item |
> >  			((unsigned long)slot & RADIX_TREE_DIRECT_PTR)));
>                                         ^^^^ Is this a legit use of slot?
> 
> >  }
> > 
> 
> Would it not be better to change the calling conventions of 
> radix_tree_replace_slot? It should get passsed a void **pslot right?
> 
> static inline void radix_tree_replace_slot(void **pslot, void *item)
> {
> 	BUG_ON(radix_tree_is_direct_ptr(item));
> 	rcu_assign_pointer(*pslot,
> 		(void *)((unsigned long)item |
> 			((unsigned long)*pslot & RADIX_TREE_DIRECT_PTR)));
> }
> 

I did consider that, and I looked at where the value of pslot came from
[radix_tree_lookup_slot()] and all of the casts and other uses of that
value.  I decided to limit the change to the one line that I submitted.
I don't actually recall my reasoning now.  Probably to maintain the
symmetry of _deref_slot() and _replace_slot().

Your suggestion certainly looks cleaner.  Could/should also change
_deref_slot()'s arg to 'void **pslot' and save a cast?

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
