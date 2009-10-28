Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B3C246B004D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 11:48:35 -0400 (EDT)
Date: Wed, 28 Oct 2009 16:48:27 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: RFC: Transparent Hugepage support
Message-ID: <20091028154827.GF9640@random.random>
References: <20091026185130.GC4868@random.random>
 <87ljiwk8el.fsf@basil.nowhere.org>
 <20091027193007.GA6043@random.random>
 <20091028042805.GJ7744@basil.fritz.box>
 <20091028120050.GD9640@random.random>
 <20091028141803.GQ7744@basil.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091028141803.GQ7744@basil.fritz.box>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 28, 2009 at 03:18:03PM +0100, Andi Kleen wrote:
> Why glibc? 
> Yes, there are quite some workloads who benefit.

That's what I meant, I said glibc to mean not just KVM (like Chris
pointed out before ;)

> Even without automatic allocation and the need to prereseve
> having the same application interface for 1GB pages is still useful.
> Otherwise people who want to use the 1GB pages have to do the
> special hacks again.

They will have to do the special hacks for reservation... No many
other hacks after that if they accept if they reserve it becomes not
swappable. Then it depends how you want to give permissions to use the
reserved areas. It's all a reservation logic that you need in order to
use 1G pages with this.

> What I was thinking of was to have a relatively easy to use
> flag that allows an application to use prereserved GB pages
> transparently. e.g. could be done with a special command
> 
> hugepagehint 1GB app
> 
> Yes I realize that this is possible to some extend with libhugetlbfs
> LD_PRELOAD, but integrating it in the kernel is much saner.
> 
> So even if there are some restrictions it would be good to not
> ignore the 1GB pages completely.

I think we should ignore them in the first round of patches, knowing
this model can fit them later if we just add a reservation logic and
all pud_trans_huge. I don't think we need to provide this immediately
as it'd grow the size of the patch, but we can do it soon after. I'm
frightened by growing the patch even more, I'd rather try to get
optimal on 2M pages and only later worry about 1G pages. I think it's
higher priority to remove a couple of split_huge_page than to support
transparent gigapages given they won't be really transparent anyway.

> Agreed, prereservation is still the way to go for 1GB.

To support gigapages, would require to decide a reservation API
now. After that, the kernel will map a 1G page if it is available and
we add pud_trans_huge all over the place. There are more urgent things
like the collapse daemon, removing a couple of split_huge_page, before
I can worry about reservation APIs and to bloat further with
pud_trans_huge all over the place.

> Agreed on not doing it unconditionally, ut the advice could be per
> process or per cgroup.

It gets more and more complicated and this "hint" is all about
reservation, not something we want to deal with with 2M pages.

> Even on 2MB pages this problem exists to some point: if you explicitely
> preallocate 2MB pages to make sure some application can use them
> with hugetlbfs you don't want random applications to still the
> "guaranteed" huge pages.

This is what the sysctl is about. You can turn it off the
transparency, and then the kernel will keep mapping hugepages only
inside madvise(MADV_HUGEPAGE). There is no need of reserving anything
here.

> So some policy here would be likely needed anyways and the same
> could be used for the 1GB pages.

1GB pages can't use the same logic but again I don't think we will be
doing any additional work, if we address 2M pages now transparent, and
we lave the reservation required for 1G pages for later.

What I mean with ignore, is not to add a requirement for merging that
1G pages are also supported or we've to add even more logics that are
absolutely useless for 2M pages.

> I'm still uneasy about this, it's a very clear "glass jaw"
> that might well cause serious problems in practice. Anything that requires
> regular reboots is bad.

Here nothing requires reboot. If you get 2M pages good, otherwise
stick to 4k pages transparently, userland can't know. When some task
quits and 2M page happens we'll just collapse the 4k pages into the
newly generated 2M pages with a background daemon. Over time we can
add more logics to try to minimize fragmentation (obviously slab needs
a front-allocator that tries 2M page allocation first always, there
are many other things we have to do in the defrag front, before we can
worry about the effect of swap that calls split_huge_page). The other
syscalls that calls split_huge_page as said won't fragment anything
physically (with the exception of munmap and madvise_dontneed if used
to truncate an hugepage).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
