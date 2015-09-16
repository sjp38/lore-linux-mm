Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id D47916B0038
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 13:05:04 -0400 (EDT)
Received: by iofb144 with SMTP id b144so237392064iof.1
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 10:05:04 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c9si3915854igg.40.2015.09.16.10.05.03
        for <linux-mm@kvack.org>;
        Wed, 16 Sep 2015 10:05:03 -0700 (PDT)
Date: Wed, 16 Sep 2015 18:05:05 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] arm64: Add support for PTE contiguous bit.
Message-ID: <20150916170505.GR28771@arm.com>
References: <1442340117-3964-1-git-send-email-dwoods@ezchip.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442340117-3964-1-git-send-email-dwoods@ezchip.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woods <dwoods@ezchip.com>
Cc: Chris Metcalf <cmetcalf@ezchip.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Steve Capper <steve.capper@linaro.org>, Marc Zyngier <Marc.Zyngier@arm.com>, Hugh Dickins <hughd@google.com>, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi David,

On Tue, Sep 15, 2015 at 07:01:57PM +0100, David Woods wrote:
> The arm64 MMU supports a Contiguous bit which is a hint that the TTE
> is one of a set of contiguous entries which can be cached in a single
> TLB entry.  Supporting this bit adds new intermediate huge page sizes.
> 
> The set of huge page sizes available depends on the base page size.
> Without using contiguous pages the huge page sizes are as follows.
> 
>  4KB:   2MB  1GB
> 64KB: 512MB  4TB
> 
> With 4KB pages, the contiguous bit groups together sets of 16 pages
> and with 64KB pages it groups sets of 32 pages.  This enables two new
> huge page sizes in each case, so that the full set of available sizes
> is as follows.
> 
>  4KB:  64KB   2MB  32MB  1GB
> 64KB:   2MB 512MB  16GB  4TB
> 
> If the base page size is set to 64KB then 2MB pages are enabled by
> default.  It is possible in the future to make 2MB the default huge
> page size for both 4KB and 64KB pages.
> 
> Signed-off-by: David Woods <dwoods@ezchip.com>
> Reviewed-by: Chris Metcalf <cmetcalf@ezchip.com>
> ---
>  arch/arm64/Kconfig                     |   3 -
>  arch/arm64/include/asm/hugetlb.h       |   4 +
>  arch/arm64/include/asm/pgtable-hwdef.h |  15 +++
>  arch/arm64/include/asm/pgtable.h       |  30 +++++-
>  arch/arm64/mm/hugetlbpage.c            | 165 ++++++++++++++++++++++++++++++++-
>  5 files changed, 210 insertions(+), 7 deletions(-)

I glanced briefly at this, and I think you'll need to do some extra work
for the CONFIG_HW_AFDBM=y case, where the CPU can set access/dirty bits
in any (i.e. not necessarily all) of the page table entries in a
contiguous mapping. In this case, things like huge_pte_dirty might need
overriding.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
