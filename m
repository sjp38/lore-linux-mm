Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_SANE_2 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5B7AC4CEC6
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 14:08:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83AEC208E4
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 14:08:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83AEC208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A8176B0005; Thu, 12 Sep 2019 10:08:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1579C6B0006; Thu, 12 Sep 2019 10:08:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 095006B0007; Thu, 12 Sep 2019 10:08:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0227.hostedemail.com [216.40.44.227])
	by kanga.kvack.org (Postfix) with ESMTP id DC5CA6B0005
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 10:08:37 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 7EB008243762
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 14:08:37 +0000 (UTC)
X-FDA: 75926449074.13.cloud69_2e0480dbe0331
X-HE-Tag: cloud69_2e0480dbe0331
X-Filterd-Recvd-Size: 3063
Received: from mailgw01.mediatek.com (unknown [210.61.82.183])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 14:08:35 +0000 (UTC)
X-UUID: 88ef5b91e7cc45ca9b12d53609cb2ee6-20190912
X-UUID: 88ef5b91e7cc45ca9b12d53609cb2ee6-20190912
Received: from mtkcas08.mediatek.inc [(172.21.101.126)] by mailgw01.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(Cellopoint E-mail Firewall v4.1.10 Build 0809 with TLS)
	with ESMTP id 1916237428; Thu, 12 Sep 2019 22:08:30 +0800
Received: from mtkcas09.mediatek.inc (172.21.101.178) by
 mtkmbs07n1.mediatek.inc (172.21.101.16) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Thu, 12 Sep 2019 22:08:28 +0800
Received: from [172.21.84.99] (172.21.84.99) by mtkcas09.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Thu, 12 Sep 2019 22:08:27 +0800
Message-ID: <1568297308.19040.5.camel@mtksdccf07>
Subject: Re: [PATCH v3] mm/kasan: dump alloc and free stack for page
 allocator
From: Walter Wu <walter-zh.wu@mediatek.com>
To: Vlastimil Babka <vbabka@suse.cz>
CC: Qian Cai <cai@lca.pw>, Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
	Matthias Brugger <matthias.bgg@gmail.com>, "Andrew Morton"
	<akpm@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Andrey Konovalov <andreyknvl@google.com>, "Arnd Bergmann" <arnd@arndb.de>,
	<linux-kernel@vger.kernel.org>, <kasan-dev@googlegroups.com>,
	<linux-mm@kvack.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-mediatek@lists.infradead.org>, <wsd_upstream@mediatek.com>
Date: Thu, 12 Sep 2019 22:08:28 +0800
In-Reply-To: <c4d2518f-4813-c941-6f47-73897f420517@suse.cz>
References: <20190911083921.4158-1-walter-zh.wu@mediatek.com>
	 <5E358F4B-552C-4542-9655-E01C7B754F14@lca.pw>
	 <c4d2518f-4813-c941-6f47-73897f420517@suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.2.3-0ubuntu6 
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000007, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


>  extern void __reset_page_owner(struct page *page, unsigned int order);
> diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
> index 6c9682ce0254..dc560c7562e8 100644
> --- a/lib/Kconfig.kasan
> +++ b/lib/Kconfig.kasan
> @@ -41,6 +41,8 @@ config KASAN_GENERIC
>  	select SLUB_DEBUG if SLUB
>  	select CONSTRUCTORS
>  	select STACKDEPOT
> +	select PAGE_OWNER
> +	select PAGE_OWNER_FREE_STACK
>  	help
>  	  Enables generic KASAN mode.
>  	  Supported in both GCC and Clang. With GCC it requires version 4.9.2
> @@ -63,6 +65,8 @@ config KASAN_SW_TAGS
>  	select SLUB_DEBUG if SLUB
>  	select CONSTRUCTORS
>  	select STACKDEPOT
> +	select PAGE_OWNER
> +	select PAGE_OWNER_FREE_STACK
>  	help

What is the difference between PAGE_OWNER+PAGE_OWNER_FREE_STACK and
DEBUG_PAGEALLOC?
If you directly enable PAGE_OWNER+PAGE_OWNER_FREE_STACK
PAGE_OWNER_FREE_STACK,don't you think low-memory device to want to use
KASAN?


