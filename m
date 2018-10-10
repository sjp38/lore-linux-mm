Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9F01A6B0006
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 00:11:42 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d63-v6so2906622pld.18
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 21:11:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q4-v6sor8743805pli.34.2018.10.09.21.11.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Oct 2018 21:11:41 -0700 (PDT)
From: john.hubbard@gmail.com
Subject: [PATCH v5 0/3] get_user_pages*() and RDMA: first steps
Date: Tue,  9 Oct 2018 21:11:31 -0700
Message-Id: <20181010041134.14096-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>, Al Viro <viro@zeniv.linux.org.uk>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Ralph Campbell <rcampbell@nvidia.com>, Andrew Morton <akpm@linux-foundation.org>

From: John Hubbard <jhubbard@nvidia.com>

Changes since v4:

-- Changed the new put_user_page*() functions to operate only on the head
   page, because that's how the final version of those functions will work.
   (Andrew Morton's feedback prompted this, thanks!)

-- Added proper documentation of the new put_user_page*() functions.

-- Moved most of the new put_user_page*() functions out of the header file,
   and into swap.c, because they have grown a little bigger than static
   inline functions should be. The trivial put_user_page() was left as
   a static inline for now, though.

-- Picked up Andrew Morton's Reviewed-by, for the first patch. I left
   Jan's Reviewed-by in place for now, but we should verify that it still
   holds, with the various changes above. The main difference is the change
   to use the head page, the rest is just code movement and documentation.

-- Fixed a bug in the infiniband patch, found by the kbuild bot.

-- Rewrote the changelogs (and part of this cover letter) to be clearer.
   Part of that is less reliance on links, and instead, just writing the
   steps directly.

Changes since v3:

-- Picks up Reviewed-by tags from Jan Kara and Dennis Dalessandro.

-- Picks up Acked-by tag from Jason Gunthorpe, in case this ends up *not*
   going in via the RDMA tree.

-- Fixes formatting of a comment.

Changes since v2:

-- Absorbed more dirty page handling logic into the put_user_page*(), and
   handled some page releasing loops in infiniband more thoroughly, as per
   Jason Gunthorpe's feedback.

-- Fixed a bug in the put_user_pages*() routines' loops (thanks to
   Ralph Campbell for spotting it).

Changes since v1:

-- Renamed release_user_pages*() to put_user_pages*(), from Jan's feedback.

-- Removed the goldfish.c changes, and instead, only included a single
   user (infiniband) of the new functions. That is because goldfish.c no
   longer has a name collision (it has a release_user_pages() routine), and
   also because infiniband exercises both the put_user_page() and
   put_user_pages*() paths.

-- Updated links to discussions and plans, so as to be sure to include
   bounce buffers, thanks to Jerome's feedback.

Also:

This short series prepares for eventually fixing the problem described
in [1]. The steps are:

1) (This patchset): Provide put_user_page*() routines, intended to be used
for releasing pages that were pinned via get_user_pages*().

2) Convert all of the call sites for get_user_pages*(), to
invoke put_user_page*(), instead of put_page(). This involves dozens of
call sites, any will take some time. Patch 3/3 here kicks off the effort,
by applying it to infiniband.

3) After (2) is complete, use get_user_pages*() and put_user_page*() to
implement tracking of these pages. This tracking will be separate from
the existing struct page refcounting.

4) Use the tracking and identification of these pages, to implement
special handling (especially in writeback paths) when the pages are
backed by a filesystem. Again, [1] provides details as to why that is
desirable.

Patch 1, although not technically critical to do now, is still nice to
have, because it's already been reviewed by Jan (and Andrew, now), and
it's just one more thing on the long TODO list here, that is ready to be
checked off.

Patch 2 is required in order to allow me (and others, if I'm lucky) to
start submitting changes to convert all of the callsites of
get_user_pages*() and put_page().  I think this will work a lot better
than trying to maintain a massive patchset and submitting all at once.

Patch 3 converts infiniband drivers: put_page() --> put_user_page(), and
also exercises put_user_pages_dirty_locked().

Once these are all in, then the floodgates can open up to convert the large
number of remaining get_user_pages*() callsites.

[1] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"

[2] https://lkml.kernel.org/r/20180709080554.21931-1-jhubbard@nvidia.com
    Proposed steps for fixing get_user_pages() + DMA problems.

[3]https://lkml.kernel.org/r/20180710082100.mkdwngdv5kkrcz6n@quack2.suse.cz
    Bounce buffers (otherwise [2] is not really viable).

[4] https://lkml.kernel.org/r/20181003162115.GG24030@quack2.suse.cz
    Follow-up discussions.

CC: Matthew Wilcox <willy@infradead.org>
CC: Michal Hocko <mhocko@kernel.org>
CC: Christopher Lameter <cl@linux.com>
CC: Jason Gunthorpe <jgg@ziepe.ca>
CC: Dan Williams <dan.j.williams@intel.com>
CC: Jan Kara <jack@suse.cz>
CC: Al Viro <viro@zeniv.linux.org.uk>
CC: Jerome Glisse <jglisse@redhat.com>
CC: Christoph Hellwig <hch@infradead.org>
CC: Ralph Campbell <rcampbell@nvidia.com>
CC: Andrew Morton <akpm@linux-foundation.org>

John Hubbard (3):
  mm: get_user_pages: consolidate error handling
  mm: introduce put_user_page*(), placeholder versions
  infiniband/mm: convert put_page() to put_user_page*()

 drivers/infiniband/core/umem.c              |  7 +-
 drivers/infiniband/core/umem_odp.c          |  2 +-
 drivers/infiniband/hw/hfi1/user_pages.c     | 11 +--
 drivers/infiniband/hw/mthca/mthca_memfree.c |  6 +-
 drivers/infiniband/hw/qib/qib_user_pages.c  | 11 +--
 drivers/infiniband/hw/qib/qib_user_sdma.c   |  6 +-
 drivers/infiniband/hw/usnic/usnic_uiom.c    |  7 +-
 include/linux/mm.h                          | 22 ++++++
 mm/gup.c                                    | 37 +++++----
 mm/swap.c                                   | 83 +++++++++++++++++++++
 10 files changed, 150 insertions(+), 42 deletions(-)

-- 
2.19.1
