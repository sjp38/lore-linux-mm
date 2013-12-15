Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f46.google.com (mail-qe0-f46.google.com [209.85.128.46])
	by kanga.kvack.org (Postfix) with ESMTP id EAC4F6B0039
	for <linux-mm@kvack.org>; Sun, 15 Dec 2013 17:58:33 -0500 (EST)
Received: by mail-qe0-f46.google.com with SMTP id a11so3281710qen.19
        for <linux-mm@kvack.org>; Sun, 15 Dec 2013 14:58:33 -0800 (PST)
Received: from mail-ve0-x22a.google.com (mail-ve0-x22a.google.com [2607:f8b0:400c:c01::22a])
        by mx.google.com with ESMTPS id gu7si6521378qab.153.2013.12.15.14.58.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 15 Dec 2013 14:58:33 -0800 (PST)
Received: by mail-ve0-f170.google.com with SMTP id oy12so2864347veb.1
        for <linux-mm@kvack.org>; Sun, 15 Dec 2013 14:58:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52AE271C.4040805@oracle.com>
References: <20130223003232.4CDDB5A41B6@corp2gmr1-2.hot.corp.google.com>
	<52AA0613.2000908@oracle.com>
	<CA+55aFw3_0_Et9bbfWgGLXEUaGQW1HE8j=oGBqFG_8j+h6jmvQ@mail.gmail.com>
	<CA+55aFyRZW=Uy9w+bZR0vMOFNPqV-yW2Xs9N42qEwTQ3AY0fDw@mail.gmail.com>
	<52AE271C.4040805@oracle.com>
Date: Sun, 15 Dec 2013 14:58:32 -0800
Message-ID: <CA+55aFw+-EB0J5v-1LMg1aiDZQJ-Mm0fzdbN312_nyBCVs+Fvw@mail.gmail.com>
Subject: Re: [patch 019/154] mm: make madvise(MADV_WILLNEED) support swap file prefetch
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, shli@kernel.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@fusionio.com>, linux-mm <linux-mm@kvack.org>

On Sun, Dec 15, 2013 at 2:03 PM, Sasha Levin <sasha.levin@oracle.com> wrote:
> On 12/15/2013 02:16 PM, Linus Torvalds wrote:
>>
>> Can anybody see what's wrong with that code? It all seems to happen
>> with mmap_sem held for reading, so there is no mmap activity going on,
>> but what about concurrent pmd splitting due to page faults etc?
>
> There's one thing that seems odd to me: the only place that allocated
> the ptl is in pgtable_page_ctor() called from pte_alloc_one().
>
> However, I don't see how ptl is allocated through all the
> mk_pmd()/mk_huge_pmd()
> calls in mm/huge_memory.c .
>
> I've added some debug output, and it seems that indeed the results of
> mk_pmd() are
> with ptl == NULL and one of them ends up getting to swapin_walk_pmd_entry
> where it NULL
> ptr derefs.

Hmm. I don't see that in my tree either, so that doesn't seem to be a
linux-next issue.

How are we not hitting this left and right? Sure, you need spinlock
debugging or something like that to trigger the BLOATED_SPINLOCKS
case, and you'd need the USE_SPLIT_PTE_PTLOCKS case to have this at
all, but that shouldn't be *that* unusual. And afaik, we should hit
this on just about any page table traversal.

So I *think* the rule is that largepages don't have ptl entries (since
they don't have page tables associated with them), and they need to be
handled specially.

But it's also possibly just that maybe nothing really uses
large-pages. And afaik, we used to disable USE_SPLIT_PTE_PTLOCKS
entirely with big spinlocks until Kirill added that indirection
pointer, so that would explain why we just never noticed this issue
before (although I'd have expected that the spinlock still needs to be
initialized, even if it doesn't need allocating - otherwise we'd
possibly just hang on a "spin_lock()" that never succeeds).

Adding Kirill to the participants, since he did the
pgtable_pmd_page_ctor/dtor stuff and enabled split PTE locks even with
BLOATED_SPINLOCKS. And Andrea, since largepages are involved. And
linux-mm just to have *some* list cc'd.

Kirill? Sasha seems to trigger this problem with
madvise(MADV_WILLNEED), possibly on a hugepage mapping (but see
below..) The

        orig_pte = pte_offset_map_lock(vma->vm_mm, pmd, start, &ptl);

in swapin_walk_pmd_entry() ends up taking a NULL ptr fault because the
pmd doesn't have a ptl pointer..

But why would we trigger this bug then, since we have:

        if (pmd_none_or_trans_huge_or_clear_bad(pmd))
                return 0;

in swapin_walk_pmd_entry(). Possibly racing with a page-in? Should we
check the "vma->vm_flags" for VM_HUGETLB?

Let's hope the new people have more answers than questions ;)

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
