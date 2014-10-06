Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4172F6B006E
	for <linux-mm@kvack.org>; Mon,  6 Oct 2014 11:03:57 -0400 (EDT)
Received: by mail-lb0-f181.google.com with SMTP id l4so4331783lbv.40
        for <linux-mm@kvack.org>; Mon, 06 Oct 2014 08:03:56 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.226])
        by mx.google.com with ESMTP id qh2si24431558lbb.34.2014.10.06.08.03.55
        for <linux-mm@kvack.org>;
        Mon, 06 Oct 2014 08:03:55 -0700 (PDT)
Date: Mon, 6 Oct 2014 18:03:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [patch for-3.17] mm, thp: fix collapsing of hugepages on madvise
Message-ID: <20141006150351.GA23754@node.dhcp.inet.fi>
References: <alpine.DEB.2.02.1410041947080.7055@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1410041947080.7055@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Suleiman Souhlal <suleiman@google.com>, stable@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Oct 04, 2014 at 07:48:04PM -0700, David Rientjes wrote:
> If an anonymous mapping is not allowed to fault thp memory and then
> madvise(MADV_HUGEPAGE) is used after fault, khugepaged will never
> collapse this memory into thp memory.
> 
> This occurs because the madvise(2) handler for thp, hugepage_advise(),
> clears VM_NOHUGEPAGE on the stack and it isn't stored in vma->vm_flags
> until the final action of madvise_behavior().  This causes the
> khugepaged_enter_vma_merge() to be a no-op in hugepage_advise() when the
> vma had previously had VM_NOHUGEPAGE set.
> 
> Fix this by passing the correct vma flags to the khugepaged mm slot
> handler.  There's no chance khugepaged can run on this vma until after
> madvise_behavior() returns since we hold mm->mmap_sem.
> 
> It would be possible to clear VM_NOHUGEPAGE directly from vma->vm_flags
> in hugepage_advise(), but I didn't want to introduce special case
> behavior into madvise_behavior().  I think it's best to just let it
> always set vma->vm_flags itself.
> 
> Cc: <stable@vger.kernel.org>
> Reported-by: Suleiman Souhlal <suleiman@google.com>
> Signed-off-by: David Rientjes <rientjes@google.com>

Okay, I've looked once again and it seems your approach is better.
Although, I don't like that we need to pass down vma->vm_flags to every
khugepaged_enter() and khugepaged_enter_vma_merge().

My proposal is below. Build-tested only.

And I don't think this is subject for stable@: no crash or serious
misbehaviour. Registering to khugepaged is postponed until first page
fault. Not a big deal.
