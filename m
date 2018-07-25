Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C42056B0006
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 13:33:53 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id i4-v6so6400553ite.3
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 10:33:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k10-v6sor4721854iod.251.2018.07.25.10.33.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Jul 2018 10:33:52 -0700 (PDT)
MIME-Version: 1.0
References: <20180724121139.62570-1-kirill.shutemov@linux.intel.com>
 <20180724121139.62570-2-kirill.shutemov@linux.intel.com> <20180724130308.bbd46afc3703af4c5e1d6868@linux-foundation.org>
 <CA+55aFz1Vj3b2w-nOBdV5=WwsCYhSBprjPjGog6=_=q75Z5Z-w@mail.gmail.com>
 <20180724134158.676dfa7a4da16adbab3b851c@linux-foundation.org> <20180725123924.g2yvgie2iz2txmek@kshutemo-mobl1>
In-Reply-To: <20180725123924.g2yvgie2iz2txmek@kshutemo-mobl1>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 25 Jul 2018 10:33:41 -0700
Message-ID: <CA+55aFyAo5DK2hLbFF2qg8FY0qFUaYJZNyS2wYhrSm=HfVvsWA@mail.gmail.com>
Subject: Re: [PATCHv3 1/3] mm: Introduce vma_init()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Jul 25, 2018 at 5:39 AM Kirill A. Shutemov <kirill@shutemov.name> wrote:
>
> There are few more:
>
> arch/arm64/include/asm/tlb.h:   struct vm_area_struct vma = { .vm_mm = tlb->mm, };
> arch/arm64/mm/hugetlbpage.c:    struct vm_area_struct vma = { .vm_mm = mm };
> arch/arm64/mm/hugetlbpage.c:    struct vm_area_struct vma = { .vm_mm = mm };

We probably do not care. These are not "real" vma's and are never used
as such. They are literally just fake vmas for the "flush_tlb()"
machinery, which won't ever really cause any VM activity and will just
call back to the architecture TLB flushing routines.

They initialize vm_mm exactly because that's how the mm is passed down
to the tlb flushing (we pass the whole vma because some architectures
than have special flags in vm_flags too that can affect how the TLB
gets flushed - ie "only flush ITLB if it's an execute-only vma" etc).

Using "vma_init()" on them is only confusing, I think.

                 Linus
