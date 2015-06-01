Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 764206B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 09:00:11 -0400 (EDT)
Received: by wgez8 with SMTP id z8so113592863wge.0
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 06:00:10 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p8si18425017wie.99.2015.06.01.06.00.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 01 Jun 2015 06:00:09 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 1/2] mm: do not ignore mapping_gfp_mask in page cache allocation paths
Date: Mon,  1 Jun 2015 15:00:02 +0200
Message-Id: <1433163603-13229-2-git-send-email-mhocko@suse.cz>
In-Reply-To: <1433163603-13229-1-git-send-email-mhocko@suse.cz>
References: <1433163603-13229-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org

page_cache_read, do_generic_file_read, __generic_file_splice_read and
__ntfs_grab_cache_pages currently ignore mapping_gfp_mask when calling
add_to_page_cache_lru which might cause recursion into fs down in the
direct reclaim path if the mapping really relies on GFP_NOFS semantic.

This doesn't seem to be the case now because page_cache_read (page fault
path) doesn't seem to suffer from the reclaim recursion issues and
do_generic_file_read and __generic_file_splice_read also shouldn't be
called under fs locks which would deadlock in the reclaim path. Anyway
it is better to obey mapping gfp mask and prevent from later breakage.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 fs/ntfs/file.c | 2 +-
 fs/splice.c    | 2 +-
 mm/filemap.c   | 6 ++++--
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/ntfs/file.c b/fs/ntfs/file.c
index 1da9b2d184dc..568c9dbc7e61 100644
--- a/fs/ntfs/file.c
+++ b/fs/ntfs/file.c
@@ -422,7 +422,7 @@ static inline int __ntfs_grab_cache_pages(struct address_space *mapping,
 				}
 			}
 			err = add_to_page_cache_lru(*cached_page, mapping, index,
-					GFP_KERNEL);
+					GFP_KERNEL & mapping_gfp_mask(mapping));
 			if (unlikely(err)) {
 				if (err == -EEXIST)
 					continue;
diff --git a/fs/splice.c b/fs/splice.c
index 7d2fbb788fc5..ebd184f24e0d 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -360,7 +360,7 @@ __generic_file_splice_read(struct file *in, loff_t *ppos,
 				break;
 
 			error = add_to_page_cache_lru(page, mapping, index,
-						GFP_KERNEL);
+						GFP_KERNEL & mapping_gfp_mask(mapping));
 			if (unlikely(error)) {
 				page_cache_release(page);
 				if (error == -EEXIST)
diff --git a/mm/filemap.c b/mm/filemap.c
index df533a10e8c3..adfc5d2e21c8 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1669,7 +1669,8 @@ static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,
 			goto out;
 		}
 		error = add_to_page_cache_lru(page, mapping,
-						index, GFP_KERNEL);
+						index,
+						GFP_KERNEL & mapping_gfp_mask(mapping));
 		if (error) {
 			page_cache_release(page);
 			if (error == -EEXIST) {
@@ -1770,7 +1771,8 @@ static int page_cache_read(struct file *file, pgoff_t offset)
 		if (!page)
 			return -ENOMEM;
 
-		ret = add_to_page_cache_lru(page, mapping, offset, GFP_KERNEL);
+		ret = add_to_page_cache_lru(page, mapping, offset,
+				GFP_KERNEL & mapping_gfp_mask(mapping));
 		if (ret == 0)
 			ret = mapping->a_ops->readpage(file, page);
 		else if (ret == -EEXIST)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
