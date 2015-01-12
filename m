Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id B51F56B0070
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 04:20:10 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lf10so31028830pab.5
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 01:20:10 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id ke10si22387683pbc.235.2015.01.12.01.20.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 12 Jan 2015 01:20:09 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NI2002JP4S9ZJ10@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 12 Jan 2015 09:24:09 +0000 (GMT)
From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [PATCH 3/5] clk: convert clock name allocations to kstrdup_const
Date: Mon, 12 Jan 2015 10:18:41 +0100
Message-id: <1421054323-14430-4-git-send-email-a.hajda@samsung.com>
In-reply-to: <1421054323-14430-1-git-send-email-a.hajda@samsung.com>
References: <1421054323-14430-1-git-send-email-a.hajda@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrzej Hajda <a.hajda@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, linux-kernel@vger.kernel.org, andi@firstfloor.org, andi@lisas.de, Mike Turquette <mturquette@linaro.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

Clock subsystem frequently performs duplication of strings located
in read-only memory section. Replacing kstrdup by kstrdup_const
allows to avoid such operations.

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
 drivers/clk/clk.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/clk/clk.c b/drivers/clk/clk.c
index f4963b7..27e644a 100644
--- a/drivers/clk/clk.c
+++ b/drivers/clk/clk.c
@@ -2048,7 +2048,7 @@ struct clk *clk_register(struct device *dev, struct clk_hw *hw)
 		goto fail_out;
 	}
 
-	clk->name = kstrdup(hw->init->name, GFP_KERNEL);
+	clk->name = kstrdup_const(hw->init->name, GFP_KERNEL);
 	if (!clk->name) {
 		pr_err("%s: could not allocate clk->name\n", __func__);
 		ret = -ENOMEM;
@@ -2075,7 +2075,7 @@ struct clk *clk_register(struct device *dev, struct clk_hw *hw)
 
 	/* copy each string name in case parent_names is __initdata */
 	for (i = 0; i < clk->num_parents; i++) {
-		clk->parent_names[i] = kstrdup(hw->init->parent_names[i],
+		clk->parent_names[i] = kstrdup_const(hw->init->parent_names[i],
 						GFP_KERNEL);
 		if (!clk->parent_names[i]) {
 			pr_err("%s: could not copy parent_names\n", __func__);
@@ -2090,10 +2090,10 @@ struct clk *clk_register(struct device *dev, struct clk_hw *hw)
 
 fail_parent_names_copy:
 	while (--i >= 0)
-		kfree(clk->parent_names[i]);
+		kfree_const(clk->parent_names[i]);
 	kfree(clk->parent_names);
 fail_parent_names:
-	kfree(clk->name);
+	kfree_const(clk->name);
 fail_name:
 	kfree(clk);
 fail_out:
@@ -2112,10 +2112,10 @@ static void __clk_release(struct kref *ref)
 
 	kfree(clk->parents);
 	while (--i >= 0)
-		kfree(clk->parent_names[i]);
+		kfree_const(clk->parent_names[i]);
 
 	kfree(clk->parent_names);
-	kfree(clk->name);
+	kfree_const(clk->name);
 	kfree(clk);
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
