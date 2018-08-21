Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD246B1ED0
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 09:35:54 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id n21-v6so11834886plp.9
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 06:35:54 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v17-v6si11979029pgk.135.2018.08.21.06.35.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 21 Aug 2018 06:35:51 -0700 (PDT)
Date: Tue, 21 Aug 2018 06:35:48 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH RFC] mm: don't miss the last page because of round-off
 error
Message-ID: <20180821133548.GA10602@bombadil.infradead.org>
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
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>, Shaohua Li <shli@fb.com>

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

Shaohua added the div64 usage initially, adding him to the cc.

> There is macro DIV_ROUND_UP in kernel.h

Indeed there is.
