Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E432C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:50:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CEEB52067B
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:50:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CEEB52067B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F23F6B0003; Tue, 10 Sep 2019 06:50:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A3776B0006; Tue, 10 Sep 2019 06:50:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 492096B0007; Tue, 10 Sep 2019 06:50:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0109.hostedemail.com [216.40.44.109])
	by kanga.kvack.org (Postfix) with ESMTP id 287716B0003
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 06:50:47 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id AA3A9998E
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:50:46 +0000 (UTC)
X-FDA: 75918692892.30.nut71_5e0803773ab50
X-HE-Tag: nut71_5e0803773ab50
X-Filterd-Recvd-Size: 4654
Received: from relay.sw.ru (relay.sw.ru [185.231.240.75])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:50:46 +0000 (UTC)
Received: from [172.16.25.5]
	by relay.sw.ru with esmtp (Exim 4.92)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1i7djC-0007sY-TJ; Tue, 10 Sep 2019 13:50:31 +0300
Subject: Re: [PATCH v2 0/2] mm/kasan: dump alloc/free stack for page allocator
To: Vlastimil Babka <vbabka@suse.cz>, walter-zh.wu@mediatek.com,
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
 <d53d88df-d9a4-c126-32a8-4baeb0645a2c@suse.cz>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <a7863965-90ab-5dae-65e7-8f68f4b4beb5@virtuozzo.com>
Date: Tue, 10 Sep 2019 13:50:29 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <d53d88df-d9a4-c126-32a8-4baeb0645a2c@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 9/9/19 4:07 PM, Vlastimil Babka wrote:
> On 9/9/19 10:24 AM, walter-zh.wu@mediatek.com wrote:
>> From: Walter Wu <walter-zh.wu@mediatek.com>
>>
>> This patch is KASAN report adds the alloc/free stacks for page allocat=
or
>> in order to help programmer to see memory corruption caused by page.
>>
>> By default, KASAN doesn't record alloc and free stack for page allocat=
or.
>> It is difficult to fix up page use-after-free or dobule-free issue.
>>
>> Our patchsets will record the last stack of pages.
>> It is very helpful for solving the page use-after-free or double-free.
>>
>> KASAN report will show the last stack of page, it may be:
>> a) If page is in-use state, then it prints alloc stack.
>> =C2=A0=C2=A0=C2=A0 It is useful to fix up page out-of-bound issue.
>=20
> I still disagree with duplicating most of page_owner functionality for =
the sake of using a single stack handle for both alloc and free (while pa=
ge_owner + debug_pagealloc with patches in mmotm uses two handles). It re=
duces the amount of potentially important debugging information, and I re=
ally doubt the u32-per-page savings are significant, given the rest of KA=
SAN overhead.
>=20
>> BUG: KASAN: slab-out-of-bounds in kmalloc_pagealloc_oob_right+0x88/0x9=
0
>> Write of size 1 at addr ffffffc0d64ea00a by task cat/115
>> ...
>> Allocation stack of page:
>> =C2=A0 set_page_stack.constprop.1+0x30/0xc8
>> =C2=A0 kasan_alloc_pages+0x18/0x38
>> =C2=A0 prep_new_page+0x5c/0x150
>> =C2=A0 get_page_from_freelist+0xb8c/0x17c8
>> =C2=A0 __alloc_pages_nodemask+0x1a0/0x11b0
>> =C2=A0 kmalloc_order+0x28/0x58
>> =C2=A0 kmalloc_order_trace+0x28/0xe0
>> =C2=A0 kmalloc_pagealloc_oob_right+0x2c/0x68
>>
>> b) If page is freed state, then it prints free stack.
>> =C2=A0=C2=A0=C2=A0 It is useful to fix up page use-after-free or doubl=
e-free issue.
>>
>> BUG: KASAN: use-after-free in kmalloc_pagealloc_uaf+0x70/0x80
>> Write of size 1 at addr ffffffc0d651c000 by task cat/115
>> ...
>> Free stack of page:
>> =C2=A0 kasan_free_pages+0x68/0x70
>> =C2=A0 __free_pages_ok+0x3c0/0x1328
>> =C2=A0 __free_pages+0x50/0x78
>> =C2=A0 kfree+0x1c4/0x250
>> =C2=A0 kmalloc_pagealloc_uaf+0x38/0x80
>>
>> This has been discussed, please refer below link.
>> https://bugzilla.kernel.org/show_bug.cgi?id=3D203967
>=20
> That's not a discussion, but a single comment from Dmitry, which btw co=
ntains "provide alloc *and* free stacks for it" ("it" refers to page, emp=
hasis mine). It would be nice if he or other KASAN guys could clarify.
>=20

For slab objects we memorize both alloc and free stacks. You'll never kno=
w in advance what information will be usefull
to fix an issue, so it usually better to provide more information. I don'=
t think we should do anything different for pages.

Given that we already have the page_owner responsible for providing alloc=
/free stacks for pages, all that we should in KASAN do is to
enable the feature by default. Free stack saving should be decoupled from=
 debug_pagealloc into separate option so that it can be enabled=20
by KASAN and/or debug_pagealloc.

=20



