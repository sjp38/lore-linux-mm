Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 94BF86B0272
	for <linux-mm@kvack.org>; Fri,  6 May 2016 18:01:19 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b203so253815756pfb.1
        for <linux-mm@kvack.org>; Fri, 06 May 2016 15:01:19 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s1si20611633paw.158.2016.05.06.15.01.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 May 2016 15:01:13 -0700 (PDT)
Date: Fri, 6 May 2016 15:01:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 117731] New: Doing mprotect for PROT_NONE and then for
 PROT_READ|PROT_WRITE reduces CPU write B/W on buffer
Message-Id: <20160506150112.9b27324b4b2b141146b0ff25@linux-foundation.org>
In-Reply-To: <bug-117731-27@https.bugzilla.kernel.org/>
References: <bug-117731-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ashish0srivastava0@gmail.com
Cc: bugzilla-daemon@bugzilla.kernel.org, Peter Feiner <pfeiner@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

Great bug report, thanks.

I assume the breakage was caused by

commit 64e455079e1bd7787cc47be30b7f601ce682a5f6
Author:     Peter Feiner <pfeiner@google.com>
AuthorDate: Mon Oct 13 15:55:46 2014 -0700
Commit:     Linus Torvalds <torvalds@linux-foundation.org>
CommitDate: Tue Oct 14 02:18:28 2014 +0200

    mm: softdirty: enable write notifications on VMAs after VM_SOFTDIRTY cleared
    

Could someone (Peter, Kirill?) please take a look?

On Fri, 06 May 2016 13:15:19 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=117731
> 
>             Bug ID: 117731
>            Summary: Doing mprotect for PROT_NONE and then for
>                     PROT_READ|PROT_WRITE reduces CPU write B/W on buffer
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 3.18 and beyond
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>           Assignee: akpm@linux-foundation.org
>           Reporter: ashish0srivastava0@gmail.com
>         Regression: No
> 
> Created attachment 215401
>   --> https://bugzilla.kernel.org/attachment.cgi?id=215401&action=edit
> Repro code
> 
> This is a regression that is present in kernel 3.18 and beyond and not in
> previous ones.
> Attached is a simple repro case. It measures the time taken to write and then
> read all pages in a buffer, then it does mprotect for PROT_NONE and then
> mprotect for PROT_READ|PROT_WRITE, then it again measures time taken to write
> and then read all pages in a buffer. The 2nd time taken is much larger (20 to
> 30 times) than the first one.
> 
> I have looked at the code in the kernel tree that is causing this and it is
> because writes are causing faults, as pte_mkwrite is not being done during
> mprotect_fixup for PROT_READ|PROT_WRITE.
> 
> This is the code inside mprotect_fixup in a tree v3.16.35 or older:
>     /*
>      * vm_flags and vm_page_prot are protected by the mmap_sem
>      * held in write mode.
>      */
>     vma->vm_flags = newflags;
>     vma->vm_page_prot = pgprot_modify(vma->vm_page_prot,
>                       vm_get_page_prot(newflags));
> 
>     if (vma_wants_writenotify(vma)) {
>         vma->vm_page_prot = vm_get_page_prot(newflags & ~VM_SHARED);
>         dirty_accountable = 1;
>     }
> This is the code in the same region inside mprotect_fixup in a recent tree:
>     /*
>      * vm_flags and vm_page_prot are protected by the mmap_sem
>      * held in write mode.
>      */
>     vma->vm_flags = newflags;
>     dirty_accountable = vma_wants_writenotify(vma);
>     vma_set_page_prot(vma);
> 
> The difference is the setting of dirty_accountable. result of
> vma_wants_writenotify does not depend on vma->vm_flags alone but also depends
> on vma->vm_page_prot and following code will make it return 0 because in newer
> code we are setting dirty_accountable before setting vma->vm_page_prot.
>     /* The open routine did something to the protections that pgprot_modify
>      * won't preserve? */
>     if (pgprot_val(vma->vm_page_prot) !=
>         pgprot_val(vm_pgprot_modify(vma->vm_page_prot, vm_flags)))
>         return 0;
> 
> Now, suppose we change code by calling vma_set_page_prot before setting
> dirty_accountable:
>     vma->vm_flags = newflags;
>     vma_set_page_prot(vma);
>     dirty_accountable = vma_wants_writenotify(vma);
> Still, dirty_accountable will be 0. This is because following code in
> vma_set_page_prot modifies vma->vm_page_prot without modifying vma->vm_flags:
>     if (vma_wants_writenotify(vma)) {
>         vm_flags &= ~VM_SHARED;
>         vma->vm_page_prot = vm_pgprot_modify(vma->vm_page_prot,
>                              vm_flags);
>     }
> so this check in vma_wants_writenotify will again return 0: 
>     /* The open routine did something to the protections that pgprot_modify
>      * won't preserve? */
>     if (pgprot_val(vma->vm_page_prot) !=
>         pgprot_val(vm_pgprot_modify(vma->vm_page_prot, vm_flags)))
>         return 0;
> So dirty_accountable is still 0.
> 
> This code in change_pte_range decides whether to call pte_mkwrite or not:
>             /* Avoid taking write faults for known dirty pages */
>             if (dirty_accountable && pte_dirty(ptent) &&
>                     (pte_soft_dirty(ptent) ||
>                      !(vma->vm_flags & VM_SOFTDIRTY))) {
>                 ptent = pte_mkwrite(ptent);
>             }
> If dirty_accountable is 0 even though the pte was dirty already, pte_mkwrite
> will not be done.
> 
> I think the correct solution should be that dirty_accountable be set with the
> value of vma_wants_writenotify queried before vma->vm_page_prot is set with
> VM_SHARED removed from flags. One way to do so could be to have
> vma_set_page_prot return the value of dirty_accountable that it can set right
> after vma_wants_writenotify check. Another way could be to do
>     vma->vm_page_prot = pgprot_modify(vma->vm_page_prot,
>                       vm_get_page_prot(newflags));
> and then set dirty_accountable based on vma_wants_writenotify and then call
> vma_set_page_prot.
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
