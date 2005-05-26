Message-Id: <200505261744.j4QHi4g22996@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [PATCH] Avoiding mmap fragmentation - clean rev
Date: Thu, 26 May 2005 10:44:05 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <4296082A.3000900@rentec.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Wolfgang Wander' <wwc@rentec.com>
Cc: 'Andrew Morton' <akpm@osdl.org>, herve@elma.fr, mingo@elte.hu, arjanv@redhat.com, linux-mm@kvack.org, colin.harrison@virgin.net
List-ID: <linux-mm.kvack.org>

Wolfgang Wander wrote on Thursday, May 26, 2005 10:32 AM
> This one seems to have triggered already the second bug report on lkm.
> 
> Is it possible that  in
> 
> static void
> detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
>      struct vm_area_struct *prev, unsigned long end)
> {
>      struct vm_area_struct **insertion_point;
>      struct vm_area_struct *tail_vma = NULL;
> 
>      insertion_point = (prev ? &prev->vm_next : &mm->mmap);
>      do {
>          rb_erase(&vma->vm_rb, &mm->mm_rb);
>          mm->map_count--;
>          tail_vma = vma;
>          vma = vma->vm_next;
>      } while (vma && vma->vm_start < end);
>      *insertion_point = vma;
>      tail_vma->vm_next = NULL;
>      if (mm->unmap_area == arch_unmap_area)
>          tail_vma->vm_private_data = (void*) prev->vm_end;
>      else
>          tail_vma->vm_private_data = vma ?
>              (void*) vma->vm_start : (void*) mm->mmap_base;
>      mm->mmap_cache = NULL;        /* Kill the cache. */
> }
> 
> 'prev' seems to possibly be NULL and the assignemnt of
>    tail_vma->vm_private_data = (void*) prev->vm_end;
> which fix-2 adds does not check for that.
> That potential problem does not seem to match the stacktrace
> below however...

It sure looks like 'prev' can be null.  It needs the similar check
like the one in the top down case.  I will double check on it.  Thanks
for catching the bug.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
