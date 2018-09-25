Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8387B8E009E
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 11:30:23 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id d205-v6so6296579qkg.16
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 08:30:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l13-v6sor884602qvi.64.2018.09.25.08.30.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Sep 2018 08:30:22 -0700 (PDT)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 4/8] mm: drop mmap_sem for swap read IO submission
Date: Tue, 25 Sep 2018 11:30:07 -0400
Message-Id: <20180925153011.15311-5-josef@toxicpanda.com>
In-Reply-To: <20180925153011.15311-1-josef@toxicpanda.com>
References: <20180925153011.15311-1-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, riel@redhat.com, hannes@cmpxchg.org, tj@kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Johannes Weiner <jweiner@fb.com>

From: Johannes Weiner <jweiner@fb.com>

We don't need to hold the mmap_sem while we're doing the IO, simply drop
it and retry appropriately.

Signed-off-by: Johannes Weiner <jweiner@fb.com>
Signed-off-by: Josef Bacik <josef@toxicpanda.com>
---
 mm/page_io.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/mm/page_io.c b/mm/page_io.c
index aafd19ec1db4..bf21b56a964e 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -365,6 +365,20 @@ int swap_readpage(struct page *page, bool synchronous)
 		goto out;
 	}
 
+	/*
+	 * XXX:
+	 *
+	 * Propagate mm->mmap_sem into this function. Then:
+	 *
+	 * get_file(sis->swap_file)
+	 * up_read(mm->mmap_sem)
+	 * submit io request
+	 * fput
+	 *
+	 * After mmap_sem is dropped, sis is no longer valid. Go
+	 * through swap_file->blah->bdev.
+	 */
+
 	if (sis->flags & SWP_FILE) {
 		struct file *swap_file = sis->swap_file;
 		struct address_space *mapping = swap_file->f_mapping;
-- 
2.14.3
