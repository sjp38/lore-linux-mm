Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id DDCF46B1FCD
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 13:16:03 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id r2-v6so10225942ybb.4
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 10:16:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y63-v6sor1490579ybf.104.2018.08.21.10.15.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Aug 2018 10:15:58 -0700 (PDT)
Date: Tue, 21 Aug 2018 13:15:55 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH RFC] mm: don't miss the last page because of round-off
 error
Message-ID: <20180821171555.GA16545@cmpxchg.org>
References: <20180817231834.15959-1-guro@fb.com>
 <20180818012213.GA14115@bombadil.infradead.org>
 <CALYGNiOf_0fR4R747J11JNROO7_FW_9u16Bg09f+CdWPiFwGvw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALYGNiOf_0fR4R747J11JNROO7_FW_9u16Bg09f+CdWPiFwGvw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>

On Tue, Aug 21, 2018 at 08:11:44AM +0300, Konstantin Khlebnikov wrote:
> On Sat, Aug 18, 2018 at 4:22 AM, Matthew Wilcox <willy@infradead.org> wrote:
> > On Fri, Aug 17, 2018 at 04:18:34PM -0700, Roman Gushchin wrote:
> >> -                     scan = div64_u64(scan * fraction[file],
> >> -                                      denominator);
> >> +                     if (scan > 1)
> >> +                             scan = div64_u64(scan * fraction[file],
> >> +                                              denominator);
> >
> > Wouldn't we be better off doing a div_round_up?  ie:
> >
> >         scan = div64_u64(scan * fraction[file] + denominator - 1, denominator);
> >
> > although i'd rather hide that in a new macro in math64.h than opencode it
> > here.
> 
> All numbers here should be up to nr_pages * 200 and fit into unsigned long.
> I see no reason for u64. If they overflow then u64 wouldn't help either.

It is nr_pages * 200 * recent_scanned, where recent_scanned can be up
to four times of what's on the LRUs. That can overflow a u32 with even
small amounts of memory.
