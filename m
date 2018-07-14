Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 015936B0007
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 23:04:25 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id i4-v6so9061371ite.3
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 20:04:24 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id d19-v6si19098052jam.5.2018.07.13.20.04.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 20:04:23 -0700 (PDT)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6E2xMfG040879
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 03:04:23 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2130.oracle.com with ESMTP id 2k76pcr3pp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 03:04:23 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w6E34Lfl000321
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 03:04:21 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w6E34KKH000310
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 03:04:21 GMT
Received: by mail-oi0-f48.google.com with SMTP id n84-v6so65673586oib.9
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 20:04:20 -0700 (PDT)
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
 <5edf2d71-f548-98f9-16dd-b7fed29f4869@oracle.com> <CA+55aFwPAwczHS3XKkEnjY02PaDf2mWrcqx_hket4Ce3nScsSg@mail.gmail.com>
In-Reply-To: <CA+55aFwPAwczHS3XKkEnjY02PaDf2mWrcqx_hket4Ce3nScsSg@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 13 Jul 2018 23:03:43 -0400
Message-ID: <CAGM2rebeo3UUo2bL6kXCMGhuM36wjF5CfvqGG_3rpCfBs5S2wA@mail.gmail.com>
Subject: Re: Instability in current -git tree
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, tglx@linutronix.de, willy@infradead.org, mingo@redhat.com, axboe@kernel.dk, gregkh@linuxfoundation.org, davem@davemloft.net, viro@zeniv.linux.org.uk, airlied@gmail.com, Tejun Heo <tj@kernel.org>, tytso@google.com, snitzer@redhat.com, Linux Memory Management List <linux-mm@kvack.org>, neelx@redhat.com, mgorman@techsingularity.net

On Fri, Jul 13, 2018 at 10:40 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> On Fri, Jul 13, 2018 at 5:47 PM Pavel Tatashin
> <pasha.tatashin@oracle.com> wrote:
> >
> > The commit intends to zero memmap (struct pages) for every hole in
> > e820 ranges by marking them reserved in memblock. Later
> > zero_resv_unavail() walks through memmap ranges and zeroes struct
> > pages for every page that is reserved, but does not have a physical
> > backing known by kernel.
>
> Ahh. That just looks incoredibly buggy.
>
> You can't just memset() the 'struct page' to zero after it's been set up.

That should not be happening, unless there is a bug.
zero_resv_unavail() is supposed be zeroing struct pages that were not
setup.

Struct pages are configured here:

free_area_init_nodes()
  free_area_init_node()
    free_area_init_core()
      memmap_init()
        memmap_init_zone()
         if (pfn_valid(pfn))   <--- Actually few more checks:
early_pfn_valid(pfn), early_pfn_in_nid(pfn, nid)
          __init_single_page(pfn_to_page(pfn))
            mm_zero_struct_page(page);
            set the other fields in struct page
  zero_resv_unavail(); <-- is called at the end of free_area_init_nodes()
        if (!pfn_valid(pfn))
            mm_zero_struct_page(pfn_to_page(pfn)); <- So the idea that
we zero only the part of memmap that
            was not initialized in __init_single_page().

We want to zero those struct pages so we do not have uninitialized
data accessed by various parts of the code that rounds down large
pages and access the first page in section without verifying that the
page is valid. The example of this is described in commit that
introduced zero_resv_unavail()

>
> That also zeroes page->flags, but page->flags contains things like the
> zone and node ID.
>
> That would explain the completely bogus "DMA" zone. That's not the
> real zone, it's just that page_zonenr() returns 0 because of an
> incorrect clearing of page->flags.
>
> And it would also completely bugger pfn_to_page() for
> CONFIG_DISCONTIGMEM, because the way that works is that it looks up
> the node using page_to_nid(), and then looks up the pfn by using the
> per-node pglist_data ->node_mem_map (that the 'struct page' is
> supposed to be a pointer into).
>
> So zerong the page->flags after it has been set up is completely wrong
> as far as I can see. It literally invalidates 'struct page' and makes
> various core VM function assumptions stop working.
>
> As an example, it makes "page_to_pfn -> pfn_to_page" not be the
> identity transformation, which could result in totally random
> behavior.
>
> And it definitely explains the whole "oh, now the zone ID doesn't
> match" issue. It &*should* have been zone #1 ("DMA32"), but it got
> cleared and that made it zone #0 ("DMA").
>
> So yeah, this looks like the cause of it. And it could result in any
> number of really odd problems, so this could easily explain the syzbot
> failures and reboots at bootup too. Who knows what happens when
> pfn_to_page() doesn't work any more.
>
> Should we perhaps just revert
>
>   124049decbb1 x86/e820: put !E820_TYPE_RAM regions into memblock.reserved
>   f7f99100d8d9 mm: stop zeroing memory during allocation in vmemmap
>
> it still reverts fairly cleanly (there's a trivial conflict with the
> older commit).
>
>               Linus
>
