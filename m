Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id A3B9F6B0008
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 02:04:16 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id z26-v6so35718980qtz.4
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 23:04:16 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k34-v6sor25778729qvf.68.2018.10.18.23.04.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Oct 2018 23:04:15 -0700 (PDT)
MIME-Version: 1.0
From: Joel Fernandes <joelaf@google.com>
Date: Thu, 18 Oct 2018 23:04:02 -0700
Message-ID: <CAJWu+oqnGC6FFZP5Trxh=WKHwAM3LM1c1mbhtJsh1yoh=ABi0g@mail.gmail.com>
Subject: Question about ptep_get_and_clear and TLB flush
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Jann Horn <jannh@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, kirill.shutemov@linux.intel.com, Minchan Kim <minchan@kernel.org>, Ramon Pantin <pantin@google.com>

Hello friends,
I was trying to understand the safety of this piece of code in
move_ptes in mremap.c
Here we have some code that does this in a loop:

for (; old_addr < old_end; old_pte++, old_addr += PAGE_SIZE,
 new_pte++, new_addr += PAGE_SIZE) {
  if (pte_none(*old_pte))
       continue;
    pte = ptep_get_and_clear(mm, old_addr, old_pte);
    if (pte_present(pte) && pte_dirty(pte))
         force_flush = true;
    pte = move_pte(pte, new_vma->vm_page_prot, old_addr, new_addr);
    pte = move_soft_dirty_pte(pte);
    set_pte_at(mm, new_addr, new_pte, pte);
}

If I understand correctly, the ptep_get_and_clear is needed to
atomically get and clear the page table entry so that we do not miss
any other bits in PTE that may get set but have not been read, before
we clear it. Such as the dirty bit.

My question is, After the ptep_get_and_clear runs, what happens if
another CPU has a valid TLB entry for this old_addr and does a
memory-write *before* the TLBs are flushed. Would that not cause us to
lose the dirty bit? Once set_pte_at runs, it would be using the PTE
fetched earlier which did not have the dirty bit set. This seems wrong
to me. What do you think?

Thanks,
Joel
