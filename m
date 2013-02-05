Return-Path: <owner-linux-mm@kvack.org>
From: Lin Feng <linfeng@cn.fujitsu.com>
Subject: [PATCH V2 2/2] fs/aio.c: use get_user_pages_non_movable() to pin ring pages when support memory hotremove
Date: Tue, 5 Feb 2013 17:21:53 +0800
Message-Id: <1360056113-14294-3-git-send-email-linfeng@cn.fujitsu.com>
In-Reply-To: <1360056113-14294-1-git-send-email-linfeng@cn.fujitsu.com>
References: <1360056113-14294-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, bcrl@kvack.org, viro@zeniv.linux.org.uk
Cc: khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, zab@redhat.com, jmoyer@redhat.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Lin Feng <linfeng@cn.fujitsu.com>

This patch gets around the aio ring pages can't be migrated bug caused by
get_user_pages() via using the new function. It only works as configed with
CONFIG_MEMORY_HOTREMOVE, otherwise it falls back to use the old version
 of get_user_pages().

Cc: Benjamin LaHaise <bcrl@kvack.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Zach Brown <zab@redhat.com>
Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
---
 fs/aio.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 71f613c..f7a0d5c 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -138,8 +138,8 @@ static int aio_setup_ring(struct kioctx *ctx)
 	}
 
 	dprintk("mmap address: 0x%08lx\n", info->mmap_base);
-	info->nr_pages = get_user_pages(current, ctx->mm,
-					info->mmap_base, nr_pages, 
+	info->nr_pages = get_user_pages_non_movable(current, ctx->mm,
+					info->mmap_base, nr_pages,
 					1, 0, info->ring_pages, NULL);
 	up_write(&ctx->mm->mmap_sem);
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
