Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B7DB46B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 19:51:00 -0400 (EDT)
Date: Fri, 27 Aug 2010 01:50:52 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: fix hang on anon_vma->root->lock
Message-ID: <20100826235052.GZ6803@random.random>
References: <alpine.LSU.2.00.1008252305540.19107@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1008252305540.19107@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Hugh,

On Wed, Aug 25, 2010 at 11:12:54PM -0700, Hugh Dickins wrote:
> After several hours, kbuild tests hang with anon_vma_prepare() spinning on
> a newly allocated anon_vma's lock - on a box with CONFIG_TREE_PREEMPT_RCU=y
> (which makes this very much more likely, but it could happen without).
> 
> The ever-subtle page_lock_anon_vma() now needs a further twist: since
> anon_vma_prepare() and anon_vma_fork() are liable to change the ->root
> of a reused anon_vma structure at any moment, page_lock_anon_vma()
> needs to check page_mapped() again before succeeding, otherwise
> page_unlock_anon_vma() might address a different root->lock.

I don't get it, the anon_vma can be freed and reused only after we run
rcu_read_unlock(). And the anon_vma->root can't change unless the
anon_vma is freed and reused. Last but not the least by the time
page->mapping points to "anon_vma" the "anon_vma->root" is already
initialized and stable.

The page_mapped test is only relevant against the rcu_read_lock, not
the spin_lock, so how it can make a difference to run it twice inside
the same rcu_read_lock protected critical section? The first one still
is valid also after the anon_vma_lock() returns, it's not like that
anon_vma_lock drops the rcu_read_lock internally.

Furthermore no need of ACCESS_ONCE on the anon_vma->root because it
can't change from under us as the anon_vma can't be freed from under
us until rcu_read_unlock returns (after we verified the first time
that page_mapped is true under the rcu_read_lock, which we already do
before trying to take the anon_vma_lock).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
