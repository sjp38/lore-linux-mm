Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 024106B0034
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 07:03:37 -0400 (EDT)
Received: by mail-ie0-f173.google.com with SMTP id qd12so557107ieb.4
        for <linux-mm@kvack.org>; Fri, 23 Aug 2013 04:03:37 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 23 Aug 2013 19:03:37 +0800
Message-ID: <CAL1ERfPzB=CvKJ6kAq2YYTkkg-EgSOWRyfSFWkvKp8ZdQkCDxA@mail.gmail.com>
Subject: [PATCH 1/4] zswap bugfix: memory leaks when re-swapon
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Bob Liu <bob.liu@oracle.com>, sjenning@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, weijie.yang@samsung.com

zswap_tree is not freed when swapoff, and it got re-kzalloc in swapon,
memory leak occurs.
Add check statement in zswap_frontswap_init so that zswap_tree is
inited only once.

---
 mm/zswap.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index deda2b6..1cf1c07 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -826,6 +826,11 @@ static void zswap_frontswap_init(unsigned type)
 {
 	struct zswap_tree *tree;

+	if (zswap_trees[type]) {
+		BUG_ON(zswap_trees[type]->rbroot != RB_ROOT);  /* invalidate_area set it */
+		return;
+	}
+
 	tree = kzalloc(sizeof(struct zswap_tree), GFP_KERNEL);
 	if (!tree)
 		goto err;
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
