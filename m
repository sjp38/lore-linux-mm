Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 857B06B0005
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 18:57:28 -0500 (EST)
Date: Thu, 31 Jan 2013 15:57:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/6] lib: Implement range locks
Message-Id: <20130131155726.05d09b21.akpm@linux-foundation.org>
In-Reply-To: <1359668994-13433-2-git-send-email-jack@suse.cz>
References: <1359668994-13433-1-git-send-email-jack@suse.cz>
	<1359668994-13433-2-git-send-email-jack@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, 31 Jan 2013 22:49:49 +0100
Jan Kara <jack@suse.cz> wrote:

> Implement range locking using interval tree.
> 
> ...
>
> +void range_lock(struct range_lock_tree *tree, struct range_lock *lock)
> +{
> +	struct interval_tree_node *node;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&tree->lock, flags);
> +	node = interval_tree_iter_first(&tree->root, lock->node.start,
> +					lock->node.last);
> +	while (node) {
> +		lock->blocking_ranges++;
> +		node = interval_tree_iter_next(node, lock->node.start,
> +					       lock->node.last);
> +	}
> +	interval_tree_insert(&lock->node, &tree->root);
> +	/* Do we need to go to sleep? */
> +	while (lock->blocking_ranges) {
> +		lock->task = current;
> +		__set_current_state(TASK_UNINTERRUPTIBLE);
> +		spin_unlock_irqrestore(&tree->lock, flags);
> +		schedule();
> +		spin_lock_irqsave(&tree->lock, flags);
> +	}
> +	spin_unlock_irqrestore(&tree->lock, flags);
> +}
>
> ...
>
> +void range_unlock(struct range_lock_tree *tree, struct range_lock *lock)
> +{
> +	struct interval_tree_node *node;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&tree->lock, flags);
> +	interval_tree_remove(&lock->node, &tree->root);
> +	node = interval_tree_iter_first(&tree->root, lock->node.start,
> +					lock->node.last);
> +	while (node) {
> +		range_lock_unblock((struct range_lock *)node);
> +		node = interval_tree_iter_next(node, lock->node.start,
> +					       lock->node.last);
> +	}
> +	spin_unlock_irqrestore(&tree->lock, flags);
> +}

What are the worst-case interrupt-off durations here?

I note that the new exported functions in this patchset are
refreshingly free of documentation ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
