Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DB83C3A5A8
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 14:16:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6CAEB22CED
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 14:16:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6CAEB22CED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EEEA46B0003; Wed,  4 Sep 2019 10:16:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E78646B0006; Wed,  4 Sep 2019 10:16:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D66EB6B0007; Wed,  4 Sep 2019 10:16:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0178.hostedemail.com [216.40.44.178])
	by kanga.kvack.org (Postfix) with ESMTP id B408F6B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 10:16:46 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 5F967180AD7C3
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 14:16:46 +0000 (UTC)
X-FDA: 75897439212.10.bread38_5814da771d54b
X-HE-Tag: bread38_5814da771d54b
X-Filterd-Recvd-Size: 3035
Received: from mailgw02.mediatek.com (unknown [210.61.82.184])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 14:16:44 +0000 (UTC)
X-UUID: ec6f2baf4842498f92829352c925dd9a-20190904
X-UUID: ec6f2baf4842498f92829352c925dd9a-20190904
Received: from mtkexhb02.mediatek.inc [(172.21.101.103)] by mailgw02.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(Cellopoint E-mail Firewall v4.1.10 Build 0809 with TLS)
	with ESMTP id 2114202653; Wed, 04 Sep 2019 22:16:40 +0800
Received: from mtkcas09.mediatek.inc (172.21.101.178) by
 mtkmbs07n1.mediatek.inc (172.21.101.16) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Wed, 4 Sep 2019 22:16:38 +0800
Received: from [172.21.84.99] (172.21.84.99) by mtkcas09.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Wed, 4 Sep 2019 22:16:30 +0800
Message-ID: <1567606591.32522.21.camel@mtksdccf07>
Subject: Re: [PATCH 1/2] mm/kasan: dump alloc/free stack for page allocator
From: Walter Wu <walter-zh.wu@mediatek.com>
To: Andrey Konovalov <andreyknvl@google.com>
CC: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko
	<glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Matthias Brugger
	<matthias.bgg@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Martin
 Schwidefsky" <schwidefsky@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>,
	kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List
	<linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linux ARM
	<linux-arm-kernel@lists.infradead.org>, <linux-mediatek@lists.infradead.org>,
	<wsd_upstream@mediatek.com>
Date: Wed, 4 Sep 2019 22:16:31 +0800
In-Reply-To: <CAAeHK+wyvLF8=DdEczHLzNXuP+oC0CEhoPmp_LHSKVNyAiRGLQ@mail.gmail.com>
References: <20190904065133.20268-1-walter-zh.wu@mediatek.com>
	 <CAAeHK+wyvLF8=DdEczHLzNXuP+oC0CEhoPmp_LHSKVNyAiRGLQ@mail.gmail.com>
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

On Wed, 2019-09-04 at 15:44 +0200, Andrey Konovalov wrote:
> On Wed, Sep 4, 2019 at 8:51 AM Walter Wu <walter-zh.wu@mediatek.com> wrote:
> > +config KASAN_DUMP_PAGE
> > +       bool "Dump the page last stack information"
> > +       depends on KASAN && PAGE_OWNER
> > +       help
> > +         By default, KASAN doesn't record alloc/free stack for page allocator.
> > +         It is difficult to fix up page use-after-free issue.
> > +         This feature depends on page owner to record the last stack of page.
> > +         It is very helpful for solving the page use-after-free or out-of-bound.
> 
> I'm not sure if we need a separate config for this. Is there any
> reason to not have this enabled by default?

PAGE_OWNER need some memory usage, it is not allowed to enable by
default in low RAM device. so I create new feature option and the person
who wants to use it to enable it.

Thanks.
Walter


