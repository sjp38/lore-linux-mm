Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 88EB96B0260
	for <linux-mm@kvack.org>; Fri, 29 Dec 2017 03:01:58 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id d4so24551776plr.8
        for <linux-mm@kvack.org>; Fri, 29 Dec 2017 00:01:58 -0800 (PST)
Received: from huawei.com ([45.249.212.35])
        by mx.google.com with ESMTPS id s24si27526306plp.220.2017.12.29.00.01.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Dec 2017 00:01:57 -0800 (PST)
Subject: Re: [RFC patch] ioremap: don't set up huge I/O mappings when
 p4d/pud/pmd is zero
From: Hanjun Guo <guohanjun@huawei.com>
References: <1514460261-65222-1-git-send-email-guohanjun@huawei.com>
Message-ID: <17c8384a-7748-3acc-a56f-78698087560a@huawei.com>
Date: Fri, 29 Dec 2017 16:00:25 +0800
MIME-Version: 1.0
In-Reply-To: <1514460261-65222-1-git-send-email-guohanjun@huawei.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Cc: linuxarm@huawei.com, linux-mm@kvack.org, Hanjun Guo <hanjun.guo@linaro.org>, Toshi Kani <toshi.kani@hpe.com>, Mark Rutland <mark.rutland@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Xuefeng Wang <wxf.wang@hisilicon.com>

oops, the title of this patch is wrong, should be:
ioremap: skip setting up huge I/O mappings when p4d/pud/pmd is zero

On 2017/12/28 19:24, Hanjun Guo wrote:
> From: Hanjun Guo <hanjun.guo@linaro.org>
> 
> When we using iounmap() to free the 4K mapping, it just clear the PTEs
> but leave P4D/PUD/PMD unchanged, also will not free the memory of page
> tables.
> 
> This will cause issues on ARM64 platform (not sure if other archs have
> the same issue) for this case:
> 
> 1. ioremap a 4K size, valid page table will build,
> 2. iounmap it, pte0 will set to 0;
> 3. ioremap the same address with 2M size, pgd/pmd is unchanged,
>    then set the a new value for pmd;
> 4. pte0 is leaked;
> 5. CPU may meet exception because the old pmd is still in TLB,
>    which will lead to kernel panic.
> 
> Fix it by skip setting up the huge I/O mappings when p4d/pud/pmd is
> zero.
> 
> Reported-by: Lei Li <lious.lilei@hisilicon.com>
> Signed-off-by: Hanjun Guo <hanjun.guo@linaro.org>
> Cc: Toshi Kani <toshi.kani@hpe.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Xuefeng Wang <wxf.wang@hisilicon.com>
> ---
> 
> Not sure if this is the right direction, this patch has a obvious
> side effect that a mapped address with 4K will not back to 2M.  I may
> miss something and just wrong, so this is just a RFC version, comments
> are welcomed.
> 
>  lib/ioremap.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/lib/ioremap.c b/lib/ioremap.c
> index b808a39..4e6f19a 100644
> --- a/lib/ioremap.c
> +++ b/lib/ioremap.c
> @@ -89,7 +89,7 @@ static inline int ioremap_pmd_range(pud_t *pud, unsigned long addr,
>  	do {
>  		next = pmd_addr_end(addr, end);
>  
> -		if (ioremap_pmd_enabled() &&
> +		if (ioremap_pmd_enabled() && pmd_none(*pmd) &&
>  		    ((next - addr) == PMD_SIZE) &&
>  		    IS_ALIGNED(phys_addr + addr, PMD_SIZE)) {
>  			if (pmd_set_huge(pmd, phys_addr + addr, prot))
> @@ -115,7 +115,7 @@ static inline int ioremap_pud_range(p4d_t *p4d, unsigned long addr,
>  	do {
>  		next = pud_addr_end(addr, end);
>  
> -		if (ioremap_pud_enabled() &&
> +		if (ioremap_pud_enabled() && pud_none(*pud) &&
>  		    ((next - addr) == PUD_SIZE) &&
>  		    IS_ALIGNED(phys_addr + addr, PUD_SIZE)) {
>  			if (pud_set_huge(pud, phys_addr + addr, prot))
> @@ -141,7 +141,7 @@ static inline int ioremap_p4d_range(pgd_t *pgd, unsigned long addr,
>  	do {
>  		next = p4d_addr_end(addr, end);
>  
> -		if (ioremap_p4d_enabled() &&
> +		if (ioremap_p4d_enabled() && p4d_none(*p4d) &&
>  		    ((next - addr) == P4D_SIZE) &&
>  		    IS_ALIGNED(phys_addr + addr, P4D_SIZE)) {
>  			if (p4d_set_huge(p4d, phys_addr + addr, prot))
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
