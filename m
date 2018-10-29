Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1AEC56B0386
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 12:10:39 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id d12-v6so10489112qtj.2
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 09:10:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m67-v6si200426qte.64.2018.10.29.09.10.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Oct 2018 09:10:38 -0700 (PDT)
Date: Mon, 29 Oct 2018 12:10:34 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: Question about ptep_get_and_clear and TLB flush
Message-ID: <20181029161033.GA30742@redhat.com>
References: <CAJWu+oqnGC6FFZP5Trxh=WKHwAM3LM1c1mbhtJsh1yoh=ABi0g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJWu+oqnGC6FFZP5Trxh=WKHwAM3LM1c1mbhtJsh1yoh=ABi0g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joelaf@google.com>
Cc: "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Jann Horn <jannh@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, kirill.shutemov@linux.intel.com, Minchan Kim <minchan@kernel.org>, Ramon Pantin <pantin@google.com>

On Thu, Oct 18, 2018 at 11:04:02PM -0700, Joel Fernandes wrote:
> Hello friends,
> I was trying to understand the safety of this piece of code in
> move_ptes in mremap.c
> Here we have some code that does this in a loop:
> 
> for (; old_addr < old_end; old_pte++, old_addr += PAGE_SIZE,
>  new_pte++, new_addr += PAGE_SIZE) {
>   if (pte_none(*old_pte))
>        continue;
>     pte = ptep_get_and_clear(mm, old_addr, old_pte);
>     if (pte_present(pte) && pte_dirty(pte))
>          force_flush = true;
>     pte = move_pte(pte, new_vma->vm_page_prot, old_addr, new_addr);
>     pte = move_soft_dirty_pte(pte);
>     set_pte_at(mm, new_addr, new_pte, pte);
> }
> 
> If I understand correctly, the ptep_get_and_clear is needed to
> atomically get and clear the page table entry so that we do not miss
> any other bits in PTE that may get set but have not been read, before
> we clear it. Such as the dirty bit.
> 
> My question is, After the ptep_get_and_clear runs, what happens if
> another CPU has a valid TLB entry for this old_addr and does a
> memory-write *before* the TLBs are flushed. Would that not cause us to
> lose the dirty bit? Once set_pte_at runs, it would be using the PTE
> fetched earlier which did not have the dirty bit set. This seems wrong
> to me. What do you think?
> 

https://yarchive.net/comp/linux/x86_tlb.html
