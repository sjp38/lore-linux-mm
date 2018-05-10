Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8FC1B6B0624
	for <linux-mm@kvack.org>; Thu, 10 May 2018 12:15:09 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e1-v6so1412092wma.3
        for <linux-mm@kvack.org>; Thu, 10 May 2018 09:15:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k2-v6sor380177wmf.37.2018.05.10.09.15.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 May 2018 09:15:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1523975611-15978-7-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com> <1523975611-15978-7-git-send-email-ldufour@linux.vnet.ibm.com>
From: vinayak menon <vinayakm.list@gmail.com>
Date: Thu, 10 May 2018 21:45:05 +0530
Message-ID: <CAOaiJ-n6P-hjBEkiR4+MyFYunocPgzAYkG1wALDcmi7ROe4-ag@mail.gmail.com>
Subject: Re: [PATCH v10 06/25] mm: make pte_unmap_same compatible with SPF
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Paul McKenney <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, Vinayak Menon <vinmenon@codeaurora.org>

On Tue, Apr 17, 2018 at 8:03 PM, Laurent Dufour
<ldufour@linux.vnet.ibm.com> wrote:
> pte_unmap_same() is making the assumption that the page table are still
> around because the mmap_sem is held.
> This is no more the case when running a speculative page fault and
> additional check must be made to ensure that the final page table are still
> there.
>
> This is now done by calling pte_spinlock() to check for the VMA's
> consistency while locking for the page tables.
>
> This is requiring passing a vm_fault structure to pte_unmap_same() which is
> containing all the needed parameters.
>
> As pte_spinlock() may fail in the case of a speculative page fault, if the
> VMA has been touched in our back, pte_unmap_same() should now return 3
> cases :
>         1. pte are the same (0)
>         2. pte are different (VM_FAULT_PTNOTSAME)
>         3. a VMA's changes has been detected (VM_FAULT_RETRY)
>
> The case 2 is handled by the introduction of a new VM_FAULT flag named
> VM_FAULT_PTNOTSAME which is then trapped in cow_user_page().
> If VM_FAULT_RETRY is returned, it is passed up to the callers to retry the
> page fault while holding the mmap_sem.
>
> Acked-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> ---
>  include/linux/mm.h |  1 +
>  mm/memory.c        | 39 ++++++++++++++++++++++++++++-----------
>  2 files changed, 29 insertions(+), 11 deletions(-)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 4d1aff80669c..714da99d77a3 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1208,6 +1208,7 @@ static inline void clear_page_pfmemalloc(struct page *page)
>  #define VM_FAULT_NEEDDSYNC  0x2000     /* ->fault did not modify page tables
>                                          * and needs fsync() to complete (for
>                                          * synchronous page faults in DAX) */
> +#define VM_FAULT_PTNOTSAME 0x4000      /* Page table entries have changed */


This has to be added to VM_FAULT_RESULT_TRACE ?
