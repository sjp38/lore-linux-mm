Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8BE4F6B0003
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 12:00:46 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id n10-v6so1077234otl.2
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 09:00:46 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j188-v6si4799065oia.350.2018.06.25.09.00.45
        for <linux-mm@kvack.org>;
        Mon, 25 Jun 2018 09:00:45 -0700 (PDT)
Date: Mon, 25 Jun 2018 17:00:40 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: Calling vmalloc_to_page() on ioremap memory?
Message-ID: <20180625160040.di75264empbcf6xz@lakrids.cambridge.arm.com>
References: <CAG_fn=Vc5134sX6JRUoGp=W0to6eg56DuW3YErqeWuR_W_O9gQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG_fn=Vc5134sX6JRUoGp=W0to6eg56DuW3YErqeWuR_W_O9gQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Mon, Jun 25, 2018 at 04:59:23PM +0200, Alexander Potapenko wrote:
> Hi Ard, Mark, Andrew and others,
> 
> AFAIU, commit 029c54b09599573015a5c18dbe59cbdf42742237 ("mm/vmalloc.c:
> huge-vmap: fail gracefully on unexpected huge vmap mappings") was
> supposed to make vmalloc_to_page() return NULL for pointers not
> returned by vmalloc().

It's a little more subtle than that -- avoiding an edge case where we
unexpectedly hit huge mappings, rather than determining whether an
address same from vmalloc().

> For memory error detection purposes I'm trying to map the addresses
> from the vmalloc range to valid struct pages, or at least make sure
> there's no struct page for a given address.
> Looking up the vmap_area_root rbtree isn't an option, as this must be
> done from instrumented code, including interrupt handlers.

I'm not sure how you can do this without looking at VMAs.

In general, the vmalloc area can contain addresses which are not memory,
and this cannot be detremined from the address alone.

You *might* be able to get away with pfn_valid(vmalloc_to_pfn(x)), but
IIRC there's some disagreement on the precise meaning of pfn_valid(), so
that might just tell you that the address happens to fall close to some
valid memory.

Thanks,
Mark.
