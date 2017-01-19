Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 65EAB6B0288
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 04:52:17 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id d134so51215763pfd.0
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 01:52:17 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id j62si3048526pgc.184.2017.01.19.01.52.15
        for <linux-mm@kvack.org>;
        Thu, 19 Jan 2017 01:52:16 -0800 (PST)
Date: Thu, 19 Jan 2017 18:52:07 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v5 01/13] lockdep: Refactor lookup_chain_cache()
Message-ID: <20170119095207.GP3326@X58A-UD3R>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-2-git-send-email-byungchul.park@lge.com>
 <20170119091627.GG15084@tardis.cn.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170119091627.GG15084@tardis.cn.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boqun Feng <boqun.feng@gmail.com>
Cc: peterz@infradead.org, mingo@kernel.org, tglx@linutronix.de, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Thu, Jan 19, 2017 at 05:16:27PM +0800, Boqun Feng wrote:
> On Wed, Jan 18, 2017 at 10:17:27PM +0900, Byungchul Park wrote:
> > Currently, lookup_chain_cache() provides both 'lookup' and 'add'
> > functionalities in a function. However, each is useful. So this
> > patch makes lookup_chain_cache() only do 'lookup' functionality and
> > makes add_chain_cahce() only do 'add' functionality. And it's more
> > readable than before.
> > 
> > Signed-off-by: Byungchul Park <byungchul.park@lge.com>
> > ---
> >  kernel/locking/lockdep.c | 129 +++++++++++++++++++++++++++++------------------
> >  1 file changed, 81 insertions(+), 48 deletions(-)
> > 
> > diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
> > index 4d7ffc0..f37156f 100644
> > --- a/kernel/locking/lockdep.c
> > +++ b/kernel/locking/lockdep.c
> > @@ -2109,15 +2109,9 @@ static int check_no_collision(struct task_struct *curr,
> >  	return 1;
> >  }
> >  
> > -/*
> > - * Look up a dependency chain. If the key is not present yet then
> > - * add it and return 1 - in this case the new dependency chain is
> > - * validated. If the key is already hashed, return 0.
> > - * (On return with 1 graph_lock is held.)
> > - */
> 
> I think you'd better put some comments here for the behavior of
> add_chain_cache(), something like:
> 
> /*
>  * Add a dependency chain into chain hashtable.
>  * 
>  * Must be called with graph_lock held.
>  * Return 0 if fail to add the chain, and graph_lock is released.
>  * Return 1 with graph_lock held if succeed.
>  */

Yes. I will apply what you recommand.

Thank you very much. :)

Thanks,
Byungchul

> 
> Regards,
> Boqun
> 
> > -static inline int lookup_chain_cache(struct task_struct *curr,
> > -				     struct held_lock *hlock,
> > -				     u64 chain_key)
> > +static inline int add_chain_cache(struct task_struct *curr,
> > +				  struct held_lock *hlock,
> > +				  u64 chain_key)
> >  {
> >  	struct lock_class *class = hlock_class(hlock);
> >  	struct hlist_head *hash_head = chainhashentry(chain_key);
> > @@ -2125,49 +2119,18 @@ static inline int lookup_chain_cache(struct task_struct *curr,
> >  	int i, j;
> >  
> >  	/*
> > +	 * Allocate a new chain entry from the static array, and add
> > +	 * it to the hash:
> > +	 */
> > +
> > +	/*
> >  	 * We might need to take the graph lock, ensure we've got IRQs
> >  	 * disabled to make this an IRQ-safe lock.. for recursion reasons
> >  	 * lockdep won't complain about its own locking errors.
> >  	 */
> >  	if (DEBUG_LOCKS_WARN_ON(!irqs_disabled()))
> >  		return 0;
> [...]


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
