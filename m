Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id AADC38E0033
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 20:02:42 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id a2so12172383pgt.11
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 17:02:42 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p26si550610pfj.244.2018.12.17.17.02.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 17:02:40 -0800 (PST)
Received: from mail-wm1-f49.google.com (mail-wm1-f49.google.com [209.85.128.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B5DB72184E
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 01:02:39 +0000 (UTC)
Received: by mail-wm1-f49.google.com with SMTP id f81so1021730wmd.4
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 17:02:39 -0800 (PST)
MIME-Version: 1.0
References: <20181212000354.31955-1-rick.p.edgecombe@intel.com>
 <20181212000354.31955-2-rick.p.edgecombe@intel.com> <CALCETrVP577NvdeYj8bzpEfTXj3GZD3nFcJxnUq5n1daDBxU=g@mail.gmail.com>
 <f5cbf6aefeb19f12faafa6f213c6ff72bf693ddc.camel@intel.com>
 <CALCETrV0BGagp8stapCPBQ9iWOeepGkcKybzmi2WwLU_zzy2sQ@mail.gmail.com>
 <096da253543acc3d1aa23df22db5ce0acfc0c961.camel@intel.com>
 <CALCETrW+5JZOQDnJ6HYkDRvMHiz+cY5HAn06SrxCxmk2XzoyDQ@mail.gmail.com> <0b9818bbc334a03df0c9d2abce26f032d3b4796e.camel@intel.com>
In-Reply-To: <0b9818bbc334a03df0c9d2abce26f032d3b4796e.camel@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 17 Dec 2018 17:02:26 -0800
Message-ID: <CALCETrWirPd3ESYpmsibPm66e9-UXdR7W5hQWx9XJDvqz-tnqA@mail.gmail.com>
Subject: Re: [PATCH v2 1/4] vmalloc: New flags for safe vfree on special perms
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Cc: "luto@kernel.org" <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "jeyu@kernel.org" <jeyu@kernel.org>, "rostedt@goodmis.org" <rostedt@goodmis.org>, "ast@kernel.org" <ast@kernel.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jannh@google.com" <jannh@google.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "will.deacon@arm.com" <will.deacon@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "namit@vmware.com" <namit@vmware.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Keshavamurthy, Anil S" <anil.s.keshavamurthy@intel.com>, "mhiramat@kernel.org" <mhiramat@kernel.org>, "naveen.n.rao@linux.vnet.ibm.com" <naveen.n.rao@linux.vnet.ibm.com>, "davem@davemloft.net" <davem@davemloft.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>

On Mon, Dec 17, 2018 at 4:24 PM Edgecombe, Rick P
<rick.p.edgecombe@intel.com> wrote:
>
> On Sat, 2018-12-15 at 10:52 -0800, Andy Lutomirski wrote:
> > On Wed, Dec 12, 2018 at 2:01 PM Edgecombe, Rick P
> > <rick.p.edgecombe@intel.com> wrote:
> > >
> > > On Wed, 2018-12-12 at 11:57 -0800, Andy Lutomirski wrote:
> > > > On Wed, Dec 12, 2018 at 11:50 AM Edgecombe, Rick P
> > > > <rick.p.edgecombe@intel.com> wrote:
> > > > >
> > > > > On Tue, 2018-12-11 at 18:20 -0800, Andy Lutomirski wrote:
> > > > > > On Tue, Dec 11, 2018 at 4:12 PM Rick Edgecombe
> > > > > > <rick.p.edgecombe@intel.com> wrote:
> > > > > > >
> > > > > > > This adds two new flags VM_IMMEDIATE_UNMAP and VM_HAS_SPECIAL_PERMS,
> > > > > > > for
> > > > > > > enabling vfree operations to immediately clear executable TLB
> > > > > > > entries to
> > > > > > > freed
> > > > > > > pages, and handle freeing memory with special permissions.
> > > > > > >
> > > > > > > In order to support vfree being called on memory that might be RO,
> > > > > > > the
> > > > > > > vfree
> > > > > > > deferred list node is moved to a kmalloc allocated struct, from
> > > > > > > where it
> > > > > > > is
> > > > > > > today, reusing the allocation being freed.
> > > > > > >
> > > > > > > arch_vunmap is a new __weak function that implements the actual
> > > > > > > unmapping
> > > > > > > and
> > > > > > > resetting of the direct map permissions. It can be overridden by
> > > > > > > more
> > > > > > > efficient
> > > > > > > architecture specific implementations.
> > > > > > >
> > > > > > > For the default implementation, it uses architecture agnostic
> > > > > > > methods
> > > > > > > which
> > > > > > > are
> > > > > > > equivalent to what most usages do before calling vfree. So now it is
> > > > > > > just
> > > > > > > centralized here.
> > > > > > >
> > > > > > > This implementation derives from two sketches from Dave Hansen and
> > > > > > > Andy
> > > > > > > Lutomirski.
> > > > > > >
> > > > > > > Suggested-by: Dave Hansen <dave.hansen@intel.com>
> > > > > > > Suggested-by: Andy Lutomirski <luto@kernel.org>
> > > > > > > Suggested-by: Will Deacon <will.deacon@arm.com>
> > > > > > > Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
> > > > > > > ---
> > > > > > >  include/linux/vmalloc.h |  2 ++
> > > > > > >  mm/vmalloc.c            | 73 +++++++++++++++++++++++++++++++++++++-
> > > > > > > ---
> > > > > > >  2 files changed, 69 insertions(+), 6 deletions(-)
> > > > > > >
> > > > > > > diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> > > > > > > index 398e9c95cd61..872bcde17aca 100644
> > > > > > > --- a/include/linux/vmalloc.h
> > > > > > > +++ b/include/linux/vmalloc.h
> > > > > > > @@ -21,6 +21,8 @@ struct notifier_block;                /* in
> > > > > > > notifier.h
> > > > > > > */
> > > > > > >  #define VM_UNINITIALIZED       0x00000020      /* vm_struct is not
> > > > > > > fully
> > > > > > > initialized */
> > > > > > >  #define VM_NO_GUARD            0x00000040      /* don't add guard
> > > > > > > page
> > > > > > > */
> > > > > > >  #define VM_KASAN               0x00000080      /* has allocated
> > > > > > > kasan
> > > > > > > shadow memory */
> > > > > > > +#define VM_IMMEDIATE_UNMAP     0x00000200      /* flush before
> > > > > > > releasing
> > > > > > > pages */
> > > > > > > +#define VM_HAS_SPECIAL_PERMS   0x00000400      /* may be freed with
> > > > > > > special
> > > > > > > perms */
> > > > > > >  /* bits [20..32] reserved for arch specific ioremap internals */
> > > > > > >
> > > > > > >  /*
> > > > > > > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > > > > > > index 97d4b25d0373..02b284d2245a 100644
> > > > > > > --- a/mm/vmalloc.c
> > > > > > > +++ b/mm/vmalloc.c
> > > > > > > @@ -18,6 +18,7 @@
> > > > > > >  #include <linux/interrupt.h>
> > > > > > >  #include <linux/proc_fs.h>
> > > > > > >  #include <linux/seq_file.h>
> > > > > > > +#include <linux/set_memory.h>
> > > > > > >  #include <linux/debugobjects.h>
> > > > > > >  #include <linux/kallsyms.h>
> > > > > > >  #include <linux/list.h>
> > > > > > > @@ -38,6 +39,11 @@
> > > > > > >
> > > > > > >  #include "internal.h"
> > > > > > >
> > > > > > > +struct vfree_work {
> > > > > > > +       struct llist_node node;
> > > > > > > +       void *addr;
> > > > > > > +};
> > > > > > > +
> > > > > > >  struct vfree_deferred {
> > > > > > >         struct llist_head list;
> > > > > > >         struct work_struct wq;
> > > > > > > @@ -50,9 +56,13 @@ static void free_work(struct work_struct *w)
> > > > > > >  {
> > > > > > >         struct vfree_deferred *p = container_of(w, struct
> > > > > > > vfree_deferred,
> > > > > > > wq);
> > > > > > >         struct llist_node *t, *llnode;
> > > > > > > +       struct vfree_work *cur;
> > > > > > >
> > > > > > > -       llist_for_each_safe(llnode, t, llist_del_all(&p->list))
> > > > > > > -               __vunmap((void *)llnode, 1);
> > > > > > > +       llist_for_each_safe(llnode, t, llist_del_all(&p->list)) {
> > > > > > > +               cur = container_of(llnode, struct vfree_work, node);
> > > > > > > +               __vunmap(cur->addr, 1);
> > > > > > > +               kfree(cur);
> > > > > > > +       }
> > > > > > >  }
> > > > > > >
> > > > > > >  /*** Page table manipulation functions ***/
> > > > > > > @@ -1494,6 +1504,48 @@ struct vm_struct *remove_vm_area(const void
> > > > > > > *addr)
> > > > > > >         return NULL;
> > > > > > >  }
> > > > > > >
> > > > > > > +/*
> > > > > > > + * This function handles unmapping and resetting the direct map as
> > > > > > > efficiently
> > > > > > > + * as it can with cross arch functions. The three categories of
> > > > > > > architectures
> > > > > > > + * are:
> > > > > > > + *   1. Architectures with no set_memory implementations and no
> > > > > > > direct
> > > > > > > map
> > > > > > > + *      permissions.
> > > > > > > + *   2. Architectures with set_memory implementations but no direct
> > > > > > > map
> > > > > > > + *      permissions
> > > > > > > + *   3. Architectures with set_memory implementations and direct
> > > > > > > map
> > > > > > > permissions
> > > > > > > + */
> > > > > > > +void __weak arch_vunmap(struct vm_struct *area, int
> > > > > > > deallocate_pages)
> > > > > >
> > > > > > My general preference is to avoid __weak functions -- they don't
> > > > > > optimize well.  Instead, I prefer either:
> > > > > >
> > > > > > #ifndef arch_vunmap
> > > > > > void arch_vunmap(...);
> > > > > > #endif
> > > > > >
> > > > > > or
> > > > > >
> > > > > > #ifdef CONFIG_HAVE_ARCH_VUNMAP
> > > > > > ...
> > > > > > #endif
> > > > >
> > > > > Ok.
> > > > > >
> > > > > > > +{
> > > > > > > +       unsigned long addr = (unsigned long)area->addr;
> > > > > > > +       int immediate = area->flags & VM_IMMEDIATE_UNMAP;
> > > > > > > +       int special = area->flags & VM_HAS_SPECIAL_PERMS;
> > > > > > > +
> > > > > > > +       /*
> > > > > > > +        * In case of 2 and 3, use this general way of resetting the
> > > > > > > permissions
> > > > > > > +        * on the directmap. Do NX before RW, in case of X, so there
> > > > > > > is
> > > > > > > no
> > > > > > > W^X
> > > > > > > +        * violation window.
> > > > > > > +        *
> > > > > > > +        * For case 1 these will be noops.
> > > > > > > +        */
> > > > > > > +       if (immediate)
> > > > > > > +               set_memory_nx(addr, area->nr_pages);
> > > > > > > +       if (deallocate_pages && special)
> > > > > > > +               set_memory_rw(addr, area->nr_pages);
> > > > > >
> > > > > > Can you elaborate on the intent here?  VM_IMMEDIATE_UNMAP means "I
> > > > > > want that alias gone before any deallocation happens".
> > > > > > VM_HAS_SPECIAL_PERMS means "I mucked with the direct map -- fix it for
> > > > > > me, please".  deallocate means "this was vfree -- please free the
> > > > > > pages".  I'm not convinced that all the various combinations make
> > > > > > sense.  Do we really need both flags?
> > > > >
> > > > > VM_HAS_SPECIAL_PERMS is supposed to mean, like you said, "reset the
> > > > > direct
> > > > > map".
> > > > > Where VM_IMMEDIATE_UNMAP means, the vmalloc allocation has extra
> > > > > capabilties
> > > > > where we don't want to leave an enhanced capability TLB entry to the
> > > > > freed
> > > > > page.
> > > > >
> > > > > I was trying to pick names that could apply more generally for potential
> > > > > future
> > > > > special memory capabilities. Today VM_HAS_SPECIAL_PERMS does just mean
> > > > > reset
> > > > > write to the directmap and VM_IMMEDIATE_UNMAP means vmalloc mapping is
> > > > > executable.
> > > > >
> > > > > A present day reason for keeping both flags is, it is more efficient in
> > > > > the
> > > > > arch-agnostic implementation when freeing memory that is just RO and not
> > > > > executable. It saves a TLB flush.
> > > > >
> > > > > > (VM_IMMEDIATE_UNMAP is a bit of a lie, since, if in_interrupt(), it's
> > > > > > not immediate.)
> > > > >
> > > > > True, maybe VM_MUST_FLUSH or something else?
> > > > >
> > > > > > If we do keep both flags, maybe some restructuring would make sense,
> > > > > > like this, perhaps.  Sorry about horrible whitespace damage.
> > > > > >
> > > > > > if (special) {
> > > > > >   /* VM_HAS_SPECIAL_PERMS makes little sense without deallocate_pages.
> > > > > > */
> > > > > >   WARN_ON_ONCE(!deallocate_pages);
> > > > > >
> > > > > >   if (immediate) {
> > > > > >     /* It's possible that the vmap alias is X and we're about to make
> > > > > > the direct map RW.  To avoid a window where executable memory is
> > > > > > writable, first mark the vmap alias NX.  This is silly, since we're
> > > > > > about to *unmap* it, but this is the best we can do if all we have to
> > > > > > work with is the set_memory_abc() APIs.  Architectures should override
> > > > > > this whole function to get better behavior. */
> > > > > >     set_memory_nx(...);
> > > > > >   }
> > > > > >
> > > > > >   set_memory_rw(addr, area->nr_pages);
> > > > > > }
> > > > >
> > > > > Ok.
> > > > >
> > > > > >
> > > > > > > +
> > > > > > > +       /* Always actually remove the area */
> > > > > > > +       remove_vm_area(area->addr);
> > > > > > > +
> > > > > > > +       /*
> > > > > > > +        * Need to flush the TLB before freeing pages in the case of
> > > > > > > this
> > > > > > > flag.
> > > > > > > +        * As long as that's happening, unmap aliases.
> > > > > > > +        *
> > > > > > > +        * For 2 and 3, this will not be needed because of the
> > > > > > > set_memory_nx
> > > > > > > +        * above, because the stale TLBs will be NX.
> > > > > >
> > > > > > I'm not sure I agree with this comment.  If the caller asked for an
> > > > > > immediate unmap, we should give an immediate unmap.  But I'm still not
> > > > > > sure I see why VM_IMMEDIATE_UNMAP needs to exist as a separate flag.
> > > > >
> > > > > Yea. I was just trying to save a TLB flush, since for today's callers
> > > > > that
> > > > > have
> > > > > set_memory there isn't a security downside I know of to just leaving it
> > > > > NX.
> > > > > Maybe its not worth the tradeoff of confusion? Or I can clarify that in
> > > > > the
> > > > > comment.
> > > >
> > > > Don't both of the users in your series set both flags, though?  My
> > > > real objection to having them be separate is that, in the absence of
> > > > users, it's less clear exactly what they should do and the code
> > > > doesn't get exercised.
> > >
> > > The only "just RO" user today is one of the BPF allocations. I don't have a
> > > strong objection to combining them, just explaining the thinking. I guess if
> > > we
> > > could always add another flag later if it becomes more needed.
> > >
> > > > If you document that VM_IMMEDIATE_UNMAP means "I want the TLB entries
> > > > gone", then I can re-review the code in light of that.  But then I'm
> > > > unconvinced by your generic implementation, since set_memory_nx()
> > > > seems like an odd way to go about it.
> > >
> > > Masami Hiramatsu pointed out if we don't do set_memory_nx before
> > > set_memory_rw,
> > > then there will be a small window of W^X violation. So that was the concern
> > > for
> > > the executable case, regardless of the semantics. I think the concern
> > > applies
> > > for any "special capability" permissions. Alternatively, if we
> > > remove_vm_area
> > > before we reset the direct map perms RW, maybe that would accomplish the
> > > same
> > > thing, if that's possible in a cross arch way. Maybe this is too much
> > > designing
> > > for hypothetical future... just was trying to avoid having to change the
> > > interface, and could just update the generic implementation if new
> > > permissions
> > > or usages come up.
> > >
> > > The set_memory_ stuff is really only needed for arm64 which seems to be the
> > > only
> > > other one with directmap permissions. So if it could eventually have its own
> > > arch_vunmap then all of the set_memory_ parts could be dropped and the
> > > default
> > > would just be the simple unmap then flush logic that it was originally.
> >
> > I think that's probably the best solution.  If there are only two
> > arches that have anything fancy here, let's just fix both of them up
> > for real.
> >
> > >
> > > Or we have up to three flushes for the generic version and meet the name
> > > expectations and needed functionality today. I guess I'll just try that.
> > > > >
> > > > > > > +        */
> > > > > > > +       if (immediate && !IS_ENABLED(ARCH_HAS_SET_MEMORY))
> > > > > > > +               vm_unmap_aliases();
> > > > > > > +}
> > > > > > > +
> > > > > > >  static void __vunmap(const void *addr, int deallocate_pages)
> > > > > > >  {
> > > > > > >         struct vm_struct *area;
> > > > > > > @@ -1515,7 +1567,8 @@ static void __vunmap(const void *addr, int
> > > > > > > deallocate_pages)
> > > > > > >         debug_check_no_locks_freed(area->addr,
> > > > > > > get_vm_area_size(area));
> > > > > > >         debug_check_no_obj_freed(area->addr,
> > > > > > > get_vm_area_size(area));
> > > > > > >
> > > > > > > -       remove_vm_area(addr);
> > > > > > > +       arch_vunmap(area, deallocate_pages);
> > > > > > > +
> > > > > > >         if (deallocate_pages) {
> > > > > > >                 int i;
> > > > > > >
> > > > > > > @@ -1542,8 +1595,15 @@ static inline void __vfree_deferred(const
> > > > > > > void
> > > > > > > *addr)
> > > > > > >          * nother cpu's list.  schedule_work() should be fine with
> > > > > > > this
> > > > > > > too.
> > > > > > >          */
> > > > > > >         struct vfree_deferred *p = raw_cpu_ptr(&vfree_deferred);
> > > > > > > +       struct vfree_work *w = kmalloc(sizeof(struct vfree_work),
> > > > > > > GFP_ATOMIC);
> > > > > > > +
> > > > > > > +       /* If no memory for the deferred list node, give up */
> > > > > > > +       if (!w)
> > > > > > > +               return;
> > > > > >
> > > > > > That's nasty.  I see what you're trying to do here, but I think you're
> > > > > > solving a problem that doesn't need solving quite so urgently.  How
> > > > > > about dropping this part and replacing it with a comment like "NB:
> > > > > > this writes a word to a potentially executable address.  It would be
> > > > > > nice if we could avoid doing this."  And maybe a future patch could
> > > > > > more robustly avoid it without risking memory leaks.
> > > > >
> > > > > Yea, sorry I should have called this out, because I wasn't sure on how
> > > > > likely
> > > > > that was to happen. I did find some other places in the kernel with the
> > > > > same
> > > > > ignoring logic.
> > > > >
> > > > > I'll have to think though, I am not sure what the alternative is. Since
> > > > > the
> > > > > memory can be RO in the module_memfree case, the old method of re-using
> > > > > the
> > > > > allocation will no longer work. The list node could be stuffed on the
> > > > > vm_struct,
> > > > > but then the all of the spin_lock(&vmap_area_lock)'s need to be changed
> > > > > to
> > > > > work
> > > > > with interrupts so that the struct could be looked up. Not sure of the
> > > > > implications of that. Or maybe have some slow backup that resets the
> > > > > permissions
> > > > > and re-uses the allocation if kmalloc fails?
> > > > >
> > > > > I guess it could also go back to the old v1 implementation that doesn't
> > > > > handle
> > > > > RO and the directmap, and leave the W^X violation window during
> > > > > teardown.
> > > > > Then
> > > > > solve that problem when modules are loaded via something like Nadav's
> > > > > stuff.
> > > > >
> > > >
> > > > Hmm.  Switching to spin_lock_irqsave() doesn't seem so bad to me.
> > >
> > > Ok.
> >
> > Actually, I think I have a better solution.  Just declare the
> > problematic case to be illegal: say that you may not free memory with
> > the new flags set while IRQs are off.  Enforce this with a VM_WARN_ON
> > in the code that reads the vfree_deferred list.
>
> Thanks. Yea just making a rule for the one case seems better that disabling
> interrupts all over. It turned out to lock in quite a few places, including the
> longish lazy purge operation. Reading a little history on the deferred free list
> - 6 years ago vfree used to not support interrupts at all, and different clients
> had their own work queues. So this will just be having the original situation
> for the new vm flag.
>
> I think we only need to move the module init section free from the RCU callback
> to a work queue, to get to the point where, functionally wise, everything should
> work with the existing deferred free list implementation (since then we will
> just not use it for the new special memory case).

> We could also just add a
> WARN_ON(in_interrupt()) in module_memfree to give context to some callers to
> what will soon be a "BUG: unable to handle kernel paging request". Any objection
> to leaving it there?
>

Seems reasonable.

> Over the above, moving the vfree_deferred list to the struct and the associated
> cost of the lookup in every interrupt/atomic vfree would enable a WARN and the
> handling of a (declared) illegal case that could deadlock anyway, right? Is it
> worth it?

I suspect it's not worth it.

>
> I'm not sure we why we wouldn't have deadlocks in normal interrupt vfrees if we
> don't use irq spinlocks everywhere...I may be missing your insight.
>

I may be misunderstanding your question, but: I suspect that we can
easily deadlock if vfree() is called with IRQs off but
!in_interrupt().  Perhaps no one does that?  At the very least, I
assume that lockdep would scream loudly if this happened.

--Andy
