Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 966936B0044
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 00:28:14 -0400 (EDT)
Date: Wed, 28 Oct 2009 05:28:05 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Transparent Hugepage support
Message-ID: <20091028042805.GJ7744@basil.fritz.box>
References: <20091026185130.GC4868@random.random> <87ljiwk8el.fsf@basil.nowhere.org> <20091027193007.GA6043@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091027193007.GA6043@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 27, 2009 at 08:30:07PM +0100, Andrea Arcangeli wrote:

Hi Andrea,

> On Tue, Oct 27, 2009 at 07:18:26PM +0100, Andi Kleen wrote:
> > In general the best would be to just merge hugetlbfs into
> > the normal VM. It has been growing for far too long as a separate
> > "second VM" by now. This seems like a reasonable first step,
> > but some comments blow.
> 
> Problem is hugetlbfs as it stands now can't be merged... it
> deliberately takes its own paths and it tries to be as far away from
> the VM as possible. But as you said, as people tries to make hugetlbfs

I think longer term the standard VM just needs to understand
huge pages properly. Originally when huge pages were only
considered a "Oracle hack" the separation made sense, but now
with more and more use that is really not true anymore.

Also hugetlbfs is gaining more and more functionality all the time.

Maintaining two VMs in parallel forever seems like the wrong
thing to do.

Also the fragmentation avoidance heuristics got a lot better
in the last years, so it's much more practical than it used to be
(at least for 2MB)

> > The problem is that this will interact badly with 1GB pages -- once
> > you split them up you'll never get them back, because they 
> > can't be allocated at runtime.
> 
> 1GB pages can't be handled by this code, and clearly it's not
> practical to hope 1G pages to materialize in the buddy (even if we

That seems short sightened. You do this because 2MB pages give you
x% performance advantage, but then it's likely that 1GB pages will give 
another y% improvement and why should people stop at the smaller
improvement?

Ignoring the gigantic pages now would just mean that this
would need to be revised later again or that users still
need to use hacks like libhugetlbfs.

Given 1GB pages for a time are harder to use on the system
administrator level, but at least for applications the interfaces
should be similar at least.

> were to increase the buddy so much slowing it down regular page
> allocation). Let's forget 1G pages here... we're only focused on sizes
> that can be allocated dynamically. Main problem are the 64k pages or
> such that don't fit into a pmd...

What 64k pages? You're talking about soft pages or non x86?
> 
> > Even for 2MB pages it can be a problem.
> > 
> > You'll likely need to fix the page table code.
> 
> In terms of fragmentation split_huge_page itself won't create
> it.. unless it swaps (but then CPU performance is lost on the mapping
> anyway).

The problem is that the performance will be lost forever. So if
you ever do something that only does a little temporary 
swapping (like a backup run) you would be ready for a reboot.
Not good.

>  We need to teach mprotect/mremap not to call split_huge_page
> true, but not to avoid fragmentation. btw, thinking at fragmentation

I think they just have to be fixed properly.

My suspicion is btw that there's some more code sharing possible
in all that VMA handling code of ther different system calls
(I remember thinking that when I wrote mbind() :-). Then perhaps 
variable page support would be easier anyways because less code needs
to be changed.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
