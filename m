Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 11BE08E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 01:40:04 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 186-v6so5577197pgc.12
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 22:40:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 15-v6sor1117246pgt.175.2018.09.27.22.40.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Sep 2018 22:40:02 -0700 (PDT)
From: john.hubbard@gmail.com
Subject: [PATCH 4/4] goldfish_pipe/mm: convert to the new release_user_pages() call
Date: Thu, 27 Sep 2018 22:39:49 -0700
Message-Id: <20180928053949.5381-5-jhubbard@nvidia.com>
In-Reply-To: <20180928053949.5381-1-jhubbard@nvidia.com>
References: <20180928053949.5381-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

From: John Hubbard <jhubbard@nvidia.com>

For code that retains pages via get_user_pages*(),
release those pages via the new release_user_pages(),
instead of calling put_page().

This prepares for eventually fixing the problem described
in [1], and is following a plan listed in [2].

[1] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"

[2] https://lkml.kernel.org/r/20180709080554.21931-1-jhubbard@nvidia.com
    Proposed steps for fixing get_user_pages() + DMA problems.

CC: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/platform/goldfish/goldfish_pipe.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/platform/goldfish/goldfish_pipe.c b/drivers/platform/goldfish/goldfish_pipe.c
index fad0345376e0..1e9455a86698 100644
--- a/drivers/platform/goldfish/goldfish_pipe.c
+++ b/drivers/platform/goldfish/goldfish_pipe.c
@@ -340,8 +340,9 @@ static void __release_user_pages(struct page **pages, int pages_count,
 	for (i = 0; i < pages_count; i++) {
 		if (!is_write && consumed_size > 0)
 			set_page_dirty(pages[i]);
-		put_page(pages[i]);
 	}
+
+	release_user_pages(pages, pages_count);
 }
 
 /* Populate the call parameters, merging adjacent pages together */
-- 
2.19.0
