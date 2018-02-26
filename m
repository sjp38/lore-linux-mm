Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 458956B0007
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 06:04:23 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id y8so2891690ote.15
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 03:04:23 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b13si2629445oih.300.2018.02.26.03.04.22
        for <linux-mm@kvack.org>;
        Mon, 26 Feb 2018 03:04:22 -0800 (PST)
Date: Mon, 26 Feb 2018 11:04:22 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: =?utf-8?B?562U5aSNOiBbUkZDIHBhdGNoXSBp?= =?utf-8?Q?oremap?=
 =?utf-8?Q?=3A?= don't set up huge I/O mappings when p4d/pud/pmd is zero
Message-ID: <20180226110422.GD8736@arm.com>
References: <1514460261-65222-1-git-send-email-guohanjun@huawei.com>
 <861128ce-966f-7006-45ba-6a7298918686@codeaurora.org>
 <1519175992.16384.121.camel@hpe.com>
 <etPan.5a8d2180.1dbfd272.49b8@localhost>
 <20180221115758.GA7614@arm.com>
 <32c9b1c3-086b-ba54-f9e9-aefa50066730@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <32c9b1c3-086b-ba54-f9e9-aefa50066730@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hanjun Guo <guohanjun@huawei.com>
Cc: "Wangxuefeng (E)" <wxf.wang@hisilicon.com>, "toshi.kani" <toshi.kani@hpe.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, cpandya <cpandya@codeaurora.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linuxarm <linuxarm@huawei.com>, linux-mm <linux-mm@kvack.org>, akpm <akpm@linux-foundation.org>, "mark.rutland" <mark.rutland@arm.com>, "catalin.marinas" <catalin.marinas@arm.com>, mhocko <mhocko@suse.com>, "hanjun.guo" <hanjun.guo@linaro.org>

On Mon, Feb 26, 2018 at 06:57:20PM +0800, Hanjun Guo wrote:
> On 2018/2/21 19:57, Will Deacon wrote:
> > [sorry, trying to deal with top-posting here]
> > 
> > On Wed, Feb 21, 2018 at 07:36:34AM +0000, Wangxuefeng (E) wrote:
> >>      The old flow of reuse the 4k page as 2M page does not follow the BBM flow
> >> for page table reconstructioni 1/4 ?not only the memory leak problems.  If BBM flow
> >> is not followedi 1/4 ?the speculative prefetch of tlb will made false tlb entries
> >> cached in MMU, the false address will be goti 1/4 ? panic will happen.
> > 
> > If I understand Toshi's suggestion correctly, he's saying that the PMD can
> > be cleared when unmapping the last PTE (like try_to_free_pte_page). In this
> > case, there's no issue with the TLB because this is exactly BBM -- the PMD
> > is cleared and TLB invalidation is issued before the PTE table is freed. A
> > subsequent 2M map request will see an empty PMD and put down a block
> > mapping.
> > 
> > The downside is that freeing becomes more expensive as the last level table
> > becomes more sparsely populated and you need to ensure you don't have any
> > concurrent maps going on for the same table when you're unmapping. I also
> > can't see a neat way to fit this into the current vunmap code. Perhaps we
> > need an iounmap_page_range.
> > 
> > In the meantime, the code in lib/ioremap.c looks totally broken so I think
> > we should deselect CONFIG_HAVE_ARCH_HUGE_VMAP on arm64 until it's fixed.
> 
> Simply do something below at now (before the broken code is fixed)?
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index b2b95f7..a86148c 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -84,7 +84,6 @@ config ARM64
>         select HAVE_ALIGNED_STRUCT_PAGE if SLUB
>         select HAVE_ARCH_AUDITSYSCALL
>         select HAVE_ARCH_BITREVERSE
> -   select HAVE_ARCH_HUGE_VMAP
>         select HAVE_ARCH_JUMP_LABEL
>         select HAVE_ARCH_KASAN if !(ARM64_16K_PAGES && ARM64_VA_BITS_48)
>         select HAVE_ARCH_KGDB

No, that actually breaks with the use of block mappings for the kernel
text. Anyway, see:

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=15122ee2c515a253b0c66a3e618bc7ebe35105eb

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
