Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_2
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17B29C3A59E
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 01:54:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D665C20820
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 01:54:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D665C20820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F10E6B0006; Wed,  4 Sep 2019 21:54:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A1586B0007; Wed,  4 Sep 2019 21:54:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58F696B0008; Wed,  4 Sep 2019 21:54:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0051.hostedemail.com [216.40.44.51])
	by kanga.kvack.org (Postfix) with ESMTP id 394766B0006
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 21:54:43 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id CDB422DFA
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 01:54:42 +0000 (UTC)
X-FDA: 75899198004.09.ship05_4615e781f4313
X-HE-Tag: ship05_4615e781f4313
X-Filterd-Recvd-Size: 3470
Received: from mailgw02.mediatek.com (unknown [210.61.82.184])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 01:54:41 +0000 (UTC)
X-UUID: e1c814d6fac6479dbb5a3b406a2fee58-20190905
X-UUID: e1c814d6fac6479dbb5a3b406a2fee58-20190905
Received: from mtkmrs01.mediatek.inc [(172.21.131.159)] by mailgw02.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(Cellopoint E-mail Firewall v4.1.10 Build 0809 with TLS)
	with ESMTP id 1846864118; Thu, 05 Sep 2019 09:54:37 +0800
Received: from mtkcas07.mediatek.inc (172.21.101.84) by
 mtkmbs07n2.mediatek.inc (172.21.101.141) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Thu, 5 Sep 2019 09:54:34 +0800
Received: from [172.21.84.99] (172.21.84.99) by mtkcas07.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Thu, 5 Sep 2019 09:54:34 +0800
Message-ID: <1567648476.32522.36.camel@mtksdccf07>
Subject: Re: [PATCH 1/2] mm/kasan: dump alloc/free stack for page allocator
From: Walter Wu <walter-zh.wu@mediatek.com>
To: Qian Cai <cai@lca.pw>
CC: Dmitry Vyukov <dvyukov@google.com>, Matthias Brugger
	<matthias.bgg@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Martin
 Schwidefsky" <schwidefsky@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>,
	kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List
	<linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linux ARM
	<linux-arm-kernel@lists.infradead.org>, <linux-mediatek@lists.infradead.org>,
	<wsd_upstream@mediatek.com>, Alexander Potapenko <glider@google.com>, "Andrey
 Ryabinin" <aryabinin@virtuozzo.com>
Date: Thu, 5 Sep 2019 09:54:36 +0800
In-Reply-To: <1567607824.5576.77.camel@lca.pw>
References: <20190904065133.20268-1-walter-zh.wu@mediatek.com>
	 <CAAeHK+wyvLF8=DdEczHLzNXuP+oC0CEhoPmp_LHSKVNyAiRGLQ@mail.gmail.com>
	 <1567606591.32522.21.camel@mtksdccf07> <1567607824.5576.77.camel@lca.pw>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.2.3-0ubuntu6 
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000011, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-09-04 at 10:37 -0400, Qian Cai wrote:
> On Wed, 2019-09-04 at 22:16 +0800, Walter Wu wrote:
> > On Wed, 2019-09-04 at 15:44 +0200, Andrey Konovalov wrote:
> > > On Wed, Sep 4, 2019 at 8:51 AM Walter Wu <walter-zh.wu@mediatek.com> wrote:
> > > > +config KASAN_DUMP_PAGE
> > > > +       bool "Dump the page last stack information"
> > > > +       depends on KASAN && PAGE_OWNER
> > > > +       help
> > > > +         By default, KASAN doesn't record alloc/free stack for page
> > > > allocator.
> > > > +         It is difficult to fix up page use-after-free issue.
> > > > +         This feature depends on page owner to record the last stack of
> > > > page.
> > > > +         It is very helpful for solving the page use-after-free or out-
> > > > of-bound.
> > > 
> > > I'm not sure if we need a separate config for this. Is there any
> > > reason to not have this enabled by default?
> > 
> > PAGE_OWNER need some memory usage, it is not allowed to enable by
> > default in low RAM device. so I create new feature option and the person
> > who wants to use it to enable it.
> 
> Or you can try to look into reducing the memory footprint of PAGE_OWNER to fit
> your needs. It does not always need to be that way.

Thanks your suggestion. We can try to think what can be slimmed.

Thanks.
Walter


