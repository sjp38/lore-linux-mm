Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 91D066B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 11:57:36 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id l125so90173562pga.4
        for <linux-mm@kvack.org>; Wed, 24 May 2017 08:57:36 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 1si24581429pgu.95.2017.05.24.08.57.35
        for <linux-mm@kvack.org>;
        Wed, 24 May 2017 08:57:35 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH] mm: hwpoison: Use compound_head() flags for huge pages
References: <20170524130204.21845-1-james.morse@arm.com>
Date: Wed, 24 May 2017 16:57:32 +0100
In-Reply-To: <20170524130204.21845-1-james.morse@arm.com> (James Morse's
	message of "Wed, 24 May 2017 14:02:04 +0100")
Message-ID: <8737bufdsj.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

James Morse <james.morse@arm.com> writes:

> memory_failure() chooses a recovery action function based on the page
> flags. For huge pages it uses the tail page flags which don't have
> anything interesting set, resulting in:
>> Memory failure: 0x9be3b4: Unknown page state
>> Memory failure: 0x9be3b4: recovery action for unknown page: Failed
>
> Instead, save a copy of the head page's flags if this is a huge page,
> this means if there are no relevant flags for this tail page, we use
> the head pages flags instead. This results in the me_huge_page()
> recovery action being called:
>> Memory failure: 0x9b7969: recovery action for huge page: Delayed
>
> For hugepages that have not yet been allocated, this allows the hugepage
> to be dequeued.
>
> CC: Punit Agrawal <punit.agrawal@arm.com>
> Signed-off-by: James Morse <james.morse@arm.com>
> ---
> This is intended as a fix, but I can't find the patch that introduced this
> behaviour. (not recent, and there is a lot of history down there!)
>
> This doesn't apply to stable trees before v3.10...
> Cc: stable@vger.kernel.org # 3.10.105
>
>  mm/memory-failure.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 2527dfeddb00..44a6a33af219 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1184,7 +1184,10 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>  	 * page_remove_rmap() in try_to_unmap_one(). So to determine page status
>  	 * correctly, we save a copy of the page flags at this time.
>  	 */
> -	page_flags = p->flags;
> +	if (PageHuge(p))
> +		page_flags = hpage->flags;
> +	else
> +		page_flags = p->flags;
>  
>  	/*
>  	 * unpoison always clear PG_hwpoison inside page lock

I can confirm that this patch reduces the number of failing cases when
running hugepage tests from mce-tests suite.

FWIW,

Acked-by: Punit Agrawal <punit.agrawal@arm.com>
Tested-by: Punit Agrawal <punit.agrawal@arm.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
