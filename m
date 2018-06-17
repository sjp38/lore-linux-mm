Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 610226B0005
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 21:25:42 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id n40-v6so8156402ote.13
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 18:25:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z35-v6sor3888426otz.301.2018.06.16.18.25.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 16 Jun 2018 18:25:41 -0700 (PDT)
From: john.hubbard@gmail.com
Subject: [PATCH 0/2] mm: gup: don't unmap or drop filesystem buffers
Date: Sat, 16 Jun 2018 18:25:08 -0700
Message-Id: <20180617012510.20139-1-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>

From: John Hubbard <jhubbard@nvidia.com>

Hi,

I'm including people who have been talking about this. This is in one sense
a medium-term work around, because there is a plan to talk about more
extensive fixes at the upcoming Linux Plumbers Conference. I am seeing
several customer bugs, though, and I really want to fix those sooner.

I've come up with what I claim is a simple, robust fix, but...I'm
presuming to burn a struct page flag, and limit it to 64-bit arches, in
order to get there. Given that the problem is old (Jason Gunthorpe noted
that RDMA has been living with this problem since 2005), I think it's
worth it.

Leaving the new page flag set "nearly forever" is not great, but on the
other hand, once the page is actually freed, the flag does get cleared.
It seems like an acceptable tradeoff, given that we only get one bit
(and are lucky to even have that).

As hinted at in the longer writeup in patch #2, I really don't like the
various other approaches in which we try to hook into the (many!)
downstream symptoms and try to deduce that we're in this situation. It's
more appropriate to say, "these pages shall not be unmapped, nor buffers
removed ("do not disturb"), because they have been, well, pinned by the
get_user_pages call. I believe that this is what the original intention
might have been, and in any case, that's certainly how a lot of device
driver writers have interpreted get_user_pages memory over the last
decade.

John Hubbard (2):
  consolidate get_user_pages error handling
  mm: set PG_dma_pinned on get_user_pages*()

 include/linux/page-flags.h     |  9 +++++++
 include/trace/events/mmflags.h |  9 ++++++-
 mm/gup.c                       | 48 ++++++++++++++++++++++------------
 mm/page_alloc.c                |  1 +
 mm/rmap.c                      |  2 ++
 5 files changed, 51 insertions(+), 18 deletions(-)

-- 
2.17.1
