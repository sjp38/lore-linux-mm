Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 60CBC6B027B
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 04:06:33 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id r144-v6so8297556ywg.9
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 01:06:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n125-v6sor1167974ybb.59.2018.07.09.01.06.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Jul 2018 01:06:32 -0700 (PDT)
From: john.hubbard@gmail.com
Subject: [PATCH 0/2] mm/fs: put_user_page() proposal
Date: Mon,  9 Jul 2018 01:05:52 -0700
Message-Id: <20180709080554.21931-1-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

From: John Hubbard <jhubbard@nvidia.com>

Hi,

With respect to tracking get_user_pages*() pages with page->dma_pinned*
fields [1], I spent a few days retrofitting most of the get_user_pages*()
call sites, by adding calls to a new put_user_page() function, in place
of put_page(), where appropriate. This will work, but it's a large effort.

Design note: I didn't see anything that hinted at a way to fix this
problem, without actually changing all of the get_user_pages*() call sites,
so I think it's reasonable to start with that.

Anyway, it's still incomplete, but because this is a large, tree-wide
change (that will take some time and testing), I'd like to propose a plan,
before spamming zillions of people with put_user_page() conversion patches.
So I picked out the first two patches to show where this is going.

Proposed steps:

Step 1:

Start with the patches here, then continue with...dozens more.
This will eventually convert all of the call sites to use put_user_page().
This is easy in some places, but complex in others, such as:

    -- drivers/gpu/drm/amd
    -- bio
    -- fuse
    -- cifs
    -- anything from:
           git grep  iov_iter_get_pages | cut -f1 -d ':' | sort | uniq

The easy ones can be grouped into a single patchset, perhaps, and the
complex ones probably each need a patchset, in order to get the in-depth
review they'll need.

Furthermore, some of these areas I hope to attract some help on, once
this starts going.

Step 2:

In parallel, tidy up the core patchset that was discussed in [1], (version
2 has already been reviewed, so I know what to do), and get it perfected
and reviewed. Don't apply it until step 1 is all done, though.

Step 3:

Activate refcounting of dma-pinned pages (essentially, patch #5, which is
[1]), but don't use it yet. Place a few WARN_ON_ONCE calls to start
mopping up any missed call sites.

Step 4:

After some soak time, actually connect it up (patch #6 of [1]) and start
taking action based on the new page->dma_pinned* fields.

[1] https://www.spinics.net/lists/linux-mm/msg156409.html

  or, the same thread on LKML if it's working for you:

    https://lkml.org/lkml/2018/7/4/368

John Hubbard (2):
  mm: introduce put_user_page(), placeholder version
  goldfish_pipe/mm: convert to the new put_user_page() call

 drivers/platform/goldfish/goldfish_pipe.c |  6 +++---
 include/linux/mm.h                        | 14 ++++++++++++++
 2 files changed, 17 insertions(+), 3 deletions(-)

-- 
2.18.0
