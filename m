Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D36F3C4740C
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 13:07:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80F3C20863
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 13:07:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80F3C20863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7D786B0008; Mon,  9 Sep 2019 09:07:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2DA96B000A; Mon,  9 Sep 2019 09:07:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1BFE6B000C; Mon,  9 Sep 2019 09:07:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0040.hostedemail.com [216.40.44.40])
	by kanga.kvack.org (Postfix) with ESMTP id AA3F36B0008
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 09:07:48 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 51C3A8243770
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 13:07:48 +0000 (UTC)
X-FDA: 75915409416.01.crib43_4417778514619
X-HE-Tag: crib43_4417778514619
X-Filterd-Recvd-Size: 4422
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 13:07:47 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 737C5ADDD;
	Mon,  9 Sep 2019 13:07:46 +0000 (UTC)
Subject: Re: [PATCH v2 0/2] mm/kasan: dump alloc/free stack for page allocator
To: walter-zh.wu@mediatek.com, Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 Matthias Brugger <matthias.bgg@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>, Will Deacon <will@kernel.org>,
 Andrey Konovalov <andreyknvl@google.com>, Arnd Bergmann <arnd@arndb.de>,
 Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@kernel.org>,
 Qian Cai <cai@lca.pw>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com,
 linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org,
 linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com
References: <20190909082412.24356-1-walter-zh.wu@mediatek.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d53d88df-d9a4-c126-32a8-4baeb0645a2c@suse.cz>
Date: Mon, 9 Sep 2019 15:07:45 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190909082412.24356-1-walter-zh.wu@mediatek.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/9/19 10:24 AM, walter-zh.wu@mediatek.com wrote:
> From: Walter Wu <walter-zh.wu@mediatek.com>
> 
> This patch is KASAN report adds the alloc/free stacks for page allocator
> in order to help programmer to see memory corruption caused by page.
> 
> By default, KASAN doesn't record alloc and free stack for page allocator.
> It is difficult to fix up page use-after-free or dobule-free issue.
> 
> Our patchsets will record the last stack of pages.
> It is very helpful for solving the page use-after-free or double-free.
> 
> KASAN report will show the last stack of page, it may be:
> a) If page is in-use state, then it prints alloc stack.
>     It is useful to fix up page out-of-bound issue.

I still disagree with duplicating most of page_owner functionality for 
the sake of using a single stack handle for both alloc and free (while 
page_owner + debug_pagealloc with patches in mmotm uses two handles). It 
reduces the amount of potentially important debugging information, and I 
really doubt the u32-per-page savings are significant, given the rest of 
KASAN overhead.

> BUG: KASAN: slab-out-of-bounds in kmalloc_pagealloc_oob_right+0x88/0x90
> Write of size 1 at addr ffffffc0d64ea00a by task cat/115
> ...
> Allocation stack of page:
>   set_page_stack.constprop.1+0x30/0xc8
>   kasan_alloc_pages+0x18/0x38
>   prep_new_page+0x5c/0x150
>   get_page_from_freelist+0xb8c/0x17c8
>   __alloc_pages_nodemask+0x1a0/0x11b0
>   kmalloc_order+0x28/0x58
>   kmalloc_order_trace+0x28/0xe0
>   kmalloc_pagealloc_oob_right+0x2c/0x68
> 
> b) If page is freed state, then it prints free stack.
>     It is useful to fix up page use-after-free or double-free issue.
> 
> BUG: KASAN: use-after-free in kmalloc_pagealloc_uaf+0x70/0x80
> Write of size 1 at addr ffffffc0d651c000 by task cat/115
> ...
> Free stack of page:
>   kasan_free_pages+0x68/0x70
>   __free_pages_ok+0x3c0/0x1328
>   __free_pages+0x50/0x78
>   kfree+0x1c4/0x250
>   kmalloc_pagealloc_uaf+0x38/0x80
> 
> This has been discussed, please refer below link.
> https://bugzilla.kernel.org/show_bug.cgi?id=203967

That's not a discussion, but a single comment from Dmitry, which btw 
contains "provide alloc *and* free stacks for it" ("it" refers to page, 
emphasis mine). It would be nice if he or other KASAN guys could clarify.

> Changes since v1:
> - slim page_owner and move it into kasan
> - enable the feature by default
> 
> Signed-off-by: Walter Wu <walter-zh.wu@mediatek.com>
> ---
>   include/linux/kasan.h |  1 +
>   lib/Kconfig.kasan     |  2 ++
>   mm/kasan/common.c     | 32 ++++++++++++++++++++++++++++++++
>   mm/kasan/kasan.h      |  5 +++++
>   mm/kasan/report.c     | 27 +++++++++++++++++++++++++++
>   5 files changed, 67 insertions(+)

