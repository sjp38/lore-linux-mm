Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id A61AA6B0253
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 10:40:09 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id yy13so113862388pab.3
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 07:40:09 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w6si13208870pfi.99.2016.03.01.07.40.08
        for <linux-mm@kvack.org>;
        Tue, 01 Mar 2016 07:40:08 -0800 (PST)
Date: Tue, 1 Mar 2016 15:39:58 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v2 5/9] arm64: mm: move vmemmap region right below the
 linear region
Message-ID: <20160301153957.GA22107@localhost.localdomain>
References: <1456757084-1078-1-git-send-email-ard.biesheuvel@linaro.org>
 <1456757084-1078-6-git-send-email-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456757084-1078-6-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, will.deacon@arm.com, mark.rutland@arm.com, jonas@southpole.se, linux-mm@kvack.org, nios2-dev@lists.rocketboards.org, linux@lists.openrisc.net, lftan@altera.com, akpm@linux-foundation.org

On Mon, Feb 29, 2016 at 03:44:40PM +0100, Ard Biesheuvel wrote:
> @@ -404,6 +404,12 @@ void __init mem_init(void)
>  	BUILD_BUG_ON(TASK_SIZE_32			> TASK_SIZE_64);
>  #endif
>  
> +	/*
> +	 * Make sure we chose the upper bound of sizeof(struct page)
> +	 * correctly.
> +	 */
> +	BUILD_BUG_ON(sizeof(struct page) > (1 << STRUCT_PAGE_MAX_SHIFT));

Since with the vmemmap fix you already assume that PAGE_OFFSET is half
of the VA space, we should add another check on PAGE_OFFSET !=
UL(0xffffffffffffffff) << (VA_BITS - 1), just in case someone thinks
they could map a bit of extra RAM without going for a larger VA.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
