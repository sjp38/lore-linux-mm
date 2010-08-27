Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E68716B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 20:19:35 -0400 (EDT)
Date: Fri, 27 Aug 2010 02:19:26 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: fix hang on anon_vma->root->lock
Message-ID: <20100827001926.GA6803@random.random>
References: <alpine.LSU.2.00.1008252305540.19107@sister.anvils>
 <20100825.234149.189710316.davem@davemloft.net>
 <AANLkTik8cHD_qsey8NBw-YWsoibwMM5RNP9SeKom2VtC@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTik8cHD_qsey8NBw-YWsoibwMM5RNP9SeKom2VtC@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org, akpm@linux-foundation.org, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 26, 2010 at 03:54:28AM -0700, Hugh Dickins wrote:
> On Wed, Aug 25, 2010 at 11:41 PM, David Miller <davem@davemloft.net> wrote:
> > From: Hugh Dickins <hughd@google.com>
> > Date: Wed, 25 Aug 2010 23:12:54 -0700 (PDT)
> >
> >> After several hours, kbuild tests hang with anon_vma_prepare() spinning on
> >> a newly allocated anon_vma's lock - on a box with CONFIG_TREE_PREEMPT_RCU=y
> >> (which makes this very much more likely, but it could happen without).
> >>
> >> The ever-subtle page_lock_anon_vma() now needs a further twist: since
> >> anon_vma_prepare() and anon_vma_fork() are liable to change the ->root
> >> of a reused anon_vma structure at any moment, page_lock_anon_vma()
> >> needs to check page_mapped() again before succeeding, otherwise
> >> page_unlock_anon_vma() might address a different root->lock.
> >>
> >> Signed-off-by: Hugh Dickins <hughd@google.com>
> >
> > Interesting, is the condition which allows this to trigger specific
> > to this merge window or was it always possible?
> 
> Just specific to this merge window, which started using
> anon_vma->root->lock in place of anon_vma->lock (anon_vma->root is
> often anon_vma itself, but not always).  I _think_ that change was
> itself a simplification of the locking in 2.6.35, rather than plugging
> a particular hole (it's not been backported to -stable), but I may be
> wrong on that - Rik?

rmap_walk_anon isn't stable without the anon_vma->root->lock. This is
because it only locks the local anon_vma and but the "vma" can be
still modified under it in vma_adjust, so vma_address can fail and
migration will crash. swapping is not issue as it's ok to miss a pte
once in a while if the vma is under vma_adjust by the time the VM
tries to unmap the page.

See the anon_vma_lock added as well to vma_adjust (without it, it'd be
just an useless exercise, but instead it's really plugging a real hole
thanks to the anon_vma_lock addition to vma_adjust).

Again not an issue unless you use migration (incidentally what memory
compaction uses, and you know who the primary user of memory
compaction is :).

Secondly ksm_does_need_to_copy can't be fixed to cow only pages that
are nonlinear as the page->mapping != anon_vma can now generate false
positives. It's now trivial to fix with page->mapping->root !=
anon_vma->root.

About your patch, it's a noop in my view... A single page_mapping
check after rcu_read_lock is enough. And "anon_vma->root" can't change
if page->mapping points to "anon_vma" at any time after rcu_read_lock
returns. rcu_read_lock works for all anon_vma including
anon_vma->root.

If you were running the page_mapped() check on a different "page" then
it could make a difference, but repeating it on the same page in the
same rcu_read_lock protected critical section won't make a difference
as far as the anon_vma freeing is concerned.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
