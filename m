Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2486B0005
	for <linux-mm@kvack.org>; Mon,  1 Feb 2016 05:48:49 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id 128so64415474wmz.1
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 02:48:49 -0800 (PST)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id r138si14252763wmg.30.2016.02.01.02.48.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Feb 2016 02:48:48 -0800 (PST)
Received: by mail-wm0-x22c.google.com with SMTP id r129so63772971wmr.0
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 02:48:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160129123544.GB146512@black.fi.intel.com>
References: <CACT4Y+Z9UDZNLsoEz-DO3fX_+0gTwPUA=uE++J=w1sAG_4CGJg@mail.gmail.com>
 <20160128105136.GD2396@node.shutemov.name> <CACT4Y+ZZkWTuw8hxnqLEf81bF=GL2SKv8Buqwv3qByBeSLBf+A@mail.gmail.com>
 <20160128114042.GE2396@node.shutemov.name> <CACT4Y+Ybn_YAsP6f_wRfPr-zw2ZbF8cfKBMtqhZ=ya-qCpeq3w@mail.gmail.com>
 <20160129123544.GB146512@black.fi.intel.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 1 Feb 2016 11:48:27 +0100
Message-ID: <CACT4Y+ZbW=7tq0ZTCDrDp_YF0cG8qcgzO8Q8hLr7-PJ=wpVzUg@mail.gmail.com>
Subject: Re: mm: another VM_BUG_ON_PAGE(PageTail(page))
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzkaller <syzkaller@googlegroups.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Doug Gilbert <dgilbert@interlog.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Shiraz Hashim <shashim@codeaurora.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, linux-scsi <linux-scsi@vger.kernel.org>

On Fri, Jan 29, 2016 at 1:35 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> From 691a961bb401c5815ed741dac63591efbc6027e3 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Fri, 29 Jan 2016 15:06:17 +0300
> Subject: [PATCH 2/2] mempolicy: do not try to queue pages from
>  !vma_migratable()
>
> Maybe I miss some point, but I don't see a reason why we try to queue
> pages from non migratable VMAs.
>
> The only case when we can queue pages from such VMA is MPOL_MF_STRICT
> plus MPOL_MF_MOVE or MPOL_MF_MOVE_ALL for VMA which has pages on LRU,
> but gfp mask is not sutable for migaration (see mapping_gfp_mask() check
> in vma_migratable()). That's looks like a bug to me.
>
> Let's filter out non-migratable vma at start of queue_pages_test_walk()
> and go to queue_pages_pte_range() only if MPOL_MF_MOVE or
> MPOL_MF_MOVE_ALL flag is set.


I've run the fuzzer with these two patches for the weekend and seen no crashes.
I guess we can consider this as fixed.
Thanks!


> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/mempolicy.c | 14 +++++---------
>  1 file changed, 5 insertions(+), 9 deletions(-)
>
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 27d135408a22..4c4187c0e1de 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -548,8 +548,7 @@ retry:
>                         goto retry;
>                 }
>
> -               if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
> -                       migrate_page_add(page, qp->pagelist, flags);
> +               migrate_page_add(page, qp->pagelist, flags);
>         }
>         pte_unmap_unlock(pte - 1, ptl);
>         cond_resched();
> @@ -625,7 +624,7 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
>         unsigned long endvma = vma->vm_end;
>         unsigned long flags = qp->flags;
>
> -       if (vma->vm_flags & VM_PFNMAP)
> +       if (!vma_migratable(vma))
>                 return 1;
>
>         if (endvma > end)
> @@ -644,16 +643,13 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
>
>         if (flags & MPOL_MF_LAZY) {
>                 /* Similar to task_numa_work, skip inaccessible VMAs */
> -               if (vma_migratable(vma) &&
> -                       vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE))
> +               if (vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE))
>                         change_prot_numa(vma, start, endvma);
>                 return 1;
>         }
>
> -       if ((flags & MPOL_MF_STRICT) ||
> -           ((flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) &&
> -            vma_migratable(vma)))
> -               /* queue pages from current vma */
> +       /* queue pages from current vma */
> +       if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
>                 return 0;
>         return 1;
>  }
> --
> 2.7.0.rc3
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller+unsubscribe@googlegroups.com.
> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
