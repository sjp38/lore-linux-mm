Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 491EF6B0005
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 05:10:35 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id do7so3410984pab.2
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 02:10:35 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d3si66100335pas.116.2016.01.05.02.10.34
        for <linux-mm@kvack.org>;
        Tue, 05 Jan 2016 02:10:34 -0800 (PST)
Date: Tue, 5 Jan 2016 10:10:19 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] arm64: fix add kasan bug
Message-ID: <20160105101017.GA14545@localhost.localdomain>
References: <1451556549-8962-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1451556549-8962-1-git-send-email-zhongjiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ryabinin.a.a@gmail.com" <ryabinin.a.a@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>, "long.wanglong@huawei.com" <long.wanglong@huawei.com>, Will Deacon <will.deacon@arm.com>

On Thu, Dec 31, 2015 at 10:09:09AM +0000, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
> 
> In general, each process have 16kb stack space to use, but
> stack need extra space to store red_zone when kasan enable.
> the patch fix above question.
> 
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  arch/arm64/include/asm/thread_info.h | 15 +++++++++++++--
>  1 file changed, 13 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm64/include/asm/thread_info.h b/arch/arm64/include/asm/thread_info.h
> index 90c7ff2..45b5a7e 100644
> --- a/arch/arm64/include/asm/thread_info.h
> +++ b/arch/arm64/include/asm/thread_info.h
[...]
> +#ifdef CONFIG_KASAN
> +#define THREAD_SIZE		32768
> +#else
>  #define THREAD_SIZE		16384
> +#endif

I'm not really keen on increasing the stack size to 32KB when KASan is
enabled (that's 8 4K pages). Have you actually seen a real problem with
the default size? How large is the red_zone?

With 4.5 we are going for separate IRQ stack on arm64, so the typical
stack overflow case no longer exists.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
