Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8E09C900004
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 10:29:06 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so956864pbc.3
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 07:29:06 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 14/26] nfs: Convert direct IO to use get_user_pages_fast()
Date: Wed,  2 Oct 2013 16:27:55 +0200
Message-Id: <1380724087-13927-15-git-send-email-jack@suse.cz>
In-Reply-To: <1380724087-13927-1-git-send-email-jack@suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org

CC: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/nfs/direct.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 91ff089d3412..1aaf4aa2b3d7 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -337,10 +337,8 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_pageio_descriptor *de
 		if (!pagevec)
 			break;
 		if (uio) {
-			down_read(&current->mm->mmap_sem);
-			result = get_user_pages(current, current->mm, user_addr,
-					npages, 1, 0, pagevec, NULL);
-			up_read(&current->mm->mmap_sem);
+			result = get_user_pages_fast(user_addr, npages, 1,
+						     pagevec);
 			if (result < 0)
 				break;
 		} else {
@@ -658,10 +656,8 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_pageio_descriptor *d
 			break;
 
 		if (uio) {
-			down_read(&current->mm->mmap_sem);
-			result = get_user_pages(current, current->mm, user_addr,
-						npages, 0, 0, pagevec, NULL);
-			up_read(&current->mm->mmap_sem);
+			result = get_user_pages_fast(user_addr, npages, 0,
+						     pagevec);
 			if (result < 0)
 				break;
 		} else {
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
