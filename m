Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 8B1B66B0068
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 13:21:15 -0500 (EST)
Received: by mail-da0-f52.google.com with SMTP id f10so2223407dak.39
        for <linux-mm@kvack.org>; Fri, 21 Dec 2012 10:21:14 -0800 (PST)
Date: Fri, 21 Dec 2012 10:21:16 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch] mm, mempolicy: Introduce spinlock to read shared policy
 tree
In-Reply-To: <CA+55aFxrdPpMWLD8LF0NNqgJqmB-L-HW3Xyxht6e5AwnoaueTw@mail.gmail.com>
Message-ID: <alpine.LNX.2.00.1212210944050.1699@eggly.anvils>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org> <1353624594-1118-19-git-send-email-mingo@kernel.org> <alpine.DEB.2.00.1212031644440.32354@chino.kir.corp.google.com> <CA+55aFyrSVzGZ438DGnTFuyFb1BOXaMmvxtkW0Xhnx+BxAg2PA@mail.gmail.com>
 <alpine.DEB.2.00.1212201440250.7807@chino.kir.corp.google.com> <20121221134740.GC13367@suse.de> <CA+55aFxrdPpMWLD8LF0NNqgJqmB-L-HW3Xyxht6e5AwnoaueTw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Sasha Levin <levinsasha928@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Fri, 21 Dec 2012, Linus Torvalds wrote:
> On Fri, Dec 21, 2012 at 5:47 AM, Mel Gorman <mgorman@suse.de> wrote:
> > On Thu, Dec 20, 2012 at 02:55:22PM -0800, David Rientjes wrote:
> >>
> >> This is probably worth discussing now to see if we can't revert
> >> b22d127a39dd ("mempolicy: fix a race in shared_policy_replace()"), keep it
> >> only as a spinlock as you suggest, and do what KOSAKI suggested in
> >> http://marc.info/?l=linux-kernel&m=133940650731255 instead.  I don't think
> >> it's worth trying to optimize this path at the cost of having both a
> >> spinlock and mutex.
> >
> > Jeez, I'm still not keen on that approach for the reasons that are explained
> > in the changelog for b22d127a39dd.
> 
> Christ, Mel.
> 
> Your reasons in b22d127a39dd are weak as hell, and then you come up
> with *THIS* shit instead:
> 
> > That leads to this third *ugly* option that conditionally drops the lock
> > and it's up to the caller to figure out what happened. Fooling around with
> > how it conditionally releases the lock results in different sorts of ugly.
> > We now have three ugly sister patches for this. Who wants to be Cinderalla?
> >
> > ---8<---
> > mm: numa: Release the PTL if calling vm_ops->get_policy during NUMA hinting faults
> 
> Heck no. In fact, not a f*cking way in hell. Look yourself in the
> mirror, Mel. This patch is ugly, and *guaranteed* to result in subtle
> locking issues, and then you have the *gall* to quote the "uhh, that's
> a bit ugly due to some trivial duplication" thing in commit
> b22d127a39dd.
> 
> Reverting commit b22d127a39dd and just having a "ok, if we need to
> allocate, then drop the lock, allocate, re-get the lock, and see if we
> still need the new allocation" is *beautiful* code compared to the
> diseased abortion you just posted.
> 
> Seriously. Conditional locking is error-prone, and about a million
> times worse than the trivial fix that Kosaki suggested.

I'm picking up a vibe that you don't entirely like Mel's approach.

I've an unsubstantiated suspicion that it's also incomplete as is.
Although at first I thought huge_memory.c does not need a similar
mod, because THPages are anonymous and cannot come from tmpfs,
I now wonder about a MAP_PRIVATE mapping from tmpfs - for better
or for worse, anon pages there are subject to the same mempolicy
as the shared file pages, and I don't see what prevents khugepaged
from gathering those into THPages.  But it didn't happen when I
tried, so maybe I'm just missing what prevents it.

I don't understand David's and Mel's remarks about the "shared pages"
check making Sasha's warning unlikely: page_mapcount has nothing to do
with whether a page belongs to shm/shmem/tmpfs, and it's easy enough
to reproduce Sasha's warning on the current git tree.  "mount -o
remount,mpol=local /tmp" or something like that is useful in testing.

I wish wish wish I had time to spend on this today, but I don't.
And I've not looked to see (let alone tested) whether it's easy
to revert Mel's mutex then add in Kosaki's patch (which I didn't
look at so have no opinion on).

Shall we go for Peter/David's mutex+spinlock for rc1 - I assume
they both tested that - with a promise to do better in rc2?

What I wanted to try is separate the get_vma_policy() out from
mpol_misplaced(), and have the various callsites do that first
outside the page table lock, passing it in to mpol_misplaced.
But that doesn't work (efficiently) unless it also returns the
range that that policy is valid for, so we don't have to (drop
lock and) call it on every pte.  I cannot do that for rc1, and
perhaps it's irrelevant if Kosaki's patch is preferred.

(Perhaps I should confess I've another reason to come here for
rc2: that "+ info->vfs_inode.i_ino" we recently added for better
interleave distribution in shmem_alloc_page: I think NUMA placement
faults will be fighting shmem_alloc_page's choices because that
offset is not exposed.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
