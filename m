Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 83B7B6B0262
	for <linux-mm@kvack.org>; Wed, 18 May 2016 03:30:43 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w143so23519094wmw.3
        for <linux-mm@kvack.org>; Wed, 18 May 2016 00:30:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z4si8612469wjh.249.2016.05.18.00.30.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 May 2016 00:30:42 -0700 (PDT)
Subject: Re: [PATCH v1] mm: bad_page() checks bad_flags instead of page->flags
 for hwpoison page
References: <1463470975-29972-1-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <573C1A21.6030006@suse.cz>
Date: Wed, 18 May 2016 09:30:41 +0200
MIME-Version: 1.0
In-Reply-To: <1463470975-29972-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On 05/17/2016 09:42 AM, Naoya Horiguchi wrote:
> There's a race window between checking page->flags and unpoisoning, which
> taints kernel with "BUG: Bad page state". That's overkill. It's safer to
> use bad_flags to detect hwpoisoned page.
>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>   mm/page_alloc.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git tmp/mm/page_alloc.c tmp_patched/mm/page_alloc.c
> index 5b269bc..4e0fa37 100644
> --- tmp/mm/page_alloc.c
> +++ tmp_patched/mm/page_alloc.c
> @@ -522,8 +522,8 @@ static void bad_page(struct page *page, const char *reason,
>   	static unsigned long nr_shown;
>   	static unsigned long nr_unshown;
>
> -	/* Don't complain about poisoned pages */
> -	if (PageHWPoison(page)) {
> +	/* Don't complain about hwpoisoned pages */
> +	if (bad_flags == __PG_HWPOISON) {

This will wrongly return prematurely on !CONFIG_MEMORY_FAILURE where 
__PG_HWPOISON == 0 and bad_page() called for other reasons than bad flags?

>   		page_mapcount_reset(page); /* remove PageBuddy */
>   		return;
>   	}
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
