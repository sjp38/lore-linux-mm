Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1ED366B00A2
	for <linux-mm@kvack.org>; Wed,  6 May 2009 10:46:03 -0400 (EDT)
Date: Wed, 6 May 2009 15:46:31 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 2/6] ksm: dont allow overlap memory addresses registrations.
In-Reply-To: <20090506152100.41266e4c@lxorguk.ukuu.org.uk>
Message-ID: <Pine.LNX.4.64.0905061532240.25289@blonde.anvils>
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com>
 <1241475935-21162-2-git-send-email-ieidus@redhat.com>
 <1241475935-21162-3-git-send-email-ieidus@redhat.com> <4A00DD4F.8010101@redhat.com>
 <4A015C69.7010600@redhat.com> <4A0181EA.3070600@redhat.com>
 <20090506131735.GW16078@random.random> <Pine.LNX.4.64.0905061424480.19190@blonde.anvils>
 <20090506140904.GY16078@random.random> <20090506152100.41266e4c@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, chrisw@redhat.com, device@lanana.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Wed, 6 May 2009, Alan Cox wrote:
> > the max number of ksm pages that can be allocated at any given time so
> > to avoid OOM conditions, like the swap-compress logic that limits the
> > swapdevice size to less than ram.

(I don't know anything about that swap-compress logic and limitation.)

> 
> Are those pages accounted for in the vm_overcommit logic, as if you
> allocate a big chunk of memory as KSM will do you need the worst case
> vm_overcommit behaviour preserved and that means keeping the stats
> correct.

As I understand it, KSM won't affect the vm_overcommit behaviour at all.
Those pages Izik refers to are not allocated up front, they're just a
limit on the number of process pages which may get held in core at any
one time, through being shared via the KSM mechanism.

KSM is not evading vm_committed_space at all, not opening a backdoor
away from the ordinary mmaps: just collapsing duplicated pages in
what's been mapped in the usual way, down to single copies.

So the vm_commited_space accounting is exactly as before: it would
be a bit odd to be running KSM along with OVERCOMMIT_NEVER, but it
doesn't change its calculations at all - it will and will have to
be as pessimistic as it ever was.

The only difference would be in how much memory (mostly lowmem)
KSM's own data structures will take up - as usual, the kernel
data structures aren't being accounted, but do take up memory.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
