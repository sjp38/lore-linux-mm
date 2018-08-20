Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 985746B1A9B
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 15:06:12 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id m2-v6so15971801qka.9
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 12:06:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z11-v6sor5688848qti.109.2018.08.20.12.06.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Aug 2018 12:06:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180820115818.mmeayjkplux2z6im@kshutemo-mobl1>
References: <20180820032204.9591-1-aarcange@redhat.com> <20180820115818.mmeayjkplux2z6im@kshutemo-mobl1>
From: Yang Shi <shy828301@gmail.com>
Date: Mon, 20 Aug 2018 12:06:11 -0700
Message-ID: <CAHbLzkqU88GbwpdP3dX7psVKG7boy21F+3iM4qnn4qE1wMeVyg@mail.gmail.com>
Subject: Re: [PATCH 0/2] fix for "pathological THP behavior"
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

On Mon, Aug 20, 2018 at 4:58 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Sun, Aug 19, 2018 at 11:22:02PM -0400, Andrea Arcangeli wrote:
>> Hello,
>>
>> we detected a regression compared to older kernels, only happening
>> with defrag=always or by using MADV_HUGEPAGE (and QEMU uses it).
>>
>> I haven't bisected but I suppose this started since commit
>> 5265047ac30191ea24b16503165000c225f54feb combined with previous
>> commits that introduced the logic to not try to invoke reclaim for THP
>> allocations in the remote nodes.
>>
>> Once I looked into it the problem was pretty obvious and there are two
>> possible simple fixes, one is not to invoke reclaim and stick to
>> compaction in the local node only (still __GFP_THISNODE model).
>>
>> This approach keeps the logic the same and prioritizes for NUMA
>> locality over THP generation.
>>
>> Then I'll send the an alternative that drops the __GFP_THISNODE logic
>> if_DIRECT_RECLAIM is set. That however changes the behavior for
>> MADV_HUGEPAGE and prioritizes THP generation over NUMA locality.
>>
>> A possible incremental improvement for this __GFP_COMPACT_ONLY
>> solution would be to remove __GFP_THISNODE (and in turn
>> __GFP_COMPACT_ONLY) after checking the watermarks if there's no free
>> PAGE_SIZEd memory in the local node. However checking the watermarks
>> in mempolicy.c is not ideal so it would be a more messy change and
>> it'd still need to use __GFP_COMPACT_ONLY as implemented here for when
>> there's no PAGE_SIZEd free memory in the local node. That further
>> improvement wouldn't be necessary if there's agreement to prioritize
>> THP generation over NUMA locality (the alternative solution I'll send
>> in a separate post).
>
> I personally prefer to prioritize NUMA locality over THP
> (__GFP_COMPACT_ONLY variant), but I don't know page-alloc/compaction good
> enough to Ack it.


May the approach #1 break the setting of zone_reclaim_mode? Or it may
behave like zone_reclaim_mode is set even though the knob is cleared?

Thanks,
Yang

>
> --
>  Kirill A. Shutemov
>
