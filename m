Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7F1CE6B0200
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 05:55:53 -0400 (EDT)
Date: Fri, 27 Aug 2010 11:55:46 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: fix hang on anon_vma->root->lock
Message-ID: <20100827095546.GC6803@random.random>
References: <alpine.LSU.2.00.1008252305540.19107@sister.anvils>
 <20100826235052.GZ6803@random.random>
 <AANLkTimgKcP78CNakDf34NrVrd5apfXrtptNw+G6G5DK@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTimgKcP78CNakDf34NrVrd5apfXrtptNw+G6G5DK@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 26, 2010 at 06:43:31PM -0700, Hugh Dickins wrote:
> some light., I think you're mistaking the role that RCU plays here.

That's exactly correct, I thought it prevented reuse of the slab
entry, not only of the whole slab... SLAB_DESTROY_BY_RCU is a lot more
tricky to use than I though...

However at the light of this, I think page_lock_anon_vma could have
returned a freed and reused anon_vma well before the anon-vma changes.

The anon_vma could have been freed after the first page_mapped check
succeed but before taking the spinlock. I think, it worked fine
because the rmap walks are robust enough just not to fall apart on a
reused anon_vma while the lock is hold. It become a visible problem
now because we were unlocking the wrong lock leading to a
deadlock. But I guess it wasn't too intentional to return a reused
anon_vma out of page_lock_anon_vma.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
