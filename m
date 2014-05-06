Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8EE8B900002
	for <linux-mm@kvack.org>; Tue,  6 May 2014 09:07:03 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id e51so1775685eek.9
        for <linux-mm@kvack.org>; Tue, 06 May 2014 06:07:02 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id v41si13338479eew.314.2014.05.06.06.07.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 06 May 2014 06:07:01 -0700 (PDT)
Date: Tue, 6 May 2014 09:06:55 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm, thp: close race between mremap() and
 split_huge_page()
Message-ID: <20140506130655.GE19914@cmpxchg.org>
References: <1399328011-15317-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1399328011-15317-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Dave Jones <davej@redhat.com>, stable@vger.kernel.org

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

Yeah, I think the actual bug was introduced in preparation of the
interval tree, when the optimization of moving the target anon_vma to
the tail of the chain was replaced by explicit locking again.  That
missed the THP case.

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

Fixes: 108d6642ad81 ("mm anon rmap: remove anon_vma_moveto_tail")

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
