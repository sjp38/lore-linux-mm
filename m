Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04255C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 21:02:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F35620656
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 21:02:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="aKjnu5T9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F35620656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43F3F6B000D; Tue,  7 May 2019 17:02:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3EF926B000E; Tue,  7 May 2019 17:02:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2910C6B0010; Tue,  7 May 2019 17:02:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id F017C6B000D
	for <linux-mm@kvack.org>; Tue,  7 May 2019 17:02:16 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id v13so2315102oie.12
        for <linux-mm@kvack.org>; Tue, 07 May 2019 14:02:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=45qD73j/kj+Yrs+a6400FKd0OOGHzurHt4ZIRvIFUxk=;
        b=dC+hjTVBJuVJvnhxG5zprXccafpYe9s6uWYU3wTr68rV6SN6lrZzS3xhVfx3LprtEU
         eynVAUqCPKCjOp/mXLruzFweskZ1oXOyTFyPeuwyqqySvWXF2Tv6Y64F3FfNFADoayXw
         Uv7EgNjCl0bU5Rm+Ax5EUxP5r68QIm/VeYx8/EuCf4CTSHQvbusm3Cch6985LXvkOsxb
         x3cvTMeLf3DBNOSAPFxL5uSKTDazjS8KGUMLQi6i9QXX/593GDGPvHc/wg7ZG278RyQi
         CtfIyimtjwL/SxEfhk6QItUuLZH7a5OImamLCe52YUbo60vL/NC5QKxNAL3IUYnEhHgq
         wadQ==
X-Gm-Message-State: APjAAAUH5A/ylCAxt41JzN7vdzaST2kj8+xUXwQ/FFUCG2AcodTqW2no
	wdKpVt1BIJQtZWvAaBmrGP+UgZbnwI28cr4pVBZYOCSRqBP2zQEa0ZsH5HqKIDlOY6yqLSW0Cwa
	I9DOstvlW3SDOlOVBM9LfemcZWyKeASCEPwqCny0l9uxVgvYEsTPCzdfxunTXHPVLFw==
X-Received: by 2002:aca:3405:: with SMTP id b5mr323312oia.40.1557262936548;
        Tue, 07 May 2019 14:02:16 -0700 (PDT)
X-Received: by 2002:aca:3405:: with SMTP id b5mr323254oia.40.1557262935564;
        Tue, 07 May 2019 14:02:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557262935; cv=none;
        d=google.com; s=arc-20160816;
        b=j99XqXe6cW2aFE4M7ImN+KUKg8g3IWKTE6/pmiSGdHM1ykzOZNMD/HHV08xeomBczD
         1yBNdNkAJclMfSjRbHGvZpVn1/lYcRDFxgIGx46AGXUHpY7JKR5AOEHlsdanMQ35H8v3
         PnESyWp/PiOrKYAKV7jsq8IEOp5CnFfNjL/hG8EX9geiJ1O2HZh8mKoOK2ymNlpsK17U
         e+f5yrYo/tjdX/grkAzd//RJUrUCTySk5UIB8Gzf5GHobiFleBLRoyR5L5WpoQq5WTSJ
         6fGBoLCNV+QH0b4oHkGaJ4q+PV22u7wF0qg6n1IpfV2t/qte+yntvgofq4lqiYBSq4fa
         fA9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=45qD73j/kj+Yrs+a6400FKd0OOGHzurHt4ZIRvIFUxk=;
        b=TfPvRCWWOXov2KEj23oUaQfHMUtJJaEAPGxoz3ACuOmHmFwdKQUCaiKIVWNDzLdTIQ
         q3O9E5qPQ6m45u6UXHi/qzk9r9diWzlJqCdIRj8QWQikjQSvH1rm762CMoYDWwuwWsWd
         QHHVc2VEfB3oikayl6R5LYnyjn+p/iFkv9Kn9dIV/Bx6JPE3UFomwFTtFGLgK//HXKuy
         +0oJY0hrrjej1KUElzKEnrq7tvwwp7dAjqtZRd/WuSCHksPhhk/xuVR/ZhMfXBdOadjv
         MgiEFt2PhqYu7PvQBcKTIzyvr65t203gpjdGT19CnNz7JTx75sflRtJYWHqQKv12NKWU
         E8cA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=aKjnu5T9;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n127sor6273566oih.169.2019.05.07.14.02.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 14:02:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=aKjnu5T9;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=45qD73j/kj+Yrs+a6400FKd0OOGHzurHt4ZIRvIFUxk=;
        b=aKjnu5T94oAi5XuoZSUACQovXis8kBeXEPSlrU/jE6KzUHv63+LkHWOXj7Ul4cy8JM
         MRBt+IYV1zghhpx217oRXyTOdRcPV0MIvsTexDSNyRu0T5qaeqJMZ0321j+MJ+4+IoTJ
         QU8EAU7+4r1FjnWqpTmwxXpcynVDN4NStntcJV/9P/ofoUKifRu0ElioByLbR1gFFAlQ
         07z/LEv+pCWSxpbOTDVZKgk20922wkdOM2JaarMIOir/V4W1xOUgICg30LTtq90lE8CZ
         yb+bQh03ycx2t+cBP5Sl78srNbYWVqZIEwwKcInnZ084J3t8JPZhzuzD80ZjXw3z3MeM
         J0Lw==
X-Google-Smtp-Source: APXvYqwUggt0ll17lJcUQps1vubYeL9ujvgAmDTqrw0CH57ncRJR/cnHgI+g1CwK4YxQJ6JEBjUqsw5JNCojkigylvQ=
X-Received: by 2002:aca:220f:: with SMTP id b15mr285608oic.73.1557262935026;
 Tue, 07 May 2019 14:02:15 -0700 (PDT)
MIME-Version: 1.0
References: <20190507183804.5512-1-david@redhat.com> <20190507183804.5512-4-david@redhat.com>
In-Reply-To: <20190507183804.5512-4-david@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 7 May 2019 14:02:03 -0700
Message-ID: <CAPcyv4jpnKjeP3QEvF3_9CzdZhtFXN2nMU7P-Ee7y06J3bGZ0A@mail.gmail.com>
Subject: Re: [PATCH v2 3/8] mm/memory_hotplug: arch_remove_memory() and
 __remove_pages() with CONFIG_MEMORY_HOTPLUG
To: David Hildenbrand <david@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, 
	Linux-sh <linux-sh@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, 
	Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, 
	Rich Felker <dalias@libc.org>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, 
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
	"H. Peter Anvin" <hpa@zytor.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	"Rafael J. Wysocki" <rafael@kernel.org>, Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.ibm.com>, 
	Oscar Salvador <osalvador@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	Alex Deucher <alexander.deucher@amd.com>, "David S. Miller" <davem@davemloft.net>, 
	Mark Brown <broonie@kernel.org>, Chris Wilson <chris@chris-wilson.co.uk>, 
	Christophe Leroy <christophe.leroy@c-s.fr>, Nicholas Piggin <npiggin@gmail.com>, 
	Vasily Gorbik <gor@linux.ibm.com>, Rob Herring <robh@kernel.org>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, "mike.travis@hpe.com" <mike.travis@hpe.com>, 
	Andrew Banman <andrew.banman@hpe.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, 
	Wei Yang <richardw.yang@linux.intel.com>, Arun KS <arunks@codeaurora.org>, 
	Qian Cai <cai@lca.pw>, Mathieu Malaterre <malat@debian.org>, Baoquan He <bhe@redhat.com>, 
	Logan Gunthorpe <logang@deltatee.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 7, 2019 at 11:38 AM David Hildenbrand <david@redhat.com> wrote:
>
> Let's prepare for better error handling while adding memory by allowing
> to use arch_remove_memory() and __remove_pages() even if
> CONFIG_MEMORY_HOTREMOVE is not set. CONFIG_MEMORY_HOTREMOVE effectively
> covers
> - Offlining of system ram (memory block devices) - offline_pages()
> - Unplug of system ram - remove_memory()
> - Unplug/remap of device memory - devm_memremap()
>
> This allows e.g. for handling like
>
> arch_add_memory()
> rc = do_something();
> if (rc) {
>         arch_remove_memory();
> }
>
> Whereby do_something() will for example be memory block device creation
> after it has been factored out.

What's left after this? Can we just get rid of CONFIG_MEMORY_HOTREMOVE
option completely when CONFIG_MEMORY_HOTPLUG is enabled? It's not
clear to me why there was ever the option to compile out the remove
code when the add code is included.

> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
> Cc: Rich Felker <dalias@libc.org>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Borislav Petkov <bp@alien8.de>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Mike Rapoport <rppt@linux.ibm.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Oscar Salvador <osalvador@suse.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Alex Deucher <alexander.deucher@amd.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Mark Brown <broonie@kernel.org>
> Cc: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Christophe Leroy <christophe.leroy@c-s.fr>
> Cc: Nicholas Piggin <npiggin@gmail.com>
> Cc: Vasily Gorbik <gor@linux.ibm.com>
> Cc: Rob Herring <robh@kernel.org>
> Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
> Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
> Cc: Andrew Banman <andrew.banman@hpe.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Wei Yang <richardw.yang@linux.intel.com>
> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Mathieu Malaterre <malat@debian.org>
> Cc: Baoquan He <bhe@redhat.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  arch/ia64/mm/init.c            | 2 --
>  arch/powerpc/mm/mem.c          | 2 --
>  arch/s390/mm/init.c            | 2 --
>  arch/sh/mm/init.c              | 2 --
>  arch/x86/mm/init_32.c          | 2 --
>  arch/x86/mm/init_64.c          | 2 --
>  drivers/base/memory.c          | 2 --
>  include/linux/memory.h         | 2 --
>  include/linux/memory_hotplug.h | 2 --
>  mm/memory_hotplug.c            | 2 --
>  mm/sparse.c                    | 6 ------
>  11 files changed, 26 deletions(-)
>
> diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
> index d28e29103bdb..aae75fd7b810 100644
> --- a/arch/ia64/mm/init.c
> +++ b/arch/ia64/mm/init.c
> @@ -681,7 +681,6 @@ int arch_add_memory(int nid, u64 start, u64 size,
>         return ret;
>  }
>
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  void arch_remove_memory(int nid, u64 start, u64 size,
>                         struct vmem_altmap *altmap)
>  {
> @@ -693,4 +692,3 @@ void arch_remove_memory(int nid, u64 start, u64 size,
>         __remove_pages(zone, start_pfn, nr_pages, altmap);
>  }
>  #endif
> -#endif
> diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
> index a2b78e72452f..ddc69b59575c 100644
> --- a/arch/powerpc/mm/mem.c
> +++ b/arch/powerpc/mm/mem.c
> @@ -131,7 +131,6 @@ int __ref arch_add_memory(int nid, u64 start, u64 size,
>         return __add_pages(nid, start_pfn, nr_pages, restrictions);
>  }
>
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  void __ref arch_remove_memory(int nid, u64 start, u64 size,
>                              struct vmem_altmap *altmap)
>  {
> @@ -164,7 +163,6 @@ void __ref arch_remove_memory(int nid, u64 start, u64 size,
>         resize_hpt_for_hotplug(memblock_phys_mem_size());
>  }
>  #endif
> -#endif /* CONFIG_MEMORY_HOTPLUG */
>
>  #ifndef CONFIG_NEED_MULTIPLE_NODES
>  void __init mem_topology_setup(void)
> diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
> index 1e0cbae69f12..eafa3c750efc 100644
> --- a/arch/s390/mm/init.c
> +++ b/arch/s390/mm/init.c
> @@ -233,7 +233,6 @@ int arch_add_memory(int nid, u64 start, u64 size,
>         return rc;
>  }
>
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  void arch_remove_memory(int nid, u64 start, u64 size,
>                         struct vmem_altmap *altmap)
>  {
> @@ -245,5 +244,4 @@ void arch_remove_memory(int nid, u64 start, u64 size,
>         __remove_pages(zone, start_pfn, nr_pages, altmap);
>         vmem_remove_mapping(start, size);
>  }
> -#endif
>  #endif /* CONFIG_MEMORY_HOTPLUG */
> diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
> index 5aeb4d7099a1..59c5fe511f25 100644
> --- a/arch/sh/mm/init.c
> +++ b/arch/sh/mm/init.c
> @@ -428,7 +428,6 @@ int memory_add_physaddr_to_nid(u64 addr)
>  EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
>  #endif
>
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  void arch_remove_memory(int nid, u64 start, u64 size,
>                         struct vmem_altmap *altmap)
>  {
> @@ -439,5 +438,4 @@ void arch_remove_memory(int nid, u64 start, u64 size,
>         zone = page_zone(pfn_to_page(start_pfn));
>         __remove_pages(zone, start_pfn, nr_pages, altmap);
>  }
> -#endif
>  #endif /* CONFIG_MEMORY_HOTPLUG */
> diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
> index 075e568098f2..8d4bf2d97d50 100644
> --- a/arch/x86/mm/init_32.c
> +++ b/arch/x86/mm/init_32.c
> @@ -859,7 +859,6 @@ int arch_add_memory(int nid, u64 start, u64 size,
>         return __add_pages(nid, start_pfn, nr_pages, restrictions);
>  }
>
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  void arch_remove_memory(int nid, u64 start, u64 size,
>                         struct vmem_altmap *altmap)
>  {
> @@ -871,7 +870,6 @@ void arch_remove_memory(int nid, u64 start, u64 size,
>         __remove_pages(zone, start_pfn, nr_pages, altmap);
>  }
>  #endif
> -#endif
>
>  int kernel_set_to_readonly __read_mostly;
>
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 20d14254b686..f1b55ddea23f 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -1131,7 +1131,6 @@ void __ref vmemmap_free(unsigned long start, unsigned long end,
>         remove_pagetable(start, end, false, altmap);
>  }
>
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  static void __meminit
>  kernel_physical_mapping_remove(unsigned long start, unsigned long end)
>  {
> @@ -1156,7 +1155,6 @@ void __ref arch_remove_memory(int nid, u64 start, u64 size,
>         __remove_pages(zone, start_pfn, nr_pages, altmap);
>         kernel_physical_mapping_remove(start, start + size);
>  }
> -#endif
>  #endif /* CONFIG_MEMORY_HOTPLUG */
>
>  static struct kcore_list kcore_vsyscall;
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index f180427e48f4..6e0cb4fda179 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -728,7 +728,6 @@ int hotplug_memory_register(int nid, struct mem_section *section)
>         return ret;
>  }
>
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  static void
>  unregister_memory(struct memory_block *memory)
>  {
> @@ -767,7 +766,6 @@ void unregister_memory_section(struct mem_section *section)
>  out_unlock:
>         mutex_unlock(&mem_sysfs_mutex);
>  }
> -#endif /* CONFIG_MEMORY_HOTREMOVE */
>
>  /* return true if the memory block is offlined, otherwise, return false */
>  bool is_memblock_offlined(struct memory_block *mem)
> diff --git a/include/linux/memory.h b/include/linux/memory.h
> index e1dc1bb2b787..474c7c60c8f2 100644
> --- a/include/linux/memory.h
> +++ b/include/linux/memory.h
> @@ -112,9 +112,7 @@ extern void unregister_memory_notifier(struct notifier_block *nb);
>  extern int register_memory_isolate_notifier(struct notifier_block *nb);
>  extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
>  int hotplug_memory_register(int nid, struct mem_section *section);
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  extern void unregister_memory_section(struct mem_section *);
> -#endif
>  extern int memory_dev_init(void);
>  extern int memory_notify(unsigned long val, void *v);
>  extern int memory_isolate_notify(unsigned long val, void *v);
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index ae892eef8b82..2d4de313926d 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -123,12 +123,10 @@ static inline bool movable_node_is_enabled(void)
>         return movable_node_enabled;
>  }
>
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  extern void arch_remove_memory(int nid, u64 start, u64 size,
>                                struct vmem_altmap *altmap);
>  extern void __remove_pages(struct zone *zone, unsigned long start_pfn,
>                            unsigned long nr_pages, struct vmem_altmap *altmap);
> -#endif /* CONFIG_MEMORY_HOTREMOVE */
>
>  /*
>   * Do we want sysfs memblock files created. This will allow userspace to online
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 202febe88b58..7b5439839d67 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -317,7 +317,6 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
>         return err;
>  }
>
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  /* find the smallest valid pfn in the range [start_pfn, end_pfn) */
>  static unsigned long find_smallest_section_pfn(int nid, struct zone *zone,
>                                      unsigned long start_pfn,
> @@ -581,7 +580,6 @@ void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
>
>         set_zone_contiguous(zone);
>  }
> -#endif /* CONFIG_MEMORY_HOTREMOVE */
>
>  int set_online_page_callback(online_page_callback_t callback)
>  {
> diff --git a/mm/sparse.c b/mm/sparse.c
> index fd13166949b5..d1d5e05f5b8d 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -604,7 +604,6 @@ static void __kfree_section_memmap(struct page *memmap,
>
>         vmemmap_free(start, end, altmap);
>  }
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  static void free_map_bootmem(struct page *memmap)
>  {
>         unsigned long start = (unsigned long)memmap;
> @@ -612,7 +611,6 @@ static void free_map_bootmem(struct page *memmap)
>
>         vmemmap_free(start, end, NULL);
>  }
> -#endif /* CONFIG_MEMORY_HOTREMOVE */
>  #else
>  static struct page *__kmalloc_section_memmap(void)
>  {
> @@ -651,7 +649,6 @@ static void __kfree_section_memmap(struct page *memmap,
>                            get_order(sizeof(struct page) * PAGES_PER_SECTION));
>  }
>
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  static void free_map_bootmem(struct page *memmap)
>  {
>         unsigned long maps_section_nr, removing_section_nr, i;
> @@ -681,7 +678,6 @@ static void free_map_bootmem(struct page *memmap)
>                         put_page_bootmem(page);
>         }
>  }
> -#endif /* CONFIG_MEMORY_HOTREMOVE */
>  #endif /* CONFIG_SPARSEMEM_VMEMMAP */
>
>  /**
> @@ -746,7 +742,6 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
>         return ret;
>  }
>
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  #ifdef CONFIG_MEMORY_FAILURE
>  static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
>  {
> @@ -823,5 +818,4 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
>                         PAGES_PER_SECTION - map_offset);
>         free_section_usemap(memmap, usemap, altmap);
>  }
> -#endif /* CONFIG_MEMORY_HOTREMOVE */
>  #endif /* CONFIG_MEMORY_HOTPLUG */
> --
> 2.20.1
>

