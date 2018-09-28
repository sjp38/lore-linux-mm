Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6588E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 01:40:02 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x85-v6so5627874pfe.13
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 22:40:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v126-v6sor1089741pgv.289.2018.09.27.22.40.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Sep 2018 22:40:01 -0700 (PDT)
From: john.hubbard@gmail.com
Subject: [PATCH 2/4] mm: introduce put_user_page(), placeholder version
Date: Thu, 27 Sep 2018 22:39:48 -0700
Message-Id: <20180928053949.5381-4-jhubbard@nvidia.com>
In-Reply-To: <20180928053949.5381-1-jhubbard@nvidia.com>
References: <20180928053949.5381-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

From: John Hubbard <jhubbard@nvidia.com>

Introduces put_user_page(), which simply calls put_page().
This provides a way to update all get_user_pages*() callers,
so that they call put_user_page(), instead of put_page().

Also adds release_user_pages(), a drop-in replacement for
release_pages(). This is intended to be easily grep-able,
for later performance improvements, since release_user_pages
is not batched like release_pages() is, and is significantly
slower.

Also: rename goldfish_pipe.c's release_user_pages(), in order
to avoid a naming conflict with the new external function of
the same name.

This prepares for eventually fixing the problem described
in [1], and is following a plan listed in [2].

[1] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"

[2] https://lkml.kernel.org/r/20180709080554.21931-1-jhubbard@nvidia.com
    Proposed steps for fixing get_user_pages() + DMA problems.

CC: Matthew Wilcox <willy@infradead.org>
CC: Michal Hocko <mhocko@kernel.org>
CC: Christopher Lameter <cl@linux.com>
CC: Jason Gunthorpe <jgg@ziepe.ca>
CC: Dan Williams <dan.j.williams@intel.com>
CC: Jan Kara <jack@suse.cz>
CC: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/platform/goldfish/goldfish_pipe.c |  4 ++--
 include/linux/mm.h                        | 14 ++++++++++++++
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/platform/goldfish/goldfish_pipe.c b/drivers/platform/goldfish/goldfish_pipe.c
index 2da567540c2d..fad0345376e0 100644
--- a/drivers/platform/goldfish/goldfish_pipe.c
+++ b/drivers/platform/goldfish/goldfish_pipe.c
@@ -332,7 +332,7 @@ static int pin_user_pages(unsigned long first_page, unsigned long last_page,
 
 }
 
-static void release_user_pages(struct page **pages, int pages_count,
+static void __release_user_pages(struct page **pages, int pages_count,
 	int is_write, s32 consumed_size)
 {
 	int i;
@@ -410,7 +410,7 @@ static int transfer_max_buffers(struct goldfish_pipe *pipe,
 
 	*consumed_size = pipe->command_buffer->rw_params.consumed_size;
 
-	release_user_pages(pages, pages_count, is_write, *consumed_size);
+	__release_user_pages(pages, pages_count, is_write, *consumed_size);
 
 	mutex_unlock(&pipe->lock);
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a61ebe8ad4ca..72caf803115f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -943,6 +943,20 @@ static inline void put_page(struct page *page)
 		__put_page(page);
 }
 
+/* Placeholder version, until all get_user_pages*() callers are updated. */
+static inline void put_user_page(struct page *page)
+{
+	put_page(page);
+}
+
+/* A drop-in replacement for release_pages(): */
+static inline void release_user_pages(struct page **pages,
+				      unsigned long npages)
+{
+	while (npages)
+		put_user_page(pages[--npages]);
+}
+
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
 #define SECTION_IN_PAGE_FLAGS
 #endif
-- 
2.19.0
