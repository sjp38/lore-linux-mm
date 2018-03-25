Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9C3C76B0030
	for <linux-mm@kvack.org>; Sun, 25 Mar 2018 17:50:17 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c5so9983920pfn.17
        for <linux-mm@kvack.org>; Sun, 25 Mar 2018 14:50:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n65sor3507432pfn.121.2018.03.25.14.50.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 25 Mar 2018 14:50:16 -0700 (PDT)
Date: Sun, 25 Mar 2018 14:50:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v9 05/24] mm: Introduce pte_spinlock for
 FAULT_FLAG_SPECULATIVE
In-Reply-To: <1520963994-28477-6-git-send-email-ldufour@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.20.1803251446180.80485@chino.kir.corp.google.com>
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com> <1520963994-28477-6-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Tue, 13 Mar 2018, Laurent Dufour wrote:

> When handling page fault without holding the mmap_sem the fetch of the
> pte lock pointer and the locking will have to be done while ensuring
> that the VMA is not touched in our back.
> 
> So move the fetch and locking operations in a dedicated function.
> 
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> ---
>  mm/memory.c | 15 +++++++++++----
>  1 file changed, 11 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 8ac241b9f370..21b1212a0892 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2288,6 +2288,13 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
>  }
>  EXPORT_SYMBOL_GPL(apply_to_page_range);
>  
> +static bool pte_spinlock(struct vm_fault *vmf)

inline?

> +{
> +	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
> +	spin_lock(vmf->ptl);
> +	return true;
> +}
> +
>  static bool pte_map_lock(struct vm_fault *vmf)
>  {
>  	vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd,

Shouldn't pte_unmap_same() take struct vm_fault * and use the new 
pte_spinlock()?
