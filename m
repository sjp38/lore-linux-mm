Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id D5F6F6B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 07:36:37 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id f14so7337765lbb.2
        for <linux-mm@kvack.org>; Tue, 17 May 2016 04:36:37 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id vx2si2120768lbb.180.2016.05.17.04.36.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 04:36:36 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id u64so874088lff.2
        for <linux-mm@kvack.org>; Tue, 17 May 2016 04:36:36 -0700 (PDT)
Date: Tue, 17 May 2016 14:36:34 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [Bug 117731] New: Doing mprotect for PROT_NONE and then for
 PROT_READ|PROT_WRITE reduces CPU write B/W on buffer
Message-ID: <20160517113634.GD9540@node.shutemov.name>
References: <bug-117731-27@https.bugzilla.kernel.org/>
 <20160506150112.9b27324b4b2b141146b0ff25@linux-foundation.org>
 <20160516133543.GA9540@node.shutemov.name>
 <CAGoWJG8mEwscwkUW31ejFyHR63Jm4eQKtUDpeADB2nUinrL59w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGoWJG8mEwscwkUW31ejFyHR63Jm4eQKtUDpeADB2nUinrL59w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ashish Srivastava <ashish0srivastava0@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, Peter Feiner <pfeiner@google.com>, linux-mm@kvack.org

On Tue, May 17, 2016 at 04:56:02PM +0530, Ashish Srivastava wrote:
> Yes, the original repro was using a custom allocator but I was seeing the
> issue with malloc'd memory as well on my (ARMv7) platform.

Test-case for that would be helpful, as normal malloc()'ed anon memory
cannot be subject for the bug. Unless I miss something obvious.

> I agree that the repro code won't reliably work so have modified the repro
> code attached to the bug to use file backed memory.
> 
> That really is the root cause of the problem. I can make the following
> change in the kernel that can make the slow writes problem go away.
> This makes vma_set_page_prot return the value of vma_wants_writenotify to
> the caller after setting vma->vmpage_prot.
> 
> In vma_set_page_prot:
> -void vma_set_page_prot(struct vm_area_struct *vma)
> +bool vma_set_page_prot(struct vm_area_struct *vma)
> {
>     unsigned long vm_flags = vma->vm_flags;
> 
>     vma->vm_page_prot = vm_pgprot_modify(vma->vm_page_prot, vm_flags);
>     if (vma_wants_writenotify(vma)) {
>         vm_flags &= ~VM_SHARED;
>         vma->vm_page_prot = vm_pgprot_modify(vma->vm_page_prot,
>                              vm_flags);
> +        return 1;
>      }
> +    return 0;
> }
> 
> In mprotect_fixup:
> 
>      * held in write mode.
>       */
>      vma->vm_flags = newflags;
> -    dirty_accountable = vma_wants_writenotify(vma);
> -    vma_set_page_prot(vma);
> +    dirty_accountable = vma_set_page_prot(vma);
> 
>      change_protection(vma, start, end, vma->vm_page_prot,
>                dirty_accountable, 0)
> 

That looks good to me. Please prepare proper patch.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
