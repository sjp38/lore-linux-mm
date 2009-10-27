Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 36E916B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 12:43:15 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0A12482C70A
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 12:49:02 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 7Vvnq11wz1S1 for <linux-mm@kvack.org>;
	Tue, 27 Oct 2009 12:48:57 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 44BF582C63D
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 12:48:57 -0400 (EDT)
Date: Tue, 27 Oct 2009 16:42:39 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: RFC: Transparent Hugepage support
In-Reply-To: <20091026185130.GC4868@random.random>
Message-ID: <alpine.DEB.1.10.0910271630540.20363@V090114053VZO-1>
References: <20091026185130.GC4868@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 26 Oct 2009, Andrea Arcangeli wrote:

> Lately I've been working to make KVM use hugepages transparently
> without the usual restrictions of hugetlbfs. Some of the restrictions
> I'd like to see removed:

Transparent huge page support is something that would be useful in many
areas. The larger memories grow the more pressing the issue will become.

> 1) hugepages have to be swappable or the guest physical memory remains
>    locked in RAM and can't be paged out to swap

Thats not such a big issue IMHO. Paging is not necessary. Swapping is
deadly to many performance based loads. You would abort a job anyways that
it going to swap. On the other hand I wish we would have migration support
(which may be contingent on swap support).

> 2) if a hugepage allocation fails, regular pages should be allocated
>    instead and mixed in the same vma without any failure and without
>    userland noticing

Wont you be running into issues with page dirtying on that level?

> 3) if some task quits and more hugepages become available in the
>    buddy, guest physical memory backed by regular pages should be
>    relocated on hugepages automatically in regions under
>    madvise(MADV_HUGEPAGE) (ideally event driven by waking up the
>    kernel deamon if the order=HPAGE_SHIFT-PAGE_SHIFT list becomes not
>    null)

Oww. This sounds like a heuristic page promotion demotion scheme.
http://www.cs.rice.edu/~jnavarro/superpages/
We have discussed this a couple of times and there was a strong feeling
that the heuristics are bad. But that may no longer be the case since we
already have stuff like KSM in the kernel. Memory management may get very
complex in the future.

> The most important design choice is: always fallback to 4k allocation
> if the hugepage allocation fails! This is the _very_ opposite of some
> large pagecache patches that failed with -EIO back then if a 64k (or
> similar) allocation failed...

Those also had fall back logic to 4k. Does this scheme also allow I/O with
Hugepages through the VFS layer?

> Second important decision (to reduce the impact of the feature on the
> existing pagetable handling code) is that at any time we can split an
> hugepage into 512 regular pages and it has to be done with an
> operation that can't fail. This way the reliability of the swapping
> isn't decreased (no need to allocate memory when we are short on
> memory to swap) and it's trivial to plug a split_huge_page* one-liner
> where needed without polluting the VM. Over time we can teach
> mprotect, mremap and friends to handle pmd_trans_huge natively without
> calling split_huge_page*. The fact it can't fail isn't just for swap:
> if split_huge_page would return -ENOMEM (instead of the current void)
> we'd need to rollback the mprotect from the middle of it (ideally
> including undoing the split_vma) which would be a big change and in
> the very wrong direction (it'd likely be simpler not to call
> split_huge_page at all and to teach mprotect and friends to handle
> hugepages instead of rolling them back from the middle). In short the
> very value of split_huge_page is that it can't fail.

I dont get the point of this. What do you mean by "an operation that
cannot fail"? Atomic section?

> The default I like is that transparent hugepages are used at page
> fault time if they're available in O(1) in the buddy. This can be
> disabled via sysctl/sysfs setting the value to 0, and if it is

The consequence of this could be a vast waste of memory if you f.e. touch
memory only in 1 megabyte increments.

Separate the patch into a patchset for easy review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
