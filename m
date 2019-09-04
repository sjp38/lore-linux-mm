Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 736A7C3A5A7
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 12:49:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 391ED21883
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 12:49:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 391ED21883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4AC96B0007; Wed,  4 Sep 2019 08:49:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD45C6B0008; Wed,  4 Sep 2019 08:49:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9C836B000A; Wed,  4 Sep 2019 08:49:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0188.hostedemail.com [216.40.44.188])
	by kanga.kvack.org (Postfix) with ESMTP id 81E926B0007
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 08:49:10 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 1DA60181AC9B6
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 12:49:10 +0000 (UTC)
X-FDA: 75897218460.03.way03_32df4bbc9344f
X-HE-Tag: way03_32df4bbc9344f
X-Filterd-Recvd-Size: 5401
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 12:49:09 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F03BCAF47;
	Wed,  4 Sep 2019 12:49:07 +0000 (UTC)
Subject: Re: [PATCH 1/2] mm/kasan: dump alloc/free stack for page allocator
To: Walter Wu <walter-zh.wu@mediatek.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 Matthias Brugger <matthias.bgg@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com
References: <20190904065133.20268-1-walter-zh.wu@mediatek.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <401064ae-279d-bef3-a8d5-0fe155d0886d@suse.cz>
Date: Wed, 4 Sep 2019 14:49:06 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190904065133.20268-1-walter-zh.wu@mediatek.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/4/19 8:51 AM, Walter Wu wrote:
> This patch is KASAN report adds the alloc/free stacks for page allocator
> in order to help programmer to see memory corruption caused by page.
> 
> By default, KASAN doesn't record alloc/free stack for page allocator.
> It is difficult to fix up page use-after-free issue.
> 
> This feature depends on page owner to record the last stack of pages.
> It is very helpful for solving the page use-after-free or out-of-bound.
> 
> KASAN report will show the last stack of page, it may be:
> a) If page is in-use state, then it prints alloc stack.
>    It is useful to fix up page out-of-bound issue.

I expect this will conflict both in syntax and semantics with my series [1] that
adds the freeing stack to page_owner when used together with debug_pagealloc,
and it's now in mmotm. Glad others see the need as well :) Perhaps you could
review the series, see if it fulfils your usecase (AFAICS the series should be a
superset, by storing both stacks at once), and perhaps either make KASAN enable
debug_pagealloc, or turn KASAN into an alternative enabler of the functionality
there?

Thanks, Vlastimil

[1] https://lore.kernel.org/linux-mm/20190820131828.22684-1-vbabka@suse.cz/t/#u

> BUG: KASAN: slab-out-of-bounds in kmalloc_pagealloc_oob_right+0x88/0x90
> Write of size 1 at addr ffffffc0d64ea00a by task cat/115
> ...
> Allocation stack of page:
>  prep_new_page+0x1a0/0x1d8
>  get_page_from_freelist+0xd78/0x2748
>  __alloc_pages_nodemask+0x1d4/0x1978
>  kmalloc_order+0x28/0x58
>  kmalloc_order_trace+0x28/0xe0
>  kmalloc_pagealloc_oob_right+0x2c/0x90
> 
> b) If page is freed state, then it prints free stack.
>    It is useful to fix up page use-after-free issue.
> 
> BUG: KASAN: use-after-free in kmalloc_pagealloc_uaf+0x70/0x80
> Write of size 1 at addr ffffffc0d651c000 by task cat/115
> ...
> Free stack of page:
>  kasan_free_pages+0x68/0x70
>  __free_pages_ok+0x3c0/0x1328
>  __free_pages+0x50/0x78
>  kfree+0x1c4/0x250
>  kmalloc_pagealloc_uaf+0x38/0x80
> 
> 
> This has been discussed, please refer below link.
> https://bugzilla.kernel.org/show_bug.cgi?id=203967
> 
> Signed-off-by: Walter Wu <walter-zh.wu@mediatek.com>
> ---
>  lib/Kconfig.kasan | 9 +++++++++
>  mm/kasan/common.c | 6 ++++++
>  2 files changed, 15 insertions(+)
> 
> diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
> index 4fafba1a923b..ba17f706b5f8 100644
> --- a/lib/Kconfig.kasan
> +++ b/lib/Kconfig.kasan
> @@ -135,6 +135,15 @@ config KASAN_S390_4_LEVEL_PAGING
>  	  to 3TB of RAM with KASan enabled). This options allows to force
>  	  4-level paging instead.
>  
> +config KASAN_DUMP_PAGE
> +	bool "Dump the page last stack information"
> +	depends on KASAN && PAGE_OWNER
> +	help
> +	  By default, KASAN doesn't record alloc/free stack for page allocator.
> +	  It is difficult to fix up page use-after-free issue.
> +	  This feature depends on page owner to record the last stack of page.
> +	  It is very helpful for solving the page use-after-free or out-of-bound.
> +
>  config TEST_KASAN
>  	tristate "Module for testing KASAN for bug detection"
>  	depends on m && KASAN
> diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> index 2277b82902d8..2a32474efa74 100644
> --- a/mm/kasan/common.c
> +++ b/mm/kasan/common.c
> @@ -35,6 +35,7 @@
>  #include <linux/vmalloc.h>
>  #include <linux/bug.h>
>  #include <linux/uaccess.h>
> +#include <linux/page_owner.h>
>  
>  #include "kasan.h"
>  #include "../slab.h"
> @@ -227,6 +228,11 @@ void kasan_alloc_pages(struct page *page, unsigned int order)
>  
>  void kasan_free_pages(struct page *page, unsigned int order)
>  {
> +#ifdef CONFIG_KASAN_DUMP_PAGE
> +	gfp_t gfp_flags = GFP_KERNEL;
> +
> +	set_page_owner(page, order, gfp_flags);
> +#endif
>  	if (likely(!PageHighMem(page)))
>  		kasan_poison_shadow(page_address(page),
>  				PAGE_SIZE << order,
> 


