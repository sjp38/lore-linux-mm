Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 334016B0253
	for <linux-mm@kvack.org>; Wed, 16 Mar 2016 08:03:30 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id p65so186580638wmp.1
        for <linux-mm@kvack.org>; Wed, 16 Mar 2016 05:03:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q199si4303278wmd.117.2016.03.16.05.03.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 16 Mar 2016 05:03:28 -0700 (PDT)
Subject: Re: Suspicious error for CMA stress test
References: <56D93ABE.9070406@huawei.com>
 <20160307043442.GB24602@js1304-P5Q-DELUXE> <56DD38E7.3050107@huawei.com>
 <56DDCB86.4030709@redhat.com> <56DE30CB.7020207@huawei.com>
 <56DF7B28.9060108@huawei.com>
 <CAAmzW4NDJwgq_P33Ru_X0MKXGQEnY5dr_SY1GFutPAqEUAc_rg@mail.gmail.com>
 <56E2FB5C.1040602@suse.cz> <20160314064925.GA27587@js1304-P5Q-DELUXE>
 <56E662E8.700@suse.cz> <20160314071803.GA28094@js1304-P5Q-DELUXE>
 <56E6AED1.6060703@suse.cz>
 <CAAmzW4OKQHJ06Bi86jqVFGxqWsW7h_EWeGPAFB9K1aY754C4aQ@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56E94B89.80706@suse.cz>
Date: Wed, 16 Mar 2016 13:03:21 +0100
MIME-Version: 1.0
In-Reply-To: <CAAmzW4OKQHJ06Bi86jqVFGxqWsW7h_EWeGPAFB9K1aY754C4aQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>, Laura Abbott <labbott@redhat.com>, Hanjun Guo <guohanjun@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 03/14/2016 03:10 PM, Joonsoo Kim wrote:
> 2016-03-14 21:30 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
>
> Now I see why this happen. I enabled CONFIG_DEBUG_PAGEALLOC
> and it makes difference.
>
> I tested on x86_64, gcc (Ubuntu 4.8.4-2ubuntu1~14.04.1) 4.8.4.
>
> With CONFIG_CMA + CONFIG_DEBUG_PAGEALLOC
> ./scripts/bloat-o-meter page_alloc_base.o page_alloc_vlastimil_orig.o
> add/remove: 0/0 grow/shrink: 2/0 up/down: 510/0 (510)
> function                                     old     new   delta
> free_one_page                               1050    1334    +284
> free_pcppages_bulk                          1396    1622    +226
>
> ./scripts/bloat-o-meter page_alloc_base.o page_alloc_mine.o
> add/remove: 0/0 grow/shrink: 2/0 up/down: 351/0 (351)
> function                                     old     new   delta
> free_one_page                               1050    1230    +180
> free_pcppages_bulk                          1396    1567    +171
>
>
> With CONFIG_CMA + !CONFIG_DEBUG_PAGEALLOC
> (pa_b is base, pa_v is yours and pa_m is mine)
>
> ./scripts/bloat-o-meter pa_b.o pa_v.o
> add/remove: 0/0 grow/shrink: 1/1 up/down: 88/-23 (65)
> function                                     old     new   delta
> free_one_page                                761     849     +88
> free_pcppages_bulk                          1117    1094     -23
>
> ./scripts/bloat-o-meter pa_b.o pa_m.o
> add/remove: 0/0 grow/shrink: 2/0 up/down: 329/0 (329)
> function                                     old     new   delta
> free_one_page                                761    1031    +270
> free_pcppages_bulk                          1117    1176     +59
>
> Still, it has difference but less than before.
> Maybe, we are still using different configuration. Could you
> check if CONFIG_DEBUG_VM is enabled or not? In my case, it's not

It's disabled here.

> enabled. And, do you think this bloat isn't acceptable?

Well, it is quite significant. But given that Hanjun sees the errors 
still, it's not the biggest issue now :/

> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
