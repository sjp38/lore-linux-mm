Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 9018A6B000D
	for <linux-mm@kvack.org>; Mon, 11 Feb 2013 05:27:34 -0500 (EST)
Date: Mon, 11 Feb 2013 11:27:30 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/6] lib: Implement range locks
Message-ID: <20130211102730.GA5318@quack.suse.cz>
References: <1359668994-13433-1-git-send-email-jack@suse.cz>
 <1359668994-13433-2-git-send-email-jack@suse.cz>
 <CANN689ExHJjXvAdYM=eYP_hZFT78SHZb1AbJv6743Q=KjohBVQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANN689ExHJjXvAdYM=eYP_hZFT78SHZb1AbJv6743Q=KjohBVQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Sun 10-02-13 21:42:32, Michel Lespinasse wrote:
> Hi Jan,
> 
> On Thu, Jan 31, 2013 at 1:49 PM, Jan Kara <jack@suse.cz> wrote:
> > Implement range locking using interval tree.
> 
> Yay! I like to see interval trees being put to good use.
  Yeah, you saved me some coding of interval tree implementation :) The
code I originally planned would be slightly more efficient I think but
yours is far more simpler.

> > +/*
> > + * Range locking
> > + *
> > + * We allow exclusive locking of arbitrary ranges. We guarantee that each
> > + * range is locked only after all conflicting range locks requested previously
> > + * have been unlocked. Thus we achieve fairness and avoid livelocks.
> > + *
> > + * The cost of lock and unlock of a range is O(log(R_all)+R_int) where R_all is
> > + * total number of ranges and R_int is the number of ranges intersecting the
> > + * operated range.
> > + */
> 
> I think the cost is actually O((1+R_int)log(R_all)) as each
> interval_tree_iter_{first,next} call is O(log(R_all))
  Right. I'll fix that in the comment.
 
> Not that it'll make a huge difference in practice - the cost will be
> cheap enough either way.
> 
> > +struct range_lock {
> > +       struct interval_tree_node node;
> > +       struct task_struct *task;
> > +       /* Number of ranges which are blocking acquisition of the lock */
> s/ranges/previously requested ranges/
> 
> I think it's worth writing this down as I originally found this confusing.
> 
> BTW, I like how you only count previously requested ranges in order to
> guarantee fairness. This was absolutely not obvious to me.
  OK, I'll update the comment.

> > +#define RANGE_LOCK_INITIALIZER(start, end) {\
> > +       .node = {\
> > +               .start = (start),\
> > +               .end = (end)\
> > +       }\
> > +}
> 
> I have not found any uses of this, but it seems it wouldn't work as
> you want .last instead of .end
  I'll just delete it I guess.

> BTW, it's important to make it clear that last is the last value that
> is *included* in the interval, not the first value that follows it.
  In current versions I have this noted at function definitions.

> > +void range_lock_init(struct range_lock *lock, unsigned long start,
> > +                    unsigned long end);
> > +void range_lock(struct range_lock_tree *tree, struct range_lock *lock);
> > +void range_unlock(struct range_lock_tree *tree, struct range_lock *lock);
> 
> Is there a point to separating the init and lock stages ? maybe the API could be
> void range_lock(struct range_lock_tree *tree, struct range_lock *lock,
> unsigned long start, unsigned long last);
> void range_unlock(struct range_lock_tree *tree, struct range_lock *lock);
  I was thinking about this as well. Currently I don't have a place which
would make it beneficial to separate _init and _lock but I can imagine such
uses (where you don't want to pass the interval information down the stack
and it's easier to pass the whole lock structure). Also it looks a bit
confusing to pass (tree, lock, start, last) to the locking functon. So I
left it there. 

OTOH I had to somewhat change the API so that the locking phase is now
separated in "lock_prep" phase which inserts the node into the tree and
counts blocking ranges and "wait" phase which waits for the blocking ranges
to unlock. The reason for this split is that while "lock_prep" needs to
happen under some lock synchronizing operations on the tree, "wait" phase
can be easily lockless. So this allows me to remove the knowledge of how
operations on the tree are synchronized from range locking code itself.
That further allowed me to use mapping->tree_lock for synchronization and
basically reduce the cost of mapping range locking close to 0 for buffered
IO (just a single tree lookup in the tree in the fast path).

So maybe we want to reduce the number of calls for locking from 3 to 2 by
removing the _init phase. I'm not really decided as for mapping range lock
itself, the lock operation is squashed into 1 call anyway and we don't have
other users now...

> (I changed end to last because I think end makes it sound like it's
> the first value after the interval, while last makes it clear that
> it's the last value in the interval)
  This may be a useful change. I'll use that I think.

> > +/*
> > + * Implementation of range locks.
> > + *
> > + * We keep interval tree of locked and to-be-locked ranges. When new range lock
> > + * is requested, we add its interval to the tree and store number of intervals
> > + * intersecting it to 'blocking_ranges'.
> > + *
> > + * When a range is unlocked, we again walk intervals that intersect with the
> > + * unlocked one and decrement their 'blocking_ranges'.  We wake up owner of any
> > + * range lock whose 'blocking_ranges' drops to 0.
> > + */
> 
> May be worth repeating the comment about how this achieves fairness
> and avoids livelocks.
  Good idea. Added.

> > +void range_lock_init(struct range_lock *lock, unsigned long start,
> > +                    unsigned long end)
> > +{
> > +       lock->node.start = start;
> > +       lock->node.last = end;
> > +       RB_CLEAR_NODE(&lock->node.rb);
> 
> I really wish people didn't unnecessarily use RB_CLEAR_NODE before
> inserting nodes in an rbtree.
> RB_CLEAR_NODE is never necessary unless you want to tag unused nodes
> and check them later using RB_EMPTY_NODES.
  OK, removed and noted in memory.

> > +void range_lock(struct range_lock_tree *tree, struct range_lock *lock)
> > +{
> > +       struct interval_tree_node *node;
> > +       unsigned long flags;
> > +
> > +       spin_lock_irqsave(&tree->lock, flags);
> 
> Are you expecting range locks to be used from hardirq context ? If
> not, it may be more appropriate to just use spin_lock_bh ?
  They are used from ->end_io context. I'm actually not sure whether that's
hardirq or just bh (I guess just bh). Anyway I use mapping->tree_lock for
now.

> > +       node = interval_tree_iter_first(&tree->root, lock->node.start,
> > +                                       lock->node.last);
> > +       while (node) {
> > +               lock->blocking_ranges++;
> > +               node = interval_tree_iter_next(node, lock->node.start,
> > +                                              lock->node.last);
> > +       }
> 
> Nitpicking here, but I think this is slightly easier to read as a for loop:
> for (node = interval_tree_iter_first(...);
>      node;
>      node = interval_tree_iter_next(...))
>         lock->blocking_ranges++;
  OK.

> > +       /* Do we need to go to sleep? */
> > +       while (lock->blocking_ranges) {
> > +               lock->task = current;
> > +               __set_current_state(TASK_UNINTERRUPTIBLE);
> > +               spin_unlock_irqrestore(&tree->lock, flags);
> > +               schedule();
> > +               spin_lock_irqsave(&tree->lock, flags);
> > +       }
> > +       spin_unlock_irqrestore(&tree->lock, flags);
> 
> I think I would prefer:
>         lock->task = tsk = current;
>         spin_unlock_irqrestore(&tree->lock, flags);
>         while (true) {
>                 set_task_state(tsk, TASK_UNINTERRUPTIBLE);
>                 if (!lock->blocking_ranges)
>                         break;
>                 schedule();
>         }
>         set_task_state(tsk, TASK_RUNNING);
> 
> This avoids an unnecessary spinlock acquisition when we obtain the range lock.
> (You can optionally choose to avoid the whole thing and just unlock
> the spinlock if !lock->blocking_ranges)
  This code is somewhat different in the latest version...

> > +static void range_lock_unblock(struct range_lock *lock)
> > +{
> > +       if (!--lock->blocking_ranges)
> > +               wake_up_process(lock->task);
> > +}
> > +
> > +void range_unlock(struct range_lock_tree *tree, struct range_lock *lock)
> > +{
> > +       struct interval_tree_node *node;
> > +       unsigned long flags;
> > +
> > +       spin_lock_irqsave(&tree->lock, flags);
> > +       interval_tree_remove(&lock->node, &tree->root);
> > +       node = interval_tree_iter_first(&tree->root, lock->node.start,
> > +                                       lock->node.last);
> > +       while (node) {
> > +               range_lock_unblock((struct range_lock *)node);
> > +               node = interval_tree_iter_next(node, lock->node.start,
> > +                                              lock->node.last);
> > +       }
> 
> Maybe just a personal preference, but I prefer a for loop.
  OK, although I don't see a difference in this case...

> Also, I would prefer container_of() instead of a cast.
  Ah, that's indeed better.

> Finally, I don't think I see the benefit of having a separate
> range_lock_unblock function instead of a couple lines to do it within
> the for loop.
  Yup.

> The above may sound critical, but I actually like your proposal a lot :)
  Thanks for detailed review!

> Reviewed-by: Michel Lespinasse <walken@google.com>
  I actually didn't add this because there are some differences in the
current version...
								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
