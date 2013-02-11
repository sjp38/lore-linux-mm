Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 258B16B0002
	for <linux-mm@kvack.org>; Mon, 11 Feb 2013 00:42:34 -0500 (EST)
Received: by mail-ve0-f181.google.com with SMTP id d10so4871614vea.12
        for <linux-mm@kvack.org>; Sun, 10 Feb 2013 21:42:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1359668994-13433-2-git-send-email-jack@suse.cz>
References: <1359668994-13433-1-git-send-email-jack@suse.cz>
	<1359668994-13433-2-git-send-email-jack@suse.cz>
Date: Sun, 10 Feb 2013 21:42:32 -0800
Message-ID: <CANN689ExHJjXvAdYM=eYP_hZFT78SHZb1AbJv6743Q=KjohBVQ@mail.gmail.com>
Subject: Re: [PATCH 1/6] lib: Implement range locks
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Hi Jan,

On Thu, Jan 31, 2013 at 1:49 PM, Jan Kara <jack@suse.cz> wrote:
> Implement range locking using interval tree.

Yay! I like to see interval trees being put to good use.

> +/*
> + * Range locking
> + *
> + * We allow exclusive locking of arbitrary ranges. We guarantee that each
> + * range is locked only after all conflicting range locks requested previously
> + * have been unlocked. Thus we achieve fairness and avoid livelocks.
> + *
> + * The cost of lock and unlock of a range is O(log(R_all)+R_int) where R_all is
> + * total number of ranges and R_int is the number of ranges intersecting the
> + * operated range.
> + */

I think the cost is actually O((1+R_int)log(R_all)) as each
interval_tree_iter_{first,next} call is O(log(R_all))

Not that it'll make a huge difference in practice - the cost will be
cheap enough either way.

> +struct range_lock {
> +       struct interval_tree_node node;
> +       struct task_struct *task;
> +       /* Number of ranges which are blocking acquisition of the lock */
s/ranges/previously requested ranges/

I think it's worth writing this down as I originally found this confusing.

BTW, I like how you only count previously requested ranges in order to
guarantee fairness. This was absolutely not obvious to me.

> +#define RANGE_LOCK_INITIALIZER(start, end) {\
> +       .node = {\
> +               .start = (start),\
> +               .end = (end)\
> +       }\
> +}

I have not found any uses of this, but it seems it wouldn't work as
you want .last instead of .end

BTW, it's important to make it clear that last is the last value that
is *included* in the interval, not the first value that follows it.

> +void range_lock_init(struct range_lock *lock, unsigned long start,
> +                    unsigned long end);
> +void range_lock(struct range_lock_tree *tree, struct range_lock *lock);
> +void range_unlock(struct range_lock_tree *tree, struct range_lock *lock);

Is there a point to separating the init and lock stages ? maybe the API could be
void range_lock(struct range_lock_tree *tree, struct range_lock *lock,
unsigned long start, unsigned long last);
void range_unlock(struct range_lock_tree *tree, struct range_lock *lock);

(I changed end to last because I think end makes it sound like it's
the first value after the interval, while last makes it clear that
it's the last value in the interval)

> +/*
> + * Implementation of range locks.
> + *
> + * We keep interval tree of locked and to-be-locked ranges. When new range lock
> + * is requested, we add its interval to the tree and store number of intervals
> + * intersecting it to 'blocking_ranges'.
> + *
> + * When a range is unlocked, we again walk intervals that intersect with the
> + * unlocked one and decrement their 'blocking_ranges'.  We wake up owner of any
> + * range lock whose 'blocking_ranges' drops to 0.
> + */

May be worth repeating the comment about how this achieves fairness
and avoids livelocks.

> +void range_lock_init(struct range_lock *lock, unsigned long start,
> +                    unsigned long end)
> +{
> +       lock->node.start = start;
> +       lock->node.last = end;
> +       RB_CLEAR_NODE(&lock->node.rb);

I really wish people didn't unnecessarily use RB_CLEAR_NODE before
inserting nodes in an rbtree.
RB_CLEAR_NODE is never necessary unless you want to tag unused nodes
and check them later using RB_EMPTY_NODES.

> +void range_lock(struct range_lock_tree *tree, struct range_lock *lock)
> +{
> +       struct interval_tree_node *node;
> +       unsigned long flags;
> +
> +       spin_lock_irqsave(&tree->lock, flags);

Are you expecting range locks to be used from hardirq context ? If
not, it may be more appropriate to just use spin_lock_bh ?

> +       node = interval_tree_iter_first(&tree->root, lock->node.start,
> +                                       lock->node.last);
> +       while (node) {
> +               lock->blocking_ranges++;
> +               node = interval_tree_iter_next(node, lock->node.start,
> +                                              lock->node.last);
> +       }

Nitpicking here, but I think this is slightly easier to read as a for loop:
for (node = interval_tree_iter_first(...);
     node;
     node = interval_tree_iter_next(...))
        lock->blocking_ranges++;

> +       /* Do we need to go to sleep? */
> +       while (lock->blocking_ranges) {
> +               lock->task = current;
> +               __set_current_state(TASK_UNINTERRUPTIBLE);
> +               spin_unlock_irqrestore(&tree->lock, flags);
> +               schedule();
> +               spin_lock_irqsave(&tree->lock, flags);
> +       }
> +       spin_unlock_irqrestore(&tree->lock, flags);

I think I would prefer:
        lock->task = tsk = current;
        spin_unlock_irqrestore(&tree->lock, flags);
        while (true) {
                set_task_state(tsk, TASK_UNINTERRUPTIBLE);
                if (!lock->blocking_ranges)
                        break;
                schedule();
        }
        set_task_state(tsk, TASK_RUNNING);

This avoids an unnecessary spinlock acquisition when we obtain the range lock.
(You can optionally choose to avoid the whole thing and just unlock
the spinlock if !lock->blocking_ranges)

> +static void range_lock_unblock(struct range_lock *lock)
> +{
> +       if (!--lock->blocking_ranges)
> +               wake_up_process(lock->task);
> +}
> +
> +void range_unlock(struct range_lock_tree *tree, struct range_lock *lock)
> +{
> +       struct interval_tree_node *node;
> +       unsigned long flags;
> +
> +       spin_lock_irqsave(&tree->lock, flags);
> +       interval_tree_remove(&lock->node, &tree->root);
> +       node = interval_tree_iter_first(&tree->root, lock->node.start,
> +                                       lock->node.last);
> +       while (node) {
> +               range_lock_unblock((struct range_lock *)node);
> +               node = interval_tree_iter_next(node, lock->node.start,
> +                                              lock->node.last);
> +       }

Maybe just a personal preference, but I prefer a for loop.
Also, I would prefer container_of() instead of a cast.
Finally, I don't think I see the benefit of having a separate
range_lock_unblock function instead of a couple lines to do it within
the for loop.

The above may sound critical, but I actually like your proposal a lot :)

Reviewed-by: Michel Lespinasse <walken@google.com>

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
