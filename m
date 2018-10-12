Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5A87E6B0003
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 23:22:01 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id f77-v6so7503917oic.15
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 20:22:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g5-v6sor14537530oia.123.2018.10.11.20.21.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Oct 2018 20:21:59 -0700 (PDT)
MIME-Version: 1.0
References: <20181009201400.168705-1-joel@joelfernandes.org>
In-Reply-To: <20181009201400.168705-1-joel@joelfernandes.org>
From: Jann Horn <jannh@google.com>
Date: Fri, 12 Oct 2018 05:21:32 +0200
Message-ID: <CAG48ez3yLkMcyaTXFt_+w8_-HtmrjW=XB51DDQSGdjPj43XWmA@mail.gmail.com>
Subject: Re: [PATCH] mm: Speed up mremap on large regions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: joel@joelfernandes.org
Cc: kernel list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, kernel-team@android.com, Minchan Kim <minchan@google.com>, Hugh Dickins <hughd@google.com>, lokeshgidra@google.com, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, pombredanne@nexb.com, Thomas Gleixner <tglx@linutronix.de>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, kvm@vger.kernel.org

+cc xen maintainers and kvm folks

On Fri, Oct 12, 2018 at 4:40 AM Joel Fernandes (Google)
<joel@joelfernandes.org> wrote:
> Android needs to mremap large regions of memory during memory management
> related operations. The mremap system call can be really slow if THP is
> not enabled. The bottleneck is move_page_tables, which is copying each
> pte at a time, and can be really slow across a large map. Turning on THP
> may not be a viable option, and is not for us. This patch speeds up the
> performance for non-THP system by copying at the PMD level when possible.
[...]
> +bool move_normal_pmd(struct vm_area_struct *vma, unsigned long old_addr,
> +                 unsigned long new_addr, unsigned long old_end,
> +                 pmd_t *old_pmd, pmd_t *new_pmd, bool *need_flush)
> +{
[...]
> +       /*
> +        * We don't have to worry about the ordering of src and dst
> +        * ptlocks because exclusive mmap_sem prevents deadlock.
> +        */
> +       old_ptl = pmd_lock(vma->vm_mm, old_pmd);
> +       if (old_ptl) {
> +               pmd_t pmd;
> +
> +               new_ptl = pmd_lockptr(mm, new_pmd);
> +               if (new_ptl != old_ptl)
> +                       spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
> +
> +               /* Clear the pmd */
> +               pmd = *old_pmd;
> +               pmd_clear(old_pmd);
> +
> +               VM_BUG_ON(!pmd_none(*new_pmd));
> +
> +               /* Set the new pmd */
> +               set_pmd_at(mm, new_addr, new_pmd, pmd);
> +               if (new_ptl != old_ptl)
> +                       spin_unlock(new_ptl);
> +               spin_unlock(old_ptl);

How does this interact with Xen PV? From a quick look at the Xen PV
integration code in xen_alloc_ptpage(), it looks to me as if, in a
config that doesn't use split ptlocks, this is going to temporarily
drop Xen's type count for the page to zero, causing Xen to de-validate
and then re-validate the L1 pagetable; if you first set the new pmd
before clearing the old one, that wouldn't happen. I don't know how
this interacts with shadow paging implementations.

> +               *need_flush = true;
> +               return true;
> +       }
> +       return false;
> +}
