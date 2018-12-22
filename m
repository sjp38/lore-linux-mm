Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 85C288E0001
	for <linux-mm@kvack.org>; Sat, 22 Dec 2018 06:12:49 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id k4so7313366ioc.10
        for <linux-mm@kvack.org>; Sat, 22 Dec 2018 03:12:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i19sor18080ion.6.2018.12.22.03.12.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 22 Dec 2018 03:12:47 -0800 (PST)
MIME-Version: 1.0
References: <20181212000354.31955-1-rick.p.edgecombe@intel.com>
 <20181212000354.31955-2-rick.p.edgecombe@intel.com> <CALCETrVP577NvdeYj8bzpEfTXj3GZD3nFcJxnUq5n1daDBxU=g@mail.gmail.com>
 <CAKv+Gu_kunBqhUAQt6==SN-ei4Xc+z6=Z=pKXHHJYjk4Gdw73g@mail.gmail.com>
 <CALCETrWScgJpdnzNswJSKioQ93Oyw+Y_dJLoRxPX2Z=REVV1Ug@mail.gmail.com>
 <CAKv+Gu9cb-HJhZoJdQov0WHtbtuW1V0SUbm-Nm==YRSF4P+06g@mail.gmail.com> <cd2d6714cdd776e7f12d4e8752ef1682606ccde1.camel@intel.com>
In-Reply-To: <cd2d6714cdd776e7f12d4e8752ef1682606ccde1.camel@intel.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Sat, 22 Dec 2018 12:12:37 +0100
Message-ID: <CAKv+Gu8hW=6F1NtihjRhQuPjdA0xBJEvM7-YZoVHsjSFC2QHPw@mail.gmail.com>
Subject: Re: [PATCH v2 1/4] vmalloc: New flags for safe vfree on special perms
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Cc: "luto@kernel.org" <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "jeyu@kernel.org" <jeyu@kernel.org>, "rostedt@goodmis.org" <rostedt@goodmis.org>, "ast@kernel.org" <ast@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jannh@google.com" <jannh@google.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "will.deacon@arm.com" <will.deacon@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "namit@vmware.com" <namit@vmware.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Keshavamurthy, Anil S" <anil.s.keshavamurthy@intel.com>, "mhiramat@kernel.org" <mhiramat@kernel.org>, "naveen.n.rao@linux.vnet.ibm.com" <naveen.n.rao@linux.vnet.ibm.com>, "davem@davemloft.net" <davem@davemloft.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>

On Fri, 21 Dec 2018 at 20:57, Edgecombe, Rick P
<rick.p.edgecombe@intel.com> wrote:
>
> On Fri, 2018-12-21 at 18:25 +0100, Ard Biesheuvel wrote:
> > On Fri, 21 Dec 2018 at 18:12, Andy Lutomirski <luto@kernel.org>
> > wrote:
> > > > On Dec 21, 2018, at 9:39 AM, Ard Biesheuvel <
> > > > ard.biesheuvel@linaro.org> wrote:
> > > >
> > > > > On Wed, 12 Dec 2018 at 03:20, Andy Lutomirski <luto@kernel.org>
> > > > > wrote:
> > > > >
> > > > > On Tue, Dec 11, 2018 at 4:12 PM Rick Edgecombe
> > > > > <rick.p.edgecombe@intel.com> wrote:
> > > > > > This adds two new flags VM_IMMEDIATE_UNMAP and
> > > > > > VM_HAS_SPECIAL_PERMS, for
> > > > > > enabling vfree operations to immediately clear executable TLB
> > > > > > entries to freed
> > > > > > pages, and handle freeing memory with special permissions.
> > > > > >
> > > > > > In order to support vfree being called on memory that might
> > > > > > be RO, the vfree
> > > > > > deferred list node is moved to a kmalloc allocated struct,
> > > > > > from where it is
> > > > > > today, reusing the allocation being freed.
> > > > > >
> > > > > > arch_vunmap is a new __weak function that implements the
> > > > > > actual unmapping and
> > > > > > resetting of the direct map permissions. It can be overridden
> > > > > > by more efficient
> > > > > > architecture specific implementations.
> > > > > >
> > > > > > For the default implementation, it uses architecture agnostic
> > > > > > methods which are
> > > > > > equivalent to what most usages do before calling vfree. So
> > > > > > now it is just
> > > > > > centralized here.
> > > > > >
> > > > > > This implementation derives from two sketches from Dave
> > > > > > Hansen and Andy
> > > > > > Lutomirski.
> > > > > >
> > > > > > Suggested-by: Dave Hansen <dave.hansen@intel.com>
> > > > > > Suggested-by: Andy Lutomirski <luto@kernel.org>
> > > > > > Suggested-by: Will Deacon <will.deacon@arm.com>
> > > > > > Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
> > > > > > ---
> > > > > > include/linux/vmalloc.h |  2 ++
> > > > > > mm/vmalloc.c            | 73
> > > > > > +++++++++++++++++++++++++++++++++++++----
> > > > > > 2 files changed, 69 insertions(+), 6 deletions(-)
> > > > > >
> > > > > > diff --git a/include/linux/vmalloc.h
> > > > > > b/include/linux/vmalloc.h
> > > > > > index 398e9c95cd61..872bcde17aca 100644
> > > > > > --- a/include/linux/vmalloc.h
> > > > > > +++ b/include/linux/vmalloc.h
> > > > > > @@ -21,6 +21,8 @@ struct notifier_block;                /* in
> > > > > > notifier.h */
> > > > > > #define VM_UNINITIALIZED       0x00000020      /* vm_struct
> > > > > > is not fully initialized */
> > > > > > #define VM_NO_GUARD            0x00000040      /* don't add
> > > > > > guard page */
> > > > > > #define VM_KASAN               0x00000080      /* has
> > > > > > allocated kasan shadow memory */
> > > > > > +#define VM_IMMEDIATE_UNMAP     0x00000200      /* flush
> > > > > > before releasing pages */
> > > > > > +#define VM_HAS_SPECIAL_PERMS   0x00000400      /* may be
> > > > > > freed with special perms */
> > > > > > /* bits [20..32] reserved for arch specific ioremap internals
> > > > > > */
> > > > > >
> > > > > > /*
> > > > > > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > > > > > index 97d4b25d0373..02b284d2245a 100644
> > > > > > --- a/mm/vmalloc.c
> > > > > > +++ b/mm/vmalloc.c
> > > > > > @@ -18,6 +18,7 @@
> > > > > > #include <linux/interrupt.h>
> > > > > > #include <linux/proc_fs.h>
> > > > > > #include <linux/seq_file.h>
> > > > > > +#include <linux/set_memory.h>
> > > > > > #include <linux/debugobjects.h>
> > > > > > #include <linux/kallsyms.h>
> > > > > > #include <linux/list.h>
> > > > > > @@ -38,6 +39,11 @@
> > > > > >
> > > > > > #include "internal.h"
> > > > > >
> > > > > > +struct vfree_work {
> > > > > > +       struct llist_node node;
> > > > > > +       void *addr;
> > > > > > +};
> > > > > > +
> > > > > > struct vfree_deferred {
> > > > > >        struct llist_head list;
> > > > > >        struct work_struct wq;
> > > > > > @@ -50,9 +56,13 @@ static void free_work(struct work_struct
> > > > > > *w)
> > > > > > {
> > > > > >        struct vfree_deferred *p =3D container_of(w, struct
> > > > > > vfree_deferred, wq);
> > > > > >        struct llist_node *t, *llnode;
> > > > > > +       struct vfree_work *cur;
> > > > > >
> > > > > > -       llist_for_each_safe(llnode, t, llist_del_all(&p-
> > > > > > >list))
> > > > > > -               __vunmap((void *)llnode, 1);
> > > > > > +       llist_for_each_safe(llnode, t, llist_del_all(&p-
> > > > > > >list)) {
> > > > > > +               cur =3D container_of(llnode, struct vfree_work,
> > > > > > node);
> > > > > > +               __vunmap(cur->addr, 1);
> > > > > > +               kfree(cur);
> > > > > > +       }
> > > > > > }
> > > > > >
> > > > > > /*** Page table manipulation functions ***/
> > > > > > @@ -1494,6 +1504,48 @@ struct vm_struct *remove_vm_area(const
> > > > > > void *addr)
> > > > > >        return NULL;
> > > > > > }
> > > > > >
> > > > > > +/*
> > > > > > + * This function handles unmapping and resetting the direct
> > > > > > map as efficiently
> > > > > > + * as it can with cross arch functions. The three categories
> > > > > > of architectures
> > > > > > + * are:
> > > > > > + *   1. Architectures with no set_memory implementations and
> > > > > > no direct map
> > > > > > + *      permissions.
> > > > > > + *   2. Architectures with set_memory implementations but no
> > > > > > direct map
> > > > > > + *      permissions
> > > > > > + *   3. Architectures with set_memory implementations and
> > > > > > direct map permissions
> > > > > > + */
> > > > > > +void __weak arch_vunmap(struct vm_struct *area, int
> > > > > > deallocate_pages)
> > > > >
> > > > > My general preference is to avoid __weak functions -- they
> > > > > don't
> > > > > optimize well.  Instead, I prefer either:
> > > > >
> > > > > #ifndef arch_vunmap
> > > > > void arch_vunmap(...);
> > > > > #endif
> > > > >
> > > > > or
> > > > >
> > > > > #ifdef CONFIG_HAVE_ARCH_VUNMAP
> > > > > ...
> > > > > #endif
> > > > >
> > > > >
> > > > > > +{
> > > > > > +       unsigned long addr =3D (unsigned long)area->addr;
> > > > > > +       int immediate =3D area->flags & VM_IMMEDIATE_UNMAP;
> > > > > > +       int special =3D area->flags & VM_HAS_SPECIAL_PERMS;
> > > > > > +
> > > > > > +       /*
> > > > > > +        * In case of 2 and 3, use this general way of
> > > > > > resetting the permissions
> > > > > > +        * on the directmap. Do NX before RW, in case of X,
> > > > > > so there is no W^X
> > > > > > +        * violation window.
> > > > > > +        *
> > > > > > +        * For case 1 these will be noops.
> > > > > > +        */
> > > > > > +       if (immediate)
> > > > > > +               set_memory_nx(addr, area->nr_pages);
> > > > > > +       if (deallocate_pages && special)
> > > > > > +               set_memory_rw(addr, area->nr_pages);
> > > > >
> > > > > Can you elaborate on the intent here?  VM_IMMEDIATE_UNMAP means
> > > > > "I
> > > > > want that alias gone before any deallocation happens".
> > > > > VM_HAS_SPECIAL_PERMS means "I mucked with the direct map -- fix
> > > > > it for
> > > > > me, please".  deallocate means "this was vfree -- please free
> > > > > the
> > > > > pages".  I'm not convinced that all the various combinations
> > > > > make
> > > > > sense.  Do we really need both flags?
> > > > >
> > > > > (VM_IMMEDIATE_UNMAP is a bit of a lie, since, if
> > > > > in_interrupt(), it's
> > > > > not immediate.)
> > > > >
> > > > > If we do keep both flags, maybe some restructuring would make
> > > > > sense,
> > > > > like this, perhaps.  Sorry about horrible whitespace damage.
> > > > >
> > > > > if (special) {
> > > > >  /* VM_HAS_SPECIAL_PERMS makes little sense without
> > > > > deallocate_pages. */
> > > > >  WARN_ON_ONCE(!deallocate_pages);
> > > > >
> > > > >  if (immediate) {
> > > > >    /* It's possible that the vmap alias is X and we're about to
> > > > > make
> > > > > the direct map RW.  To avoid a window where executable memory
> > > > > is
> > > > > writable, first mark the vmap alias NX.  This is silly, since
> > > > > we're
> > > > > about to *unmap* it, but this is the best we can do if all we
> > > > > have to
> > > > > work with is the set_memory_abc() APIs.  Architectures should
> > > > > override
> > > > > this whole function to get better behavior. */
> > > >
> > > > So can't we fix this first? Assuming that architectures that
> > > > bother to
> > > > implement them will not have executable mappings in the linear
> > > > region,
> > > > all we'd need is set_linear_range_ro/rw() routines that default
> > > > to
> > > > doing nothing, and encapsulate the existing code for x86 and
> > > > arm64.
> > > > That way, we can handle do things in the proper order, i.e.,
> > > > release
> > > > the vmalloc mapping (without caring about the permissions),
> > > > restore
> > > > the linear alias attributes, and finally release the pages.
> > >
> > > Seems reasonable, except that I think it should be
> > > set_linear_range_not_present() and set_linear_range_rw(), for three
> > > reasons:
> > >
> > > 1. It=E2=80=99s not at all clear to me that we need to keep the linea=
r
> > > mapping
> > > around for modules.
> > >
> >
> > I'm pretty sure hibernate on arm64 will have to be fixed, since it
> > expects to be able to read all valid pages via the linear map. But we
> > can fix that.
> Hmm, now I wonder what else might be trying to access the entire direct
> map for some reason. Since the window of not present is so small,
> issues could lurk for some time. I guess that should show up with XPFO
> too though.
>

I don't think there is usually a need to scan the entire address space
like that, unless you are trying to preserve the contents and write
them to disk, like in the hibernate case.

However, IIUC, hibernate on arm64 can already deal with
debug_pagealloc, which relies on clearing the access flag as well, so
if we stick with that we should be ok, I guess.

> > > 2. At least on x86, the obvious algorithm to do the free operation
> > > with a single flush requires it.  Someone should probably confirm
> > > that
> > > arm=E2=80=99s TLB works the same way, i.e. that no flush is needed wh=
en
> > > changing from not-present (or whatever ARM calls it) to RW.
> > >
> >
> > Good point. ARM is similar in this regard, although we'll probably
> > clear the access flag rather than unmap the page entirely (which is
> > treated the same way in terms of required TLB management)
> How about set_alias_nv(not valid)/set_alias_default for the name? It
> can cover the general behavior of not cacheable in the TLB.
>

Works for me

> Also, FYI for anyone that is following this - Nadav and I have
> discussed merging this with the text poke patchset because of the
> overlap. With the US holidays, I may not get this done and tested until
> first week of January. I'll go back and make the efficient direct map
> permissions part arch generic now too.
>

Excellent!

> > > 3. Anyone playing with XPFO wants this facility anyway.  In fact,
> > > with
> > > this change, Rick=E2=80=99s series will more or less implement XPFO f=
or
> > > vmalloc memory :)
> > >
> > > Does that seem reasonable to you?
> >
> > Absolutely.
