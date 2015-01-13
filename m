Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f174.google.com (mail-vc0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 10A9C6B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 15:36:33 -0500 (EST)
Received: by mail-vc0-f174.google.com with SMTP id id10so1640813vcb.5
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 12:36:32 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id p3si1519209vdx.87.2015.01.13.12.36.31
        for <linux-mm@kvack.org>;
        Tue, 13 Jan 2015 12:36:31 -0800 (PST)
Message-ID: <54B581C7.50206@linux.intel.com>
Date: Tue, 13 Jan 2015 12:36:23 -0800
From: Dave Hansen <dave.hansen@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: rename mm->nr_ptes to mm->nr_pgtables
References: <1421176456-21796-1-git-send-email-kirill.shutemov@linux.intel.com> <1421176456-21796-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1421176456-21796-2-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@openvz.org>, linux-kernel@vger.kernel.org

On 01/13/2015 11:14 AM, Kirill A. Shutemov wrote:
>  	pgd_t * pgd;
>  	atomic_t mm_users;			/* How many users with user space? */
>  	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
> -	atomic_long_t nr_ptes;			/* Page table pages */
> +	atomic_long_t nr_pgtables;		/* Page table pages */
>  	int map_count;				/* number of VMAs */

One more crazy idea...

There are 2^9 possible pud pages, 2^18 pmd pages and 2^27 pte pages.
That's only 54 bits (technically minus one bit each because the upper
half of the address space is for the kernel).

That's enough to actually account for pte, pmd and pud pages separately
without increasing the size of the storage we need.  You could even
enforce that warning you were talking about at exit time for pte pages,
but just ignore pmd mismatches so you don't have false warnings on
hugetlbfs shared pmd pages.  Or, even better, strictly track pmd page
usage _unless_ hugetlbfs shared pmds are in play and track _that_ in
another bit.

On 32-bit PAE, that's 2 bits for PMD pages, and 11 for PTE pages, so it
should fit in an atomic_long_t there too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
