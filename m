Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id ECE566B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 07:44:35 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id p10so6730348pdj.12
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 04:44:35 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 8si11705146pbe.10.2013.12.17.04.44.32
        for <linux-mm@kvack.org>;
        Tue, 17 Dec 2013 04:44:33 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <52AF9860.9000303@oracle.com>
References: <20130223003232.4CDDB5A41B6@corp2gmr1-2.hot.corp.google.com>
 <52AA0613.2000908@oracle.com>
 <CA+55aFw3_0_Et9bbfWgGLXEUaGQW1HE8j=oGBqFG_8j+h6jmvQ@mail.gmail.com>
 <CA+55aFyRZW=Uy9w+bZR0vMOFNPqV-yW2Xs9N42qEwTQ3AY0fDw@mail.gmail.com>
 <52AE271C.4040805@oracle.com>
 <CA+55aFw+-EB0J5v-1LMg1aiDZQJ-Mm0fzdbN312_nyBCVs+Fvw@mail.gmail.com>
 <20131216124754.29063E0090@blue.fi.intel.com>
 <52AF19CF.2060102@oracle.com>
 <20131216205244.GG21218@redhat.com>
 <52AF9860.9000303@oracle.com>
Subject: Re: [patch 019/154] mm: make madvise(MADV_WILLNEED) support swap file
 prefetch
Content-Transfer-Encoding: 7bit
Message-Id: <20131217124426.B06F5E0090@blue.fi.intel.com>
Date: Tue, 17 Dec 2013 14:44:26 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, shli@kernel.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@fusionio.com>, linux-mm <linux-mm@kvack.org>

Sasha Levin wrote:
> Hi Andrea,
> 
> On 12/16/2013 03:52 PM, Andrea Arcangeli wrote:
> > Is the bug reproducible? If yes the simplest is probably to add some
> > allocation tracking to the page, so if page->ptl is null we can simply
> > print a stack trace of who allocated the page (and later forgot to
> > initialize the ptl).
> 
> Yes, it's easy to reproduce.

I'm trying to reproduce it with trinity. No luck so far. Any suggestions?
Kernel config? VM setup? Do you have swap enabled? How do you run trinity?

> I've done as suggested and here's the trace from
> the allocation:
> 
> [  184.139519]  [<ffffffff8107de0f>] save_stack_trace+0x2f/0x50
> [  184.140706]  [<ffffffff81257769>] get_page_from_freelist+0x759/0x7a0
> [  184.141605]  [<ffffffff81258438>] __alloc_pages_nodemask+0x3b8/0x520
> [  184.142810]  [<ffffffff812a4baf>] alloc_pages_vma+0x1df/0x220
> [  184.143631]  [<ffffffff812bcd58>] do_huge_pmd_wp_page+0x2d8/0x730
> [  184.144526]  [<ffffffff81280e01>] __handle_mm_fault+0x2b1/0x3d0
> [  184.145361]  [<ffffffff81281053>] handle_mm_fault+0x133/0x1c0
> [  184.146129]  [<ffffffff812815f8>] __get_user_pages+0x448/0x640
> [  184.147055]  [<ffffffff812827a4>] __mlock_vma_pages_range+0xd4/0xe0
> [  184.147980]  [<ffffffff812828c0>] __mm_populate+0x110/0x190
> [  184.148933]  [<ffffffff812839b2>] SyS_mlock+0xf2/0x130
> [  184.149689]  [<ffffffff843c5e50>] tracesys+0xdd/0xe2

It's trace from huge page allocation, not from page table allocation we
are interested in.

In our case we need to know who allocated pmd_page(*pmd) when 

orig_pte = pte_offset_map_lock(vma->vm_mm, pmd, start, &ptl);

crashes. Note: we usually allocate page tables with __GFP_NOTRACK. It
probably need to be changed for this experiment.

> > Agree with Kirill that it would help to verify the bug goes away by
> > disabling USE_SPLIT_PTE_PTLOCKS.
> 
> It seems that the bug is gone without USE_SPLIT_PTE_PTLOCKS.

What about PMD sibling: USE_SPLIT_PMD_PTLOCKS?
I mean USE_SPLIT_PTE_PTLOCKS == 1, USE_SPLIT_PMD_PTLOCKS == 0.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
