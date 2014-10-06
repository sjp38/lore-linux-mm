Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 71D9C6B0069
	for <linux-mm@kvack.org>; Mon,  6 Oct 2014 05:42:23 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id uq10so4765418igb.2
        for <linux-mm@kvack.org>; Mon, 06 Oct 2014 02:42:23 -0700 (PDT)
Received: from mail-ie0-x230.google.com (mail-ie0-x230.google.com [2607:f8b0:4001:c03::230])
        by mx.google.com with ESMTPS id s1si30783580icj.2.2014.10.06.02.42.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 06 Oct 2014 02:42:22 -0700 (PDT)
Received: by mail-ie0-f176.google.com with SMTP id rp18so2859895iec.7
        for <linux-mm@kvack.org>; Mon, 06 Oct 2014 02:42:21 -0700 (PDT)
Date: Mon, 6 Oct 2014 02:42:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch for-3.17] mm, thp: fix collapsing of hugepages on
 madvise
In-Reply-To: <20141005184115.GA21713@node.dhcp.inet.fi>
Message-ID: <alpine.DEB.2.02.1410060237580.12568@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1410041947080.7055@chino.kir.corp.google.com> <20141005184115.GA21713@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Suleiman Souhlal <suleiman@google.com>, stable@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, 5 Oct 2014, Kirill A. Shutemov wrote:

> On Sat, Oct 04, 2014 at 07:48:04PM -0700, David Rientjes wrote:
> > If an anonymous mapping is not allowed to fault thp memory and then
> > madvise(MADV_HUGEPAGE) is used after fault, khugepaged will never
> > collapse this memory into thp memory.
> > 
> > This occurs because the madvise(2) handler for thp, hugepage_advise(),
> > clears VM_NOHUGEPAGE on the stack and it isn't stored in vma->vm_flags
> > until the final action of madvise_behavior().  This causes the
> > khugepaged_enter_vma_merge() to be a no-op in hugepage_advise() when the

This should be hugepage_madvise().

> > vma had previously had VM_NOHUGEPAGE set.
> > 
> > Fix this by passing the correct vma flags to the khugepaged mm slot
> > handler.  There's no chance khugepaged can run on this vma until after
> > madvise_behavior() returns since we hold mm->mmap_sem.
> > 
> > It would be possible to clear VM_NOHUGEPAGE directly from vma->vm_flags
> > in hugepage_advise(), but I didn't want to introduce special case
> > behavior into madvise_behavior().  I think it's best to just let it
> > always set vma->vm_flags itself.
> > 
> > Cc: <stable@vger.kernel.org>
> > Reported-by: Suleiman Souhlal <suleiman@google.com>
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> Look like rather complex fix for a not that complex bug.
> What about untested patch below?
> 
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Sun, 5 Oct 2014 21:22:43 +0300
> Subject: [PATCH] thp: fix registering VMA into khugepaged on
>  madvise(MADV_HUGEPAGE)
> 
> hugepage_madvise() tries to register VMA into khugepaged with
> khugepaged_enter_vma_merge() on madvise(MADV_HUGEPAGE). Unfortunately
> it's effectevely nop, since khugepaged_enter_vma_merge() rely on
> vma->vm_flags which has not yet updated by the time of
> hugepage_madvise().
> 
> Let's move khugepaged_enter_vma_merge() to the end of madvise_behavior().
> Now we also have chance to catch VMAs which become good for THP after
> vma_merge().
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/huge_memory.c | 8 +++-----
>  mm/madvise.c     | 6 ++++++
>  2 files changed, 9 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index f8ffd9412ec5..f84d52158a66 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1966,12 +1966,10 @@ int hugepage_madvise(struct vm_area_struct *vma,
>  		*vm_flags &= ~VM_NOHUGEPAGE;
>  		*vm_flags |= VM_HUGEPAGE;
>  		/*
> -		 * If the vma become good for khugepaged to scan,
> -		 * register it here without waiting a page fault that
> -		 * may not happen any time soon.
> +		 * vma->vm_flags is not yet updated here. madvise_behavior()
> +		 * will take care to register it in khugepaged once flags
> +		 * updated.
>  		 */
> -		if (unlikely(khugepaged_enter_vma_merge(vma)))
> -			return -ENOMEM;
>  		break;
>  	case MADV_NOHUGEPAGE:
>  		/*
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 0938b30da4ab..60effd2c5e9c 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -128,6 +128,12 @@ success:
>  	 */
>  	vma->vm_flags = new_flags;
>  
> +	/*
> +	 * If the vma become good for khugepaged to scan, register it here
> +	 * without waiting a page fault that may not happen any time soon.
> +	 */
> +	if (unlikely(khugepaged_enter_vma_merge(vma)))
> +		error = -ENOMEM;
>  out:
>  	if (error == -ENOMEM)
>  		error = -EAGAIN;

I'm pretty sure this won't compile, but I'm also pretty sure it's easy to 
come up with an madvise() bit for anon vmas that would cause the BUG_ON() 
to trigger for CONFIG_DEBUG_VM and unnecessarily do alloc_mm_slot() for 
madvise() calls that aren't MADV_HUGEPAGE with this that go through the 
madvise_behavior() path, and for that reason it's probably not as 
extendable as we'd like.  I can verify this tomorrow if you'd like.  This 
is the point of the last paragraph of my changelog to isolate all thp 
behavior changes to MADV_HUGEPAGE and MADV_NOHUGEPAGE in one place as it's 
currently done and not add any special handling in madvise_behavior().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
