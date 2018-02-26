Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 39D3A6B0005
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 05:57:58 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id d19so2167769pgn.20
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 02:57:58 -0800 (PST)
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id i6si1613469pgv.519.2018.02.26.02.57.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 02:57:57 -0800 (PST)
Subject: =?UTF-8?Q?Re:_=e7=ad=94=e5=a4=8d:_[RFC_patch]_ioremap:_don't_set_up?=
 =?UTF-8?Q?_huge_I/O_mappings_when_p4d/pud/pmd_is_zero?=
References: <1514460261-65222-1-git-send-email-guohanjun@huawei.com>
 <861128ce-966f-7006-45ba-6a7298918686@codeaurora.org>
 <1519175992.16384.121.camel@hpe.com> <etPan.5a8d2180.1dbfd272.49b8@localhost>
 <20180221115758.GA7614@arm.com>
From: Hanjun Guo <guohanjun@huawei.com>
Message-ID: <32c9b1c3-086b-ba54-f9e9-aefa50066730@huawei.com>
Date: Mon, 26 Feb 2018 18:57:20 +0800
MIME-Version: 1.0
In-Reply-To: <20180221115758.GA7614@arm.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, "Wangxuefeng (E)" <wxf.wang@hisilicon.com>
Cc: "toshi.kani" <toshi.kani@hpe.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, cpandya <cpandya@codeaurora.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linuxarm <linuxarm@huawei.com>, linux-mm <linux-mm@kvack.org>, akpm <akpm@linux-foundation.org>, "mark.rutland" <mark.rutland@arm.com>, "catalin.marinas" <catalin.marinas@arm.com>, mhocko <mhocko@suse.com>, "hanjun.guo" <hanjun.guo@linaro.org>

On 2018/2/21 19:57, Will Deacon wrote:
> [sorry, trying to deal with top-posting here]
> 
> On Wed, Feb 21, 2018 at 07:36:34AM +0000, Wangxuefeng (E) wrote:
>>      The old flow of reuse the 4k page as 2M page does not follow the BBM flow
>> for page table reconstructioni 1/4 ?not only the memory leak problems.  If BBM flow
>> is not followedi 1/4 ?the speculative prefetch of tlb will made false tlb entries
>> cached in MMU, the false address will be goti 1/4 ? panic will happen.
> 
> If I understand Toshi's suggestion correctly, he's saying that the PMD can
> be cleared when unmapping the last PTE (like try_to_free_pte_page). In this
> case, there's no issue with the TLB because this is exactly BBM -- the PMD
> is cleared and TLB invalidation is issued before the PTE table is freed. A
> subsequent 2M map request will see an empty PMD and put down a block
> mapping.
> 
> The downside is that freeing becomes more expensive as the last level table
> becomes more sparsely populated and you need to ensure you don't have any
> concurrent maps going on for the same table when you're unmapping. I also
> can't see a neat way to fit this into the current vunmap code. Perhaps we
> need an iounmap_page_range.
> 
> In the meantime, the code in lib/ioremap.c looks totally broken so I think
> we should deselect CONFIG_HAVE_ARCH_HUGE_VMAP on arm64 until it's fixed.

Simply do something below at now (before the broken code is fixed)?

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index b2b95f7..a86148c 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -84,7 +84,6 @@ config ARM64
        select HAVE_ALIGNED_STRUCT_PAGE if SLUB
        select HAVE_ARCH_AUDITSYSCALL
        select HAVE_ARCH_BITREVERSE
-   select HAVE_ARCH_HUGE_VMAP
        select HAVE_ARCH_JUMP_LABEL
        select HAVE_ARCH_KASAN if !(ARM64_16K_PAGES && ARM64_VA_BITS_48)
        select HAVE_ARCH_KGDB

Thanks
Hanjun


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
