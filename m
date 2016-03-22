Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 43EEC6B025E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 10:47:47 -0400 (EDT)
Received: by mail-wm0-f53.google.com with SMTP id l68so167215657wml.1
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 07:47:47 -0700 (PDT)
Received: from metis.ext.pengutronix.de (metis.ext.pengutronix.de. [2001:67c:670:201:290:27ff:fe1d:cc33])
        by mx.google.com with ESMTPS id r3si37800384wjy.50.2016.03.22.07.47.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 22 Mar 2016 07:47:45 -0700 (PDT)
Message-ID: <1458658023.2171.16.camel@pengutronix.de>
Subject: Re: Suspicious error for CMA stress test
From: Lucas Stach <l.stach@pengutronix.de>
Date: Tue, 22 Mar 2016 15:47:03 +0100
In-Reply-To: <56EC6BFB.2020107@suse.cz>
References: <56DD38E7.3050107@huawei.com> <56DDCB86.4030709@redhat.com>
	 <56DE30CB.7020207@huawei.com> <56DF7B28.9060108@huawei.com>
	 <CAAmzW4NDJwgq_P33Ru_X0MKXGQEnY5dr_SY1GFutPAqEUAc_rg@mail.gmail.com>
	 <56E2FB5C.1040602@suse.cz> <20160314064925.GA27587@js1304-P5Q-DELUXE>
	 <56E662E8.700@suse.cz> <20160314071803.GA28094@js1304-P5Q-DELUXE>
	 <56E92AFC.9050208@huawei.com> <20160317065426.GA10315@js1304-P5Q-DELUXE>
	 <56EA77BC.2090702@huawei.com> <56EAD0B4.2060807@suse.cz>
	 <CAAmzW4MNdFHSSTpCfWqy7oDtkR_Hfu2dZa_LW97W8J5vr5m4tg@mail.gmail.com>
	 <56EC0C41.70503@suse.cz> <1458312126.18134.45.camel@pengutronix.de>
	 <56EC6BFB.2020107@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <js1304@gmail.com>, Hanjun Guo <guohanjun@huawei.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>, Laura Abbott <labbott@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

Am Freitag, den 18.03.2016, 21:58 +0100 schrieb Vlastimil Babka:
> On 03/18/2016 03:42 PM, Lucas Stach wrote:
> > Am Freitag, den 18.03.2016, 15:10 +0100 schrieb Vlastimil Babka:
> >> On 03/17/2016 04:52 PM, Joonsoo Kim wrote:
> >> > 2016-03-18 0:43 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> >>
> >> OK, here it is. Hanjun can you please retest this, as I'm not sure if you had
> >> the same code due to the followup one-liner patches in the thread. Lucas, see if
> >> it helps with your issue as well. Laura and Joonsoo, please also test and review
> >> and check changelog if my perception of the problem is accurate :)
> >>
> >
> > This doesn't help for my case, as it is still trying to merge pages in
> > isolated ranges. It even tries extra hard at doing so.
> >
> > With concurrent isolation and frees going on this may lead to the start
> > page of the range to be isolated merging into an higher order buddy page
> > if it isn't already pageblock aligned, leading both test_pages_isolated
> > and isolate_freepages to fail on an otherwise perfectly fine range.
> >
> > What I am arguing is that if a page is freed into an isolated range we
> > should not try merge it with it's buddies at all, by setting max_order =
> > order. If the range is isolated because want to isolate freepages from
> > it, the work to do the merging is wasted, as isolate_freepages will
> > split higher order pages into order-0 pages again.
> >
> > If we already finished isolating freepages and are in the process of
> > undoing the isolation, we don't strictly need to do the merging in
> > __free_one_page, but can defer it to unset_migratetype_isolate, allowing
> > to simplify those code paths by disallowing any merging of isolated
> > pages at all.
> 
> Oh, I think understand now. Yeah, skipping merging for pages in isolated 
> pageblocks might be a rather elegant solution. But still, we would have to check 
> buddy's migratetype at order >= pageblock_order like my patch does, which is 
> annoying. Because even without isolated merging, the buddy might have already 
> had order>=pageblock_order when it was isolated.

> So what if isolation also split existing buddies in the pageblock immediately 
> when it sets the MIGRATETYPE_ISOLATE on the pageblock? Then we would have it 
> guaranteed that there's no isolated buddy - a buddy candidate at order >= 
> pageblock_order either has a smaller order (so it's not a buddy) or is not 
> MIGRATE_ISOLATE so it's safe to merge with.
> 
> Does that make sense?
> 
This might increase the the overhead of isolation a lot. CMA is also
used for small order allocations, so the work of splitting a whole
pageblock to allocate a small number of pages out just to merge a lot of
them again on unisolation might make this unattractive.

My feeling is that checking the buddy migratetype for >=pageblock_order
frees might be lower overhead, but I have no hard numbers to back this
claim.

Then on the other hand moving the work to isolation/unisolation affects
only code paths that are expected to be quite slow anyways, doing the
check in _free_one_page will affect everyone.

Regards,
Lucas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
