Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 663E96B027F
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 04:06:37 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id u1-v6so18853936ywg.6
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 01:06:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s144-v6sor4311351ybc.58.2018.07.09.01.06.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Jul 2018 01:06:36 -0700 (PDT)
From: john.hubbard@gmail.com
Subject: [PATCH 2/2] goldfish_pipe/mm: convert to the new put_user_page() call
Date: Mon,  9 Jul 2018 01:05:54 -0700
Message-Id: <20180709080554.21931-3-jhubbard@nvidia.com>
In-Reply-To: <20180709080554.21931-1-jhubbard@nvidia.com>
References: <20180709080554.21931-1-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

From: John Hubbard <jhubbard@nvidia.com>

For code that retains pages via get_user_pages*(),
release those pages via the new put_user_page(),
instead of put_page().

Also: rename release_user_pages(), to avoid a naming
conflict with the new external function of the same name.

CC: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/platform/goldfish/goldfish_pipe.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/platform/goldfish/goldfish_pipe.c b/drivers/platform/goldfish/goldfish_pipe.c
index 3e32a4c14d5f..3ab871c22a88 100644
--- a/drivers/platform/goldfish/goldfish_pipe.c
+++ b/drivers/platform/goldfish/goldfish_pipe.c
@@ -331,7 +331,7 @@ static int pin_user_pages(unsigned long first_page, unsigned long last_page,
 
 }
 
-static void release_user_pages(struct page **pages, int pages_count,
+static void __release_user_pages(struct page **pages, int pages_count,
 	int is_write, s32 consumed_size)
 {
 	int i;
@@ -339,7 +339,7 @@ static void release_user_pages(struct page **pages, int pages_count,
 	for (i = 0; i < pages_count; i++) {
 		if (!is_write && consumed_size > 0)
 			set_page_dirty(pages[i]);
-		put_page(pages[i]);
+		put_user_page(pages[i]);
 	}
 }
 
@@ -409,7 +409,7 @@ static int transfer_max_buffers(struct goldfish_pipe *pipe,
 
 	*consumed_size = pipe->command_buffer->rw_params.consumed_size;
 
-	release_user_pages(pages, pages_count, is_write, *consumed_size);
+	__release_user_pages(pages, pages_count, is_write, *consumed_size);
 
 	mutex_unlock(&pipe->lock);
 
-- 
2.18.0
