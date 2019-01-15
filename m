Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id D2ED18E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 12:24:59 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id t22-v6so909213lji.14
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 09:24:59 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id m25-v6si3096358ljb.153.2019.01.15.09.24.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 09:24:58 -0800 (PST)
Subject: Re: [PATCH v2] page_poison: play nicely with KASAN
References: <2e46c139-70d3-dc86-28c9-a9f263651b57@virtuozzo.com>
 <20190114233405.67843-1-cai@lca.pw>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <3a2aefb4-f108-5354-ddb9-7a35d8e0b3f2@virtuozzo.com>
Date: Tue, 15 Jan 2019 20:25:20 +0300
MIME-Version: 1.0
In-Reply-To: <20190114233405.67843-1-cai@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 1/15/19 2:34 AM, Qian Cai wrote:
> KASAN does not play well with the page poisoning
> (CONFIG_PAGE_POISONING). It triggers false positives in the allocation
> path,
> 
> BUG: KASAN: use-after-free in memchr_inv+0x2ea/0x330
> Read of size 8 at addr ffff88881f800000 by task swapper/0
> CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc1+ #54
> Call Trace:
>  dump_stack+0xe0/0x19a
>  print_address_description.cold.2+0x9/0x28b
>  kasan_report.cold.3+0x7a/0xb5
>  __asan_report_load8_noabort+0x19/0x20
>  memchr_inv+0x2ea/0x330
>  kernel_poison_pages+0x103/0x3d5
>  get_page_from_freelist+0x15e7/0x4d90
> 
> because KASAN has not yet unpoisoned the shadow page for allocation
> before it checks memchr_inv() but only found a stale poison pattern.
> 
> Also, false positives in free path,
> 
> BUG: KASAN: slab-out-of-bounds in kernel_poison_pages+0x29e/0x3d5
> Write of size 4096 at addr ffff8888112cc000 by task swapper/0/1
> CPU: 5 PID: 1 Comm: swapper/0 Not tainted 5.0.0-rc1+ #55
> Call Trace:
>  dump_stack+0xe0/0x19a
>  print_address_description.cold.2+0x9/0x28b
>  kasan_report.cold.3+0x7a/0xb5
>  check_memory_region+0x22d/0x250
>  memset+0x28/0x40
>  kernel_poison_pages+0x29e/0x3d5
>  __free_pages_ok+0x75f/0x13e0
> 
> due to KASAN adds poisoned redzones around slab objects, but the page
> poisoning needs to poison the whole page.
> 
> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
> 
Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
