Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 915976B009C
	for <linux-mm@kvack.org>; Tue,  5 Nov 2013 17:10:48 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id um15so355611pbc.22
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 14:10:48 -0800 (PST)
Received: from psmtp.com ([74.125.245.102])
        by mx.google.com with SMTP id ra5si11910589pbc.164.2013.11.05.14.10.45
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 14:10:46 -0800 (PST)
Date: Tue, 5 Nov 2013 23:10:17 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] mm: hugetlbfs: fix hugetlbfs optimization
Message-ID: <20131105221017.GI3835@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: gregkh@linuxfoundation.org, bhutchings@solarflare.com, pshelar@nicira.com, cl@linux.com, hannes@cmpxchg.org, mel@csn.ul.ie, riel@redhat.com, minchan@kernel.org, andi@firstfloor.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-mm@kvack.org

Hi,

this patch is an alternative implementation of the hugetlbfs directio
optimization discussed earlier. We've been looking into this with
Khalid last week and an earlier version of this patch (fully
equivalent as far as CPU overhead is concerned) was benchmarked by
Khalid and it didn't degrade performance compared to the PageHuge
check in current upstream code, so we should be good.

The patch applies cleanly only after reverting
7cb2ef56e6a8b7b368b2e883a0a47d02fed66911, it's much easier to review
it in this form as it avoids all the alignment changes. I'll resend to
Andrew against current upstream by squashing it with the revert after
reviews.

I wished to remove the _mapcount tailpage refcounting for slab and
hugetlbfs tails too, but if the last put_page of a slab tail happens
after the slab page isn't a slab page anymore (but still compound as
it wasn't freed yet because of the tail pin), a VM_BUG_ON would
trigger during the last (unpinning) put_page(slab_tail) with the
mapcount underflow:

			VM_BUG_ON(page_mapcount(page) <= 0);

Not even sure if any driver is doing anything like that, but the
current code would allow it, Pravin should know more about when
exactly in which conditions the last put_page is done on slab tail
pages.

It shall be possible to remove the _mapcount refcounting anyway, as it
is only read by split_huge_page and so it doesn't actually matter if
it underflows, but I prefer to keep the VM_BUG_ON. In fact I added one
more VM_BUG_ON(!PageHead()) even in this patch.

I also didn't notice we missed a PageHead check before calling
__put_single_page(page_head), so I corrected that. It sounds very
unlikely that it could have ever triggered but still better to fix it.

I just booted it... not very well tested yet. Help with the testing
appreciated :).

=====
