Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0CCEB6B22D0
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 02:01:35 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id v144-v6so455093ywa.23
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 23:01:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h88-v6sor289040ybi.57.2018.08.21.23.01.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Aug 2018 23:01:32 -0700 (PDT)
MIME-Version: 1.0
References: <20180817231834.15959-1-guro@fb.com> <20180818012213.GA14115@bombadil.infradead.org>
 <CALYGNiOf_0fR4R747J11JNROO7_FW_9u16Bg09f+CdWPiFwGvw@mail.gmail.com> <20180821171555.GA16545@cmpxchg.org>
In-Reply-To: <20180821171555.GA16545@cmpxchg.org>
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Wed, 22 Aug 2018 09:01:19 +0300
Message-ID: <CALYGNiMO973zcp85i5yd=Fa-Jo7SdObXH6sPuogoO3hnB-GgRA@mail.gmail.com>
Subject: Re: [PATCH RFC] mm: don't miss the last page because of round-off error
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Matthew Wilcox <willy@infradead.org>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>

On Tue, Aug 21, 2018 at 8:15 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Tue, Aug 21, 2018 at 08:11:44AM +0300, Konstantin Khlebnikov wrote:
>> On Sat, Aug 18, 2018 at 4:22 AM, Matthew Wilcox <willy@infradead.org> wrote:
>> > On Fri, Aug 17, 2018 at 04:18:34PM -0700, Roman Gushchin wrote:
>> >> -                     scan = div64_u64(scan * fraction[file],
>> >> -                                      denominator);
>> >> +                     if (scan > 1)
>> >> +                             scan = div64_u64(scan * fraction[file],
>> >> +                                              denominator);
>> >
>> > Wouldn't we be better off doing a div_round_up?  ie:
>> >
>> >         scan = div64_u64(scan * fraction[file] + denominator - 1, denominator);
>> >
>> > although i'd rather hide that in a new macro in math64.h than opencode it
>> > here.
>>
>> All numbers here should be up to nr_pages * 200 and fit into unsigned long.
>> I see no reason for u64. If they overflow then u64 wouldn't help either.
>
> It is nr_pages * 200 * recent_scanned, where recent_scanned can be up
> to four times of what's on the LRUs. That can overflow a u32 with even
> small amounts of memory.

Ah, this thing is inverted because it aims to proportional reactivation rate
rather than the proportional pressure to reclaimable pages.
That's not obvious. I suppose this should be in comment above it.

Well, at least denominator should fit into unsigned long. So full
64/64 division is redundant.
