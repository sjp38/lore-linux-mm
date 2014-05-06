Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id CD51682963
	for <linux-mm@kvack.org>; Tue,  6 May 2014 10:13:45 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id a108so2778636qge.36
        for <linux-mm@kvack.org>; Tue, 06 May 2014 07:13:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id t1si5158888qap.46.2014.05.06.07.13.44
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 07:13:45 -0700 (PDT)
Date: Tue, 6 May 2014 16:13:06 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm, thp: close race between mremap() and
 split_huge_page()
Message-ID: <20140506141306.GG10342@redhat.com>
References: <1399328011-15317-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1399328011-15317-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Dave Jones <davej@redhat.com>, stable@vger.kernel.org

On Tue, May 06, 2014 at 01:13:31AM +0300, Kirill A. Shutemov wrote:
> It's critical for split_huge_page() (and migration) to catch and freeze
> all PMDs on rmap walk. It gets tricky if there's concurrent fork() or
> mremap() since usually we copy/move page table entries on dup_mm() or
> move_page_tables() without rmap lock taken. To get it work we rely on
> rmap walk order to not miss any entry. We expect to see destination VMA
> after source one to work correctly.
> 
> But after switching rmap implementation to interval tree it's not always
> possible to preserve expected walk order.
> 
> It works fine for dup_mm() since new VMA has the same vma_start_pgoff()
> / vma_last_pgoff() and explicitly insert dst VMA after src one with
> vma_interval_tree_insert_after().
> 
> But on move_vma() destination VMA can be merged into adjacent one and as
> result shifted left in interval tree. Fortunately, we can detect the
> situation and prevent race with rmap walk by moving page table entries
> under rmap lock. See commit 38a76013ad80.
> 
> Problem is that we miss the lock when we move transhuge PMD. Most likely
> this bug caused the crash[1].
> 
> [1] http://thread.gmane.org/gmane.linux.kernel.mm/96473
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Michel Lespinasse <walken@google.com>
> Cc: Dave Jones <davej@redhat.com>
> Cc: <stable@vger.kernel.org>        [3.7+]
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/mremap.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Glad the interval tree has a stable insert when the index is the same
(so fork was safe) and it already contemplated the out of order
problem in the case of mremap when the index changes. The anon_vma
lock is actually heavy and not so nice having to take during pte/pmd
mangling, but we already take it for the pte move and it is only
needed in some case so it should be ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
