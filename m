Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 095626B6BB8
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 19:17:27 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id p15so12549194pfk.7
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 16:17:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j1sor20722366plk.57.2018.12.03.16.17.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Dec 2018 16:17:25 -0800 (PST)
From: john.hubbard@gmail.com
Subject: [PATCH 0/2] put_user_page*(): start converting the call sites
Date: Mon,  3 Dec 2018 16:17:18 -0800
Message-Id: <20181204001720.26138-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Jan Kara <jack@suse.cz>, Tom Talpey <tom@talpey.com>, Al Viro <viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, Dan Williams <dan.j.williams@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Ralph Campbell <rcampbell@nvidia.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

From: John Hubbard <jhubbard@nvidia.com>

Hi,

Summary: I'd like these two patches to go into the next convenient cycle.
I *think* that means 4.21.

Details

At the Linux Plumbers Conference, we talked about this approach [1], and
the primary lingering concern was over performance. Tom Talpey helped me
through a much more accurate run of the fio performance test, and now
it's looking like an under 1% performance cost, to add and remove pages
from the LRU (this is only paid when dealing with get_user_pages) [2]. So
we should be fine to start converting call sites.

This patchset gets the conversion started. Both patches already had a fair
amount of review.

(Tom, I'll add you Tested-by to the actual implementation that moves
pages on and off the LRU. These first two patches don't do that.)

[1] https://linuxplumbersconf.org/event/2/contributions/126/
    "RDMA and get_user_pages"

[2] https://lore.kernel.org/r/79d1ee27-9ea0-3d15-3fc4-97c1bd79c990@talpey.com

John Hubbard (2):
  mm: introduce put_user_page*(), placeholder versions
  infiniband/mm: convert put_page() to put_user_page*()

 drivers/infiniband/core/umem.c              |  7 +-
 drivers/infiniband/core/umem_odp.c          |  2 +-
 drivers/infiniband/hw/hfi1/user_pages.c     | 11 ++-
 drivers/infiniband/hw/mthca/mthca_memfree.c |  6 +-
 drivers/infiniband/hw/qib/qib_user_pages.c  | 11 ++-
 drivers/infiniband/hw/qib/qib_user_sdma.c   |  6 +-
 drivers/infiniband/hw/usnic/usnic_uiom.c    |  7 +-
 include/linux/mm.h                          | 20 ++++++
 mm/swap.c                                   | 80 +++++++++++++++++++++
 9 files changed, 123 insertions(+), 27 deletions(-)

-- 
2.19.2
