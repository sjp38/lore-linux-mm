Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 326146B0372
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 05:33:18 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 139so8673113wmf.5
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 02:33:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j23si19891659wre.45.2017.06.01.02.33.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 02:33:16 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 27/35] shmem: Use pagevec_lookup() in shmem_unlock_mapping()
Date: Thu,  1 Jun 2017 11:32:37 +0200
Message-Id: <20170601093245.29238-28-jack@suse.cz>
In-Reply-To: <20170601093245.29238-1-jack@suse.cz>
References: <20170601093245.29238-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, David Howells <dhowells@redhat.com>, linux-afs@lists.infradead.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, tytso@mit.edu, linux-ext4@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Jan Kara <jack@suse.cz>

The comment about find_get_pages() returning if it finds a row of swap
entries seems to be stale. Use pagevec_lookup() in
shmem_unlock_mapping() to simplify the code.

CC: Hugh Dickins <hughd@google.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/shmem.c | 14 ++------------
 1 file changed, 2 insertions(+), 12 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index e67d6ba4e98e..a614a9cfb58c 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -729,24 +729,14 @@ unsigned long shmem_swap_usage(struct vm_area_struct *vma)
 void shmem_unlock_mapping(struct address_space *mapping)
 {
 	struct pagevec pvec;
-	pgoff_t indices[PAGEVEC_SIZE];
 	pgoff_t index = 0;
 
 	pagevec_init(&pvec, 0);
 	/*
 	 * Minor point, but we might as well stop if someone else SHM_LOCKs it.
 	 */
-	while (!mapping_unevictable(mapping)) {
-		/*
-		 * Avoid pagevec_lookup(): find_get_pages() returns 0 as if it
-		 * has finished, if it hits a row of PAGEVEC_SIZE swap entries.
-		 */
-		pvec.nr = find_get_entries(mapping, index,
-					   PAGEVEC_SIZE, pvec.pages, indices);
-		if (!pvec.nr)
-			break;
-		index = indices[pvec.nr - 1] + 1;
-		pagevec_remove_exceptionals(&pvec);
+	while (!mapping_unevictable(mapping) &&
+			pagevec_lookup(&pvec, mapping, &index)) {
 		check_move_unevictable_pages(pvec.pages, pvec.nr);
 		pagevec_release(&pvec);
 		cond_resched();
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
