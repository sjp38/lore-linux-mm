Return-Path: <SRS0=s2+Z=O6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4345EC43612
	for <linux-mm@archiver.kernel.org>; Fri, 21 Dec 2018 16:39:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB1FD21916
	for <linux-mm@archiver.kernel.org>; Fri, 21 Dec 2018 16:39:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linaro.org header.i=@linaro.org header.b="NVRBfNmy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB1FD21916
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3789B8E0002; Fri, 21 Dec 2018 11:39:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 326438E0001; Fri, 21 Dec 2018 11:39:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EEE08E0002; Fri, 21 Dec 2018 11:39:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id ECA7E8E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 11:39:34 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id g7so5585973itg.7
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 08:39:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=XraM5WUeK23rXa1xoKBrqeBBCshgPfte+/8YLIj79Q8=;
        b=BgtSIuYjPtoQM1r0WTCyR2fNcoxl9/awXy6fMp5Cd7FHjYNh1zDdrF+knhaKLk6cso
         1UPT/FSUFT/U1EQJKH9VcSWUkwq3dh32rKdwoDyuPGft8arj3pdedlTKPNOoVIS2YRnN
         edgd6C6CkKznwypv02C/WdRwB8XqdwXtAjXCfkHL74OItJBLQa/74iVqFnAUXoCLATac
         E2WTp8B3Te7DBZHdvxacrHBL5kXenjlqpSKUumGgcjfheSYn6tVhGqX22yyyvDvBGj1d
         hQzD1qSeAGwBOCUOGU62WBEqO6LW5DAoyRCgsnJQ+sDFXEvolpxd9oKHJDhZmO1wtgWD
         PDLg==
X-Gm-Message-State: AA+aEWbMUyrEfwjI3gxtodLt4NgcY5hm1MjT1zTBYi8FJz3nBwl78ElQ
	bxvPs9IRqhaKhQktWSyGtTSL96SKEU1pZVlox24+OVKpzHGkGdSapHI1jJs3aUJGDDgTuAvTlI8
	IuEuCbqw+OA8jHuw4oyVT5xjy36jyu6bUEqfCgywiILdx8CmqnxHFFuoiWd9DGUxkfl4GX0Nf07
	HQ3LTRk4xJgpgpVp3r1U8JEPJFVGNYytxIl4BKk9BgFHNIcjGGCaYfeVU5VqED1KCww1ZyNFeKy
	xLwu5QvmMajVccyKIWkI7WWgZLvuttCSOdwQDfOhdpf/Aakfh/VtzhLSWOz5ghd6kWzfPRHrKc4
	QjsHbw+ZIKMXSK6d0je3YvX8qe2QZ1a6wz3ABw98DTDGv3jwQRE6oa9Sz9lzmesojpKOKByO8+s
	a
X-Received: by 2002:a24:fa04:: with SMTP id v4mr2118636ith.175.1545410374576;
        Fri, 21 Dec 2018 08:39:34 -0800 (PST)
X-Received: by 2002:a24:fa04:: with SMTP id v4mr2118593ith.175.1545410373279;
        Fri, 21 Dec 2018 08:39:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545410373; cv=none;
        d=google.com; s=arc-20160816;
        b=ykm8LxSs7BSQrCxFIXhmT8O3YXw8g0SvVy25I5hV8nh7m2Tztili2xRNj8pUQVLTgO
         M9KF8XEMd4Tv5gD4/OUovG7MUXBcp7oCB32ZpEliDstWd2lYiayweLBLmvUp1fveGGxj
         mh3UUSloz6drxA4Dxy1Gczah3/cdvZIDMXcTHRoX13ctrMhASU3Tjq/u3O0NaoRSEIOq
         QnTS4mxJBi0l60ADSqYtkvgVp7g0U4+OHdBbfe2p7O4CVi+2qPRY0G6iBFEjQC95xw59
         JU766FxtNIc5inVe5gVUOMEaxULkOfBZ62hpNcq1OuED/zJ69jURVKBCnRI8e93ancOd
         hwbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=XraM5WUeK23rXa1xoKBrqeBBCshgPfte+/8YLIj79Q8=;
        b=qy7U142LCmMppHgOmrKtxsK36LparcYIYXxv1JF/ThrR6VhE0WP6vdkJ4ye1JsJjZj
         vjcZZxQiBJM/mLcyDAi+SCmpwsMeZLm5/1O+5QXAD7cr2yoxFlTL3zMi37Xss6C71MPA
         byf2l9TSvoDMlbwNpR8yBpfHbtO4E3fLb3TL7pTlVJMiE00wlGgyOF9/ROV3J7A+sSJM
         mlP9xqG7VYMPzcfmALXPLiQMFGAyw0ktXhc3CIx5uWTf8K7mntyG/tcBikbTw8GPZfiT
         wyBiWYSNzFvqzpAjTem9zItTLMn4XkS25p3pAR6K3typK1wr5ngh60v50EdLI2WUedkV
         MpGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=NVRBfNmy;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v20sor17604352ita.10.2018.12.21.08.39.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Dec 2018 08:39:33 -0800 (PST)
Received-SPF: pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=NVRBfNmy;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=XraM5WUeK23rXa1xoKBrqeBBCshgPfte+/8YLIj79Q8=;
        b=NVRBfNmyDhXKYmvvR0703WQpE7jSm7u+YaJglQSTnrONLa71KfpCTdfA+u/BZXQvK/
         1T7U7UfWvjrmHP4kNY5Pms+FiIXeIzs7jvhfxi6NnJIDMMZVtrhhi//Ogiw8c5J3rRvm
         Ow0js5/FEfGlgGl24gR9Nv5cya2EoR9T/q3P8=
X-Google-Smtp-Source: AFSGD/WMUXG3EqZc6WkBZTmux9jDoCAOaFEZrpMzcSbohWykU7FMgXREfnFsx3F9KIFtLKgmSrTwujMy54mXiY6ybEM=
X-Received: by 2002:a24:edc4:: with SMTP id r187mr2673475ith.158.1545410372665;
 Fri, 21 Dec 2018 08:39:32 -0800 (PST)
MIME-Version: 1.0
References: <20181212000354.31955-1-rick.p.edgecombe@intel.com>
 <20181212000354.31955-2-rick.p.edgecombe@intel.com> <CALCETrVP577NvdeYj8bzpEfTXj3GZD3nFcJxnUq5n1daDBxU=g@mail.gmail.com>
In-Reply-To: <CALCETrVP577NvdeYj8bzpEfTXj3GZD3nFcJxnUq5n1daDBxU=g@mail.gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 21 Dec 2018 17:39:21 +0100
Message-ID:
 <CAKv+Gu_kunBqhUAQt6==SN-ei4Xc+z6=Z=pKXHHJYjk4Gdw73g@mail.gmail.com>
Subject: Re: [PATCH v2 1/4] vmalloc: New flags for safe vfree on special perms
To: Andy Lutomirski <luto@kernel.org>
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, 
	"Naveen N . Rao" <naveen.n.rao@linux.vnet.ibm.com>, 
	Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>, "David S. Miller" <davem@davemloft.net>, 
	Masami Hiramatsu <mhiramat@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, 
	Ingo Molnar <mingo@redhat.com>, Alexei Starovoitov <ast@kernel.org>, 
	Daniel Borkmann <daniel@iogearbox.net>, Jessica Yu <jeyu@kernel.org>, Nadav Amit <namit@vmware.com>, 
	Network Development <netdev@vger.kernel.org>, Jann Horn <jannh@google.com>, 
	Kristen Carlson Accardi <kristen@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, 
	"Dock, Deneen T" <deneen.t.dock@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181221163921.RYWnK9jUNpGDZbBu4aE6d8mZQJaIC0gkL3gXh9tGHsE@z>

On Wed, 12 Dec 2018 at 03:20, Andy Lutomirski <luto@kernel.org> wrote:
>
> On Tue, Dec 11, 2018 at 4:12 PM Rick Edgecombe
> <rick.p.edgecombe@intel.com> wrote:
> >
> > This adds two new flags VM_IMMEDIATE_UNMAP and VM_HAS_SPECIAL_PERMS, for
> > enabling vfree operations to immediately clear executable TLB entries to freed
> > pages, and handle freeing memory with special permissions.
> >
> > In order to support vfree being called on memory that might be RO, the vfree
> > deferred list node is moved to a kmalloc allocated struct, from where it is
> > today, reusing the allocation being freed.
> >
> > arch_vunmap is a new __weak function that implements the actual unmapping and
> > resetting of the direct map permissions. It can be overridden by more efficient
> > architecture specific implementations.
> >
> > For the default implementation, it uses architecture agnostic methods which are
> > equivalent to what most usages do before calling vfree. So now it is just
> > centralized here.
> >
> > This implementation derives from two sketches from Dave Hansen and Andy
> > Lutomirski.
> >
> > Suggested-by: Dave Hansen <dave.hansen@intel.com>
> > Suggested-by: Andy Lutomirski <luto@kernel.org>
> > Suggested-by: Will Deacon <will.deacon@arm.com>
> > Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
> > ---
> >  include/linux/vmalloc.h |  2 ++
> >  mm/vmalloc.c            | 73 +++++++++++++++++++++++++++++++++++++----
> >  2 files changed, 69 insertions(+), 6 deletions(-)
> >
> > diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> > index 398e9c95cd61..872bcde17aca 100644
> > --- a/include/linux/vmalloc.h
> > +++ b/include/linux/vmalloc.h
> > @@ -21,6 +21,8 @@ struct notifier_block;                /* in notifier.h */
> >  #define VM_UNINITIALIZED       0x00000020      /* vm_struct is not fully initialized */
> >  #define VM_NO_GUARD            0x00000040      /* don't add guard page */
> >  #define VM_KASAN               0x00000080      /* has allocated kasan shadow memory */
> > +#define VM_IMMEDIATE_UNMAP     0x00000200      /* flush before releasing pages */
> > +#define VM_HAS_SPECIAL_PERMS   0x00000400      /* may be freed with special perms */
> >  /* bits [20..32] reserved for arch specific ioremap internals */
> >
> >  /*
> > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > index 97d4b25d0373..02b284d2245a 100644
> > --- a/mm/vmalloc.c
> > +++ b/mm/vmalloc.c
> > @@ -18,6 +18,7 @@
> >  #include <linux/interrupt.h>
> >  #include <linux/proc_fs.h>
> >  #include <linux/seq_file.h>
> > +#include <linux/set_memory.h>
> >  #include <linux/debugobjects.h>
> >  #include <linux/kallsyms.h>
> >  #include <linux/list.h>
> > @@ -38,6 +39,11 @@
> >
> >  #include "internal.h"
> >
> > +struct vfree_work {
> > +       struct llist_node node;
> > +       void *addr;
> > +};
> > +
> >  struct vfree_deferred {
> >         struct llist_head list;
> >         struct work_struct wq;
> > @@ -50,9 +56,13 @@ static void free_work(struct work_struct *w)
> >  {
> >         struct vfree_deferred *p = container_of(w, struct vfree_deferred, wq);
> >         struct llist_node *t, *llnode;
> > +       struct vfree_work *cur;
> >
> > -       llist_for_each_safe(llnode, t, llist_del_all(&p->list))
> > -               __vunmap((void *)llnode, 1);
> > +       llist_for_each_safe(llnode, t, llist_del_all(&p->list)) {
> > +               cur = container_of(llnode, struct vfree_work, node);
> > +               __vunmap(cur->addr, 1);
> > +               kfree(cur);
> > +       }
> >  }
> >
> >  /*** Page table manipulation functions ***/
> > @@ -1494,6 +1504,48 @@ struct vm_struct *remove_vm_area(const void *addr)
> >         return NULL;
> >  }
> >
> > +/*
> > + * This function handles unmapping and resetting the direct map as efficiently
> > + * as it can with cross arch functions. The three categories of architectures
> > + * are:
> > + *   1. Architectures with no set_memory implementations and no direct map
> > + *      permissions.
> > + *   2. Architectures with set_memory implementations but no direct map
> > + *      permissions
> > + *   3. Architectures with set_memory implementations and direct map permissions
> > + */
> > +void __weak arch_vunmap(struct vm_struct *area, int deallocate_pages)
>
> My general preference is to avoid __weak functions -- they don't
> optimize well.  Instead, I prefer either:
>
> #ifndef arch_vunmap
> void arch_vunmap(...);
> #endif
>
> or
>
> #ifdef CONFIG_HAVE_ARCH_VUNMAP
> ...
> #endif
>
>
> > +{
> > +       unsigned long addr = (unsigned long)area->addr;
> > +       int immediate = area->flags & VM_IMMEDIATE_UNMAP;
> > +       int special = area->flags & VM_HAS_SPECIAL_PERMS;
> > +
> > +       /*
> > +        * In case of 2 and 3, use this general way of resetting the permissions
> > +        * on the directmap. Do NX before RW, in case of X, so there is no W^X
> > +        * violation window.
> > +        *
> > +        * For case 1 these will be noops.
> > +        */
> > +       if (immediate)
> > +               set_memory_nx(addr, area->nr_pages);
> > +       if (deallocate_pages && special)
> > +               set_memory_rw(addr, area->nr_pages);
>
> Can you elaborate on the intent here?  VM_IMMEDIATE_UNMAP means "I
> want that alias gone before any deallocation happens".
> VM_HAS_SPECIAL_PERMS means "I mucked with the direct map -- fix it for
> me, please".  deallocate means "this was vfree -- please free the
> pages".  I'm not convinced that all the various combinations make
> sense.  Do we really need both flags?
>
> (VM_IMMEDIATE_UNMAP is a bit of a lie, since, if in_interrupt(), it's
> not immediate.)
>
> If we do keep both flags, maybe some restructuring would make sense,
> like this, perhaps.  Sorry about horrible whitespace damage.
>
> if (special) {
>   /* VM_HAS_SPECIAL_PERMS makes little sense without deallocate_pages. */
>   WARN_ON_ONCE(!deallocate_pages);
>
>   if (immediate) {
>     /* It's possible that the vmap alias is X and we're about to make
> the direct map RW.  To avoid a window where executable memory is
> writable, first mark the vmap alias NX.  This is silly, since we're
> about to *unmap* it, but this is the best we can do if all we have to
> work with is the set_memory_abc() APIs.  Architectures should override
> this whole function to get better behavior. */

So can't we fix this first? Assuming that architectures that bother to
implement them will not have executable mappings in the linear region,
all we'd need is set_linear_range_ro/rw() routines that default to
doing nothing, and encapsulate the existing code for x86 and arm64.
That way, we can handle do things in the proper order, i.e., release
the vmalloc mapping (without caring about the permissions), restore
the linear alias attributes, and finally release the pages.


>     set_memory_nx(...);
>   }
>
>   set_memory_rw(addr, area->nr_pages);
> }
>
>
> > +
> > +       /* Always actually remove the area */
> > +       remove_vm_area(area->addr);
> > +
> > +       /*
> > +        * Need to flush the TLB before freeing pages in the case of this flag.
> > +        * As long as that's happening, unmap aliases.
> > +        *
> > +        * For 2 and 3, this will not be needed because of the set_memory_nx
> > +        * above, because the stale TLBs will be NX.
>
> I'm not sure I agree with this comment.  If the caller asked for an
> immediate unmap, we should give an immediate unmap.  But I'm still not
> sure I see why VM_IMMEDIATE_UNMAP needs to exist as a separate flag.
>
> > +        */
> > +       if (immediate && !IS_ENABLED(ARCH_HAS_SET_MEMORY))
> > +               vm_unmap_aliases();
> > +}
> > +
> >  static void __vunmap(const void *addr, int deallocate_pages)
> >  {
> >         struct vm_struct *area;
> > @@ -1515,7 +1567,8 @@ static void __vunmap(const void *addr, int deallocate_pages)
> >         debug_check_no_locks_freed(area->addr, get_vm_area_size(area));
> >         debug_check_no_obj_freed(area->addr, get_vm_area_size(area));
> >
> > -       remove_vm_area(addr);
> > +       arch_vunmap(area, deallocate_pages);
> > +
> >         if (deallocate_pages) {
> >                 int i;
> >
> > @@ -1542,8 +1595,15 @@ static inline void __vfree_deferred(const void *addr)
> >          * nother cpu's list.  schedule_work() should be fine with this too.
> >          */
> >         struct vfree_deferred *p = raw_cpu_ptr(&vfree_deferred);
> > +       struct vfree_work *w = kmalloc(sizeof(struct vfree_work), GFP_ATOMIC);
> > +
> > +       /* If no memory for the deferred list node, give up */
> > +       if (!w)
> > +               return;
>
> That's nasty.  I see what you're trying to do here, but I think you're
> solving a problem that doesn't need solving quite so urgently.  How
> about dropping this part and replacing it with a comment like "NB:
> this writes a word to a potentially executable address.  It would be
> nice if we could avoid doing this."  And maybe a future patch could
> more robustly avoid it without risking memory leaks.

