Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 56E246B0038
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 08:11:34 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 189so8046548iow.14
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 05:11:34 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l7sor2941180ioa.325.2017.11.03.05.11.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 Nov 2017 05:11:33 -0700 (PDT)
MIME-Version: 1.0
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 3 Nov 2017 05:11:12 -0700
Message-ID: <CALCETrW73eB7GFkO6BEkF25wJODr2KCCv0baUykzfBZnWwOrVQ@mail.gmail.com>
Subject: Can someone explain what free_pgd_range(), etc actually do?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: X86 ML <x86@kernel.org>

I want to reserve a tiny bit of the address space just below 1<<47 on
x86_64 for kernel purposes but without stealing away management of the
page tables.  It seems like the way to do that is to set
USER_PGTABLES_CEILING to 0 and then make some adjustment to
exit_mmap() to free the tables on exit.

The problem is that free_pgd_range(), free_pgtables, etc are quite
opaque to me, and I'm having a hard time understanding the pagetable
freeing code.  Some questions I haven't figured out:

 - What is the intended purpose of addr, end, floor, and ceiling?
What are the pagetable freeing functions actually *supposed* to do?

 - Are there any invariants that, for example, there is never a
pagetable that doesn't have any vmas at all under it?  I can
understand how all the code would be correct if this invariant were to
exist, but I don't see what would preserve it.  But maybe
free_pgd_range(), etc really do preserve it.

 - What keeps mm->mmap pointing to the lowest-addressed vma?  I see
lots of code that seems to assume that you can start at mm->mmap,
follow the vm_next links, and find all vmas, but I can't figure out
why this would work.

 - What happens if a process exits while mm->mmap is NULL?

 - Is there any piece of code that makes it obvious that all the
pagetables are gone by the time the exit_mmap() finishes?

Because I'm staring to wonder whether some weird combination of maps
and unmaps will just leak pagetables, and the code is rather
complicated, subtle, and completely lacking in documentation, and I've
learned to be quite suspicious of such things.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
