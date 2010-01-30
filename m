Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8BE996B0047
	for <linux-mm@kvack.org>; Sat, 30 Jan 2010 13:29:21 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: Bug in find_vma_prev - mmap.c
Date: Sat, 30 Jan 2010 19:29:47 +0100
References: <6cafb0f01001291657q4ccbee86rce3143a4be7a1433@mail.gmail.com>
In-Reply-To: <6cafb0f01001291657q4ccbee86rce3143a4be7a1433@mail.gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201001301929.47659.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Tony Perkins <da.perk@gmail.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

[Adding CCs]

On Saturday 30 January 2010, Tony Perkins wrote:
> This code returns vma (mm->mmap) if it sees that addr is lower than first VMA.
> However, I think it falsely returns vma (mm->mmap) on the case where
> addr is in the first VMA.
> 
> If it is the first VMA region:
> - *pprev should be set to NULL
> - implying prev is NULL
> - and should therefore return vma (so in this case, I just added if
> it's the first VMA and it's within range)
> 
> /* Same as find_vma, but also return a pointer to the previous VMA in *pprev. */
> struct vm_area_struct *
> find_vma_prev(struct mm_struct *mm, unsigned long addr,
>             struct vm_area_struct **pprev)
> {
>     struct vm_area_struct *vma = NULL, *prev = NULL;
>     struct rb_node *rb_node;
>     if (!mm)
>         goto out;
> 
>     /* Guard against addr being lower than the first VMA */
>     vma = mm->mmap;
> 
>     /* Go through the RB tree quickly. */
>     rb_node = mm->mm_rb.rb_node;
> 
>     while (rb_node) {
>         struct vm_area_struct *vma_tmp;
>         vma_tmp = rb_entry(rb_node, struct vm_area_struct, vm_rb);
> 
>         if (addr < vma_tmp->vm_end) {
>             // TONY: if (vma_tmp->vm_start <= addr) vma = vma_tmp; //
> this returns the correct 'vma' when vma is the first node (i.e., no
> prev)
>             rb_node = rb_node->rb_left;
>         } else {
>             prev = vma_tmp;
>             if (!prev->vm_next || (addr < prev->vm_next->vm_end))
>                 break;
>             rb_node = rb_node->rb_right;
>         }
>     }
> 
> out:
>     *pprev = prev;
>     return prev ? prev->vm_next : vma;
> }
> 
> Is this a known issue and/or has this problem been addressed?
> Also, please CC my email address with responses.

Well, I guess you should let the mm people know (CCs added).

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
