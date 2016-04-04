Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 879906B026C
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 08:06:30 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id bc4so157092456lbc.2
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 05:06:30 -0700 (PDT)
Received: from mail-lb0-x235.google.com (mail-lb0-x235.google.com. [2a00:1450:4010:c04::235])
        by mx.google.com with ESMTPS id q65si15756437lfd.123.2016.04.04.05.06.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Apr 2016 05:06:27 -0700 (PDT)
Received: by mail-lb0-x235.google.com with SMTP id vo2so158282124lbb.1
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 05:06:27 -0700 (PDT)
Date: Mon, 4 Apr 2016 15:06:25 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm: BUG in khugepaged_scan_mm_slot
Message-ID: <20160404120625.GA6133@node.shutemov.name>
References: <CACT4Y+ZmuZMV5CjSFOeXviwQdABAgT7T+StKfTqan9YDtgEi5g@mail.gmail.com>
 <5702582A.1030904@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5702582A.1030904@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Konstantin Khlebnikov <koct9i@gmail.com>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>, Andrea Arcangeli <aarcange@redhat.com>

On Mon, Apr 04, 2016 at 02:03:54PM +0200, Vlastimil Babka wrote:
> [+CC Andrea]
> 
> On 04/02/2016 11:48 AM, Dmitry Vyukov wrote:
> >Hello,
> >
> >The following program triggers a BUG in khugepaged_scan_mm_slot:
> >
> >
> >vma ffff880032698f90 start 0000000020c57000 end 0000000020c58000
> >next ffff88003269a1b8 prev ffff88003269ac18 mm ffff88005e274780
> >prot 35 anon_vma ffff88003182c000 vm_ops           (null)
> >pgoff fed00 file ffff8800324552c0 private_data           (null)
> >flags: 0x5144477(read|write|exec|mayread|maywrite|mayexec|pfnmap|io|dontexpand|account)
> >------------[ cut here ]------------
> >kernel BUG at mm/huge_memory.c:2313!
> >invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
> 
> That's VM_BUG_ON_VMA(vma->vm_flags & VM_NO_THP, vma) in
> hugepage_vma_check().
> 
> #define VM_NO_THP (VM_SPECIAL | VM_HUGETLB | VM_SHARED | VM_MAYSHARE)
> 
> #define VM_SPECIAL (VM_IO | VM_DONTEXPAND | VM_PFNMAP | VM_MIXEDMAP)
> 
> Of those, we have VM_IO | VM_DONTEXPAND.
> 
> I don't know if it's valid for a vma with anon_vma to have such flags, if
> yes, we should probably modify hugepage_vma_check(). Called from
> khugepaged_scan_mm_slot() it should just return false out VM_NO_THP. Called
> from collapse_huge_page() it could keep the VM_BUG_ON. Or maybe just have
> VM_BUG_ON(!hugepage_vma_check()) there? Hmm actually no, there's a mmap_sem
> release for read and then acquire for write, so we can't rely on the check
> done earlier from khugepaged_scan_mm_slot().
> 
> So we should probably just change the VM_BUG_ON to another "return false"
> condition. Unless the VM_BUG_ON uncovered a real bug and the earlier
> conditions in hugepage_vma_check() should guarantee the VM_BUG_ON be false
> for any vma.

http://lkml.kernel.org/r/145961146490.28194.16019687861681349309.stgit@zurg

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
