Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 60D746B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 20:42:20 -0400 (EDT)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p4V0gItk024828
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:42:18 -0700
Received: from pvf33 (pvf33.prod.google.com [10.241.210.97])
	by kpbe13.cbf.corp.google.com with ESMTP id p4V0gG9o006267
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:42:17 -0700
Received: by pvf33 with SMTP id 33so1845352pvf.10
        for <linux-mm@kvack.org>; Mon, 30 May 2011 17:42:16 -0700 (PDT)
Date: Mon, 30 May 2011 17:42:17 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 5/14] drm/ttm: use shmem_read_mapping_page
In-Reply-To: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
Message-ID: <alpine.LSU.2.00.1105301741020.5482@sister.anvils>
References: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Thomas Hellstrom <thellstrom@vmware.com>, Dave Airlie <airlied@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Soon tmpfs will stop supporting ->readpage and read_mapping_page():
once "tmpfs: add shmem_read_mapping_page_gfp" has been applied,
this patch can be applied to ease the transition.

ttm_tt_swapin() and ttm_tt_swapout() use shmem_read_mapping_page()
in place of read_mapping_page(), since their swap_space has been
created with shmem_file_setup().

Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Thomas Hellstrom <thellstrom@vmware.com>
Cc: Dave Airlie <airlied@redhat.com>
---
 drivers/gpu/drm/ttm/ttm_tt.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux.orig/drivers/gpu/drm/ttm/ttm_tt.c	2011-05-30 13:56:10.112796608 -0700
+++ linux/drivers/gpu/drm/ttm/ttm_tt.c	2011-05-30 14:25:59.641670407 -0700
@@ -484,7 +484,7 @@ static int ttm_tt_swapin(struct ttm_tt *
 	swap_space = swap_storage->f_path.dentry->d_inode->i_mapping;
 
 	for (i = 0; i < ttm->num_pages; ++i) {
-		from_page = read_mapping_page(swap_space, i, NULL);
+		from_page = shmem_read_mapping_page(swap_space, i);
 		if (IS_ERR(from_page)) {
 			ret = PTR_ERR(from_page);
 			goto out_err;
@@ -557,7 +557,7 @@ int ttm_tt_swapout(struct ttm_tt *ttm, s
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
