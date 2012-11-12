Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id CE17C6B002B
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 15:55:04 -0500 (EST)
Received: by mail-vb0-f41.google.com with SMTP id v13so101347vbk.14
        for <linux-mm@kvack.org>; Mon, 12 Nov 2012 12:55:03 -0800 (PST)
Message-ID: <50A16212.8090507@gmail.com>
Date: Mon, 12 Nov 2012 15:54:42 -0500
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] fix missing rb_subtree_gap updates on vma insert/erase
References: <1352721091-27022-1-git-send-email-walken@google.com>
In-Reply-To: <1352721091-27022-1-git-send-email-walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

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
> These 3 patches apply on top of the stack I previously sent (or equally,
> on top of the last published mmotm).
> 
> Michel Lespinasse (3):
>   mm: ensure safe rb_subtree_gap update when inserting new VMA
>   mm: ensure safe rb_subtree_gap update when removing VMA
>   mm: debug code to verify rb_subtree_gap updates are safe
> 
>  mm/mmap.c |  121 +++++++++++++++++++++++++++++++++++++------------------------
>  1 files changed, 73 insertions(+), 48 deletions(-)
> 

Looking good: old warnings gone, no new warnings.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
