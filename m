Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id A70C06B026A
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 08:03:57 -0400 (EDT)
Received: by mail-qg0-f42.google.com with SMTP id j35so146929339qge.0
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 05:03:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d26si12993093wmi.104.2016.04.04.05.03.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Apr 2016 05:03:56 -0700 (PDT)
Subject: Re: mm: BUG in khugepaged_scan_mm_slot
References: <CACT4Y+ZmuZMV5CjSFOeXviwQdABAgT7T+StKfTqan9YDtgEi5g@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5702582A.1030904@suse.cz>
Date: Mon, 4 Apr 2016 14:03:54 +0200
MIME-Version: 1.0
In-Reply-To: <CACT4Y+ZmuZMV5CjSFOeXviwQdABAgT7T+StKfTqan9YDtgEi5g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Konstantin Khlebnikov <koct9i@gmail.com>
Cc: syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>, Andrea Arcangeli <aarcange@redhat.com>

[+CC Andrea]

On 04/02/2016 11:48 AM, Dmitry Vyukov wrote:
> Hello,
>
> The following program triggers a BUG in khugepaged_scan_mm_slot:
>
>
> vma ffff880032698f90 start 0000000020c57000 end 0000000020c58000
> next ffff88003269a1b8 prev ffff88003269ac18 mm ffff88005e274780
> prot 35 anon_vma ffff88003182c000 vm_ops           (null)
> pgoff fed00 file ffff8800324552c0 private_data           (null)
> flags: 0x5144477(read|write|exec|mayread|maywrite|mayexec|pfnmap|io|dontexpand|account)
> ------------[ cut here ]------------
> kernel BUG at mm/huge_memory.c:2313!
> invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN

That's VM_BUG_ON_VMA(vma->vm_flags & VM_NO_THP, vma) in 
hugepage_vma_check().

#define VM_NO_THP (VM_SPECIAL | VM_HUGETLB | VM_SHARED | VM_MAYSHARE)

#define VM_SPECIAL (VM_IO | VM_DONTEXPAND | VM_PFNMAP | VM_MIXEDMAP)

Of those, we have VM_IO | VM_DONTEXPAND.

I don't know if it's valid for a vma with anon_vma to have such flags, 
if yes, we should probably modify hugepage_vma_check(). Called from 
khugepaged_scan_mm_slot() it should just return false out VM_NO_THP. 
Called from collapse_huge_page() it could keep the VM_BUG_ON. Or maybe 
just have VM_BUG_ON(!hugepage_vma_check()) there? Hmm actually no, 
there's a mmap_sem release for read and then acquire for write, so we 
can't rely on the check done earlier from khugepaged_scan_mm_slot().

So we should probably just change the VM_BUG_ON to another "return 
false" condition. Unless the VM_BUG_ON uncovered a real bug and the 
earlier conditions in hugepage_vma_check() should guarantee the 
VM_BUG_ON be false for any vma.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
