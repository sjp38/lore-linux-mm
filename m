Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id D0BF76B005A
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 09:04:16 -0500 (EST)
Message-ID: <50A0FC41.5020802@redhat.com>
Date: Mon, 12 Nov 2012 08:40:17 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm: ensure safe rb_subtree_gap update when removing
 VMA
References: <1352721091-27022-1-git-send-email-walken@google.com> <1352721091-27022-3-git-send-email-walken@google.com>
In-Reply-To: <1352721091-27022-3-git-send-email-walken@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <levinsasha928@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/12/2012 06:51 AM, Michel Lespinasse wrote:
> Using the trinity fuzzer, Sasha Levin uncovered a case where
> rb_subtree_gap wasn't correctly updated.
>
> Digging into this, the root cause was that vma insertions and removals
> require both an rbtree insert or erase operation (which may trigger
> tree rotations), and an update of the next vma's gap (which does not
> change the tree topology, but may require iterating on the node's
> ancestors to propagate the update). The rbtree rotations caused the
> rb_subtree_gap values to be updated in some of the internal nodes, but
> without upstream propagation. Then the subsequent update on the next
> vma didn't iterate as high up the tree as it should have, as it
> stopped as soon as it hit one of the internal nodes that had been
> updated as part of a tree rotation.
>
> The fix is to impose that all rb_subtree_gap values must be up to date
> before any rbtree insertion or erase, with the possible exception that
> the node being erased doesn't need to have an up to date rb_subtree_gap.
>
> This change: during VMA removal, remove VMA from the rbtree before we
> remove it from the linked list. The implication is the next vma's
> rb_subtree_gap value becomes stale when next->vm_prev is updated,
> and we want to make sure vma_rb_erase() runs before there are any
> such stale rb_subtree_gap values in the rbtree.
>
> (I don't know of a reproduceable test case for this particular issue)
>
> Signed-off-by: Michel Lespinasse <walken@google.com>

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
