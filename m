Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 71C976B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 14:48:15 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id c73so7376339qke.2
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 11:48:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z13-v6sor4467593qve.58.2018.04.30.11.48.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Apr 2018 11:48:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1523975611-15978-18-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com> <1523975611-15978-18-git-send-email-ldufour@linux.vnet.ibm.com>
From: Punit Agrawal <punitagrawal@gmail.com>
Date: Mon, 30 Apr 2018 19:47:53 +0100
Message-ID: <CAD4BONeTCmSZgzThatyY66xVx1a9nCgNO+LCory0h9ZpBkn_+w@mail.gmail.com>
Subject: Re: [PATCH v10 17/25] mm: protect mm_rb tree with a rwlock
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

Hi Laurent,

One nitpick below.

On Tue, Apr 17, 2018 at 3:33 PM, Laurent Dufour
<ldufour@linux.vnet.ibm.com> wrote:
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
> ---
>  include/linux/mm.h       |   1 +
>  include/linux/mm_types.h |   4 ++
>  kernel/fork.c            |   3 ++
>  mm/init-mm.c             |   3 ++
>  mm/internal.h            |   6 +++
>  mm/mmap.c                | 115 +++++++++++++++++++++++++++++++++++------------
>  6 files changed, 104 insertions(+), 28 deletions(-)
>

[...]

> diff --git a/mm/mmap.c b/mm/mmap.c
> index 5601f1ef8bb9..a82950960f2e 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -160,6 +160,27 @@ void unlink_file_vma(struct vm_area_struct *vma)
>         }
>  }
>
> +static void __free_vma(struct vm_area_struct *vma)
> +{
> +       if (vma->vm_file)
> +               fput(vma->vm_file);
> +       mpol_put(vma_policy(vma));
> +       kmem_cache_free(vm_area_cachep, vma);
> +}
> +
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +void put_vma(struct vm_area_struct *vma)
> +{
> +       if (atomic_dec_and_test(&vma->vm_ref_count))
> +               __free_vma(vma);
> +}
> +#else
> +static inline void put_vma(struct vm_area_struct *vma)
> +{
> +       return __free_vma(vma);

Please drop the "return".

Thanks,
Punit

[...]
