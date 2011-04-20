Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B4F0B8D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 06:01:43 -0400 (EDT)
Date: Wed, 20 Apr 2011 11:01:13 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bugme-new] [Bug 33682] New: mprotect got stuck when THP is
 "always" enabled
Message-ID: <20110420100113.GC1306@csn.ul.ie>
References: <bug-33682-10286@https.bugzilla.kernel.org/>
 <20110418230651.54da5b82.akpm@linux-foundation.org>
 <20110419112506.GB5641@random.random>
 <20110419135119.GA5611@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110419135119.GA5611@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, bugs@casparzhang.com, Rik van Riel <riel@redhat.com>

On Tue, Apr 19, 2011 at 03:51:19PM +0200, Andrea Arcangeli wrote:
> Hi,
> 
> this should fix bug
> https://bugzilla.kernel.org/show_bug.cgi?id=33682 .
> 
> ====
> Subject: thp: fix /dev/zero MAP_PRIVATE and vm_flags cleanups
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> The huge_memory.c THP page fault was allowed to run if vm_ops was null (which
> would succeed for /dev/zero MAP_PRIVATE, as the f_op->mmap wouldn't setup a
> special vma->vm_ops and it would fallback to regular anonymous memory) but
> other THP logics weren't fully activated for vmas with vm_file not NULL
> (/dev/zero has a not NULL vma->vm_file).
> 
> So this removes the vm_file checks so that /dev/zero also can safely
> use THP (the other albeit safer approach to fix this bug would have
> been to prevent the THP initial page fault to run if vm_file was set).
> 
> After removing the vm_file checks, this also makes huge_memory.c
> stricter in khugepaged for the DEBUG_VM=y case. It doesn't replace the
> vm_file check with a is_pfn_mapping check (but it keeps checking for
> VM_PFNMAP under VM_BUG_ON) because for a is_cow_mapping() mapping
> VM_PFNMAP should only be allowed to exist before the first page fault,
> and in turn when vma->anon_vma is null (so preventing khugepaged
> registration). So I tend to think the previous comment saying if
> vm_file was set, VM_PFNMAP might have been set and we could still be
> registered in khugepaged (despite anon_vma was not NULL to be
> registered in khugepaged) was too paranoid. The is_linear_pfn_mapping
> check is also I think superfluous (as described by comment) but under
> DEBUG_VM it is safe to stay.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
