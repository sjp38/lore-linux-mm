Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3CE4D6B1CF8
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 01:11:47 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id z3-v6so4158584ybn.15
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 22:11:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f64-v6sor2976839ybf.78.2018.08.20.22.11.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Aug 2018 22:11:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180818012213.GA14115@bombadil.infradead.org>
References: <20180817231834.15959-1-guro@fb.com> <20180818012213.GA14115@bombadil.infradead.org>
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Tue, 21 Aug 2018 08:11:44 +0300
Message-ID: <CALYGNiOf_0fR4R747J11JNROO7_FW_9u16Bg09f+CdWPiFwGvw@mail.gmail.com>
Subject: Re: [PATCH RFC] mm: don't miss the last page because of round-off error
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>

On Sat, Aug 18, 2018 at 4:22 AM, Matthew Wilcox <willy@infradead.org> wrote:
> On Fri, Aug 17, 2018 at 04:18:34PM -0700, Roman Gushchin wrote:
>> -                     scan = div64_u64(scan * fraction[file],
>> -                                      denominator);
>> +                     if (scan > 1)
>> +                             scan = div64_u64(scan * fraction[file],
>> +                                              denominator);
>
> Wouldn't we be better off doing a div_round_up?  ie:
>
>         scan = div64_u64(scan * fraction[file] + denominator - 1, denominator);
>
> although i'd rather hide that in a new macro in math64.h than opencode it
> here.

All numbers here should be up to nr_pages * 200 and fit into unsigned long.
I see no reason for u64. If they overflow then u64 wouldn't help either.

There is macro DIV_ROUND_UP in kernel.h
