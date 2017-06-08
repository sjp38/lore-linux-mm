Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6B6B66B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 06:27:07 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id k71so14145894pgd.6
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 03:27:07 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 195si3986447pfb.354.2017.06.08.03.27.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jun 2017 03:27:06 -0700 (PDT)
Date: Thu, 8 Jun 2017 13:27:02 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 1/3] mm: numa: avoid waiting on freed migrated pages
Message-ID: <20170608102702.lqo42is4xrz3edmi@black.fi.intel.com>
References: <1496771916-28203-1-git-send-email-will.deacon@arm.com>
 <1496771916-28203-2-git-send-email-will.deacon@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1496771916-28203-2-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mark.rutland@arm.com, akpm@linux-foundation.org, Punit.Agrawal@arm.com, mgorman@suse.de, steve.capper@arm.com

On Tue, Jun 06, 2017 at 06:58:34PM +0100, Will Deacon wrote:
> From: Mark Rutland <mark.rutland@arm.com>
> 
> In do_huge_pmd_numa_page(), we attempt to handle a migrating thp pmd by
> waiting until the pmd is unlocked before we return and retry. However,
> we can race with migrate_misplaced_transhuge_page():
> 
> // do_huge_pmd_numa_page                // migrate_misplaced_transhuge_page()
> // Holds 0 refs on page                 // Holds 2 refs on page
> 
> vmf->ptl = pmd_lock(vma->vm_mm, vmf->pmd);
> /* ... */
> if (pmd_trans_migrating(*vmf->pmd)) {
>         page = pmd_page(*vmf->pmd);
>         spin_unlock(vmf->ptl);
>                                         ptl = pmd_lock(mm, pmd);
>                                         if (page_count(page) != 2)) {
>                                                 /* roll back */
>                                         }
>                                         /* ... */
>                                         mlock_migrate_page(new_page, page);
>                                         /* ... */
>                                         spin_unlock(ptl);
>                                         put_page(page);
>                                         put_page(page); // page freed here
>         wait_on_page_locked(page);
>         goto out;
> }
> 
> This can result in the freed page having its waiters flag set
> unexpectedly, which trips the PAGE_FLAGS_CHECK_AT_PREP checks in the
> page alloc/free functions. This has been observed on arm64 KVM guests.
> 
> We can avoid this by having do_huge_pmd_numa_page() take a reference on
> the page before dropping the pmd lock, mirroring what we do in
> __migration_entry_wait().
> 
> When we hit the race, migrate_misplaced_transhuge_page() will see the
> reference and abort the migration, as it may do today in other cases.
> 
> Acked-by: Steve Capper <steve.capper@arm.com>
> Signed-off-by: Mark Rutland <mark.rutland@arm.com>
> Signed-off-by: Will Deacon <will.deacon@arm.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
