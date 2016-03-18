Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 0B2F5828DF
	for <linux-mm@kvack.org>; Fri, 18 Mar 2016 09:33:00 -0400 (EDT)
Received: by mail-wm0-f54.google.com with SMTP id l68so31505646wml.0
        for <linux-mm@kvack.org>; Fri, 18 Mar 2016 06:33:00 -0700 (PDT)
Received: from metis.ext.pengutronix.de (metis.ext.pengutronix.de. [2001:67c:670:201:290:27ff:fe1d:cc33])
        by mx.google.com with ESMTPS id a17si7195952wjx.30.2016.03.18.06.32.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 18 Mar 2016 06:32:58 -0700 (PDT)
Message-ID: <1458307955.18134.31.camel@pengutronix.de>
Subject: Re: Suspicious error for CMA stress test
From: Lucas Stach <l.stach@pengutronix.de>
Date: Fri, 18 Mar 2016 14:32:35 +0100
In-Reply-To: <CAAmzW4MNdFHSSTpCfWqy7oDtkR_Hfu2dZa_LW97W8J5vr5m4tg@mail.gmail.com>
References: <56DD38E7.3050107@huawei.com> <56DDCB86.4030709@redhat.com>
	 <56DE30CB.7020207@huawei.com> <56DF7B28.9060108@huawei.com>
	 <CAAmzW4NDJwgq_P33Ru_X0MKXGQEnY5dr_SY1GFutPAqEUAc_rg@mail.gmail.com>
	 <56E2FB5C.1040602@suse.cz> <20160314064925.GA27587@js1304-P5Q-DELUXE>
	 <56E662E8.700@suse.cz> <20160314071803.GA28094@js1304-P5Q-DELUXE>
	 <56E92AFC.9050208@huawei.com> <20160317065426.GA10315@js1304-P5Q-DELUXE>
	 <56EA77BC.2090702@huawei.com> <56EAD0B4.2060807@suse.cz>
	 <CAAmzW4MNdFHSSTpCfWqy7oDtkR_Hfu2dZa_LW97W8J5vr5m4tg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: Laura Abbott <lauraa@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Catalin Marinas <Catalin.Marinas@arm.com>, Hanjun Guo <guohanjun@huawei.com>, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, qiuxishi <qiuxishi@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, dingtinahong <dingtianhong@huawei.com>, "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>, Sasha Levin <sasha.levin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Laura Abbott <labbott@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, chenjie6@huawei.com

Hi Vlastimil, Joonsoo,

Am Freitag, den 18.03.2016, 00:52 +0900 schrieb Joonsoo Kim:
> 2016-03-18 0:43 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> > On 03/17/2016 10:24 AM, Hanjun Guo wrote:
> >>
> >> On 2016/3/17 14:54, Joonsoo Kim wrote:
> >>>
> >>> On Wed, Mar 16, 2016 at 05:44:28PM +0800, Hanjun Guo wrote:
> >>>>
> >>>> On 2016/3/14 15:18, Joonsoo Kim wrote:
> >>>>>
> >>>>> On Mon, Mar 14, 2016 at 08:06:16AM +0100, Vlastimil Babka wrote:
> >>>>>>
> >>>>>> On 03/14/2016 07:49 AM, Joonsoo Kim wrote:
> >>>>>>>
> >>>>>>> On Fri, Mar 11, 2016 at 06:07:40PM +0100, Vlastimil Babka wrote:
> >>>>>>>>
> >>>>>>>> On 03/11/2016 04:00 PM, Joonsoo Kim wrote:
> >>>>>>>>
> >>>>>>>> How about something like this? Just and idea, probably buggy
> >>>>>>>> (off-by-one etc.).
> >>>>>>>> Should keep away cost from <pageblock_order iterations at the
> >>>>>>>> expense of the
> >>>>>>>> relatively fewer >pageblock_order iterations.
> >>>>>>>
> >>>>>>> Hmm... I tested this and found that it's code size is a little bit
> >>>>>>> larger than mine. I'm not sure why this happens exactly but I guess
> >>>>>>> it would be
> >>>>>>> related to compiler optimization. In this case, I'm in favor of my
> >>>>>>> implementation because it looks like well abstraction. It adds one
> >>>>>>> unlikely branch to the merge loop but compiler would optimize it to
> >>>>>>> check it once.
> >>>>>>
> >>>>>> I would be surprised if compiler optimized that to check it once, as
> >>>>>> order increases with each loop iteration. But maybe it's smart
> >>>>>> enough to do something like I did by hand? Guess I'll check the
> >>>>>> disassembly.
> >>>>>
> >>>>> Okay. I used following slightly optimized version and I need to
> >>>>> add 'max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1)'
> >>>>> to yours. Please consider it, too.
> >>>>
> >>>> Hmm, this one is not work, I still can see the bug is there after
> >>>> applying
> >>>> this patch, did I miss something?
> >>>
> >>> I may find that there is a bug which was introduced by me some time
> >>> ago. Could you test following change in __free_one_page() on top of
> >>> Vlastimil's patch?
> >>>
> >>> -page_idx = pfn & ((1 << max_order) - 1);
> >>> +page_idx = pfn & ((1 << MAX_ORDER) - 1);
> >>
> >>
> >> I tested Vlastimil's patch + your change with stress for more than half
> >> hour, the bug
> >> I reported is gone :)
> >
> >
> > Oh, ok, will try to send proper patch, once I figure out what to write in
> > the changelog :)
> 
> Thanks in advance!

After digging into the "PFN busy" race in CMA (see [1]), I believe we
should just prevent any buddy merging in isolated ranges. This fixes the
race I'm seeing without the need to hold the zone lock for extend
periods of time.
Also any merging done in an isolated range is likely to be completely
wasted work, as higher order buddy pages are broken up again into single
pages in isolate_freepages.

If we do that the patch to fix the bug in question for this report would
boil down to a check if the current pages buddy is isolated and abort
merging at that point, right? undo_isolate_page_range will then do all
necessary merging that has been skipped while the range was isolated.

Do you see issues with this approach?

Regards,
Lucas

[1] http://thread.gmane.org/gmane.linux.kernel.mm/148383

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
