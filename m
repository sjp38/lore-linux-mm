Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id CC2936B74CB
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 09:35:13 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id b17so16836286pfc.11
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 06:35:13 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c3si20156079pls.73.2018.12.05.06.35.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Dec 2018 06:35:12 -0800 (PST)
Date: Wed, 5 Dec 2018 06:35:10 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH RFC 7/7] mm: better document PG_reserved
Message-ID: <20181205143510.GA17232@bombadil.infradead.org>
References: <20181205122851.5891-1-david@redhat.com>
 <20181205122851.5891-8-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181205122851.5891-8-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-m68k@lists.linux-m68k.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-mediatek@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Pavel Tatashin <pasha.tatashin@oracle.com>, Michal Hocko <mhocko@suse.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Anthony Yznaga <anthony.yznaga@oracle.com>, Miles Chen <miles.chen@mediatek.com>, yi.z.zhang@linux.intel.com, Dan Williams <dan.j.williams@intel.com>

On Wed, Dec 05, 2018 at 01:28:51PM +0100, David Hildenbrand wrote:
> I don't see a reason why we have to document "Some of them might not even
> exist". If there is a user, we should document it. E.g. for balloon
> drivers we now use PG_offline to indicate that a page might currently
> not be backed by memory in the hypervisor. And that is independent from
> PG_reserved.

I think you're confused by the meaning of "some of them might not even
exist".  What this means is that there might not be memory there; maybe
writes to that memory will be discarded, or maybe they'll cause a machine
check.  Maybe reads will return ~0, or 0, or cause a machine check.
We just don't know what's there, and we shouldn't try touching the memory.

> +++ b/include/linux/page-flags.h
> @@ -17,8 +17,22 @@
>  /*
>   * Various page->flags bits:
>   *
> - * PG_reserved is set for special pages, which can never be swapped out. Some
> - * of them might not even exist...
> + * PG_reserved is set for special pages. The "struct page" of such a page
> + * should in general not be touched (e.g. set dirty) except by their owner.
> + * Pages marked as PG_reserved include:
> + * - Kernel image (including vDSO) and similar (e.g. BIOS, initrd)
> + * - Pages allocated early during boot (bootmem, memblock)
> + * - Zero pages
> + * - Pages that have been associated with a zone but are not available for
> + *   the page allocator (e.g. excluded via online_page_callback())
> + * - Pages to exclude from the hibernation image (e.g. loaded kexec images)
> + * - MMIO pages (communicate with a device, special caching strategy needed)
> + * - MCA pages on ia64 (pages with memory errors)
> + * - Device memory (e.g. PMEM, DAX, HMM)
> + * Some architectures don't allow to ioremap pages that are not marked
> + * PG_reserved (as they might be in use by somebody else who does not respect
> + * the caching strategy). Consequently, PG_reserved for a page mapped into
> + * user space can indicate the zero page, the vDSO, MMIO pages or device memory.

So maybe just add one more option to the list.
