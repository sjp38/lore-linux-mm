Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 50AB76B000A
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 22:40:52 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id z9-v6so11030132iom.14
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 19:40:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q2-v6sor10390302iog.302.2018.07.13.19.40.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Jul 2018 19:40:49 -0700 (PDT)
MIME-Version: 1.0
References: <CA+55aFyARQV302+mXNYznrOOjzW+yxbcv+=OkD43dG6G1ktoMQ@mail.gmail.com>
 <alpine.DEB.2.21.1807140031440.2644@nanos.tec.linutronix.de>
 <CA+55aFzBx1haeM2QSFvhaW2t_HVK78Y=bKvsiJmOZztwkZ-y7Q@mail.gmail.com>
 <CA+55aFzVGa57apuzDMBLgWQQRcm3BNBs1UEg-G_2o7YW1i=o2Q@mail.gmail.com>
 <CA+55aFy9NJZeqT7h_rAgbKUZLjzfxvDPwneFQracBjVhY53aQQ@mail.gmail.com>
 <20180713164804.fc2c27ccbac4c02ca2c8b984@linux-foundation.org>
 <CA+55aFxAZr8PHo-raTihr8TKK_D-fVL+k6_tw_UyDLychowFNw@mail.gmail.com>
 <20180713165812.ec391548ffeead96725d044c@linux-foundation.org>
 <9b93d48c-b997-01f7-2fd6-6e35301ef263@oracle.com> <CA+55aFxFw2-1BD2UBf_QJ2=faQES_8q==yUjwj4mGJ6Ub4uX7w@mail.gmail.com>
 <5edf2d71-f548-98f9-16dd-b7fed29f4869@oracle.com>
In-Reply-To: <5edf2d71-f548-98f9-16dd-b7fed29f4869@oracle.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 13 Jul 2018 19:40:37 -0700
Message-ID: <CA+55aFwPAwczHS3XKkEnjY02PaDf2mWrcqx_hket4Ce3nScsSg@mail.gmail.com>
Subject: Re: Instability in current -git tree
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Matthew Wilcox <willy@infradead.org>, Ingo Molnar <mingo@redhat.com>, Jens Axboe <axboe@kernel.dk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, David Miller <davem@davemloft.net>, Al Viro <viro@zeniv.linux.org.uk>, Dave Airlie <airlied@gmail.com>, Tejun Heo <tj@kernel.org>, Ted Ts'o <tytso@google.com>, Mike Snitzer <snitzer@redhat.com>, linux-mm <linux-mm@kvack.org>, Daniel Vacek <neelx@redhat.com>, Mel Gorman <mgorman@techsingularity.net>

On Fri, Jul 13, 2018 at 5:47 PM Pavel Tatashin
<pasha.tatashin@oracle.com> wrote:
>
> The commit intends to zero memmap (struct pages) for every hole in
> e820 ranges by marking them reserved in memblock. Later
> zero_resv_unavail() walks through memmap ranges and zeroes struct
> pages for every page that is reserved, but does not have a physical
> backing known by kernel.

Ahh. That just looks incoredibly buggy.

You can't just memset() the 'struct page' to zero after it's been set up.

That also zeroes page->flags, but page->flags contains things like the
zone and node ID.

That would explain the completely bogus "DMA" zone. That's not the
real zone, it's just that page_zonenr() returns 0 because of an
incorrect clearing of page->flags.

And it would also completely bugger pfn_to_page() for
CONFIG_DISCONTIGMEM, because the way that works is that it looks up
the node using page_to_nid(), and then looks up the pfn by using the
per-node pglist_data ->node_mem_map (that the 'struct page' is
supposed to be a pointer into).

So zerong the page->flags after it has been set up is completely wrong
as far as I can see. It literally invalidates 'struct page' and makes
various core VM function assumptions stop working.

As an example, it makes "page_to_pfn -> pfn_to_page" not be the
identity transformation, which could result in totally random
behavior.

And it definitely explains the whole "oh, now the zone ID doesn't
match" issue. It &*should* have been zone #1 ("DMA32"), but it got
cleared and that made it zone #0 ("DMA").

So yeah, this looks like the cause of it. And it could result in any
number of really odd problems, so this could easily explain the syzbot
failures and reboots at bootup too. Who knows what happens when
pfn_to_page() doesn't work any more.

Should we perhaps just revert

  124049decbb1 x86/e820: put !E820_TYPE_RAM regions into memblock.reserved
  f7f99100d8d9 mm: stop zeroing memory during allocation in vmemmap

it still reverts fairly cleanly (there's a trivial conflict with the
older commit).

              Linus
