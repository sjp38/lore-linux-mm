Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id AFC3E8E00E5
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 21:20:35 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id a9so11949763pla.2
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 18:20:35 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q2si13892707plh.261.2018.12.11.18.20.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 18:20:33 -0800 (PST)
Received: from mail-wm1-f50.google.com (mail-wm1-f50.google.com [209.85.128.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 313C920989
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 02:20:33 +0000 (UTC)
Received: by mail-wm1-f50.google.com with SMTP id m1so3548540wml.2
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 18:20:33 -0800 (PST)
MIME-Version: 1.0
References: <20181212000354.31955-1-rick.p.edgecombe@intel.com> <20181212000354.31955-2-rick.p.edgecombe@intel.com>
In-Reply-To: <20181212000354.31955-2-rick.p.edgecombe@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 11 Dec 2018 18:20:19 -0800
Message-ID: <CALCETrVP577NvdeYj8bzpEfTXj3GZD3nFcJxnUq5n1daDBxU=g@mail.gmail.com>
Subject: Re: [PATCH v2 1/4] vmalloc: New flags for safe vfree on special perms
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrew Lutomirski <luto@kernel.org>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, "Naveen N . Rao" <naveen.n.rao@linux.vnet.ibm.com>, Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>, "David S. Miller" <davem@davemloft.net>, Masami Hiramatsu <mhiramat@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Jessica Yu <jeyu@kernel.org>, Nadav Amit <namit@vmware.com>, Network Development <netdev@vger.kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Jann Horn <jannh@google.com>, Kristen Carlson Accardi <kristen@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>

On Tue, Dec 11, 2018 at 4:12 PM Rick Edgecombe
<rick.p.edgecombe@intel.com> wrote:
>
> This adds two new flags VM_IMMEDIATE_UNMAP and VM_HAS_SPECIAL_PERMS, for
> enabling vfree operations to immediately clear executable TLB entries to freed
> pages, and handle freeing memory with special permissions.
>
> In order to support vfree being called on memory that might be RO, the vfree
> deferred list node is moved to a kmalloc allocated struct, from where it is
> today, reusing the allocation being freed.
>
> arch_vunmap is a new __weak function that implements the actual unmapping and
> resetting of the direct map permissions. It can be overridden by more efficient
> architecture specific implementations.
>
> For the default implementation, it uses architecture agnostic methods which are
> equivalent to what most usages do before calling vfree. So now it is just
> centralized here.
>
> This implementation derives from two sketches from Dave Hansen and Andy
> Lutomirski.
>
> Suggested-by: Dave Hansen <dave.hansen@intel.com>
> Suggested-by: Andy Lutomirski <luto@kernel.org>
> Suggested-by: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
> ---
>  include/linux/vmalloc.h |  2 ++
>  mm/vmalloc.c            | 73 +++++++++++++++++++++++++++++++++++++----
>  2 files changed, 69 insertions(+), 6 deletions(-)
>
> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> index 398e9c95cd61..872bcde17aca 100644
> --- a/include/linux/vmalloc.h
> +++ b/include/linux/vmalloc.h
> @@ -21,6 +21,8 @@ struct notifier_block;                /* in notifier.h */
>  #define VM_UNINITIALIZED       0x00000020      /* vm_struct is not fully initialized */
>  #define VM_NO_GUARD            0x00000040      /* don't add guard page */
>  #define VM_KASAN               0x00000080      /* has allocated kasan shadow memory */
> +#define VM_IMMEDIATE_UNMAP     0x00000200      /* flush before releasing pages */
> +#define VM_HAS_SPECIAL_PERMS   0x00000400      /* may be freed with special perms */
>  /* bits [20..32] reserved for arch specific ioremap internals */
>
>  /*
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 97d4b25d0373..02b284d2245a 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -18,6 +18,7 @@
>  #include <linux/interrupt.h>
>  #include <linux/proc_fs.h>
>  #include <linux/seq_file.h>
> +#include <linux/set_memory.h>
>  #include <linux/debugobjects.h>
>  #include <linux/kallsyms.h>
>  #include <linux/list.h>
> @@ -38,6 +39,11 @@
>
>  #include "internal.h"
>
> +struct vfree_work {
> +       struct llist_node node;
> +       void *addr;
> +};
> +
>  struct vfree_deferred {
>         struct llist_head list;
>         struct work_struct wq;
> @@ -50,9 +56,13 @@ static void free_work(struct work_struct *w)
>  {
>         struct vfree_deferred *p = container_of(w, struct vfree_deferred, wq);
>         struct llist_node *t, *llnode;
> +       struct vfree_work *cur;
>
> -       llist_for_each_safe(llnode, t, llist_del_all(&p->list))
> -               __vunmap((void *)llnode, 1);
> +       llist_for_each_safe(llnode, t, llist_del_all(&p->list)) {
> +               cur = container_of(llnode, struct vfree_work, node);
> +               __vunmap(cur->addr, 1);
> +               kfree(cur);
> +       }
>  }
>
>  /*** Page table manipulation functions ***/
> @@ -1494,6 +1504,48 @@ struct vm_struct *remove_vm_area(const void *addr)
>         return NULL;
>  }
>
> +/*
> + * This function handles unmapping and resetting the direct map as efficiently
> + * as it can with cross arch functions. The three categories of architectures
> + * are:
> + *   1. Architectures with no set_memory implementations and no direct map
> + *      permissions.
> + *   2. Architectures with set_memory implementations but no direct map
> + *      permissions
> + *   3. Architectures with set_memory implementations and direct map permissions
> + */
> +void __weak arch_vunmap(struct vm_struct *area, int deallocate_pages)

My general preference is to avoid __weak functions -- they don't
optimize well.  Instead, I prefer either:

#ifndef arch_vunmap
void arch_vunmap(...);
#endif

or

#ifdef CONFIG_HAVE_ARCH_VUNMAP
...
#endif


> +{
> +       unsigned long addr = (unsigned long)area->addr;
> +       int immediate = area->flags & VM_IMMEDIATE_UNMAP;
> +       int special = area->flags & VM_HAS_SPECIAL_PERMS;
> +
> +       /*
> +        * In case of 2 and 3, use this general way of resetting the permissions
> +        * on the directmap. Do NX before RW, in case of X, so there is no W^X
> +        * violation window.
> +        *
> +        * For case 1 these will be noops.
> +        */
> +       if (immediate)
> +               set_memory_nx(addr, area->nr_pages);
> +       if (deallocate_pages && special)
> +               set_memory_rw(addr, area->nr_pages);

Can you elaborate on the intent here?  VM_IMMEDIATE_UNMAP means "I
want that alias gone before any deallocation happens".
VM_HAS_SPECIAL_PERMS means "I mucked with the direct map -- fix it for
me, please".  deallocate means "this was vfree -- please free the
pages".  I'm not convinced that all the various combinations make
sense.  Do we really need both flags?

(VM_IMMEDIATE_UNMAP is a bit of a lie, since, if in_interrupt(), it's
not immediate.)

If we do keep both flags, maybe some restructuring would make sense,
like this, perhaps.  Sorry about horrible whitespace damage.

if (special) {
  /* VM_HAS_SPECIAL_PERMS makes little sense without deallocate_pages. */
  WARN_ON_ONCE(!deallocate_pages);

  if (immediate) {
    /* It's possible that the vmap alias is X and we're about to make
the direct map RW.  To avoid a window where executable memory is
writable, first mark the vmap alias NX.  This is silly, since we're
about to *unmap* it, but this is the best we can do if all we have to
work with is the set_memory_abc() APIs.  Architectures should override
this whole function to get better behavior. */
    set_memory_nx(...);
  }

  set_memory_rw(addr, area->nr_pages);
}


> +
> +       /* Always actually remove the area */
> +       remove_vm_area(area->addr);
> +
> +       /*
> +        * Need to flush the TLB before freeing pages in the case of this flag.
> +        * As long as that's happening, unmap aliases.
> +        *
> +        * For 2 and 3, this will not be needed because of the set_memory_nx
> +        * above, because the stale TLBs will be NX.

I'm not sure I agree with this comment.  If the caller asked for an
immediate unmap, we should give an immediate unmap.  But I'm still not
sure I see why VM_IMMEDIATE_UNMAP needs to exist as a separate flag.

> +        */
> +       if (immediate && !IS_ENABLED(ARCH_HAS_SET_MEMORY))
> +               vm_unmap_aliases();
> +}
> +
>  static void __vunmap(const void *addr, int deallocate_pages)
>  {
>         struct vm_struct *area;
> @@ -1515,7 +1567,8 @@ static void __vunmap(const void *addr, int deallocate_pages)
>         debug_check_no_locks_freed(area->addr, get_vm_area_size(area));
>         debug_check_no_obj_freed(area->addr, get_vm_area_size(area));
>
> -       remove_vm_area(addr);
> +       arch_vunmap(area, deallocate_pages);
> +
>         if (deallocate_pages) {
>                 int i;
>
> @@ -1542,8 +1595,15 @@ static inline void __vfree_deferred(const void *addr)
>          * nother cpu's list.  schedule_work() should be fine with this too.
>          */
>         struct vfree_deferred *p = raw_cpu_ptr(&vfree_deferred);
> +       struct vfree_work *w = kmalloc(sizeof(struct vfree_work), GFP_ATOMIC);
> +
> +       /* If no memory for the deferred list node, give up */
> +       if (!w)
> +               return;

That's nasty.  I see what you're trying to do here, but I think you're
solving a problem that doesn't need solving quite so urgently.  How
about dropping this part and replacing it with a comment like "NB:
this writes a word to a potentially executable address.  It would be
nice if we could avoid doing this."  And maybe a future patch could
more robustly avoid it without risking memory leaks.
