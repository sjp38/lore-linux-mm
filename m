Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 08A246B0124
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 00:29:09 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id p564T7Um022114
	for <linux-mm@kvack.org>; Sun, 5 Jun 2011 21:29:07 -0700
Received: from pwi12 (pwi12.prod.google.com [10.241.219.12])
	by kpbe12.cbf.corp.google.com with ESMTP id p564T6pY008787
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 5 Jun 2011 21:29:06 -0700
Received: by pwi12 with SMTP id 12so2323272pwi.14
        for <linux-mm@kvack.org>; Sun, 05 Jun 2011 21:29:06 -0700 (PDT)
Date: Sun, 5 Jun 2011 21:29:09 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 5/14] drm/ttm: use shmem_read_mapping_page
In-Reply-To: <alpine.LSU.2.00.1106052116350.17116@sister.anvils>
Message-ID: <alpine.LSU.2.00.1106052127400.17116@sister.anvils>
References: <alpine.LSU.2.00.1106052116350.17116@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Thomas Hellstrom <thellstrom@vmware.com>, Dave Airlie <airlied@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Soon tmpfs will stop supporting ->readpage and read_mapping_page():
once "tmpfs: add shmem_read_mapping_page_gfp" has been applied,
this patch can be applied to ease the transition.

ttm_tt_swapin() and ttm_tt_swapout() use shmem_read_mapping_page()
in place of read_mapping_page(), since their swap_space has been
created with shmem_file_setup().

Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Thomas Hellstrom <thellstrom@vmware.com>
Cc: Dave Airlie <airlied@redhat.com>
---
 drivers/gpu/drm/ttm/ttm_tt.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- linux.orig/drivers/gpu/drm/ttm/ttm_tt.c	2011-05-18 21:06:34.000000000 -0700
+++ linux/drivers/gpu/drm/ttm/ttm_tt.c	2011-06-05 18:24:09.501854133 -0700
@@ -31,6 +31,7 @@
 #include <linux/sched.h>
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
+#include <linux/shmem_fs.h>
 #include <linux/file.h>
 #include <linux/swap.h>
 #include <linux/slab.h>
@@ -484,7 +485,7 @@ static int ttm_tt_swapin(struct ttm_tt *
 	swap_space = swap_storage->f_path.dentry->d_inode->i_mapping;
 
 	for (i = 0; i < ttm->num_pages; ++i) {
-		from_page = read_mapping_page(swap_space, i, NULL);
+		from_page = shmem_read_mapping_page(swap_space, i);
 		if (IS_ERR(from_page)) {
 			ret = PTR_ERR(from_page);
 			goto out_err;
@@ -557,7 +558,7 @@ int ttm_tt_swapout(struct ttm_tt *ttm, s
 		from_page = ttm->pages[i];
 		if (unlikely(from_page == NULL))
 			continue;
-		to_page = read_mapping_page(swap_space, i, NULL);
+		to_page = shmem_read_mapping_page(swap_space, i);
 		if (unlikely(IS_ERR(to_page))) {
 			ret = PTR_ERR(to_page);
 			goto out_err;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
