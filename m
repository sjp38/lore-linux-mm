Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id DA0386B0256
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 02:36:10 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so45231634pab.3
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 23:36:10 -0700 (PDT)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.122])
        by mx.google.com with ESMTPS id qp7si63996015pbc.93.2015.10.07.23.36.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 07 Oct 2015 23:36:09 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [PATCH 3/3] zram: make create "__GFP_MOVABLE" pool
Date: Thu, 8 Oct 2015 14:35:52 +0800
Message-ID: <1444286152-30175-4-git-send-email-zhuhui@xiaomi.com>
In-Reply-To: <1444286152-30175-1-git-send-email-zhuhui@xiaomi.com>
References: <1444286152-30175-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey
 Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Dave Hansen <dave.hansen@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal
 Hocko <mhocko@suse.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, Tejun Heo <tj@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jennifer Herbert <jennifer.herbert@citrix.com>, Hugh Dickins <hughd@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Vlastimil
 Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, "Steven Rostedt (Red Hat)" <rostedt@goodmis.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <wanpeng.li@hotmail.com>, Geert Uytterhoeven <geert+renesas@glider.be>, Greg
 Thelen <gthelen@google.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: teawater@gmail.com, Hui Zhu <zhuhui@xiaomi.com>

Change the flags when call zs_create_pool to make zram alloc movable
zsmalloc page.

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 drivers/block/zram/zram_drv.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 9fa15bb..8f3f524 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -514,7 +514,9 @@ static struct zram_meta *zram_meta_alloc(char *pool_name, u64 disksize)
 		goto out_error;
 	}
 
-	meta->mem_pool = zs_create_pool(pool_name, GFP_NOIO | __GFP_HIGHMEM);
+	meta->mem_pool
+		= zs_create_pool(pool_name,
+				 GFP_NOIO | __GFP_HIGHMEM | __GFP_MOVABLE);
 	if (!meta->mem_pool) {
 		pr_err("Error creating memory pool\n");
 		goto out_error;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
