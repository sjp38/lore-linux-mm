Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id DEDFE6B0005
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 09:54:28 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id u13-v6so3404914pfm.8
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 06:54:28 -0700 (PDT)
Received: from smtp.tom.com (smtprz15.163.net. [106.3.154.248])
        by mx.google.com with ESMTPS id d12-v6si5594757pla.421.2018.08.09.06.54.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Aug 2018 06:54:27 -0700 (PDT)
Received: from antispam1.tom.com (unknown [172.25.16.55])
	by freemail01.tom.com (Postfix) with ESMTP id 1BE6E1C80EA5
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 21:54:25 +0800 (CST)
Received: from antispam1.tom.com (antispam1.tom.com [127.0.0.1])
	by antispam1.tom.com (Postfix) with ESMTP id 16DD610012AC
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 21:54:25 +0800 (CST)
Received: from antispam1.tom.com ([127.0.0.1])
	by antispam1.tom.com (antispam1.tom.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 2Mn3_-HpIYNU for <linux-mm@kvack.org>;
	Thu,  9 Aug 2018 21:54:24 +0800 (CST)
From: zhouxianrong <zhouxianrong@tom.com>
Subject: [PATCH] zsmalloc: fix linking bug in init_zspage
Date: Thu,  9 Aug 2018 09:53:56 -0400
Message-Id: <20180809135356.4070-1-zhouxianrong@tom.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, zhouxianrong@tom.com

The last partial object in last subpage of zspage should not be linked
in allocation list.

Signed-off-by: zhouxianrong <zhouxianrong@tom.com>
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
