Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A14EF8E00E5
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 21:24:21 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id k125so11202130pga.5
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 18:24:21 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id ay7si13424844plb.410.2018.12.11.18.24.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 18:24:20 -0800 (PST)
Received: from mail-wm1-f41.google.com (mail-wm1-f41.google.com [209.85.128.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8BF7621473
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 02:24:19 +0000 (UTC)
Received: by mail-wm1-f41.google.com with SMTP id g67so4265201wmd.2
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 18:24:19 -0800 (PST)
MIME-Version: 1.0
References: <20181212000354.31955-1-rick.p.edgecombe@intel.com> <20181212000354.31955-5-rick.p.edgecombe@intel.com>
In-Reply-To: <20181212000354.31955-5-rick.p.edgecombe@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 11 Dec 2018 18:24:05 -0800
Message-ID: <CALCETrWunJbO=SmPGCPaZRmbvPeaqm3Cx0Ygm0EOKo-zVyrHZQ@mail.gmail.com>
Subject: Re: [PATCH v2 4/4] x86/vmalloc: Add TLB efficient x86 arch_vunmap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrew Lutomirski <luto@kernel.org>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, "Naveen N . Rao" <naveen.n.rao@linux.vnet.ibm.com>, Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>, "David S. Miller" <davem@davemloft.net>, Masami Hiramatsu <mhiramat@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Jessica Yu <jeyu@kernel.org>, Nadav Amit <namit@vmware.com>, Network Development <netdev@vger.kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Jann Horn <jannh@google.com>, Kristen Carlson Accardi <kristen@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>

On Tue, Dec 11, 2018 at 4:12 PM Rick Edgecombe
<rick.p.edgecombe@intel.com> wrote:
>
> This adds a more efficient x86 architecture specific implementation of
> arch_vunmap, that can free any type of special permission memory with only 1 TLB
> flush.
>
> In order to enable this, _set_pages_p and _set_pages_np are made non-static and
> renamed set_pages_p_noflush and set_pages_np_noflush to better communicate
> their different (non-flushing) behavior from the rest of the set_pages_*
> functions.
>
> The method for doing this with only 1 TLB flush was suggested by Andy
> Lutomirski.
>
> Suggested-by: Andy Lutomirski <luto@kernel.org>
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
> ---
>  arch/x86/include/asm/set_memory.h |  2 +
>  arch/x86/mm/Makefile              |  3 +-
>  arch/x86/mm/pageattr.c            | 11 +++--
>  arch/x86/mm/vmalloc.c             | 71 +++++++++++++++++++++++++++++++
>  4 files changed, 80 insertions(+), 7 deletions(-)
>  create mode 100644 arch/x86/mm/vmalloc.c
>
> diff --git a/arch/x86/include/asm/set_memory.h b/arch/x86/include/asm/set_memory.h
> index 07a25753e85c..70ee81e8914b 100644
> --- a/arch/x86/include/asm/set_memory.h
> +++ b/arch/x86/include/asm/set_memory.h
> @@ -84,6 +84,8 @@ int set_pages_x(struct page *page, int numpages);
>  int set_pages_nx(struct page *page, int numpages);
>  int set_pages_ro(struct page *page, int numpages);
>  int set_pages_rw(struct page *page, int numpages);
> +int set_pages_np_noflush(struct page *page, int numpages);
> +int set_pages_p_noflush(struct page *page, int numpages);
>
>  extern int kernel_set_to_readonly;
>  void set_kernel_text_rw(void);
> diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
> index 4b101dd6e52f..189681f863a6 100644
> --- a/arch/x86/mm/Makefile
> +++ b/arch/x86/mm/Makefile
> @@ -13,7 +13,8 @@ CFLAGS_REMOVE_mem_encrypt_identity.o  = -pg
>  endif
>
>  obj-y  :=  init.o init_$(BITS).o fault.o ioremap.o extable.o pageattr.o mmap.o \
> -           pat.o pgtable.o physaddr.o setup_nx.o tlb.o cpu_entry_area.o
> +           pat.o pgtable.o physaddr.o setup_nx.o tlb.o cpu_entry_area.o \
> +           vmalloc.o
>
>  # Make sure __phys_addr has no stackprotector
>  nostackp := $(call cc-option, -fno-stack-protector)
> diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
> index db7a10082238..db0a4dfb5a7f 100644
> --- a/arch/x86/mm/pageattr.c
> +++ b/arch/x86/mm/pageattr.c
> @@ -2248,9 +2248,7 @@ int set_pages_rw(struct page *page, int numpages)
>         return set_memory_rw(addr, numpages);
>  }
>
> -#ifdef CONFIG_DEBUG_PAGEALLOC
> -
> -static int __set_pages_p(struct page *page, int numpages)
> +int set_pages_p_noflush(struct page *page, int numpages)

Maybe set_pages_rwp_noflush()?

> diff --git a/arch/x86/mm/vmalloc.c b/arch/x86/mm/vmalloc.c
> new file mode 100644
> index 000000000000..be9ea42c3dfe
> --- /dev/null
> +++ b/arch/x86/mm/vmalloc.c
> @@ -0,0 +1,71 @@
> +// SPDX-License-Identifier: GPL-2.0
> +/*
> + * vmalloc.c: x86 arch version of vmalloc.c
> + *
> + * (C) Copyright 2018 Intel Corporation
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * as published by the Free Software Foundation; version 2
> + * of the License.

This paragraph may be redundant with the SPDX line.

> + */
> +
> +#include <linux/mm.h>
> +#include <linux/set_memory.h>
> +#include <linux/vmalloc.h>
> +
> +static void set_area_direct_np(struct vm_struct *area)
> +{
> +       int i;
> +
> +       for (i = 0; i < area->nr_pages; i++)
> +               set_pages_np_noflush(area->pages[i], 1);
> +}
> +
> +static void set_area_direct_prw(struct vm_struct *area)
> +{
> +       int i;
> +
> +       for (i = 0; i < area->nr_pages; i++)
> +               set_pages_p_noflush(area->pages[i], 1);
> +}
> +
> +void arch_vunmap(struct vm_struct *area, int deallocate_pages)
> +{
> +       int immediate = area->flags & VM_IMMEDIATE_UNMAP;
> +       int special = area->flags & VM_HAS_SPECIAL_PERMS;
> +
> +       /* Unmap from vmalloc area */
> +       remove_vm_area(area->addr);
> +
> +       /* If no need to reset directmap perms, just check if need to flush */
> +       if (!(deallocate_pages || special)) {
> +               if (immediate)
> +                       vm_unmap_aliases();
> +               return;
> +       }
> +
> +       /* From here we need to make sure to reset the direct map perms */
> +
> +       /*
> +        * If the area being freed does not have any extra capabilities, we can
> +        * just reset the directmap to RW before freeing.
> +        */
> +       if (!immediate) {
> +               set_area_direct_prw(area);
> +               vm_unmap_aliases();
> +               return;
> +       }
> +
> +       /*
> +        * If the vm being freed has security sensitive capabilities such as
> +        * executable we need to make sure there is no W window on the directmap
> +        * before removing the X in the TLB. So we set not present first so we
> +        * can flush without any other CPU picking up the mapping. Then we reset
> +        * RW+P without a flush, since NP prevented it from being cached by
> +        * other cpus.
> +        */
> +       set_area_direct_np(area);
> +       vm_unmap_aliases();
> +       set_area_direct_prw(area);

Here you're using "immediate" as a proxy for "was executable".  And
it's barely faster to omit immediate -- it's the same number of
flushes, and all you save is one pass over the direct map.

Do we really need to support all these combinations?  Even if we do
support them, I think that "immediate" needs a better name.
