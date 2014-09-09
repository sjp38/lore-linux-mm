Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 893326B0036
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 02:14:09 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id p10so5404512pdj.37
        for <linux-mm@kvack.org>; Mon, 08 Sep 2014 23:14:09 -0700 (PDT)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id a1si10991449pat.36.2014.09.08.23.14.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Sep 2014 23:14:08 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Tue, 9 Sep 2014 14:13:58 +0800
Subject: [RFC] Free the reserved memblock when free cma pages
Message-ID: <35FD53F367049845BC99AC72306C23D103CDBFBFB016@CNBJMBX05.corpusers.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'mhocko@suse.cz'" <mhocko@suse.cz>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'akpm@linux-foundation.org'" <akpm@linux-foundation.org>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, "hughd@google.com" <hughd@google.com>, "b.zolnierkie@samsung.com" <b.zolnierkie@samsung.com>

This patch add memblock_free to also free the reserved memblock,
so that the cma pages are not marked as reserved memory in
/sys/kernel/debug/memblock/reserved debug file

Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
---
 mm/cma.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/cma.c b/mm/cma.c
index c17751c..f3ec756 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -114,6 +114,8 @@ static int __init cma_activate_area(struct cma *cma)
 				goto err;
 		}
 		init_cma_reserved_pageblock(pfn_to_page(base_pfn));
+		memblock_free(__pfn_to_phys(base_pfn),
+				pageblock_nr_pages * PAGE_SIZE);
 	} while (--i);
=20
 	mutex_init(&cma->lock);
--=20
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
