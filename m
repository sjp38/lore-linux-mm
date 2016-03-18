Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4829D828DF
	for <linux-mm@kvack.org>; Fri, 18 Mar 2016 10:42:42 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id p65so72029171wmp.1
        for <linux-mm@kvack.org>; Fri, 18 Mar 2016 07:42:42 -0700 (PDT)
Received: from metis.ext.pengutronix.de (metis.ext.pengutronix.de. [2001:67c:670:201:290:27ff:fe1d:cc33])
        by mx.google.com with ESMTPS id gi1si16517898wjd.61.2016.03.18.07.42.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 18 Mar 2016 07:42:41 -0700 (PDT)
Message-ID: <1458312126.18134.45.camel@pengutronix.de>
Subject: Re: Suspicious error for CMA stress test
From: Lucas Stach <l.stach@pengutronix.de>
Date: Fri, 18 Mar 2016 15:42:06 +0100
In-Reply-To: <56EC0C41.70503@suse.cz>
References: <56DD38E7.3050107@huawei.com> <56DDCB86.4030709@redhat.com>
	 <56DE30CB.7020207@huawei.com> <56DF7B28.9060108@huawei.com>
	 <CAAmzW4NDJwgq_P33Ru_X0MKXGQEnY5dr_SY1GFutPAqEUAc_rg@mail.gmail.com>
	 <56E2FB5C.1040602@suse.cz> <20160314064925.GA27587@js1304-P5Q-DELUXE>
	 <56E662E8.700@suse.cz> <20160314071803.GA28094@js1304-P5Q-DELUXE>
	 <56E92AFC.9050208@huawei.com> <20160317065426.GA10315@js1304-P5Q-DELUXE>
	 <56EA77BC.2090702@huawei.com> <56EAD0B4.2060807@suse.cz>
	 <CAAmzW4MNdFHSSTpCfWqy7oDtkR_Hfu2dZa_LW97W8J5vr5m4tg@mail.gmail.com>
	 <56EC0C41.70503@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <js1304@gmail.com>, Hanjun Guo <guohanjun@huawei.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>, Laura Abbott <labbott@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

Am Freitag, den 18.03.2016, 15:10 +0100 schrieb Vlastimil Babka:
> On 03/17/2016 04:52 PM, Joonsoo Kim wrote:
> > 2016-03-18 0:43 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> >>>>>>
> >>>>>> Okay. I used following slightly optimized version and I need to
> >>>>>> add 'max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1)'
> >>>>>> to yours. Please consider it, too.
> >>>>>
> >>>>> Hmm, this one is not work, I still can see the bug is there after
> >>>>> applying
> >>>>> this patch, did I miss something?
> >>>>
> >>>> I may find that there is a bug which was introduced by me some time
> >>>> ago. Could you test following change in __free_one_page() on top of
> >>>> Vlastimil's patch?
> >>>>
> >>>> -page_idx = pfn & ((1 << max_order) - 1);
> >>>> +page_idx = pfn & ((1 << MAX_ORDER) - 1);
> >>>
> >>>
> >>> I tested Vlastimil's patch + your change with stress for more than half
> >>> hour, the bug
> >>> I reported is gone :)
> >>
> >>
> >> Oh, ok, will try to send proper patch, once I figure out what to write in
> >> the changelog :)
> > 
> > Thanks in advance!
> > 
> 
> OK, here it is. Hanjun can you please retest this, as I'm not sure if you had
> the same code due to the followup one-liner patches in the thread. Lucas, see if
> it helps with your issue as well. Laura and Joonsoo, please also test and review
> and check changelog if my perception of the problem is accurate :)
> 

This doesn't help for my case, as it is still trying to merge pages in
isolated ranges. It even tries extra hard at doing so.

With concurrent isolation and frees going on this may lead to the start
page of the range to be isolated merging into an higher order buddy page
if it isn't already pageblock aligned, leading both test_pages_isolated
and isolate_freepages to fail on an otherwise perfectly fine range.

What I am arguing is that if a page is freed into an isolated range we
should not try merge it with it's buddies at all, by setting max_order =
order. If the range is isolated because want to isolate freepages from
it, the work to do the merging is wasted, as isolate_freepages will
split higher order pages into order-0 pages again.

If we already finished isolating freepages and are in the process of
undoing the isolation, we don't strictly need to do the merging in
__free_one_page, but can defer it to unset_migratetype_isolate, allowing
to simplify those code paths by disallowing any merging of isolated
pages at all.

Regards,
Lucas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
