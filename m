Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 1B0D36B0032
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 16:39:03 -0500 (EST)
Received: by mail-qa0-f42.google.com with SMTP id dc16so28628136qab.1
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 13:39:02 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z39si19825034qgz.37.2015.02.10.13.39.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Feb 2015 13:39:02 -0800 (PST)
Date: Tue, 10 Feb 2015 22:06:57 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: incorporate zero pages into transparent huge pages
Message-ID: <20150210210657.GI11755@redhat.com>
References: <1423522057-5757-1-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1423522057-5757-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, riel@redhat.com

On Tue, Feb 10, 2015 at 12:47:37AM +0200, Ebru Akagunduz wrote:
> This patch improves THP collapse rates, by allowing zero pages.
> 
> Currently THP can collapse 4kB pages into a THP when there
> are up to khugepaged_max_ptes_none pte_none ptes in a 2MB
> range.  This patch counts pte none and mapped zero pages
> with the same variable.
> 
> The patch was tested with a program that allocates 800MB of
> memory, and performs interleaved reads and writes, in a pattern
> that causes some 2MB areas to first see read accesses, resulting
> in the zero pfn being mapped there.
> 
> To simulate memory fragmentation at allocation time, I modified
> do_huge_pmd_anonymous_page to return VM_FAULT_FALLBACK for read
> faults.
> 
> Without the patch, only %50 of the program was collapsed into
> THP and the percentage did not increase over time.
> 
> With this patch after 10 minutes of waiting khugepaged had
> collapsed %89 of the program's memory.

This is very good idea, associating it with the sysctl is sensible
here as collapsing zeropages would affect the memory footprint in the
same way as none ptes.

__collapse_huge_page_copy however is likely screwing with the
refcounts of the zero page. Did you have DEBUG_VM=y enabled? If yes
you should get one warning that the zeropage refcount underflowed that
could confirm my concern:

static inline int put_page_testzero(struct page *page)
{
	VM_BUG_ON_PAGE(atomic_read(&page->_count) == 0, page);

Zeropages are normally implemented as pte_special if the arch supports
pte_special and have no refcounting. vm_normal_pages returns NULL and
that let it skip the refcounting. But __collapse_huge_page_copy would
call both release_pte_page and free_page_and_swap_cache after a
src_page = pte_page(pteval); and not a src_page =
vm_normal_page(pteval).

So in short I think __collapse_huge_page_copy and release_pte_pages
needs an additional case that complements the already existing special
pte_none case, to account for those zeropages. The special zeropage
case can also use clear_user_highpage(page, address) instead of
copy_user_highpage (clearing uses half the CPU cache of copying so
it's more efficient to use that like for the pte_none case).

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
