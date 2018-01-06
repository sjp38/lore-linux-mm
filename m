Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id C208C6B0038
	for <linux-mm@kvack.org>; Sat,  6 Jan 2018 12:37:33 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id x204so3643938oif.18
        for <linux-mm@kvack.org>; Sat, 06 Jan 2018 09:37:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f190si386290oic.273.2018.01.06.09.37.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Jan 2018 09:37:32 -0800 (PST)
Date: Sat, 6 Jan 2018 18:37:29 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC] boot failed when enable KAISER/KPTI
Message-ID: <20180106173729.GD25546@redhat.com>
References: <5A4F09B7.8010402@huawei.com>
 <alpine.LRH.2.00.1801051930370.27010@gjva.wvxbf.pm>
 <5A50708A.9010902@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A50708A.9010902@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Jiri Kosina <jikos@kernel.org>, dave.hansen@linux.intel.com, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Yisheng Xie <xieyisheng1@huawei.com>, "Wangkefeng (Maro)" <wangkefeng.wang@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Zhao Hongjiang <zhaohongjiang@huawei.com>

Hello Xishi,

On Sat, Jan 06, 2018 at 02:45:30PM +0800, Xishi Qiu wrote:
> How about this fix patch? I tested and it works.
> 
> diff --git a/arch/x86/kernel/tboot.c b/arch/x86/kernel/tboot.c
> index 088681d..f6c32f5 100644
> --- a/arch/x86/kernel/tboot.c
> +++ b/arch/x86/kernel/tboot.c
> @@ -131,6 +131,8 @@ static int map_tboot_page(unsigned long vaddr, unsigned long pfn,
>  	pud = pud_alloc(&tboot_mm, pgd, vaddr);
>  	if (!pud)
>  		return -1;
> +	if (__supported_pte_mask & _PAGE_NX)
> +		pgd->pgd &= ~_PAGE_NX;
>  	pmd = pmd_alloc(&tboot_mm, pud, vaddr);
>  	if (!pmd)
>  		return -1;

Oh great that you already verified this.

The only difference from the above to what I applied is that I didn't
check "__supported_pte_mask & _PAGE_NX", but that's superflous
here. It won't hurt to add it, your patch is fine as well.

The location where to do the NX clearing is the correct one and same
optimal place as in efi_64.c too (right after pud_alloc success).

Only the setting of NX requires verification that it's in the
__supported_pte_mask first, the clearing is always fine (worst case it
will do nothing).

On a side note, I already verified if NX is disabled (-cpu nx=off) the
pgd isn't NX poisoned in the first place, but clearing NX won't hurt
even in such case.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
