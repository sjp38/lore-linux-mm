Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_2
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF387C3A59E
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 05:38:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CFC722CF4
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 05:38:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CFC722CF4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 239306B0007; Tue, 20 Aug 2019 01:38:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E9756B0008; Tue, 20 Aug 2019 01:38:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D82F6B000A; Tue, 20 Aug 2019 01:38:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0075.hostedemail.com [216.40.44.75])
	by kanga.kvack.org (Postfix) with ESMTP id DBD186B0007
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 01:38:06 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 7DEA08248AAF
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 05:38:06 +0000 (UTC)
X-FDA: 75841700172.26.fan66_46a2615fb0e08
X-HE-Tag: fan66_46a2615fb0e08
X-Filterd-Recvd-Size: 3965
Received: from mailgw02.mediatek.com (unknown [210.61.82.184])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 05:38:05 +0000 (UTC)
X-UUID: 0758c9be4181404e9004a4f966717179-20190820
X-UUID: 0758c9be4181404e9004a4f966717179-20190820
Received: from mtkexhb01.mediatek.inc [(172.21.101.102)] by mailgw02.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(Cellopoint E-mail Firewall v4.1.10 Build 0707 with TLS)
	with ESMTP id 757742129; Tue, 20 Aug 2019 13:37:58 +0800
Received: from mtkcas08.mediatek.inc (172.21.101.126) by
 mtkmbs07n2.mediatek.inc (172.21.101.141) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Tue, 20 Aug 2019 13:37:57 +0800
Received: from [172.21.84.99] (172.21.84.99) by mtkcas08.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Tue, 20 Aug 2019 13:37:57 +0800
Message-ID: <1566279478.9993.21.camel@mtksdccf07>
Subject: Re: [PATCH v4] kasan: add memory corruption identification for
 software tag-based mode
From: Walter Wu <walter-zh.wu@mediatek.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
CC: Alexander Potapenko <glider@google.com>, Dmitry Vyukov
	<dvyukov@google.com>, Matthias Brugger <matthias.bgg@gmail.com>, "Andrew
 Morton" <akpm@linux-foundation.org>, Martin Schwidefsky
	<schwidefsky@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner
	<tglx@linutronix.de>, Vasily Gorbik <gor@linux.ibm.com>, Andrey Konovalov
	<andreyknvl@google.com>, Miles Chen <miles.chen@mediatek.com>,
	<linux-kernel@vger.kernel.org>, <kasan-dev@googlegroups.com>,
	<linux-mm@kvack.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-mediatek@lists.infradead.org>, <wsd_upstream@mediatek.com>
Date: Tue, 20 Aug 2019 13:37:58 +0800
In-Reply-To: <20190806054340.16305-1-walter-zh.wu@mediatek.com>
References: <20190806054340.16305-1-walter-zh.wu@mediatek.com>
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

On Tue, 2019-08-06 at 13:43 +0800, Walter Wu wrote:
> This patch adds memory corruption identification at bug report for
> software tag-based mode, the report show whether it is "use-after-free"
> or "out-of-bound" error instead of "invalid-access" error. This will make
> it easier for programmers to see the memory corruption problem.
> 
> We extend the slab to store five old free pointer tag and free backtrace,
> we can check if the tagged address is in the slab record and make a
> good guess if the object is more like "use-after-free" or "out-of-bound".
> therefore every slab memory corruption can be identified whether it's
> "use-after-free" or "out-of-bound".
> 
> ====== Changes
> Change since v1:
> - add feature option CONFIG_KASAN_SW_TAGS_IDENTIFY.
> - change QUARANTINE_FRACTION to reduce quarantine size.
> - change the qlist order in order to find the newest object in quarantine
> - reduce the number of calling kmalloc() from 2 to 1 time.
> - remove global variable to use argument to pass it.
> - correct the amount of qobject cache->size into the byes of qlist_head.
> - only use kasan_cache_shrink() to shink memory.
> 
> Change since v2:
> - remove the shinking memory function kasan_cache_shrink()
> - modify the description of the CONFIG_KASAN_SW_TAGS_IDENTIFY
> - optimize the quarantine_find_object() and qobject_free()
> - fix the duplicating function name 3 times in the header.
> - modify the function name set_track() to kasan_set_track()
> 
> Change since v3:
> - change tag-based quarantine to extend slab to identify memory corruption

Hi,Andrey,

Would you review the patch,please?
This patch is to pre-allocate slub record(tag and free backtrace) during
create slub object. When kernel has memory corruption, it will print
correct corruption type and free backtrace.

Thanks.

Walter


