Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2A5D46B0003
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 19:57:07 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 61-v6so3716453plz.20
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 16:57:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i124sor362708pgc.177.2018.04.02.16.57.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Apr 2018 16:57:06 -0700 (PDT)
Date: Mon, 2 Apr 2018 16:57:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v9 16/24] mm: Introduce __page_add_new_anon_rmap()
In-Reply-To: <1520963994-28477-17-git-send-email-ldufour@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.20.1804021655100.253461@chino.kir.corp.google.com>
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com> <1520963994-28477-17-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Tue, 13 Mar 2018, Laurent Dufour wrote:

> When dealing with speculative page fault handler, we may race with VMA
> being split or merged. In this case the vma->vm_start and vm->vm_end
> fields may not match the address the page fault is occurring.
> 
> This can only happens when the VMA is split but in that case, the
> anon_vma pointer of the new VMA will be the same as the original one,
> because in __split_vma the new->anon_vma is set to src->anon_vma when
> *new = *vma.
> 
> So even if the VMA boundaries are not correct, the anon_vma pointer is
> still valid.
> 
> If the VMA has been merged, then the VMA in which it has been merged
> must have the same anon_vma pointer otherwise the merge can't be done.
> 
> So in all the case we know that the anon_vma is valid, since we have
> checked before starting the speculative page fault that the anon_vma
> pointer is valid for this VMA and since there is an anon_vma this
> means that at one time a page has been backed and that before the VMA
> is cleaned, the page table lock would have to be grab to clean the
> PTE, and the anon_vma field is checked once the PTE is locked.
> 
> This patch introduce a new __page_add_new_anon_rmap() service which
> doesn't check for the VMA boundaries, and create a new inline one
> which do the check.
> 
> When called from a page fault handler, if this is not a speculative one,
> there is a guarantee that vm_start and vm_end match the faulting address,
> so this check is useless. In the context of the speculative page fault
> handler, this check may be wrong but anon_vma is still valid as explained
> above.
> 
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>

I'm indifferent on this: it could be argued both sides that the new 
function and its variant for a simple VM_BUG_ON() isn't worth it and it 
would should rather be done in the callers of page_add_new_anon_rmap().  
It feels like it would be better left to the caller and add a comment to 
page_add_anon_rmap() itself in mm/rmap.c.
