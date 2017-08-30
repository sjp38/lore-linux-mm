Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C27F12803A5
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 01:58:19 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 128so10697496pgd.10
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 22:58:19 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id m11si3909554pln.775.2017.08.29.22.58.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 22:58:18 -0700 (PDT)
Date: Wed, 30 Aug 2017 07:58:00 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 14/20] mm: Provide speculative fault infrastructure
Message-ID: <20170830055800.GG32112@worktop.programming.kicks-ass.net>
References: <1503007519-26777-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1503007519-26777-15-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170827001823.n5wgkfq36z6snvf2@node.shutemov.name>
 <507e79d5-59df-c5b5-106d-970c9353d9bc@linux.vnet.ibm.com>
 <20170829120426.4ar56rbmiupbqmio@hirez.programming.kicks-ass.net>
 <848fa2c6-dbda-9a1e-2efd-3ce9b083365e@linux.vnet.ibm.com>
 <20170829134550.t7du5zdssvlzemtk@hirez.programming.kicks-ass.net>
 <ab0634c4-274d-208f-fc4b-43991986bacf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ab0634c4-274d-208f-fc4b-43991986bacf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Wed, Aug 30, 2017 at 10:33:50AM +0530, Anshuman Khandual wrote:
> diff --git a/mm/filemap.c b/mm/filemap.c
> index a497024..08f3042 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1181,6 +1181,18 @@ int __lock_page_killable(struct page *__page)
>  int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
>                          unsigned int flags)
>  {
> +       if (flags & FAULT_FLAG_SPECULATIVE) {
> +               if (flags & FAULT_FLAG_KILLABLE) {
> +                       int ret;
> +
> +                       ret = __lock_page_killable(page);
> +                       if (ret)
> +                               return 0;
> +               } else
> +                       __lock_page(page);
> +               return 1;
> +       }
> +
>         if (flags & FAULT_FLAG_ALLOW_RETRY) {
>                 /*
>                  * CAUTION! In this case, mmap_sem is not released

Yeah, that looks right.

> @@ -4012,17 +4010,7 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
>                 goto unlock;
>         }
> 
> +       if (unlikely(vma_is_anonymous(vma) && !vma->anon_vma)) {
>                 trace_spf_vma_notsup(_RET_IP_, vma, address);
>                 goto unlock;
>         }

As riel pointed out on IRC slightly later, private file maps also need
->anon_vma and those actually have ->vm_ops IIRC so the condition needs
to be slightly more complicated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
