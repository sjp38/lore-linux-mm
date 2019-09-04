Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7665C3A5A7
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 14:13:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96ABA22CED
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 14:13:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96ABA22CED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 358836B0003; Wed,  4 Sep 2019 10:13:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 309EA6B0006; Wed,  4 Sep 2019 10:13:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 21ED66B0007; Wed,  4 Sep 2019 10:13:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0033.hostedemail.com [216.40.44.33])
	by kanga.kvack.org (Postfix) with ESMTP id 029766B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 10:13:51 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 9D3DC180AD802
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 14:13:51 +0000 (UTC)
X-FDA: 75897431862.22.game03_3ebfa81fb2c0b
X-HE-Tag: game03_3ebfa81fb2c0b
X-Filterd-Recvd-Size: 3585
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 14:13:51 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8F3D1B048;
	Wed,  4 Sep 2019 14:13:49 +0000 (UTC)
Subject: Re: [PATCH 1/2] mm/kasan: dump alloc/free stack for page allocator
To: Walter Wu <walter-zh.wu@mediatek.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 Matthias Brugger <matthias.bgg@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>,
 kasan-dev@googlegroups.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com
References: <20190904065133.20268-1-walter-zh.wu@mediatek.com>
 <401064ae-279d-bef3-a8d5-0fe155d0886d@suse.cz>
 <1567605965.32522.14.camel@mtksdccf07>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7998e8f1-e5e2-da84-ea1f-33e696015dce@suse.cz>
Date: Wed, 4 Sep 2019 16:13:48 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <1567605965.32522.14.camel@mtksdccf07>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/4/19 4:06 PM, Walter Wu wrote:
> On Wed, 2019-09-04 at 14:49 +0200, Vlastimil Babka wrote:
>> On 9/4/19 8:51 AM, Walter Wu wrote:
>> > This patch is KASAN report adds the alloc/free stacks for page allocator
>> > in order to help programmer to see memory corruption caused by page.
>> > 
>> > By default, KASAN doesn't record alloc/free stack for page allocator.
>> > It is difficult to fix up page use-after-free issue.
>> > 
>> > This feature depends on page owner to record the last stack of pages.
>> > It is very helpful for solving the page use-after-free or out-of-bound.
>> > 
>> > KASAN report will show the last stack of page, it may be:
>> > a) If page is in-use state, then it prints alloc stack.
>> >    It is useful to fix up page out-of-bound issue.
>> 
>> I expect this will conflict both in syntax and semantics with my series [1] that
>> adds the freeing stack to page_owner when used together with debug_pagealloc,
>> and it's now in mmotm. Glad others see the need as well :) Perhaps you could
>> review the series, see if it fulfils your usecase (AFAICS the series should be a
>> superset, by storing both stacks at once), and perhaps either make KASAN enable
>> debug_pagealloc, or turn KASAN into an alternative enabler of the functionality
>> there?
>> 
>> Thanks, Vlastimil
>> 
>> [1] https://lore.kernel.org/linux-mm/20190820131828.22684-1-vbabka@suse.cz/t/#u
>> 
> Thanks your information.
> We focus on the smartphone, so it doesn't enable
> CONFIG_TRANSPARENT_HUGEPAGE, Is it invalid for our usecase?

The THP fix is not required for the rest of the series, it was even merged to
mainline separately.

> And It looks like something is different, because we only need last
> stack of page, so it can decrease memory overhead.

That would save you depot_stack_handle_t (which is u32) per page. I guess that's
nothing compared to KASAN overhead?

> I will try to enable debug_pagealloc(with your patch) and KASAN, then we
> see the result.

Thanks.

> Thanks.
> Walter 
> 


