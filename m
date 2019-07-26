Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CDC5C76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 09:55:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BDFE22CBA
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 09:55:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="PjmEpxx1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BDFE22CBA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD0FA6B0003; Fri, 26 Jul 2019 05:55:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7F8A6B0005; Fri, 26 Jul 2019 05:55:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 947D28E0002; Fri, 26 Jul 2019 05:55:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 589B26B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 05:55:16 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id 186so20871302oid.17
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 02:55:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=FDsT74jQ4s66aFz/DbLFS21XYNlLbqRMqP7UhVVnMxE=;
        b=EPUnFOKIf9a9TzSE+MFafjUZQIdyG8kGbx8CLbvDqU/7cpRFhJeSZweZfb6yzVdGtk
         UqGTGDp7sFGHG8hWShqj+1mCP8UZ3LfjNCc5YeoIBnH2qnEq8mq29r0J3ACruYWJlfrW
         LI6hWUybswxfTJevC87d/pJdXLIIZMMH+pAfI2LT+/mttOA9fn0gsH/CoHcWumID01Gi
         XGrG5OxOgxQu8MzeLuQ0j6Xse0Xh7n7WJ8wPiXlInV56r7ZC+iW/HZb/XwZDqrp0RMSw
         nVhE1OLcK20OP5EJJA4JnaeCbE1U/2O5XwgI5fSkQ+sFzzmA4uLgUT/FecJiCSj22Kgu
         sDxQ==
X-Gm-Message-State: APjAAAWvIV+reCzwafaAKit+N3dPI+Iyr5M7fF0IlFki9ha1Tt0TlYY+
	hSqkvtKZwxOsxnDIAQOsJnXbAxeS86LKPylGDUPNBrp0DtAy4PPhVKjR/i6e/XwtQ+6d1yBk1wW
	v99SM04oHe8GTJPPvqQzUJ1uj9nPCqIliY8KsdrN+FGzmDmXy/b0U57Zdqt13rQRhdw==
X-Received: by 2002:a9d:222c:: with SMTP id o41mr71179877ota.278.1564134915868;
        Fri, 26 Jul 2019 02:55:15 -0700 (PDT)
X-Received: by 2002:a9d:222c:: with SMTP id o41mr71179802ota.278.1564134914443;
        Fri, 26 Jul 2019 02:55:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564134914; cv=none;
        d=google.com; s=arc-20160816;
        b=xQBj65CG7pfGrBDNPpeIrYHm54F+6syUlKI98/PjfSexK/f9SoaVciu8tlUwFZGV8v
         q9Bajwxu9hGuozRdw9tuvuoSkPo0iTtVVZtMGEAt1j6P/ZguVL5BvDzTA/+b9khVxHNv
         vIGwN1O1aIMXeh18j2mgIcPJn7RAEOjKBQ8BocvD+6dB9MeAlGuPkbzCD1/Acc/8hkgj
         TLi5cSK4pOQd29nx0OWLA13bKBrvotqXT23vseRSVv9z7VxZpMNx68VsKNHzxt+kf5eD
         frNucBmoSqwXSc3fcD4wIrgK+PUn5VauOjAyMeCRL2VvMXq0q5scN6XO/H9LhLeTAjOh
         LDTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=FDsT74jQ4s66aFz/DbLFS21XYNlLbqRMqP7UhVVnMxE=;
        b=rotcuAvkVU2W8sgUUAOSuQ/TBSgVo1XLkpOzh1jgpSzNfUYQ6fS3qmRaTBM5fLjmiQ
         WdVxhW9fTTdx0bUhR9ZQSX7w17iu39TwUdZZSe9pguCuzrb3RFj+a80znLu1lo+MaZNu
         mG2WYARvvorrj/xjblgGYurSq/1YIdfEgpFTFDSt/Yw0tr0QB2Z5irdSLL/l5FYW0Suc
         UQZ4st5GhOer6PHJvFoVWXJYbIy2ERyh+u/dlzRAE8vqiHGXFQp+UVlbggK3flMR7Hon
         iZFq/wF8+s3HfBkTiR1uqj0XTF/2iD/xPyQxaBkhqjgIlUh6dfiQn62JfyKYEgcBfoHU
         84ag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=PjmEpxx1;
       spf=pass (google.com: domain of elver@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=elver@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n129sor23083682oif.116.2019.07.26.02.55.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 02:55:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of elver@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=PjmEpxx1;
       spf=pass (google.com: domain of elver@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=elver@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=FDsT74jQ4s66aFz/DbLFS21XYNlLbqRMqP7UhVVnMxE=;
        b=PjmEpxx1zFaeut43+WF37MGQhhOKVNKlxtY+452gzzNAFTaIAAEkzko0DuOqbRh2i4
         mQhK2zcpcFsWruOtaSLIYOzBYt3zbtdkpGIgWI6EcMG0toxnaZa9b9Bz0DyvvYql/23L
         y8bqg7YU7dThjUL4u7Yp5TK6Q6VlewMDFTkBoaE+eSyRQukZnPTqxYBWb4GXiJPtYAy+
         qsy9refKD4STL29kMVPB7+/Ntpey8hw7B4V1R5vXPAxuBrsAPTq+axqLBbOOX9YIGEpY
         sNrNhnjeG2E6jSHJvYG6FXDxYHwTbSMABhKbMuvj2gFI/xSEIWI+CIskoUdYExVHwDr7
         ZhKQ==
X-Google-Smtp-Source: APXvYqxAUXUocxlImiZO/eO3p3BszupxWMnaLaTTT6IY+thh1MUOMdLpoDrRZC4A7NVGXcSOphh/EgLwS3QQDXKsEWY=
X-Received: by 2002:a54:4081:: with SMTP id i1mr23763050oii.121.1564134913413;
 Fri, 26 Jul 2019 02:55:13 -0700 (PDT)
MIME-Version: 1.0
References: <20190725055503.19507-1-dja@axtens.net> <20190725055503.19507-2-dja@axtens.net>
 <CACT4Y+Yw74otyk9gASfUyAW_bbOr8H5Cjk__F7iptrxRWmS9=A@mail.gmail.com>
 <CACT4Y+Z3HNLBh_FtevDvf2fe_BYPTckC19csomR6nK42_w8c1Q@mail.gmail.com>
 <CANpmjNNhwcYo-3tMkYPGrvSew633FQW7fCUiTgYUp7iKYY7fpw@mail.gmail.com>
 <87o91igmr7.fsf@dja-thinkpad.axtens.net> <87h879gz1g.fsf@dja-thinkpad.axtens.net>
In-Reply-To: <87h879gz1g.fsf@dja-thinkpad.axtens.net>
From: Marco Elver <elver@google.com>
Date: Fri, 26 Jul 2019 11:55:02 +0200
Message-ID: <CANpmjNNTpX357os2Q3_dG0GkbEVHoU-3ADFaKqxJvqh3He=3eA@mail.gmail.com>
Subject: Re: [PATCH 1/3] kasan: support backing vmalloc space with real shadow memory
To: Daniel Axtens <dja@axtens.net>
Cc: Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, 
	Linux-MM <linux-mm@kvack.org>, "the arch/x86 maintainers" <x86@kernel.org>, 
	Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, 
	Andy Lutomirski <luto@kernel.org>, Mark Rutland <mark.rutland@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Jul 2019 at 07:12, Daniel Axtens <dja@axtens.net> wrote:
>
> >> It appears that stack overflows are *not* detected when KASAN_VMALLOC
> >> and VMAP_STACK are enabled.
> >>
> >> Tested with:
> >> insmod drivers/misc/lkdtm/lkdtm.ko cpoint_name=DIRECT cpoint_type=EXHAUST_STACK
> >>
> >> I've also attached the .config. Anything I missed?
> >>
>
> So this is a pretty fun bug.
>
> From qemu it seems that CPU#0 is stuck in
> queued_spin_lock_slowpath. Some registers contain the address of
> logbuf_lock. Looking at a stack in crash, we're printing:
>
> crash> bt -S 0xffffc90000530000 695
> PID: 695    TASK: ffff888069933b00  CPU: 0   COMMAND: "modprobe"
>  #0 [ffffc90000530000] __schedule at ffffffff834832e5
>  #1 [ffffc900005300d0] vscnprintf at ffffffff83464398
>  #2 [ffffc900005300f8] vprintk_store at ffffffff8123d9f0
>  #3 [ffffc90000530160] vprintk_emit at ffffffff8123e2f9
>  #4 [ffffc900005301b0] vprintk_func at ffffffff8123ff06
>  #5 [ffffc900005301c8] printk at ffffffff8123efb0
>  #6 [ffffc90000530278] recursive_loop at ffffffffc0459939 [lkdtm]
>  #7 [ffffc90000530708] recursive_loop at ffffffffc045994a [lkdtm]
>  #8 [ffffc90000530b98] recursive_loop at ffffffffc045994a [lkdtm]
> ...
>
> We seem to be deadlocking on logbuf_lock because we take the stack
> overflow inside printk after it takes the lock, as recursive_loop
> attempts to print its status. Then we try to printk() some information
> about the double-fault, which tries to take the lock again, and blam,
> we're deadlocked.
>
> I didn't see it in my build because I happen to just access the stack
> differently with lock debugging on - we happen to overflow the stack
> while not holding the lock.
>
> So I think this is a generic bug, not related to KASAN_VMALLOC.  IIUC,
> it's not safe to kill stack-overflowing tasks with die() because they
> could be holding arbitrary locks. Instead we should panic() the box.
> (panic prints without taking locks.)
>
> The following patch works for me, does it fix things for you?
>
> -----------------------------------------------------
>
> diff --git a/arch/x86/kernel/traps.c b/arch/x86/kernel/traps.c
> index 4bb0f8447112..bfb0ec667c09 100644
> --- a/arch/x86/kernel/traps.c
> +++ b/arch/x86/kernel/traps.c
> @@ -301,13 +301,14 @@ __visible void __noreturn handle_stack_overflow(const char *message,
>                                                 struct pt_regs *regs,
>                                                 unsigned long fault_address)
>  {
> -       printk(KERN_EMERG "BUG: stack guard page was hit at %p (stack is %p..%p)\n",
> -                (void *)fault_address, current->stack,
> -                (char *)current->stack + THREAD_SIZE - 1);
> -       die(message, regs, 0);
> +       /*
> +        * It's not safe to kill the task, as it's in kernel space and
> +        * might be holding important locks. Just panic.
> +        */
>
> -       /* Be absolutely certain we don't return. */
> -       panic("%s", message);
> +       panic("%s - stack guard page was hit at %p (stack is %p..%p)",
> +             message, (void *)fault_address, current->stack,
> +             (char *)current->stack + THREAD_SIZE - 1);
>  }
>
>
> -----------------------------------------------------

Many thanks for debugging this! Indeed, this seems to fix things for me.

Best Wishes,
-- Marco

> Regards,
> Daniel
>
> >
> > Fascinating - it seems to work on my config, a lightly modified
> > defconfig (attached):
> >
> > [  111.287854] lkdtm: loop 46/64 ...
> > [  111.287856] lkdtm: loop 45/64 ...
> > [  111.287859] lkdtm: loop 44/64 ...
> > [  111.287862] lkdtm: loop 43/64 ...
> > [  111.287864] lkdtm: loop 42/64 ...
> > [  111.287867] lkdtm: loop 41/64 ...
> > [  111.287869] lkdtm: loop 40/64 ...
> > [  111.288498] BUG: stack guard page was hit at 000000007bf6ef1a (stack is 000000005952e5cc..00000000ba40316c)
> > [  111.288499] kernel stack overflow (double-fault): 0000 [#1] SMP KASAN PTI
> > [  111.288500] CPU: 0 PID: 767 Comm: modprobe Not tainted 5.3.0-rc1-next-20190723+ #91
> > [  111.288501] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 0.0.0 02/06/2015
> > [  111.288501] RIP: 0010:__lock_acquire+0x43/0x3b50
> > [  111.288503] Code: 84 24 90 00 00 00 48 c7 84 24 90 00 00 00 b3 8a b5 41 48 8b 9c 24 28 01 00 00 48 c7 84 24 98 00 00 00 f8
> >  5a a9 84 48 c1 e8 03 <48> 89 44 24 18 48 89 c7 48 b8 00 00 00 00 00 fc ff df 48 c7 84 24
> > [  111.288504] RSP: 0018:ffffc90000a37fd8 EFLAGS: 00010802
> > [  111.288505] RAX: 1ffff9200014700d RBX: 0000000000000000 RCX: 0000000000000000
> > [  111.288506] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffffff84cf3ff8
> > [  111.288507] RBP: ffffffff84cf3ff8 R08: 0000000000000001 R09: 0000000000000001
> > [  111.288507] R10: fffffbfff0a440cf R11: ffffffff8522067f R12: 0000000000000000
> > [  111.288508] R13: 0000000000000000 R14: 0000000000000001 R15: 0000000000000000
> > [  111.288509] FS:  00007f97f1f23740(0000) GS:ffff88806c400000(0000) knlGS:0000000000000000
> > [  111.288510] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [  111.288510] CR2: ffffc90000a37fc8 CR3: 000000006a0fc005 CR4: 0000000000360ef0
> > [  111.288511] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > [  111.288512] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> > [  111.288512] Call Trace:
> > [  111.288513]  lock_acquire+0x125/0x300
> > [  111.288513]  ? vprintk_emit+0x6c/0x250
> > [  111.288514]  _raw_spin_lock+0x20/0x30
> >
> > I will test with your config and see if I can narrow it down tomorrow.
> >
> > Regards,
> > Daniel
> >
> >
> >
> >> Thanks,
> >> -- Marco
> >>
> >>> > > ---
> >>> > >  Documentation/dev-tools/kasan.rst | 60 +++++++++++++++++++++++++++++++
> >>> > >  include/linux/kasan.h             | 16 +++++++++
> >>> > >  lib/Kconfig.kasan                 | 16 +++++++++
> >>> > >  lib/test_kasan.c                  | 26 ++++++++++++++
> >>> > >  mm/kasan/common.c                 | 51 ++++++++++++++++++++++++++
> >>> > >  mm/kasan/generic_report.c         |  3 ++
> >>> > >  mm/kasan/kasan.h                  |  1 +
> >>> > >  mm/vmalloc.c                      | 15 +++++++-
> >>> > >  8 files changed, 187 insertions(+), 1 deletion(-)
> >>> > >
> >>> > > diff --git a/Documentation/dev-tools/kasan.rst b/Documentation/dev-tools/kasan.rst
> >>> > > index b72d07d70239..35fda484a672 100644
> >>> > > --- a/Documentation/dev-tools/kasan.rst
> >>> > > +++ b/Documentation/dev-tools/kasan.rst
> >>> > > @@ -215,3 +215,63 @@ brk handler is used to print bug reports.
> >>> > >  A potential expansion of this mode is a hardware tag-based mode, which would
> >>> > >  use hardware memory tagging support instead of compiler instrumentation and
> >>> > >  manual shadow memory manipulation.
> >>> > > +
> >>> > > +What memory accesses are sanitised by KASAN?
> >>> > > +--------------------------------------------
> >>> > > +
> >>> > > +The kernel maps memory in a number of different parts of the address
> >>> > > +space. This poses something of a problem for KASAN, which requires
> >>> > > +that all addresses accessed by instrumented code have a valid shadow
> >>> > > +region.
> >>> > > +
> >>> > > +The range of kernel virtual addresses is large: there is not enough
> >>> > > +real memory to support a real shadow region for every address that
> >>> > > +could be accessed by the kernel.
> >>> > > +
> >>> > > +By default
> >>> > > +~~~~~~~~~~
> >>> > > +
> >>> > > +By default, architectures only map real memory over the shadow region
> >>> > > +for the linear mapping (and potentially other small areas). For all
> >>> > > +other areas - such as vmalloc and vmemmap space - a single read-only
> >>> > > +page is mapped over the shadow area. This read-only shadow page
> >>> > > +declares all memory accesses as permitted.
> >>> > > +
> >>> > > +This presents a problem for modules: they do not live in the linear
> >>> > > +mapping, but in a dedicated module space. By hooking in to the module
> >>> > > +allocator, KASAN can temporarily map real shadow memory to cover
> >>> > > +them. This allows detection of invalid accesses to module globals, for
> >>> > > +example.
> >>> > > +
> >>> > > +This also creates an incompatibility with ``VMAP_STACK``: if the stack
> >>> > > +lives in vmalloc space, it will be shadowed by the read-only page, and
> >>> > > +the kernel will fault when trying to set up the shadow data for stack
> >>> > > +variables.
> >>> > > +
> >>> > > +CONFIG_KASAN_VMALLOC
> >>> > > +~~~~~~~~~~~~~~~~~~~~
> >>> > > +
> >>> > > +With ``CONFIG_KASAN_VMALLOC``, KASAN can cover vmalloc space at the
> >>> > > +cost of greater memory usage. Currently this is only supported on x86.
> >>> > > +
> >>> > > +This works by hooking into vmalloc and vmap, and dynamically
> >>> > > +allocating real shadow memory to back the mappings.
> >>> > > +
> >>> > > +Most mappings in vmalloc space are small, requiring less than a full
> >>> > > +page of shadow space. Allocating a full shadow page per mapping would
> >>> > > +therefore be wasteful. Furthermore, to ensure that different mappings
> >>> > > +use different shadow pages, mappings would have to be aligned to
> >>> > > +``KASAN_SHADOW_SCALE_SIZE * PAGE_SIZE``.
> >>> > > +
> >>> > > +Instead, we share backing space across multiple mappings. We allocate
> >>> > > +a backing page the first time a mapping in vmalloc space uses a
> >>> > > +particular page of the shadow region. We keep this page around
> >>> > > +regardless of whether the mapping is later freed - in the mean time
> >>> > > +this page could have become shared by another vmalloc mapping.
> >>> > > +
> >>> > > +This can in theory lead to unbounded memory growth, but the vmalloc
> >>> > > +allocator is pretty good at reusing addresses, so the practical memory
> >>> > > +usage grows at first but then stays fairly stable.
> >>> > > +
> >>> > > +This allows ``VMAP_STACK`` support on x86, and enables support of
> >>> > > +architectures that do not have a fixed module region.
> >>> > > diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> >>> > > index cc8a03cc9674..fcabc5a03fca 100644
> >>> > > --- a/include/linux/kasan.h
> >>> > > +++ b/include/linux/kasan.h
> >>> > > @@ -70,8 +70,18 @@ struct kasan_cache {
> >>> > >         int free_meta_offset;
> >>> > >  };
> >>> > >
> >>> > > +/*
> >>> > > + * These functions provide a special case to support backing module
> >>> > > + * allocations with real shadow memory. With KASAN vmalloc, the special
> >>> > > + * case is unnecessary, as the work is handled in the generic case.
> >>> > > + */
> >>> > > +#ifndef CONFIG_KASAN_VMALLOC
> >>> > >  int kasan_module_alloc(void *addr, size_t size);
> >>> > >  void kasan_free_shadow(const struct vm_struct *vm);
> >>> > > +#else
> >>> > > +static inline int kasan_module_alloc(void *addr, size_t size) { return 0; }
> >>> > > +static inline void kasan_free_shadow(const struct vm_struct *vm) {}
> >>> > > +#endif
> >>> > >
> >>> > >  int kasan_add_zero_shadow(void *start, unsigned long size);
> >>> > >  void kasan_remove_zero_shadow(void *start, unsigned long size);
> >>> > > @@ -194,4 +204,10 @@ static inline void *kasan_reset_tag(const void *addr)
> >>> > >
> >>> > >  #endif /* CONFIG_KASAN_SW_TAGS */
> >>> > >
> >>> > > +#ifdef CONFIG_KASAN_VMALLOC
> >>> > > +void kasan_cover_vmalloc(unsigned long requested_size, struct vm_struct *area);
> >>> > > +#else
> >>> > > +static inline void kasan_cover_vmalloc(unsigned long requested_size, struct vm_struct *area) {}
> >>> > > +#endif
> >>> > > +
> >>> > >  #endif /* LINUX_KASAN_H */
> >>> > > diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
> >>> > > index 4fafba1a923b..a320dc2e9317 100644
> >>> > > --- a/lib/Kconfig.kasan
> >>> > > +++ b/lib/Kconfig.kasan
> >>> > > @@ -6,6 +6,9 @@ config HAVE_ARCH_KASAN
> >>> > >  config HAVE_ARCH_KASAN_SW_TAGS
> >>> > >         bool
> >>> > >
> >>> > > +config HAVE_ARCH_KASAN_VMALLOC
> >>> > > +       bool
> >>> > > +
> >>> > >  config CC_HAS_KASAN_GENERIC
> >>> > >         def_bool $(cc-option, -fsanitize=kernel-address)
> >>> > >
> >>> > > @@ -135,6 +138,19 @@ config KASAN_S390_4_LEVEL_PAGING
> >>> > >           to 3TB of RAM with KASan enabled). This options allows to force
> >>> > >           4-level paging instead.
> >>> > >
> >>> > > +config KASAN_VMALLOC
> >>> > > +       bool "Back mappings in vmalloc space with real shadow memory"
> >>> > > +       depends on KASAN && HAVE_ARCH_KASAN_VMALLOC
> >>> > > +       help
> >>> > > +         By default, the shadow region for vmalloc space is the read-only
> >>> > > +         zero page. This means that KASAN cannot detect errors involving
> >>> > > +         vmalloc space.
> >>> > > +
> >>> > > +         Enabling this option will hook in to vmap/vmalloc and back those
> >>> > > +         mappings with real shadow memory allocated on demand. This allows
> >>> > > +         for KASAN to detect more sorts of errors (and to support vmapped
> >>> > > +         stacks), but at the cost of higher memory usage.
> >>> > > +
> >>> > >  config TEST_KASAN
> >>> > >         tristate "Module for testing KASAN for bug detection"
> >>> > >         depends on m && KASAN
> >>> > > diff --git a/lib/test_kasan.c b/lib/test_kasan.c
> >>> > > index b63b367a94e8..d375246f5f96 100644
> >>> > > --- a/lib/test_kasan.c
> >>> > > +++ b/lib/test_kasan.c
> >>> > > @@ -18,6 +18,7 @@
> >>> > >  #include <linux/slab.h>
> >>> > >  #include <linux/string.h>
> >>> > >  #include <linux/uaccess.h>
> >>> > > +#include <linux/vmalloc.h>
> >>> > >
> >>> > >  /*
> >>> > >   * Note: test functions are marked noinline so that their names appear in
> >>> > > @@ -709,6 +710,30 @@ static noinline void __init kmalloc_double_kzfree(void)
> >>> > >         kzfree(ptr);
> >>> > >  }
> >>> > >
> >>> > > +#ifdef CONFIG_KASAN_VMALLOC
> >>> > > +static noinline void __init vmalloc_oob(void)
> >>> > > +{
> >>> > > +       void *area;
> >>> > > +
> >>> > > +       pr_info("vmalloc out-of-bounds\n");
> >>> > > +
> >>> > > +       /*
> >>> > > +        * We have to be careful not to hit the guard page.
> >>> > > +        * The MMU will catch that and crash us.
> >>> > > +        */
> >>> > > +       area = vmalloc(3000);
> >>> > > +       if (!area) {
> >>> > > +               pr_err("Allocation failed\n");
> >>> > > +               return;
> >>> > > +       }
> >>> > > +
> >>> > > +       ((volatile char *)area)[3100];
> >>> > > +       vfree(area);
> >>> > > +}
> >>> > > +#else
> >>> > > +static void __init vmalloc_oob(void) {}
> >>> > > +#endif
> >>> > > +
> >>> > >  static int __init kmalloc_tests_init(void)
> >>> > >  {
> >>> > >         /*
> >>> > > @@ -752,6 +777,7 @@ static int __init kmalloc_tests_init(void)
> >>> > >         kasan_strings();
> >>> > >         kasan_bitops();
> >>> > >         kmalloc_double_kzfree();
> >>> > > +       vmalloc_oob();
> >>> > >
> >>> > >         kasan_restore_multi_shot(multishot);
> >>> > >
> >>> > > diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> >>> > > index 2277b82902d8..a3bb84efccbf 100644
> >>> > > --- a/mm/kasan/common.c
> >>> > > +++ b/mm/kasan/common.c
> >>> > > @@ -568,6 +568,7 @@ void kasan_kfree_large(void *ptr, unsigned long ip)
> >>> > >         /* The object will be poisoned by page_alloc. */
> >>> > >  }
> >>> > >
> >>> > > +#ifndef CONFIG_KASAN_VMALLOC
> >>> > >  int kasan_module_alloc(void *addr, size_t size)
> >>> > >  {
> >>> > >         void *ret;
> >>> > > @@ -603,6 +604,7 @@ void kasan_free_shadow(const struct vm_struct *vm)
> >>> > >         if (vm->flags & VM_KASAN)
> >>> > >                 vfree(kasan_mem_to_shadow(vm->addr));
> >>> > >  }
> >>> > > +#endif
> >>> > >
> >>> > >  extern void __kasan_report(unsigned long addr, size_t size, bool is_write, unsigned long ip);
> >>> > >
> >>> > > @@ -722,3 +724,52 @@ static int __init kasan_memhotplug_init(void)
> >>> > >
> >>> > >  core_initcall(kasan_memhotplug_init);
> >>> > >  #endif
> >>> > > +
> >>> > > +#ifdef CONFIG_KASAN_VMALLOC
> >>> > > +void kasan_cover_vmalloc(unsigned long requested_size, struct vm_struct *area)
> >>> > > +{
> >>> > > +       unsigned long shadow_alloc_start, shadow_alloc_end;
> >>> > > +       unsigned long addr;
> >>> > > +       unsigned long backing;
> >>> > > +       pgd_t *pgdp;
> >>> > > +       p4d_t *p4dp;
> >>> > > +       pud_t *pudp;
> >>> > > +       pmd_t *pmdp;
> >>> > > +       pte_t *ptep;
> >>> > > +       pte_t backing_pte;
> >>> > > +
> >>> > > +       shadow_alloc_start = ALIGN_DOWN(
> >>> > > +               (unsigned long)kasan_mem_to_shadow(area->addr),
> >>> > > +               PAGE_SIZE);
> >>> > > +       shadow_alloc_end = ALIGN(
> >>> > > +               (unsigned long)kasan_mem_to_shadow(area->addr + area->size),
> >>> > > +               PAGE_SIZE);
> >>> > > +
> >>> > > +       addr = shadow_alloc_start;
> >>> > > +       do {
> >>> > > +               pgdp = pgd_offset_k(addr);
> >>> > > +               p4dp = p4d_alloc(&init_mm, pgdp, addr);
> >>> >
> >>> > Page table allocations will be protected by mm->page_table_lock, right?
> >>> >
> >>> >
> >>> > > +               pudp = pud_alloc(&init_mm, p4dp, addr);
> >>> > > +               pmdp = pmd_alloc(&init_mm, pudp, addr);
> >>> > > +               ptep = pte_alloc_kernel(pmdp, addr);
> >>> > > +
> >>> > > +               /*
> >>> > > +                * we can validly get here if pte is not none: it means we
> >>> > > +                * allocated this page earlier to use part of it for another
> >>> > > +                * allocation
> >>> > > +                */
> >>> > > +               if (pte_none(*ptep)) {
> >>> > > +                       backing = __get_free_page(GFP_KERNEL);
> >>> > > +                       backing_pte = pfn_pte(PFN_DOWN(__pa(backing)),
> >>> > > +                                             PAGE_KERNEL);
> >>> > > +                       set_pte_at(&init_mm, addr, ptep, backing_pte);
> >>> > > +               }
> >>> > > +       } while (addr += PAGE_SIZE, addr != shadow_alloc_end);
> >>> > > +
> >>> > > +       requested_size = round_up(requested_size, KASAN_SHADOW_SCALE_SIZE);
> >>> > > +       kasan_unpoison_shadow(area->addr, requested_size);
> >>> > > +       kasan_poison_shadow(area->addr + requested_size,
> >>> > > +                           area->size - requested_size,
> >>> > > +                           KASAN_VMALLOC_INVALID);
> >>> >
> >>> >
> >>> > Do I read this correctly that if kernel code does vmalloc(64), they
> >>> > will have exactly 64 bytes available rather than full page? To make
> >>> > sure: vmalloc does not guarantee that the available size is rounded up
> >>> > to page size? I suspect we will see a throw out of new bugs related to
> >>> > OOBs on vmalloc memory. So I want to make sure that these will be
> >>> > indeed bugs that we agree need to be fixed.
> >>> > I am sure there will be bugs where the size is controlled by
> >>> > user-space, so these are bad bugs under any circumstances. But there
> >>> > will also probably be OOBs, where people will try to "prove" that
> >>> > that's fine and will work (just based on our previous experiences :)).
> >>> >
> >>> > On impl side: kasan_unpoison_shadow seems to be capable of handling
> >>> > non-KASAN_SHADOW_SCALE_SIZE-aligned sizes exactly in the way we want.
> >>> > So I think it's better to do:
> >>> >
> >>> >        kasan_unpoison_shadow(area->addr, requested_size);
> >>> >        requested_size = round_up(requested_size, KASAN_SHADOW_SCALE_SIZE);
> >>> >        kasan_poison_shadow(area->addr + requested_size,
> >>> >                            area->size - requested_size,
> >>> >                            KASAN_VMALLOC_INVALID);
> >>> >
> >>> >
> >>> >
> >>> > > +}
> >>> > > +#endif
> >>> > > diff --git a/mm/kasan/generic_report.c b/mm/kasan/generic_report.c
> >>> > > index 36c645939bc9..2d97efd4954f 100644
> >>> > > --- a/mm/kasan/generic_report.c
> >>> > > +++ b/mm/kasan/generic_report.c
> >>> > > @@ -86,6 +86,9 @@ static const char *get_shadow_bug_type(struct kasan_access_info *info)
> >>> > >         case KASAN_ALLOCA_RIGHT:
> >>> > >                 bug_type = "alloca-out-of-bounds";
> >>> > >                 break;
> >>> > > +       case KASAN_VMALLOC_INVALID:
> >>> > > +               bug_type = "vmalloc-out-of-bounds";
> >>> > > +               break;
> >>> > >         }
> >>> > >
> >>> > >         return bug_type;
> >>> > > diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> >>> > > index 014f19e76247..8b1f2fbc780b 100644
> >>> > > --- a/mm/kasan/kasan.h
> >>> > > +++ b/mm/kasan/kasan.h
> >>> > > @@ -25,6 +25,7 @@
> >>> > >  #endif
> >>> > >
> >>> > >  #define KASAN_GLOBAL_REDZONE    0xFA  /* redzone for global variable */
> >>> > > +#define KASAN_VMALLOC_INVALID   0xF9  /* unallocated space in vmapped page */
> >>> > >
> >>> > >  /*
> >>> > >   * Stack redzone shadow values
> >>> > > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> >>> > > index 4fa8d84599b0..8cbcb5056c9b 100644
> >>> > > --- a/mm/vmalloc.c
> >>> > > +++ b/mm/vmalloc.c
> >>> > > @@ -2012,6 +2012,15 @@ static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
> >>> > >         va->vm = vm;
> >>> > >         va->flags |= VM_VM_AREA;
> >>> > >         spin_unlock(&vmap_area_lock);
> >>> > > +
> >>> > > +       /*
> >>> > > +        * If we are in vmalloc space we need to cover the shadow area with
> >>> > > +        * real memory. If we come here through VM_ALLOC, this is done
> >>> > > +        * by a higher level function that has access to the true size,
> >>> > > +        * which might not be a full page.
> >>> > > +        */
> >>> > > +       if (is_vmalloc_addr(vm->addr) && !(vm->flags & VM_ALLOC))
> >>> > > +               kasan_cover_vmalloc(vm->size, vm);
> >>> > >  }
> >>> > >
> >>> > >  static void clear_vm_uninitialized_flag(struct vm_struct *vm)
> >>> > > @@ -2483,6 +2492,8 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
> >>> > >         if (!addr)
> >>> > >                 return NULL;
> >>> > >
> >>> > > +       kasan_cover_vmalloc(real_size, area);
> >>> > > +
> >>> > >         /*
> >>> > >          * In this function, newly allocated vm_struct has VM_UNINITIALIZED
> >>> > >          * flag. It means that vm_struct is not fully initialized.
> >>> > > @@ -3324,9 +3335,11 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
> >>> > >         spin_unlock(&vmap_area_lock);
> >>> > >
> >>> > >         /* insert all vm's */
> >>> > > -       for (area = 0; area < nr_vms; area++)
> >>> > > +       for (area = 0; area < nr_vms; area++) {
> >>> > >                 setup_vmalloc_vm(vms[area], vas[area], VM_ALLOC,
> >>> > >                                  pcpu_get_vm_areas);
> >>> > > +               kasan_cover_vmalloc(sizes[area], vms[area]);
> >>> > > +       }
> >>> > >
> >>> > >         kfree(vas);
> >>> > >         return vms;
> >>> > > --
> >>> > > 2.20.1
> >>> > >
> >>> > > --
> >>> > > You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> >>> > > To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> >>> > > To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/20190725055503.19507-2-dja%40axtens.net.
>
> --
> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/87h879gz1g.fsf%40dja-thinkpad.axtens.net.

