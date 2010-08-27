Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 38F806B01F2
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 21:43:36 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id o7R1hXkG002369
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 18:43:33 -0700
Received: from vws3 (vws3.prod.google.com [10.241.21.131])
	by kpbe16.cbf.corp.google.com with ESMTP id o7R1hVed008778
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 18:43:32 -0700
Received: by vws3 with SMTP id 3so2909206vws.33
        for <linux-mm@kvack.org>; Thu, 26 Aug 2010 18:43:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100826235052.GZ6803@random.random>
References: <alpine.LSU.2.00.1008252305540.19107@sister.anvils>
	<20100826235052.GZ6803@random.random>
Date: Thu, 26 Aug 2010 18:43:31 -0700
Message-ID: <AANLkTimgKcP78CNakDf34NrVrd5apfXrtptNw+G6G5DK@mail.gmail.com>
Subject: Re: [PATCH] mm: fix hang on anon_vma->root->lock
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 26, 2010 at 4:50 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> On Wed, Aug 25, 2010 at 11:12:54PM -0700, Hugh Dickins wrote:
>> After several hours, kbuild tests hang with anon_vma_prepare() spinning on
>> a newly allocated anon_vma's lock - on a box with CONFIG_TREE_PREEMPT_RCU=y
>> (which makes this very much more likely, but it could happen without).
>>
>> The ever-subtle page_lock_anon_vma() now needs a further twist: since
>> anon_vma_prepare() and anon_vma_fork() are liable to change the ->root
>> of a reused anon_vma structure at any moment, page_lock_anon_vma()
>> needs to check page_mapped() again before succeeding, otherwise
>> page_unlock_anon_vma() might address a different root->lock.
>
> I don't get it, the anon_vma can be freed and reused only after we run
> rcu_read_unlock().

No.  Between rcu_read_lock and rcu_read_unlock, once we've done the
first (original) page_mapped test to make sure that this isn't just a
long-stale page->mapping left over in there, SLAB_DESTROY_BY_RCU
ensures that the slab page on which this "struct anon_vma" resides
cannot be freed and reused for some other purpose e.g. a page of user
data.  But that piece of slab holding this "struct anon_vma" is liable
to be freed and reused for another struct anon_vma at any point, until
we've got the right lock on it.

> And the anon_vma->root can't change unless the
> anon_vma is freed and reused.

Yes, but RCU is not protecting against that: all it's doing is
guaranteeing that when we "speculatively" spin_lock the anon_vma, we
won't be corrupting some other kind of structure or data.

> Last but not the least by the time
> page->mapping points to "anon_vma" the "anon_vma->root" is already
> initialized and stable.

Yes, but two things to be careful of there: one, we leave
page->mapping pointing to the anon_vma maybe long after that address
has got reused for something else, it's only when the page is finally
freed that it's cleared (and there certainly was a good racing reason
for that, but I'd have to think long and hard to reconstruct the
sequence - OTOH it was a race between page_remove_rmap and
page_add_anon_rmap); and two, notice how anon_vma_prepare() sets
anon_vma->root = anon_vma on a newly allocated anon_vma, before it
gets anon_vma_lock - so anon_vma->root can change underneath us at any
point there, until we've got anon_vma_lock _and_ checked stability
with a second page_mapped test.

>
> The page_mapped test is only relevant against the rcu_read_lock, not
> the spin_lock, so how it can make a difference to run it twice inside
> the same rcu_read_lock protected critical section? The first one still
> is valid also after the anon_vma_lock() returns, it's not like that
> anon_vma_lock drops the rcu_read_lock internally.
>
> Furthermore no need of ACCESS_ONCE on the anon_vma->root because it
> can't change from under us as the anon_vma can't be freed from under
> us until rcu_read_unlock returns (after we verified the first time
> that page_mapped is true under the rcu_read_lock, which we already do
> before trying to take the anon_vma_lock).

I must rush off for a few hours: hopefully my assertions above shed
some light., I think you're mistaking the role that RCU plays here.
You remark in other mail "About your patch, it's a noop in my view..."
- but seems quite an effective noop ;)  Without the patch my kbuilds
would hang usually within 6 hours - though one time they did manage 20
hours, I admit. They ran with the patch for 52 hours before I switched
the machine over to something else.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
