Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 29BB86B0038
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 13:27:28 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id a81so1499939oii.15
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 10:27:28 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d138si818208oib.205.2017.11.17.10.27.26
        for <linux-mm@kvack.org>;
        Fri, 17 Nov 2017 10:27:27 -0800 (PST)
Date: Fri, 17 Nov 2017 18:27:22 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] kmemcheck: add scheduling point to kmemleak_scan
Message-ID: <20171117182722.vhgzd5rj3qgv7a6f@armageddon.cambridge.arm.com>
References: <1510902236-4444-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1510902236-4444-1-git-send-email-xieyisheng1@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Please fix the subject as the tool is called "kmemleak" rather than
"kmemcheck".

On Fri, Nov 17, 2017 at 03:03:56PM +0800, Yisheng Xie wrote:
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index e4738d5..e9f2e86 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -1523,6 +1523,8 @@ static void kmemleak_scan(void)
>  			if (page_count(page) == 0)
>  				continue;
>  			scan_block(page, page + 1, NULL);
> +			if (!(pfn % 1024))
> +				cond_resched();

For consistency with the other places where we call cond_resched() in
kmemleak, I would use MAX_SCAN_SIZE. Something like

			if (!(pfn % (MAX_SCAN_SIZE / sizeof(page))))
				cont_resched();

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
