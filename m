Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_2
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02E85C3A5A8
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 14:24:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5DD422DBF
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 14:24:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5DD422DBF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 636D76B0006; Wed,  4 Sep 2019 10:24:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E7846B0007; Wed,  4 Sep 2019 10:24:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5246E6B0008; Wed,  4 Sep 2019 10:24:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0090.hostedemail.com [216.40.44.90])
	by kanga.kvack.org (Postfix) with ESMTP id 342DD6B0006
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 10:24:33 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id BAE31180AD804
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 14:24:32 +0000 (UTC)
X-FDA: 75897458784.09.rose59_a67ae4650625
X-HE-Tag: rose59_a67ae4650625
X-Filterd-Recvd-Size: 4238
Received: from mailgw02.mediatek.com (unknown [210.61.82.184])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 14:24:31 +0000 (UTC)
X-UUID: fe267de637764d1c8c1e2ed01f75eca6-20190904
X-UUID: fe267de637764d1c8c1e2ed01f75eca6-20190904
Received: from mtkcas07.mediatek.inc [(172.21.101.84)] by mailgw02.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(Cellopoint E-mail Firewall v4.1.10 Build 0809 with TLS)
	with ESMTP id 1751036984; Wed, 04 Sep 2019 22:24:26 +0800
Received: from mtkcas09.mediatek.inc (172.21.101.178) by
 mtkmbs07n2.mediatek.inc (172.21.101.141) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Wed, 4 Sep 2019 22:24:23 +0800
Received: from [172.21.84.99] (172.21.84.99) by mtkcas09.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Wed, 4 Sep 2019 22:24:22 +0800
Message-ID: <1567607063.32522.24.camel@mtksdccf07>
Subject: Re: [PATCH 1/2] mm/kasan: dump alloc/free stack for page allocator
From: Walter Wu <walter-zh.wu@mediatek.com>
To: Vlastimil Babka <vbabka@suse.cz>
CC: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko
	<glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Matthias Brugger
	<matthias.bgg@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Martin
 Schwidefsky" <schwidefsky@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>,
	<kasan-dev@googlegroups.com>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-mediatek@lists.infradead.org>, <wsd_upstream@mediatek.com>
Date: Wed, 4 Sep 2019 22:24:23 +0800
In-Reply-To: <7998e8f1-e5e2-da84-ea1f-33e696015dce@suse.cz>
References: <20190904065133.20268-1-walter-zh.wu@mediatek.com>
	 <401064ae-279d-bef3-a8d5-0fe155d0886d@suse.cz>
	 <1567605965.32522.14.camel@mtksdccf07>
	 <7998e8f1-e5e2-da84-ea1f-33e696015dce@suse.cz>
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

On Wed, 2019-09-04 at 16:13 +0200, Vlastimil Babka wrote:
> On 9/4/19 4:06 PM, Walter Wu wrote:
> > On Wed, 2019-09-04 at 14:49 +0200, Vlastimil Babka wrote:
> >> On 9/4/19 8:51 AM, Walter Wu wrote:
> >> > This patch is KASAN report adds the alloc/free stacks for page allocator
> >> > in order to help programmer to see memory corruption caused by page.
> >> > 
> >> > By default, KASAN doesn't record alloc/free stack for page allocator.
> >> > It is difficult to fix up page use-after-free issue.
> >> > 
> >> > This feature depends on page owner to record the last stack of pages.
> >> > It is very helpful for solving the page use-after-free or out-of-bound.
> >> > 
> >> > KASAN report will show the last stack of page, it may be:
> >> > a) If page is in-use state, then it prints alloc stack.
> >> >    It is useful to fix up page out-of-bound issue.
> >> 
> >> I expect this will conflict both in syntax and semantics with my series [1] that
> >> adds the freeing stack to page_owner when used together with debug_pagealloc,
> >> and it's now in mmotm. Glad others see the need as well :) Perhaps you could
> >> review the series, see if it fulfils your usecase (AFAICS the series should be a
> >> superset, by storing both stacks at once), and perhaps either make KASAN enable
> >> debug_pagealloc, or turn KASAN into an alternative enabler of the functionality
> >> there?
> >> 
> >> Thanks, Vlastimil
> >> 
> >> [1] https://lore.kernel.org/linux-mm/20190820131828.22684-1-vbabka@suse.cz/t/#u
> >> 
> > Thanks your information.
> > We focus on the smartphone, so it doesn't enable
> > CONFIG_TRANSPARENT_HUGEPAGE, Is it invalid for our usecase?
> 
> The THP fix is not required for the rest of the series, it was even merged to
> mainline separately.
> 
> > And It looks like something is different, because we only need last
> > stack of page, so it can decrease memory overhead.
> 
> That would save you depot_stack_handle_t (which is u32) per page. I guess that's
> nothing compared to KASAN overhead?
> 
If we can use less memory, we can achieve what we want. Why not?

Thanks.
Walter



