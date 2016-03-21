Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id EA5746B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 00:40:56 -0400 (EDT)
Received: by mail-pf0-f172.google.com with SMTP id u190so251024960pfb.3
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 21:40:56 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 75si2020594pfs.118.2016.03.20.21.40.54
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 21:40:55 -0700 (PDT)
Date: Mon, 21 Mar 2016 13:42:20 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: Suspicious error for CMA stress test
Message-ID: <20160321044220.GA21578@js1304-P5Q-DELUXE>
References: <56E2FB5C.1040602@suse.cz>
 <20160314064925.GA27587@js1304-P5Q-DELUXE>
 <56E662E8.700@suse.cz>
 <20160314071803.GA28094@js1304-P5Q-DELUXE>
 <56E92AFC.9050208@huawei.com>
 <20160317065426.GA10315@js1304-P5Q-DELUXE>
 <56EA77BC.2090702@huawei.com>
 <56EAD0B4.2060807@suse.cz>
 <CAAmzW4MNdFHSSTpCfWqy7oDtkR_Hfu2dZa_LW97W8J5vr5m4tg@mail.gmail.com>
 <1458307955.18134.31.camel@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1458307955.18134.31.camel@pengutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lucas Stach <l.stach@pengutronix.de>
Cc: Vlastimil Babka <vbabka@suse.cz>, Laura Abbott <lauraa@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Catalin Marinas <Catalin.Marinas@arm.com>, Hanjun Guo <guohanjun@huawei.com>, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, qiuxishi <qiuxishi@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, dingtinahong <dingtianhong@huawei.com>, "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <labbott@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, chenjie6@huawei.com

On Fri, Mar 18, 2016 at 02:32:35PM +0100, Lucas Stach wrote:
> Hi Vlastimil, Joonsoo,
> 
> Am Freitag, den 18.03.2016, 00:52 +0900 schrieb Joonsoo Kim:
> > 2016-03-18 0:43 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> > > On 03/17/2016 10:24 AM, Hanjun Guo wrote:
> > >>
> > >> On 2016/3/17 14:54, Joonsoo Kim wrote:
> > >>>
> > >>> On Wed, Mar 16, 2016 at 05:44:28PM +0800, Hanjun Guo wrote:
> > >>>>
> > >>>> On 2016/3/14 15:18, Joonsoo Kim wrote:
> > >>>>>
> > >>>>> On Mon, Mar 14, 2016 at 08:06:16AM +0100, Vlastimil Babka wrote:
> > >>>>>>
> > >>>>>> On 03/14/2016 07:49 AM, Joonsoo Kim wrote:
> > >>>>>>>
> > >>>>>>> On Fri, Mar 11, 2016 at 06:07:40PM +0100, Vlastimil Babka wrote:
> > >>>>>>>>
> > >>>>>>>> On 03/11/2016 04:00 PM, Joonsoo Kim wrote:
> > >>>>>>>>
> > >>>>>>>> How about something like this? Just and idea, probably buggy
> > >>>>>>>> (off-by-one etc.).
> > >>>>>>>> Should keep away cost from <pageblock_order iterations at the
> > >>>>>>>> expense of the
> > >>>>>>>> relatively fewer >pageblock_order iterations.
> > >>>>>>>
> > >>>>>>> Hmm... I tested this and found that it's code size is a little bit
> > >>>>>>> larger than mine. I'm not sure why this happens exactly but I guess
> > >>>>>>> it would be
> > >>>>>>> related to compiler optimization. In this case, I'm in favor of my
> > >>>>>>> implementation because it looks like well abstraction. It adds one
> > >>>>>>> unlikely branch to the merge loop but compiler would optimize it to
> > >>>>>>> check it once.
> > >>>>>>
> > >>>>>> I would be surprised if compiler optimized that to check it once, as
> > >>>>>> order increases with each loop iteration. But maybe it's smart
> > >>>>>> enough to do something like I did by hand? Guess I'll check the
> > >>>>>> disassembly.
> > >>>>>
> > >>>>> Okay. I used following slightly optimized version and I need to
> > >>>>> add 'max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1)'
> > >>>>> to yours. Please consider it, too.
> > >>>>
> > >>>> Hmm, this one is not work, I still can see the bug is there after
> > >>>> applying
> > >>>> this patch, did I miss something?
> > >>>
> > >>> I may find that there is a bug which was introduced by me some time
> > >>> ago. Could you test following change in __free_one_page() on top of
> > >>> Vlastimil's patch?
> > >>>
> > >>> -page_idx = pfn & ((1 << max_order) - 1);
> > >>> +page_idx = pfn & ((1 << MAX_ORDER) - 1);
> > >>
> > >>
> > >> I tested Vlastimil's patch + your change with stress for more than half
> > >> hour, the bug
> > >> I reported is gone :)
> > >
> > >
> > > Oh, ok, will try to send proper patch, once I figure out what to write in
> > > the changelog :)
> > 
> > Thanks in advance!
> 
> After digging into the "PFN busy" race in CMA (see [1]), I believe we
> should just prevent any buddy merging in isolated ranges. This fixes the
> race I'm seeing without the need to hold the zone lock for extend
> periods of time.

"PFNs busy" can be caused by other type of race, too. I guess that
other cases happens more than buddy merging. Do you have any test case for
your problem?

If it is indeed a problem, you can avoid it with simple retry
MAX_ORDER times on alloc_contig_range(). This is a rather dirty but
the reason I suggest it is that there are other type of race in
__alloc_contig_range() and retry could help them, too. For example,
if some of pages in the requested range isn't attached to the LRU yet
or detached from the LRU but not freed to buddy,
test_pages_isolated() can be failed.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
