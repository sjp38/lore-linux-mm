Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1BCFF6B0069
	for <linux-mm@kvack.org>; Sat, 17 Sep 2016 20:36:59 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id p53so250116973qtp.0
        for <linux-mm@kvack.org>; Sat, 17 Sep 2016 17:36:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d140si609159ybh.230.2016.09.17.17.36.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Sep 2016 17:36:58 -0700 (PDT)
Date: Sun, 18 Sep 2016 02:36:54 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/1] mm: vma_merge: fix vm_page_prot SMP race condition
 against rmap_walk
Message-ID: <20160918003654.GA25048@redhat.com>
References: <20160916205441.GB4743@redhat.com>
 <1474128315-22726-1-git-send-email-aarcange@redhat.com>
 <1474128315-22726-2-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1474128315-22726-2-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Jan Vorlicek <janvorli@microsoft.com>, Aditya Mandaleeka <adityam@microsoft.com>

On Sat, Sep 17, 2016 at 06:05:15PM +0200, Andrea Arcangeli wrote:
> +	if (remove_next == 1) {
> +		/*
> +		 * vm_page_prot and vm_flags can be read by the
> +		 * rmap_walk, for example in remove_migration_ptes(),
> +		 * so before releasing the rmap locks the permissions
> +		 * of the expanded vmas must be already the correct
> +		 * one for the whole merged range.
> +		 *
> +		 * mprotect case 8 (which sets remove_next == 1) needs
> +		 * special handling to provide the above guarantee, as
> +		 * it is the only case where the "vma" that is being
> +		 * expanded is the one with the wrong permissions for
> +		 * the whole merged region. So copy the right
> +		 * permissions from the next one that is getting
> +		 * removed before releasing the rmap locks.
> +		 */
> +		vma->vm_page_prot = next->vm_page_prot;
> +		vma->vm_flags = next->vm_flags;
> +	}
>  	if (start != vma->vm_start) {

One more thought, doesn't remove_next get set to 1 also in case 7?

I assumed this could be fixed within vma_adjust but case 7 is
indistinguishable from case 8 from within vma_adjust. So the fix has
to move up one level in vma_merge where it's possible to differentiate
case 7 and case 8.

The fact no available testcase is exercising the race with any other
cases of vma_merge except case 8, makes the testing prone for false
negatives (accidentally upstream also initially passed as a false
negative thanks to the pmd_modify in do_numa_page that hidden the most
visible side effect of the bug even in case 8). All I can easily
verify with the testcase is that case 8 is fixed by monitoring any
erroneous do_numa_page execution on non-NUMA guests, and sure thing
case 8 was fixed.

I'll also reconsider how much more complex it is to remove the "area"
vma in case 8, instead of the "next", so that case 8 changes from
PPPPNNNNXXXX->PPPPNNNNNNNN to PPPPNNNNXXXX->PPPPXXXXXXXX, in turn
removing the oddness factor from case 8.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
