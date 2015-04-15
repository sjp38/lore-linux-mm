Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7A6206B0038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 02:22:54 -0400 (EDT)
Received: by pdea3 with SMTP id a3so40275976pde.3
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 23:22:54 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id sq5si5367217pab.179.2015.04.14.23.22.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Apr 2015 23:22:53 -0700 (PDT)
Received: by pabtp1 with SMTP id tp1so39157184pab.2
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 23:22:52 -0700 (PDT)
Date: Tue, 14 Apr 2015 23:22:42 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [Question] ksm: rmap_item pointing to some stale vmas
In-Reply-To: <552CBB49.5000308@codeaurora.org>
Message-ID: <alpine.LSU.2.11.1504142155010.11693@eggly.anvils>
References: <55268741.8010301@codeaurora.org> <alpine.LSU.2.11.1504101047200.28925@eggly.anvils> <552CBB49.5000308@codeaurora.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Susheel Khiani <skhiani@codeaurora.org>
Cc: Hugh Dickins <hughd@google.com>, akpm@linux-foundation.org, peterz@infradead.org, neilb@suse.de, dhowells@redhat.com, paulmcquad@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 14 Apr 2015, Susheel Khiani wrote:
> On 04/10/15 23:26, Hugh Dickins wrote:
> > On Thu, 9 Apr 2015, Susheel Khiani wrote:
> > > 
> > > We are seeing an issue during try_to_unmap_ksm where in call to
> > > try_to_unmap_one is failing.
> > > 
> > > try_to_unmap_ksm in this particular case is trying to go through vmas
> > > associated with each rmap_item->anon_vma. What we see is this that the
> > > corresponding page is not mapped to any of the vmas associated with 2
> > > rmap_item.
> > > 
> > > The associated rmap_item in this case looks like pointing to some valid
> > > vma
> > > but the said page is not found to be mapped under it. try_to_unmap_one
> > > thus
> > > fails to find valid ptes for these vmas.
> > > 
> > > At the same time we can see that the page actually is mapped in 2
> > > separate
> > > and different vmas which are not part of rmap_item associated with page.
> > > 
> > > So whether rmap_item is pointing to some stale vmas and now the mapping
> > > has
> > > changed? Or there is something else going on here.
> > > p
> > > Any pointer would be appreciated.
> > 
> > I expected to be able to argue this away, but no: I think you've found
> > a bug, and I think I get it too.  I have no idea what's wrong at this
> > point, will set aside some time to investigate, and report back.
> > 
> > Which kernel are you using?  try_to_unmap_ksm says v3.13 or earlier.
> > Probably doesn't affect the bug, but may affect the patch you'll need.
> > 
> 
> We are using kernel-3.10.49 and I have gone through patches of ksm above this
> kernel version but didn't find anything relevant w.r.t issue. The latest
> patch which we have for KSM on our tree is
> 
> 668f9abb: mm: close PageTail race

I agree, I don't think 3.10.49 would be missing any relevant fix -
unless there's a later fix to some "random" corruption which happens
to hit you here in KSM.

I wonder how you identified that this issue of un-unmappable pages
is peculiar to KSM.  Have you established that ordinary anon pages
(we need not worry about file pages here) are always successfully
unmappable?  KSM is reliant upon anon_vmas working as intended
(but then makes use of them in its own peculiar way).

> 
> The issue otherwise is difficult to reproduce and is appearing after days of
> testing on 512MB Android platform. What I am not able to figure out is which
> code path in ksm could actually land us in situation where in stable_node we
> still have stale rmap_items with old vmas which are now unmapped.

Whether that's something to worry about depends on what you mean.

It's normal for a stable_node to have some stale rmap_items attached,
now pointing to pages different from the stable page, or pointing to none.
That's in the nature of KSM, the way ksmd builds up its structures by
peeking at what's in each mm, moving on, and coming back a cycle later
to discover what's changed.

But the anon_vma which such a stale rmap_item points to should remain
valid (KSM holds an additional reference to it), even if its interval
tree is now empty, or none of the vmas that it holds now cover this
mm,address (but any vmas held should still be valid vmas).

I was concerned, not that the stable_node has stale rmap_items attached,
but that you know the page to be mapped, yet try_to_unmap_ksm is unable
to locate its mappings.

> 
> In the dumps we can see the new vmas mapping to the page but the new
> rmap_items with these new vmas which maps the page are still not updated in
> stable_node.

"still not updated" after how long?
I assume you to mean that, how ever long you wait (but at least
one full scan), the stable_node is not updated with an rmap_item
pointing to an anon_vma whose interval tree contains one of these
new vmas which maps the page?

(When setting up a new stable node, it will take several scans to
establish, and can be delayed by various races, such as shifts in
the unstable tree, and the trylock_page in try_to_merge_one_page.
But I think that once you can see a stable ksm page mapped somewhere,
all pointers to it should be captured within a single scan.)

That's bad, but I have no idea of the cause.  I mention corruption
above, because that would be one possibility; though unlikely if
it always hits you here in KSM only.

Whereas if you mean that a new mapping of the stable page may not
be unmapped until ksmd has completed a full scan, that is also
wrong, but not so serious.  Or would even that be a serious issue
for you?  Please describe how this comes to be a problem for you.

I believe I have found two bugs that would explain the latter case;
but both of them require fork, and legend has it that Android avoids
fork (correct me if wrong); so I doubt they're responsible for your
case, and expect both to be corrected within one full scan.

The lesser of the bugs is this: KSM reclaim (dependent on anon_vmas)
was introduced in 2.6.33, but then anon_vma_chains were introduced
in 2.6.34, and I suspect that the conversion ought to have updated
try_to_merge_with_ksm_page, to take rmap_item->anon_vma from page
instead of from vma.  I believe that some fork-connected mappings
may be missed for a scan because of that.

But fixing it doesn't help much: because the greater bug (mine) is
that the search_new_forks code is not working as well as intended.
It relies on using one rmap_item's anon_vma to locate the page in
newer mappings forked from it, before ksmd reaches them to create
their own rmap_items; but we're doing nothing to prevent that
earlier rmap_item from being removed too soon.

I would much rather be sending a patch, than trying to describe
this so obscurely; but I have not succeeded and time has run out.

I got far enough, I think, to confirm that this happens for me,
and can be fixed by delaying the removal of such rmap_items.
But I did not get far enough to stop them from leaking wildly;
and although I've searched for quick and easy ways to do it,
have come to the conclusion that fixing it safely without leaks
will require more time and care than I can afford at present.

(And even with those fixed, there would still be rare cases when
a new mapping could not immediately be unmapped: for example,
replace_page increments kpage's mapcount, but a racing
try_to_unmap_ksm may hold kpage's page lock, preventing the
relevant rmap_item from being appended to the stable tree.)

I do hate to put down half-finished work, and would have liked
to send you a patch, even if only to confirm that my problem
is actually not your problem.  But I now see no alternative to
merely informing you of this, and wishing you luck in your own
investigation: I'm sorry, I just don't know.

But if I've misunderstood, and you think that what you're seeing
fits with the transient forking bugs I've (not quite) described,
and you can explain why even the transient case is important for
you to have fixed, then I really ought to redouble my efforts.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
