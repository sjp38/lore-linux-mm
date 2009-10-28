Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 704986B004D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 15:05:18 -0400 (EDT)
Date: Wed, 28 Oct 2009 20:04:59 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: RFC: Transparent Hugepage support
Message-ID: <20091028190459.GH9640@random.random>
References: <20091026185130.GC4868@random.random>
 <87ljiwk8el.fsf@basil.nowhere.org>
 <20091027193007.GA6043@random.random>
 <20091028042805.GJ7744@basil.fritz.box>
 <20091028120050.GD9640@random.random>
 <20091028141803.GQ7744@basil.fritz.box>
 <20091028154827.GF9640@random.random>
 <20091028160352.GS7744@basil.fritz.box>
 <20091028162206.GG9640@random.random>
 <20091028163458.GT7744@basil.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091028163458.GT7744@basil.fritz.box>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 28, 2009 at 05:34:58PM +0100, Andi Kleen wrote:
> I think you need some user visible interfaces to cleanly handle existing
> reservations on a process base at least, otherwise you'll completely break 
> their semantics.
> 
> sysctls that change existing semantics greatly are usually a bad idea
> because what should the user do if they have existing applications
> that rely on old semantics, but still want the new functionality?

What is not clear about the word "transparent". This whole effort is
about not having to add visible interfaces and userland won't be able
to notice (except it runs faster). We don't want new interfaces. We
need an madvise to give an hint to the daemon of which regions are
critical to have hugepages. It's not so easy for the kernel to find it
by itself.

The reason the sysfs enable/disable of the "transparency" is because
embedded may want to disable the transparency. Not every hardware out
there will have enough memory or enough l2 CPU cache and useful
workloads to take advantage of this, so those might (and it's not
guaranteed) save a bit of memory by disabling the feature.

In short the fewer new interfaces we add the better, and the only one
I think is generic enough and needed enough, is madvise(MADV_HUGEPAGE)
(which will tell the kernel to use hugepages even if transparent
hugepage is disabled in sysfs and it'll tell the collapse_huge_page
daemon the virtual regions to relocate in hugepages). For the time
being any additional interface would defeat the objective of not
having to modify apps.

> If you rely on splitting then it all won't work
> for 1GB anyways and might need to be redone on the design level.


memory reservation is the first thing we want to remove as requirement
to use hugepages, which is the first reason why 1G won't work anyway
as we don't want reservation in this, this is all about not having to
reserve anything at boot and not having to modify binaries at all.

1G pages can work but it would need to split 512 pieces and we can do
that after my patch will swap natively 2M pages and we won't call
split_huge_page anymore. Then split_huge_page can be moved up one
level to the pud. Something like that.

Worrying about this right now is too early and not worth it so we
better ignore 1G in the transparency area.

> Code that's not complete is ok, but code that is known to need a 
> redesign from the start is not that great.

It won't need any redesign... besides this is only relevant if you can
manage to find 1G page without reservation, otherwise you're better
off with with hugetlbfs if you have to do magics visible to userland
that _entirely_ depends on reservation for them to have a slight
chance to allocate a 1G page.

> Also completely ignoring sane reservation semantics in advance also
> doesn't seem to be a particularly good way. Some way to control
> this fine grained should be there at least.

Eliminating reservation is the first objective of the patch.

> > all, we should better focus on ensuring the MADV_HUGEPAGE fits 1G
> > collapse_huge_page collapsing later (yeah, assuming 1G pages becomes
> > available and that you can hang all apps using that data for as long
> > as copy_page(1g)).
> 
> Can always schedule and check for signals during the copy.

same is true for split_huge_page... if copy_page can work on a 1G page
then we could even split it at the pte level, but frankly I think it
would be a better fit to split the pud at the pmd level only without
having to go down to the pte.

> The problem I have is that the current "split on demand" approach 
> can fragment even prereserved pages.

1) we eliminate reservation (no preserved pages here) 2)
split_huge_page on demand can't generate any fragmentation whatsoever
(only swap code can then fragment the hugepage by swapping only part
of it but you know the swap code can't swap 2M at once, it's not
split_huge_page fault if page is fragmented as it is swapped it, no
fragmentation happens when mprotect and mremap calls split_huge_page,
however we want to optimize those for performance reasons, and
definitely not for fragmentation purposes at all)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
