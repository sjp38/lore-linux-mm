Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id C37226B026A
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 20:29:25 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id d11-v6so5586035iok.21
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 17:29:25 -0700 (PDT)
Received: from smtp.tom.com (smtprz15.163.net. [106.3.154.248])
        by mx.google.com with ESMTPS id 186-v6si5128238ioc.264.2018.08.09.17.29.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Aug 2018 17:29:24 -0700 (PDT)
Received: from antispam1.tom.com (unknown [172.25.16.55])
	by freemail01.tom.com (Postfix) with ESMTP id 63DB01C80DFD
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 08:29:17 +0800 (CST)
Received: from antispam1.tom.com (antispam1.tom.com [127.0.0.1])
	by antispam1.tom.com (Postfix) with ESMTP id 5BC651001336
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 08:29:17 +0800 (CST)
Received: from antispam1.tom.com ([127.0.0.1])
	by antispam1.tom.com (antispam1.tom.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id OMmUceSOnH1n for <linux-mm@kvack.org>;
	Fri, 10 Aug 2018 08:29:15 +0800 (CST)
From: zhouxianrong <zhouxianrong@tom.com>
Subject: [PATCH] zsmalloc: fix linking bug in init_zspage
Date: Thu,  9 Aug 2018 20:28:17 -0400
Message-Id: <20180810002817.2667-1-zhouxianrong@tom.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, zhouxianrong@tom.com, zhouxianrong <zhouxianrong@huawei.com>

From: zhouxianrong <zhouxianrong@huawei.com>

The last partial object in last subpage of zspage should not be linked
in allocation list. Otherwise it could trigger BUG_ON explicitly at
function zs_map_object. But it happened rarely.

Signed-off-by: zhouxianrong <zhouxianrong@huawei.com>
---
 mm/zsmalloc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 8d87e973a4f5..24dd8da0aa59 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1040,6 +1040,8 @@ static void init_zspage(struct size_class *class, struct zspage *zspage)
 			 * Reset OBJ_TAG_BITS bit to last link to tell
 			 * whether it's allocated object or not.
 			 */
+			if (off > PAGE_SIZE)
+				link -= class->size / sizeof(*link);
 			link->next = -1UL << OBJ_TAG_BITS;
 		}
 		kunmap_atomic(vaddr);
-- 
2.13.6
