Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id EB63F6B0031
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 17:30:07 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id rr13so11448682pbb.35
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 14:30:07 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ix4si3451773pbb.119.2014.02.13.14.30.06
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 14:30:07 -0800 (PST)
Date: Thu, 13 Feb 2014 14:30:05 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] swapoff tmpfs radix_tree: remember to rcu_read_unlock
Message-Id: <20140213143005.9aea5709d5befd1df84b19a7@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.11.1402121840500.6398@eggly.anvils>
References: <alpine.LSU.2.11.1402121840500.6398@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 12 Feb 2014 18:45:07 -0800 (PST) Hugh Dickins <hughd@google.com> wrote:

> Running fsx on tmpfs with concurrent memhog-swapoff-swapon, lots of
> 
> BUG: sleeping function called from invalid context at kernel/fork.c:606
> in_atomic(): 0, irqs_disabled(): 0, pid: 1394, name: swapoff
> 1 lock held by swapoff/1394:
>  #0:  (rcu_read_lock){.+.+.+}, at: [<ffffffff812520a1>] radix_tree_locate_item+0x1f/0x2b6
> followed by
> ================================================
> [ BUG: lock held when returning to user space! ]
> 3.14.0-rc1 #3 Not tainted
> ------------------------------------------------
> swapoff/1394 is leaving the kernel with locks still held!
> 1 lock held by swapoff/1394:
>  #0:  (rcu_read_lock){.+.+.+}, at: [<ffffffff812520a1>] radix_tree_locate_item+0x1f/0x2b6
> after which the system recovered nicely.
> 
> Whoops, I long ago forgot the rcu_read_unlock() on one unlikely branch.
> 
> Fixes: e504f3fdd63d ("tmpfs radix_tree: locate_item to speed up swapoff")

huh.  Venerable.  I'm surprised that such an obvious blooper wasn't
spotted at review.  Why didn't anyone else hit this.


> Of course, the truth is that I had been hoping to break Johannes's
> patchset in mmotm, was thrilled to get this on that, then despondent
> to realize that the only bug I had found was mine.  Surprised I've
> not seen it before in 2.5 years: tried again on 3.14-rc1, got the
> same after 25 minutes.  Probably not serious enough for -stable,
> but please can we slip the fix into 3.14 - sorry, Johannes's
> mm-keep-page-cache-radix-tree-nodes-in-check.patch will need a refresh.

I fixed it up.

unsigned long radix_tree_locate_item(struct radix_tree_root *root, void *item)
{
	struct radix_tree_node *node;
	unsigned long max_index;
	unsigned long cur_index = 0;
	unsigned long found_index = -1;

	do {
		rcu_read_lock();
		node = rcu_dereference_raw(root->rnode);
		if (!radix_tree_is_indirect_ptr(node)) {
			rcu_read_unlock();
			if (node == item)
				found_index = 0;
			break;
		}

		node = indirect_to_ptr(node);
		max_index = radix_tree_maxindex(node->path &
						RADIX_TREE_HEIGHT_MASK);
		if (cur_index > max_index) {
			rcu_read_unlock();
			break;
		}

		cur_index = __locate(node, item, cur_index, &found_index);
		rcu_read_unlock();
		cond_resched();
	} while (cur_index != 0 && cur_index <= max_index);

	return found_index;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
