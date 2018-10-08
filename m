Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9E7456B0010
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 17:16:30 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id e15-v6so18459842pfi.5
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 14:16:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h194-v6sor15085607pfe.64.2018.10.08.14.16.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Oct 2018 14:16:29 -0700 (PDT)
From: john.hubbard@gmail.com
Subject: [PATCH v4 0/3] get_user_pages*() and RDMA: first steps
Date: Mon,  8 Oct 2018 14:16:20 -0700
Message-Id: <20181008211623.30796-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>, Al Viro <viro@zeniv.linux.org.uk>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Ralph Campbell <rcampbell@nvidia.com>, Andrew Morton <akpm@linux-foundation.org>

From: John Hubbard <jhubbard@nvidia.com>

Andrew, do you have a preference for which tree (MM or RDMA) this should
go in? If not, then could you please ACK this so that Jason can pick it
up for the RDMA tree?

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

-- Dennis, thanks for your earlier review, and I have not yet added your
   Reviewed-by tag, because this revision changes the things that you had
   previously reviewed, thus potentially requiring another look.

This short series prepares for eventually fixing the problem described
in [1], and is following a plan listed in [2], [3], [4].

Patch 1, although not technically critical to do now, is still nice to
have, because it's already been reviewed by Jan, and it's just one more
thing on the long TODO list here, that is ready to be checked off.

Patch 2 is required in order to allow me (and others, if I'm lucky) to
start submitting changes to convert all of the callsites of
get_user_pages*() and put_page().  I think this will work a lot better
than trying to maintain a massive patchset and submitting all at once.

Patch 3 converts infiniband drivers: put_page() --> put_user_page(), and
also exercises put_user_pages_dirty_locked().

Once these are all in, then the floodgates can open up to convert the large
number of get_user_pages*() callsites.

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

 drivers/infiniband/core/umem.c              |  7 +--
 drivers/infiniband/core/umem_odp.c          |  2 +-
 drivers/infiniband/hw/hfi1/user_pages.c     | 11 ++---
 drivers/infiniband/hw/mthca/mthca_memfree.c |  6 +--
 drivers/infiniband/hw/qib/qib_user_pages.c  | 11 ++---
 drivers/infiniband/hw/qib/qib_user_sdma.c   |  8 ++--
 drivers/infiniband/hw/usnic/usnic_uiom.c    |  7 +--
 include/linux/mm.h                          | 49 ++++++++++++++++++++-
 mm/gup.c                                    | 37 +++++++++-------
 9 files changed, 93 insertions(+), 45 deletions(-)

-- 
2.19.0
