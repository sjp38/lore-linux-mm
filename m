Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 964E36B4672
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 02:26:54 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id t2so13430348pfj.15
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 23:26:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c10sor3711309pgq.28.2018.11.26.23.26.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 23:26:53 -0800 (PST)
Date: Tue, 27 Nov 2018 10:26:48 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 02/10] mm/huge_memory: splitting set mapping+index before
 unfreeze
Message-ID: <20181127072648.nh4jqlip3too22fl@kshutemo-mobl1>
References: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
 <alpine.LSU.2.11.1811261516380.2275@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1811261516380.2275@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-mm@kvack.org

On Mon, Nov 26, 2018 at 03:19:57PM -0800, Hugh Dickins wrote:
> Huge tmpfs stress testing has occasionally hit shmem_undo_range()'s
> VM_BUG_ON_PAGE(page_to_pgoff(page) != index, page).
> 
> Move the setting of mapping and index up before the page_ref_unfreeze()
> in __split_huge_page_tail() to fix this: so that a page cache lookup
> cannot get a reference while the tail's mapping and index are unstable.
> 
> In fact, might as well move them up before the smp_wmb(): I don't see
> an actual need for that, but if I'm missing something, this way round
> is safer than the other, and no less efficient.
> 
> You might argue that VM_BUG_ON_PAGE(page_to_pgoff(page) != index, page)
> is misplaced, and should be left until after the trylock_page(); but
> left as is has not crashed since, and gives more stringent assurance.
> 
> Fixes: e9b61f19858a5 ("thp: reintroduce split_huge_page()")
> Requires: 605ca5ede764 ("mm/huge_memory.c: reorder operations in __split_huge_page_tail()")
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Cc: stable@vger.kernel.org # 4.8+

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov
