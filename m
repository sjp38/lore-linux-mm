Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2791A6B03AF
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 05:35:09 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b84so8676434wmh.0
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 02:35:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g51si18116751wra.185.2017.06.01.02.33.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 02:33:16 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 28/35] shmem: Use pagevec_lookup_entries()
Date: Thu,  1 Jun 2017 11:32:38 +0200
Message-Id: <20170601093245.29238-29-jack@suse.cz>
In-Reply-To: <20170601093245.29238-1-jack@suse.cz>
References: <20170601093245.29238-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, David Howells <dhowells@redhat.com>, linux-afs@lists.infradead.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, tytso@mit.edu, linux-ext4@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Jan Kara <jack@suse.cz>

Currently we use find_get_entries() shmem which just opencode what
pagevec_lookup_entries() does. Use pagevec_lookup_entries() instead
except for one case which plays tricks with number of pages looked up
and it won't fit in how we will make pagevec_lookup_entries() work.

CC: Hugh Dickins <hughd@google.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/shmem.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index a614a9cfb58c..8a6fddec27a1 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -768,10 +768,9 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 	pagevec_init(&pvec, 0);
 	index = start;
 	while (index < end) {
-		pvec.nr = find_get_entries(mapping, index,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE),
-			pvec.pages, indices);
-		if (!pvec.nr)
+		if (!pagevec_lookup_entries(&pvec, mapping, index,
+				min(end - index, (pgoff_t)PAGEVEC_SIZE),
+				indices))
 			break;
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
@@ -859,10 +858,9 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 	while (index < end) {
 		cond_resched();
 
-		pvec.nr = find_get_entries(mapping, index,
+		if (!pagevec_lookup_entries(&pvec, mapping, index,
 				min(end - index, (pgoff_t)PAGEVEC_SIZE),
-				pvec.pages, indices);
-		if (!pvec.nr) {
+				indices)) {
 			/* If all gone or hole-punch or unfalloc, we're done */
 			if (index == start || end != -1)
 				break;
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
