Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id E95D36B000A
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 19:18:17 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id b11-v6so4870584pla.19
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 16:18:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z14sor204004pfe.108.2018.04.02.16.18.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Apr 2018 16:18:17 -0700 (PDT)
Date: Mon, 2 Apr 2018 16:18:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v9 15/24] mm: Introduce __vm_normal_page()
In-Reply-To: <1520963994-28477-16-git-send-email-ldufour@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.20.1804021616370.104195@chino.kir.corp.google.com>
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com> <1520963994-28477-16-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Tue, 13 Mar 2018, Laurent Dufour wrote:

> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index a84ddc218bbd..73b8b99f482b 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1263,8 +1263,11 @@ struct zap_details {
>  	pgoff_t last_index;			/* Highest page->index to unmap */
>  };
>  
> -struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
> -			     pte_t pte, bool with_public_device);
> +struct page *__vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
> +			      pte_t pte, bool with_public_device,
> +			      unsigned long vma_flags);
> +#define _vm_normal_page(vma, addr, pte, with_public_device) \
> +	__vm_normal_page(vma, addr, pte, with_public_device, (vma)->vm_flags)
>  #define vm_normal_page(vma, addr, pte) _vm_normal_page(vma, addr, pte, false)
>  
>  struct page *vm_normal_page_pmd(struct vm_area_struct *vma, unsigned long addr,

If _vm_normal_page() is a static inline function does it break somehow?  
It's nice to avoid the #define's.

> diff --git a/mm/memory.c b/mm/memory.c
> index af0338fbc34d..184a0d663a76 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -826,8 +826,9 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
>  #else
>  # define HAVE_PTE_SPECIAL 0
>  #endif
> -struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
> -			     pte_t pte, bool with_public_device)
> +struct page *__vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
> +			      pte_t pte, bool with_public_device,
> +			      unsigned long vma_flags)
>  {
>  	unsigned long pfn = pte_pfn(pte);
>  

Would it be possible to update the comment since the function itself is no 
longer named vm_normal_page?
