Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92A07C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 12:46:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62601208E4
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 12:46:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62601208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D63616B0007; Tue, 10 Sep 2019 08:46:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D3A7B6B0008; Tue, 10 Sep 2019 08:46:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C50776B000A; Tue, 10 Sep 2019 08:46:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0126.hostedemail.com [216.40.44.126])
	by kanga.kvack.org (Postfix) with ESMTP id A41696B0007
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 08:46:27 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 4EE39824376D
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 12:46:27 +0000 (UTC)
X-FDA: 75918984414.06.bread97_55509745d270e
X-HE-Tag: bread97_55509745d270e
X-Filterd-Recvd-Size: 5485
Received: from mailgw01.mediatek.com (unknown [210.61.82.183])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 12:46:25 +0000 (UTC)
X-UUID: 3abd29dae8c34e82833ece7ce660722c-20190910
X-UUID: 3abd29dae8c34e82833ece7ce660722c-20190910
Received: from mtkexhb02.mediatek.inc [(172.21.101.103)] by mailgw01.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(Cellopoint E-mail Firewall v4.1.10 Build 0809 with TLS)
	with ESMTP id 723714861; Tue, 10 Sep 2019 20:46:17 +0800
Received: from mtkcas07.mediatek.inc (172.21.101.84) by
 mtkmbs07n2.mediatek.inc (172.21.101.141) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Tue, 10 Sep 2019 20:46:14 +0800
Received: from [172.21.84.99] (172.21.84.99) by mtkcas07.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Tue, 10 Sep 2019 20:46:14 +0800
Message-ID: <1568119575.24886.20.camel@mtksdccf07>
Subject: Re: [PATCH v2 0/2] mm/kasan: dump alloc/free stack for page
 allocator
From: Walter Wu <walter-zh.wu@mediatek.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
CC: Vlastimil Babka <vbabka@suse.cz>, Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>, Matthias Brugger
	<matthias.bgg@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Martin
 Schwidefsky" <schwidefsky@de.ibm.com>, Will Deacon <will@kernel.org>, Andrey
 Konovalov <andreyknvl@google.com>, Arnd Bergmann <arnd@arndb.de>, Thomas
 Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@kernel.org>, Qian Cai
	<cai@lca.pw>, <linux-kernel@vger.kernel.org>, <kasan-dev@googlegroups.com>,
	<linux-mm@kvack.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-mediatek@lists.infradead.org>, <wsd_upstream@mediatek.com>
Date: Tue, 10 Sep 2019 20:46:15 +0800
In-Reply-To: <a7863965-90ab-5dae-65e7-8f68f4b4beb5@virtuozzo.com>
References: <20190909082412.24356-1-walter-zh.wu@mediatek.com>
	 <d53d88df-d9a4-c126-32a8-4baeb0645a2c@suse.cz>
	 <a7863965-90ab-5dae-65e7-8f68f4b4beb5@virtuozzo.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.2.3-0ubuntu6 
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-09-10 at 13:50 +0300, Andrey Ryabinin wrote:
> 
> On 9/9/19 4:07 PM, Vlastimil Babka wrote:
> > On 9/9/19 10:24 AM, walter-zh.wu@mediatek.com wrote:
> >> From: Walter Wu <walter-zh.wu@mediatek.com>
> >>
> >> This patch is KASAN report adds the alloc/free stacks for page allocator
> >> in order to help programmer to see memory corruption caused by page.
> >>
> >> By default, KASAN doesn't record alloc and free stack for page allocator.
> >> It is difficult to fix up page use-after-free or dobule-free issue.
> >>
> >> Our patchsets will record the last stack of pages.
> >> It is very helpful for solving the page use-after-free or double-free.
> >>
> >> KASAN report will show the last stack of page, it may be:
> >> a) If page is in-use state, then it prints alloc stack.
> >>     It is useful to fix up page out-of-bound issue.
> > 
> > I still disagree with duplicating most of page_owner functionality for the sake of using a single stack handle for both alloc and free (while page_owner + debug_pagealloc with patches in mmotm uses two handles). It reduces the amount of potentially important debugging information, and I really doubt the u32-per-page savings are significant, given the rest of KASAN overhead.
> > 
> >> BUG: KASAN: slab-out-of-bounds in kmalloc_pagealloc_oob_right+0x88/0x90
> >> Write of size 1 at addr ffffffc0d64ea00a by task cat/115
> >> ...
> >> Allocation stack of page:
> >>   set_page_stack.constprop.1+0x30/0xc8
> >>   kasan_alloc_pages+0x18/0x38
> >>   prep_new_page+0x5c/0x150
> >>   get_page_from_freelist+0xb8c/0x17c8
> >>   __alloc_pages_nodemask+0x1a0/0x11b0
> >>   kmalloc_order+0x28/0x58
> >>   kmalloc_order_trace+0x28/0xe0
> >>   kmalloc_pagealloc_oob_right+0x2c/0x68
> >>
> >> b) If page is freed state, then it prints free stack.
> >>     It is useful to fix up page use-after-free or double-free issue.
> >>
> >> BUG: KASAN: use-after-free in kmalloc_pagealloc_uaf+0x70/0x80
> >> Write of size 1 at addr ffffffc0d651c000 by task cat/115
> >> ...
> >> Free stack of page:
> >>   kasan_free_pages+0x68/0x70
> >>   __free_pages_ok+0x3c0/0x1328
> >>   __free_pages+0x50/0x78
> >>   kfree+0x1c4/0x250
> >>   kmalloc_pagealloc_uaf+0x38/0x80
> >>
> >> This has been discussed, please refer below link.
> >> https://bugzilla.kernel.org/show_bug.cgi?id=203967
> > 
> > That's not a discussion, but a single comment from Dmitry, which btw contains "provide alloc *and* free stacks for it" ("it" refers to page, emphasis mine). It would be nice if he or other KASAN guys could clarify.
> > 
> 
> For slab objects we memorize both alloc and free stacks. You'll never know in advance what information will be usefull
> to fix an issue, so it usually better to provide more information. I don't think we should do anything different for pages.
> 
> Given that we already have the page_owner responsible for providing alloc/free stacks for pages, all that we should in KASAN do is to
> enable the feature by default. Free stack saving should be decoupled from debug_pagealloc into separate option so that it can be enabled 
> by KASAN and/or debug_pagealloc.

Thanks your suggestion.
We will send the patch v3 as described above.




