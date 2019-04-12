Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B83B3C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 18:52:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F81720869
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 18:52:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="ePQZp33I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F81720869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B2BC6B0010; Fri, 12 Apr 2019 14:52:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 064126B026A; Fri, 12 Apr 2019 14:52:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF9696B026B; Fri, 12 Apr 2019 14:52:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A02496B0010
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 14:52:39 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id s26so6942763pfm.18
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 11:52:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=Ri+qpns+QZtMlaujqaIr1XlrklS3xsQzd/K9wOKnv8A=;
        b=LV7UC2hABEFblC/PlVhu/x6EbZZRiJV+Rm8t8C/GfScNlKisH4cQ/33lj3yADv38kz
         /MHPDtMtYjO1r0lefOZMUh0uYRPSs+ERKeOnVcCquzCjkZ6VBWJ6IOYKLzGqNHcOLkhL
         sZOOvgWxS62HkQFAsx8QZvFLnmsukUuR+Sejq5AHW9VMoz6fuHbCtzVJ1RhvaGkhI3yI
         2gZNsDYR500kGVD0SLw1w8eZg2pk2q24uuMlwG3DFP5oCHvmxZ1aWPcT0fqClj4UkHzS
         XHGFBX/oSrhTM4Bf9JPCJXAP09SZsc4EiX+vqDd9ZFYjbrjZkbfK+o/FJOs8QG+ZU/Ar
         yPhQ==
X-Gm-Message-State: APjAAAVMuWRE43M7Cq0xS2d1N9jSkYMQBxGSxokinfjTxaQ35uY69Xrg
	NB0mj3oGmTXDfSCffu63PqQVcbLg1f+/26klXmF9C4rsreddhKiR500cKCJ2dDx6Gt7LM9HcXid
	+3HLI+qPguyVmNoxh7ul/k57xvSf4zuFn4IsGrglM7IfddmePiq6cDh1EfmD/QMY5Ew==
X-Received: by 2002:aa7:92d5:: with SMTP id k21mr58389646pfa.223.1555095159068;
        Fri, 12 Apr 2019 11:52:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxX749C2cTGwBCy5EwDQVWCXf9jyxdVwralSQr+USAeIhUuW2PmfmvFKrcfQlu5nEchKgFx
X-Received: by 2002:aa7:92d5:: with SMTP id k21mr58389562pfa.223.1555095157981;
        Fri, 12 Apr 2019 11:52:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555095157; cv=none;
        d=google.com; s=arc-20160816;
        b=jZnDEkj9DpuUycNz162ZY3cQaw9HJryU14gOsDPq+nPFM/q54+G+Ebjz+Ae5yOVeNs
         xWReZ25tx1e2+DyjCQvMoHPIi0BQatyLO0Vx82bYILcuh17gE3B0Suaes7lcO6v74hM+
         qB9HdO4cqExsp2qn0YlgGWlZ8PiJ1d1m7pwW6hplZKm3N0vk7AuWHAS80Fc1bGFB9AWf
         3S3OsFM039RIwH3iUKTBcrPrgKQAsxJgK7WLkP627CuGd4ar9ImeY/iS+1v3BXhmkbNA
         M4zG43R3txtLgAiUOuGe06nh9sqmtHUcWr8wtTiF7YB9gTRBpnU04PTwmD4ypAhWY87n
         dbTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=Ri+qpns+QZtMlaujqaIr1XlrklS3xsQzd/K9wOKnv8A=;
        b=QQPXyPkXZdM/ToyKQLXpEvMO+TZ47g5DPZF3n7IZWspCFS8pTDYCs/Dml8ydsezd09
         e4U+ttgxrRGp1oabgDEjJbN1n13pO8QWH+csUH+3oqrD4fXYAwbSSaf7Gis+X7QUV9pS
         7TwlXpl9xlrHMN3NOZzyJGe69Jt1ZLJLmu2voj3enfIhy+GldEnn4w8dILvwzSAx6dlG
         4fAZONKULcti0nkxoIy1hNg6mTlyl24BYvr4otl4q9MAJbAvC4zIU/4molCb5N7AS92a
         OqR0VtEhdLKB7JATgYPsn5hWtx5a7L30l6KvwigvPznAN4eqtNHQyIfS1c48UVnKNtXB
         jKiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=ePQZp33I;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id l77si21234949pfb.34.2019.04.12.11.52.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 11:52:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=ePQZp33I;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cb0de720000>; Fri, 12 Apr 2019 11:52:34 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 12 Apr 2019 11:52:36 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 12 Apr 2019 11:52:36 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 12 Apr
 2019 18:52:36 +0000
Subject: Re: [PATCH 3/9] mm: Add write-protect and clean utilities for address
 space ranges
To: Thomas Hellstrom <thellstrom@vmware.com>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	Linux-graphics-maintainer <Linux-graphics-maintainer@vmware.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
CC: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox
	<willy@infradead.org>, Will Deacon <will.deacon@arm.com>, Peter Zijlstra
	<peterz@infradead.org>, Rik van Riel <riel@surriel.com>, Minchan Kim
	<minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Huang Ying
	<ying.huang@intel.com>, Souptick Joarder <jrdr.linux@gmail.com>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>
References: <20190412160338.64994-1-thellstrom@vmware.com>
 <20190412160338.64994-4-thellstrom@vmware.com>
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <e6d86a3a-eae6-5e35-895e-ef944b4fd108@nvidia.com>
Date: Fri, 12 Apr 2019 11:52:36 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190412160338.64994-4-thellstrom@vmware.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1555095154; bh=Ri+qpns+QZtMlaujqaIr1XlrklS3xsQzd/K9wOKnv8A=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=ePQZp33I48WEsKxoKv79gfe9+oSr4AskYD3NXc8YoWYJG70NAV0OstGyzxsjc6Nl2
	 1bHPe9SU0xIBMNpnCh47RgUFtcrGczTTi9g7kNSh/AG25BF61yMq90fIXNI2STfU5Y
	 lVQGJ67BKGPNAgcxtg8EUI+C/b+aCz9lBN+818gVfK4TcAci7/YFnyvEpXKMEbkHIc
	 tR8K4HzB7In/Ts1AYkprJEo9ZHx8RUFo1iaab3qf58sIejqYGuJd6k96We3assGZHY
	 QeiQls4qPxqaEQNW5ty0rZ3MDNEIQSApjpG0dbxQ4BsmwuIP4GzT82IAsipUizzwo5
	 h54+VJPkCg9JQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 4/12/19 9:04 AM, Thomas Hellstrom wrote:
> Add two utilities to a) write-protect and b) clean all ptes pointing into
> a range of an address space

A period at the end, please.

> The utilities are intended to aid in tracking dirty pages (either
> driver-allocated system memory or pci device memory).
> The write-protect utility should be used in conjunction with
> page_mkwrite() and pfn_mkwrite() to trigger write page-faults on page
> accesses. Typically one would want to use this on sparse accesses into
> large memory regions. The clean utility should be used to utilize
> hardware dirtying functionality and avoid the overhead of page-faults,
> typically on large accesses into small memory regions.
>=20
> The added file "apply_as_range.c" is initially listed as maintained by
> VMware under our DRM driver. If somebody would like it elsewhere,
> that's of course no problem.
>=20
> Notable changes since RFC:
> - Added comments to help avoid the usage of these function for VMAs
>    it's not intended for. We also do advisory checks on the vm_flags and
>    warn on illegal usage.
> - Perform the pte modifications the same way softdirty does.
> - Add mmu_notifier range invalidation calls.
> - Add a config option so that this code is not unconditionally included.
> - Tell the mmu_gather code about pending tlb flushes.
>=20
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Rik van Riel <riel@surriel.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Souptick Joarder <jrdr.linux@gmail.com>
> Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Thomas Hellstrom <thellstrom@vmware.com>

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

> ---
>   MAINTAINERS         |   1 +
>   include/linux/mm.h  |   9 +-
>   mm/Kconfig          |   3 +
>   mm/Makefile         |   3 +-
>   mm/apply_as_range.c | 295 ++++++++++++++++++++++++++++++++++++++++++++
>   5 files changed, 309 insertions(+), 2 deletions(-)
>   create mode 100644 mm/apply_as_range.c
>=20
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 35e6357f9d30..bc243ffcb840 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -4971,6 +4971,7 @@ T:	git git://people.freedesktop.org/~thomash/linux
>   S:	Supported
>   F:	drivers/gpu/drm/vmwgfx/
>   F:	include/uapi/drm/vmwgfx_drm.h
> +F:	mm/apply_as_range.c
>  =20
>   DRM DRIVERS
>   M:	David Airlie <airlied@linux.ie>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index b7dd4ddd6efb..62f24dd0bfa0 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2642,7 +2642,14 @@ struct pfn_range_apply {
>   };
>   extern int apply_to_pfn_range(struct pfn_range_apply *closure,
>   			      unsigned long address, unsigned long size);
> -
> +unsigned long apply_as_wrprotect(struct address_space *mapping,
> +				 pgoff_t first_index, pgoff_t nr);
> +unsigned long apply_as_clean(struct address_space *mapping,
> +			     pgoff_t first_index, pgoff_t nr,
> +			     pgoff_t bitmap_pgoff,
> +			     unsigned long *bitmap,
> +			     pgoff_t *start,
> +			     pgoff_t *end);
>   #ifdef CONFIG_PAGE_POISONING
>   extern bool page_poisoning_enabled(void);
>   extern void kernel_poison_pages(struct page *page, int numpages, int en=
able);
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 25c71eb8a7db..80e41cdbb4ae 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -758,4 +758,7 @@ config GUP_BENCHMARK
>   config ARCH_HAS_PTE_SPECIAL
>   	bool
>  =20
> +config AS_DIRTY_HELPERS
> +        bool
> +
>   endmenu
> diff --git a/mm/Makefile b/mm/Makefile
> index d210cc9d6f80..b295717be856 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -39,7 +39,7 @@ obj-y			:=3D filemap.o mempool.o oom_kill.o fadvise.o \
>   			   mm_init.o mmu_context.o percpu.o slab_common.o \
>   			   compaction.o vmacache.o \
>   			   interval_tree.o list_lru.o workingset.o \
> -			   debug.o $(mmu-y)
> +			   debug.o apply_as_range.o $(mmu-y)
>  =20
>   obj-y +=3D init-mm.o
>   obj-y +=3D memblock.o
> @@ -99,3 +99,4 @@ obj-$(CONFIG_HARDENED_USERCOPY) +=3D usercopy.o
>   obj-$(CONFIG_PERCPU_STATS) +=3D percpu-stats.o
>   obj-$(CONFIG_HMM) +=3D hmm.o
>   obj-$(CONFIG_MEMFD_CREATE) +=3D memfd.o
> +obj-$(CONFIG_AS_DIRTY_HELPERS) +=3D apply_as_range.o
> diff --git a/mm/apply_as_range.c b/mm/apply_as_range.c
> new file mode 100644
> index 000000000000..32d28619aec5
> --- /dev/null
> +++ b/mm/apply_as_range.c
> @@ -0,0 +1,295 @@
> +// SPDX-License-Identifier: GPL-2.0
> +#include <linux/mm.h>
> +#include <linux/mm_types.h>
> +#include <linux/hugetlb.h>
> +#include <linux/bitops.h>
> +#include <linux/mmu_notifier.h>
> +#include <asm/cacheflush.h>
> +#include <asm/tlbflush.h>
> +
> +/**
> + * struct apply_as - Closure structure for apply_as_range
> + * @base: struct pfn_range_apply we derive from
> + * @start: Address of first modified pte
> + * @end: Address of last modified pte + 1
> + * @total: Total number of modified ptes
> + * @vma: Pointer to the struct vm_area_struct we're currently operating =
on
> + */
> +struct apply_as {
> +	struct pfn_range_apply base;
> +	unsigned long start, end;

One variable defined per line, please.

> +	unsigned long total;
> +	const struct vm_area_struct *vma;
> +};
> +
> +/**
> + * apply_pt_wrprotect - Leaf pte callback to write-protect a pte
> + * @pte: Pointer to the pte
> + * @token: Page table token, see apply_to_pfn_range()
> + * @addr: The virtual page address
> + * @closure: Pointer to a struct pfn_range_apply embedded in a
> + * struct apply_as
> + *
> + * The function write-protects a pte and records the range in
> + * virtual address space of touched ptes for efficient range TLB flushes=
.
> + *
> + * Return: Always zero.
> + */
> +static int apply_pt_wrprotect(pte_t *pte, pgtable_t token,
> +			      unsigned long addr,
> +			      struct pfn_range_apply *closure)
> +{
> +	struct apply_as *aas =3D container_of(closure, typeof(*aas), base);
> +	pte_t ptent =3D *pte;
> +
> +	if (pte_write(ptent)) {
> +		ptent =3D ptep_modify_prot_start(closure->mm, addr, pte);
> +		ptent =3D pte_wrprotect(ptent);
> +		ptep_modify_prot_commit(closure->mm, addr, pte, ptent);
> +		aas->total++;
> +		aas->start =3D min(aas->start, addr);
> +		aas->end =3D max(aas->end, addr + PAGE_SIZE);
> +	}
> +
> +	return 0;
> +}
> +
> +/**
> + * struct apply_as_clean - Closure structure for apply_as_clean
> + * @base: struct apply_as we derive from
> + * @bitmap_pgoff: Address_space Page offset of the first bit in @bitmap
> + * @bitmap: Bitmap with one bit for each page offset in the address_spac=
e range
> + * covered.
> + * @start: Address_space page offset of first modified pte relative
> + * to @bitmap_pgoff
> + * @end: Address_space page offset of last modified pte relative
> + * to @bitmap_pgoff
> + */
> +struct apply_as_clean {
> +	struct apply_as base;
> +	pgoff_t bitmap_pgoff;
> +	unsigned long *bitmap;
> +	pgoff_t start, end;

One variable defined per line, please.

> +};
> +
> +/**
> + * apply_pt_clean - Leaf pte callback to clean a pte
> + * @pte: Pointer to the pte
> + * @token: Page table token, see apply_to_pfn_range()
> + * @addr: The virtual page address
> + * @closure: Pointer to a struct pfn_range_apply embedded in a
> + * struct apply_as_clean
> + *
> + * The function cleans a pte and records the range in
> + * virtual address space of touched ptes for efficient TLB flushes.
> + * It also records dirty ptes in a bitmap representing page offsets
> + * in the address_space, as well as the first and last of the bits
> + * touched.
> + *
> + * Return: Always zero.
> + */
> +static int apply_pt_clean(pte_t *pte, pgtable_t token,
> +			  unsigned long addr,
> +			  struct pfn_range_apply *closure)
> +{
> +	struct apply_as *aas =3D container_of(closure, typeof(*aas), base);
> +	struct apply_as_clean *clean =3D container_of(aas, typeof(*clean), base=
);
> +	pte_t ptent =3D *pte;
> +
> +	if (pte_dirty(ptent)) {
> +		pgoff_t pgoff =3D ((addr - aas->vma->vm_start) >> PAGE_SHIFT) +
> +			aas->vma->vm_pgoff - clean->bitmap_pgoff;
> +
> +		ptent =3D ptep_modify_prot_start(closure->mm, addr, pte);
> +		ptent =3D pte_mkclean(ptent);
> +		ptep_modify_prot_commit(closure->mm, addr, pte, ptent);
> +
> +		aas->total++;
> +		aas->start =3D min(aas->start, addr);
> +		aas->end =3D max(aas->end, addr + PAGE_SIZE);
> +
> +		__set_bit(pgoff, clean->bitmap);
> +		clean->start =3D min(clean->start, pgoff);
> +		clean->end =3D max(clean->end, pgoff + 1);
> +	}
> +
> +	return 0;
> +}
> +
> +/**
> + * apply_as_range - Apply a pte callback to all PTEs pointing into a ran=
ge
> + * of an address_space.
> + * @mapping: Pointer to the struct address_space
> + * @aas: Closure structure
> + * @first_index: First page offset in the address_space
> + * @nr: Number of incremental page offsets to cover
> + *
> + * Return: Number of ptes touched. Note that this number might be larger
> + * than @nr if there are overlapping vmas
> + */
> +static unsigned long apply_as_range(struct address_space *mapping,
> +				    struct apply_as *aas,
> +				    pgoff_t first_index, pgoff_t nr)
> +{
> +	struct vm_area_struct *vma;
> +	pgoff_t vba, vea, cba, cea;
> +	unsigned long start_addr, end_addr;
> +	struct mmu_notifier_range range;
> +
> +	i_mmap_lock_read(mapping);
> +	vma_interval_tree_foreach(vma, &mapping->i_mmap, first_index,
> +				  first_index + nr - 1) {
> +		unsigned long vm_flags =3D READ_ONCE(vma->vm_flags);
> +
> +		/*
> +		 * We can only do advisory flag tests below, since we can't
> +		 * require the vm's mmap_sem to be held to protect the flags.
> +		 * Therefore, callers that strictly depend on specific mmap
> +		 * flags to remain constant throughout the operation must
> +		 * either ensure those flags are immutable for all relevant
> +		 * vmas or can't use this function. Fixing this properly would
> +		 * require the vma::vm_flags to be protected by a separate
> +		 * lock taken after the i_mmap_lock
> +		 */
> +
> +		/* Skip non-applicable VMAs */
> +		if ((vm_flags & (VM_SHARED | VM_WRITE)) !=3D
> +		    (VM_SHARED | VM_WRITE))
> +			continue;
> +
> +		/* Warn on and skip VMAs whose flags indicate illegal usage */
> +		if (WARN_ON((vm_flags & (VM_HUGETLB | VM_IO)) !=3D VM_IO))
> +			continue;
> +
> +		/* Clip to the vma */
> +		vba =3D vma->vm_pgoff;
> +		vea =3D vba + vma_pages(vma);
> +		cba =3D first_index;
> +		cba =3D max(cba, vba);
> +		cea =3D first_index + nr;
> +		cea =3D min(cea, vea);
> +
> +		/* Translate to virtual address */
> +		start_addr =3D ((cba - vba) << PAGE_SHIFT) + vma->vm_start;
> +		end_addr =3D ((cea - vba) << PAGE_SHIFT) + vma->vm_start;
> +		if (start_addr >=3D end_addr)
> +			continue;
> +
> +		aas->base.mm =3D vma->vm_mm;
> +		aas->vma =3D vma;
> +		aas->start =3D end_addr;
> +		aas->end =3D start_addr;
> +
> +		mmu_notifier_range_init(&range, vma->vm_mm,
> +					start_addr, end_addr);
> +		mmu_notifier_invalidate_range_start(&range);
> +
> +		/* Needed when we only change protection? */
> +		flush_cache_range(vma, start_addr, end_addr);
> +
> +		/*
> +		 * We're not using tlb_gather_mmu() since typically
> +		 * only a small subrange of PTEs are affected.
> +		 */
> +		inc_tlb_flush_pending(vma->vm_mm);
> +
> +		/* Should not error since aas->base.alloc =3D=3D 0 */
> +		WARN_ON(apply_to_pfn_range(&aas->base, start_addr,
> +					   end_addr - start_addr));
> +		if (aas->end > aas->start)
> +			flush_tlb_range(vma, aas->start, aas->end);
> +
> +		mmu_notifier_invalidate_range_end(&range);
> +		dec_tlb_flush_pending(vma->vm_mm);
> +	}
> +	i_mmap_unlock_read(mapping);
> +
> +	return aas->total;
> +}
> +
> +/**
> + * apply_as_wrprotect - Write-protect all ptes in an address_space range
> + * @mapping: The address_space we want to write protect
> + * @first_index: The first page offset in the range
> + * @nr: Number of incremental page offsets to cover
> + *
> + * WARNING: This function should only be used for address spaces that
> + * completely own the pages / memory the page table points to. Typically=
 a
> + * device file.
> + *
> + * Return: The number of ptes actually write-protected. Note that
> + * already write-protected ptes are not counted.
> + */
> +unsigned long apply_as_wrprotect(struct address_space *mapping,
> +				 pgoff_t first_index, pgoff_t nr)
> +{
> +	struct apply_as aas =3D {
> +		.base =3D {
> +			.alloc =3D 0,
> +			.ptefn =3D apply_pt_wrprotect,
> +		},
> +		.total =3D 0,
> +	};
> +
> +	return apply_as_range(mapping, &aas, first_index, nr);
> +}
> +EXPORT_SYMBOL(apply_as_wrprotect);
> +
> +/**
> + * apply_as_clean - Clean all ptes in an address_space range
> + * @mapping: The address_space we want to clean
> + * @first_index: The first page offset in the range
> + * @nr: Number of incremental page offsets to cover
> + * @bitmap_pgoff: The page offset of the first bit in @bitmap
> + * @bitmap: Pointer to a bitmap of at least @nr bits. The bitmap needs t=
o
> + * cover the whole range @first_index..@first_index + @nr.
> + * @start: Pointer to number of the first set bit in @bitmap.
> + * is modified as new bits are set by the function.
> + * @end: Pointer to the number of the last set bit in @bitmap.
> + * none set. The value is modified as new bets are set by the function.

s/bets/bits/

> + *
> + * Note: When this function returns there is no guarantee that a CPU has
> + * not already dirtied new ptes. However it will not clean any ptes not
> + * reported in the bitmap.
> + *
> + * If a caller needs to make sure all dirty ptes are picked up and none
> + * additional are added, it first needs to write-protect the address-spa=
ce
> + * range and make sure new writers are blocked in page_mkwrite() or
> + * pfn_mkwrite(). And then after a TLB flush following the write-protect=
ion
> + * pick upp all dirty bits.

s/upp/up/

> + *
> + * WARNING: This function should only be used for address spaces that
> + * completely own the pages / memory the page table points to. Typically=
 a
> + * device file.
> + *
> + * Return: The number of dirty ptes actually cleaned.
> + */
> +unsigned long apply_as_clean(struct address_space *mapping,
> +			     pgoff_t first_index, pgoff_t nr,
> +			     pgoff_t bitmap_pgoff,
> +			     unsigned long *bitmap,
> +			     pgoff_t *start,
> +			     pgoff_t *end)
> +{
> +	bool none_set =3D (*start >=3D *end);
> +	struct apply_as_clean clean =3D {
> +		.base =3D {
> +			.base =3D {
> +				.alloc =3D 0,
> +				.ptefn =3D apply_pt_clean,
> +			},
> +			.total =3D 0,
> +		},
> +		.bitmap_pgoff =3D bitmap_pgoff,
> +		.bitmap =3D bitmap,
> +		.start =3D none_set ? nr : *start,
> +		.end =3D none_set ? 0 : *end,
> +	};
> +	unsigned long ret =3D apply_as_range(mapping, &clean.base, first_index,
> +					   nr);
> +
> +	*start =3D clean.start;
> +	*end =3D clean.end;
> +	return ret;
> +}
> +EXPORT_SYMBOL(apply_as_clean);
>=20

