Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id C62B06B0005
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 13:59:30 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id t19-v6so3030456plo.9
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 10:59:30 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w13-v6si12424941pgo.542.2018.06.11.10.59.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Jun 2018 10:59:29 -0700 (PDT)
Date: Mon, 11 Jun 2018 10:59:27 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Distinguishing VMalloc pages
Message-ID: <20180611175927.GC28292@bombadil.infradead.org>
References: <20180611121129.GB12912@bombadil.infradead.org>
 <01000163efe179fe-d6270c58-eaba-482f-a6bd-334667250ef7-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000163efe179fe-d6270c58-eaba-482f-a6bd-334667250ef7-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org

On Mon, Jun 11, 2018 at 05:25:21PM +0000, Christopher Lameter wrote:
> On Mon, 11 Jun 2018, Matthew Wilcox wrote:
> 
> >
> > I think we all like the idea of being able to look at a page [1] and
> > determine what it's used for.  We have two places that we already look:
> >
> > PageSlab
> > page_type
> 
> Since we already have PageSlab: Is it possible to use that flag
> differently so that it is maybe something like PageTyped(xx)? I think
> there may be some bits available somewhere if PageSlab( is set and these
> typed pages usually are not on the lru. So if its untyped the page is on
> LRU otherwise the type can be identified somehow?

Yes, I've been thinking about that option too; thanks for bringing it up!

We need to go through the PageFlags and see which combinations of them
are valid.  I started on that in that same spreasdsheet (purposes tab) ...

Type flags: SL RS HP
State: LO ER RF UP DI LR AC WA O1 A1 PR P2 WB
HD MD RC SB UV ML UC YG ID

Mapping - 0xxx
Slab - 1000
VMalloc - 1001
Reserved - 1010
HWPoison - 1011
Kernel - 1100
PageTable - 1101
PageBuddy - 1110
1111 unused for now

SL is the Slab bit.  RS is Reserved and HP is HWPoison.  I believe that
all three of those bits are mutually exclusive (but maybe I'm wrong).

At any rate, SwapBacked only makes sense on anonymous pages (right?) and
MappedToDisk certainly doesn't make sense on slab pages, so we can use
those two bits ... I think.
