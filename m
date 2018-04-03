Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8108D6B0003
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 20:11:45 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id q12-v6so5020881plr.17
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 17:11:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u13-v6sor642181plq.11.2018.04.02.17.11.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Apr 2018 17:11:44 -0700 (PDT)
Date: Mon, 2 Apr 2018 17:11:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v9 17/24] mm: Protect mm_rb tree with a rwlock
In-Reply-To: <1520963994-28477-18-git-send-email-ldufour@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.20.1804021711090.34466@chino.kir.corp.google.com>
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com> <1520963994-28477-18-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Tue, 13 Mar 2018, Laurent Dufour wrote:

> This change is inspired by the Peter's proposal patch [1] which was
> protecting the VMA using SRCU. Unfortunately, SRCU is not scaling well in
> that particular case, and it is introducing major performance degradation
> due to excessive scheduling operations.
> 
> To allow access to the mm_rb tree without grabbing the mmap_sem, this patch
> is protecting it access using a rwlock.  As the mm_rb tree is a O(log n)
> search it is safe to protect it using such a lock.  The VMA cache is not
> protected by the new rwlock and it should not be used without holding the
> mmap_sem.
> 
> To allow the picked VMA structure to be used once the rwlock is released, a
> use count is added to the VMA structure. When the VMA is allocated it is
> set to 1.  Each time the VMA is picked with the rwlock held its use count
> is incremented. Each time the VMA is released it is decremented. When the
> use count hits zero, this means that the VMA is no more used and should be
> freed.
> 
> This patch is preparing for 2 kind of VMA access :
>  - as usual, under the control of the mmap_sem,
>  - without holding the mmap_sem for the speculative page fault handler.
> 
> Access done under the control the mmap_sem doesn't require to grab the
> rwlock to protect read access to the mm_rb tree, but access in write must
> be done under the protection of the rwlock too. This affects inserting and
> removing of elements in the RB tree.
> 
> The patch is introducing 2 new functions:
>  - vma_get() to find a VMA based on an address by holding the new rwlock.
>  - vma_put() to release the VMA when its no more used.
> These services are designed to be used when access are made to the RB tree
> without holding the mmap_sem.
> 
> When a VMA is removed from the RB tree, its vma->vm_rb field is cleared and
> we rely on the WMB done when releasing the rwlock to serialize the write
> with the RMB done in a later patch to check for the VMA's validity.
> 
> When free_vma is called, the file associated with the VMA is closed
> immediately, but the policy and the file structure remained in used until
> the VMA's use count reach 0, which may happens later when exiting an
> in progress speculative page fault.
> 
> [1] https://patchwork.kernel.org/patch/5108281/
> 
> Cc: Peter Zijlstra (Intel) <peterz@infradead.org>
> Cc: Matthew Wilcox <willy@infradead.org>
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>

Can __free_vma() be generalized for mm/nommu.c's delete_vma() and 
do_mmap()?
