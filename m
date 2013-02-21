Return-Path: <owner-linux-mm@kvack.org>
From: Lin Feng <linfeng@cn.fujitsu.com>
Subject: [PATCH V3 2/2] fs/aio.c: use get_user_pages_non_movable() to pin ring pages when support memory hotremove
Date: Thu, 21 Feb 2013 19:01:44 +0800
Message-Id: <1361444504-31888-3-git-send-email-linfeng@cn.fujitsu.com>
In-Reply-To: <1361444504-31888-1-git-send-email-linfeng@cn.fujitsu.com>
References: <1361444504-31888-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, bcrl@kvack.org, viro@zeniv.linux.org.uk
Cc: khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, tangchen@cn.fujitsu.com, guz.fnst@cn.fujitsu.com, jiang.liu@huawei.com, zab@redhat.com, jmoyer@redhat.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Lin Feng <linfeng@cn.fujitsu.com>

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
index 2512232..193e145 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -210,8 +210,8 @@ static int aio_setup_ring(struct kioctx *ctx)
 	}
 
 	pr_debug("mmap address: 0x%08lx\n", ctx->mmap_base);
-	ctx->nr_pages = get_user_pages(current, mm, ctx->mmap_base, nr_pages,
-				       1, 0, ctx->ring_pages, NULL);
+	ctx->nr_pages = get_user_pages_non_movable(current, mm, ctx->mmap_base,
+					nr_pages, 1, 0, ctx->ring_pages, NULL);
 	up_write(&mm->mmap_sem);
 
 	if (unlikely(ctx->nr_pages != nr_pages)) {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
