Subject: Re: Removing MAX_ARG_PAGES (request for comments/assistance)
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <65dd6fd50610101705t3db93a72sc0847cd120aa05d3@mail.gmail.com>
References: <65dd6fd50610101705t3db93a72sc0847cd120aa05d3@mail.gmail.com>
Content-Type: text/plain
Date: Wed, 11 Oct 2006 15:14:20 +0200
Message-Id: <1160572460.2006.79.camel@taijtu>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ollie Wild <aaw@google.com>
Cc: linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, Linus Torvalds <torvalds@osdl.org>, Arjan van de Ven <arjan@infradead.org>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Andi Kleen <ak@muc.de>, linux-arch@vger.kernel.org, David Howells <dhowells@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-10-10 at 17:05 -0700, Ollie Wild wrote:

> +                       vma->vm_flags &= ~VM_EXEC;
> +               // FIXME: Are the next two lines sufficient, or do I need to
> +               // do some additional magic?
> +               vma->vm_flags |= mm->def_flags;
> +               vma->vm_page_prot = protection_map[vma->vm_flags & 0x7];

Yeah, you'll need to change the PTEs for those pages you created by
calling get_user_page() by calling an mprotect like function; perhaps
something like:

 struct vm_area_struct *prev;
 unsigned long vm_flags = vma->vm_flags;

 s/vma->vm_flags/vm_flags/g

 err = mprotect_fixup(vma, &prev, vma->vm_start, vma->vm_end, vm_flags);
 BUG_ON(prev != vma);

mprotect_fixup will then set the new protection on all PTEs and update
vma->vm_flags and vma->vm_page_prot.

> +               /* Move stack pages down in memory. */
> +               if (stack_shift) {
> +                       // FIXME: Verify the shift is OK.
> +

What exactly are you wondering about? the call to move_vma looks sane to
me

> +                       /* This should be safe even with overlap because we
> +                        * are shifting down. */
> +                       ret = move_vma(vma, vma->vm_start,
> +                                       vma->vm_end - vma->vm_start,
> +                                       vma->vm_end - vma->vm_start,
> +                                       vma->vm_start - stack_shift);
> +                       if (ret & ~PAGE_MASK) {
> +                               up_write(&mm->mmap_sem);
> +                               return ret;
> +                       }
>                 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
