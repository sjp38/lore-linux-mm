Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2841C6B0038
	for <linux-mm@kvack.org>; Wed, 24 Aug 2016 03:29:22 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id x96so12409604ybh.2
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 00:29:22 -0700 (PDT)
Received: from mail-ua0-x22b.google.com (mail-ua0-x22b.google.com. [2607:f8b0:400c:c08::22b])
        by mx.google.com with ESMTPS id 61si2041127uab.177.2016.08.24.00.29.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Aug 2016 00:29:21 -0700 (PDT)
Received: by mail-ua0-x22b.google.com with SMTP id n59so14190179uan.2
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 00:29:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160824070442.GB31179@dhcp22.suse.cz>
References: <20160822093249.GA14916@dhcp22.suse.cz> <20160823045245.GC17039@js1304-P5Q-DELUXE>
 <20160823073318.GA23577@dhcp22.suse.cz> <20160824050157.GA22781@js1304-P5Q-DELUXE>
 <20160824070442.GB31179@dhcp22.suse.cz>
From: Joonsoo Kim <js1304@gmail.com>
Date: Wed, 24 Aug 2016 16:29:20 +0900
Message-ID: <CAAmzW4MTbBbo54op_9sZ1kE9XPBsvsx=n=_vRXa21KtuFMiJ3w@mail.gmail.com>
Subject: Re: OOM detection regressions since 4.7
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, greg@suse.cz, Linus Torvalds <torvalds@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Vlastimil Babka <vbabka@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2016-08-24 16:04 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> On Wed 24-08-16 14:01:57, Joonsoo Kim wrote:
>> Looks like my mail client eat my reply so I resend.
>>
>> On Tue, Aug 23, 2016 at 09:33:18AM +0200, Michal Hocko wrote:
>> > On Tue 23-08-16 13:52:45, Joonsoo Kim wrote:
>> > [...]
>> > > Hello, Michal.
>> > >
>> > > I agree with partial revert but revert should be a different form.
>> > > Below change try to reuse should_compact_retry() version for
>> > > !CONFIG_COMPACTION but it turned out that it also causes regression in
>> > > Markus report [1].
>> >
>> > I would argue that CONFIG_COMPACTION=n behaves so arbitrary for high
>> > order workloads that calling any change in that behavior a regression
>> > is little bit exaggerated. Disabling compaction should have a very
>> > strong reason. I haven't heard any so far. I am even wondering whether
>> > there is a legitimate reason for that these days.
>> >
>> > > Theoretical reason for this regression is that it would stop retry
>> > > even if there are enough lru pages. It only checks if freepage
>> > > excesses min watermark or not for retry decision. To prevent
>> > > pre-mature OOM killer, we need to keep allocation loop when there are
>> > > enough lru pages. So, logic should be something like that.
>> > >
>> > > should_compact_retry()
>> > > {
>> > >         for_each_zone_zonelist_nodemask {
>> > >                 available = zone_reclaimable_pages(zone);
>> > >                 available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
>> > >                 if (__zone_watermark_ok(zone, *0*, min_wmark_pages(zone),
>> > >                         ac_classzone_idx(ac), alloc_flags, available))
>> > >                         return true;
>> > >
>> > >         }
>> > > }
>> > >
>> > > I suggested it before and current situation looks like it is indeed
>> > > needed.
>> >
>> > this just opens doors for an unbounded reclaim/threshing becacause
>> > you can reclaim as much as you like and there is no guarantee of a
>> > forward progress. The reason why !COMPACTION should_compact_retry only
>> > checks for the min_wmark without the reclaimable bias is that this will
>> > guarantee a retry if we are failing due to high order wmark check rather
>> > than a lack of memory. This condition is guaranteed to converge and the
>> > probability of the unbounded reclaim is much more reduced.
>>
>> In case of a lack of memory with a lot of reclaimable lru pages, why
>> do we stop reclaim/compaction?
>>
>> With your partial reverting patch, allocation logic would be like as
>> following.
>>
>> Assume following situation:
>> o a lot of reclaimable lru pages
>> o no order-2 freepage
>> o not enough order-0 freepage for min watermark
>> o order-2 allocation
>>
>> 1. order-2 allocation failed due to min watermark
>> 2. go to reclaim/compaction
>> 3. reclaim some pages (maybe SWAP_CLUSTER_MAX (32) pages) but still
>> min watermark isn't met for order-0
>> 4. compaction is skipped due to not enough freepage
>> 5. should_reclaim_retry() returns false because min watermark for
>> order-2 page isn't met
>> 6. should_compact_retry() returns false because min watermark for
>> order-0 page isn't met
>> 6. allocation is failed without any retry and OOM is invoked.
>
> If the direct reclaim is not able to get us over min wmark for order-0
> then we would be likely to hit the oom even for order-0 requests.

No, this situation is that direct reclaim can get us over min wmark for order-0
but it needs retry. IIUC, direct reclaim would not reclaim enough memory
at once. It tries to reclaim small amount of lru pages and break out to check
watermark.

>> Is it what you want?
>>
>> And, please elaborate more on how your logic guarantee to converge.
>> After order-0 freepage exceed min watermark, there is no way to stop
>> reclaim/threshing. Number of freepage just increase monotonically and
>> retry cannot be stopped until order-2 allocation succeed. Am I missing
>> something?
>
> My statement was imprecise at best. You are right that there is no
> guarantee to fullfil order-2 request. What I meant to say is that we
> should converge when we are getting out of memory (aka even order-0
> would have hard time to succeed). should_reclaim_retry does that by
> the back off scaling of the reclaimable pages. should_compact_retry
> would have to do the same thing which would effectively turn it into
> should_reclaim_retry.

So, I suggested to change should_reclaim_retry() for high order request,
before.

>> > > And, I still think that your OOM detection rework has some flaws.
>> > >
>> > > 1) It doesn't consider freeable objects that can be freed by shrink_slab().
>> > > There are many subsystems that cache many objects and they will be
>> > > freed by shrink_slab() interface. But, you don't account them when
>> > > making the OOM decision.
>> >
>> > I fully rely on the reclaim and compaction feedback. And that is the
>> > place where we should strive for improvements. So if we are growing way
>> > too many slab objects we should take care about that in the slab reclaim
>> > which is tightly coupled with the LRU reclaim rather than up the layer
>> > in the page allocator.
>>
>> No. slab shrink logic which is tightly coupled with the LRU reclaim
>> totally makes sense.
>
> Once the number of slab object is much larger than LRU pages (what we
> have seen in some oom reports) then the way how they are coupled just
> stops making a sense because the current approach no longer scales.  We
> might not have cared before because we used to retry blindly.  At least
> that is my understanding.

If your logic guarantee to retry until number of lru pages are scanned,
it would work well. It's not a problem of slab shrink.

> I am sorry to skip large parts of your email but I believe those things
> have been discussed and we would just repeat here. I full understand

Okay. We discussed it several times and I'm also tired to discuss this topic.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
