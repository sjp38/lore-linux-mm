Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 71F756B025E
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 17:11:23 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id u134so200761386ywg.2
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 14:11:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o13si9963875qko.135.2016.07.22.14.11.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jul 2016 14:11:22 -0700 (PDT)
Date: Fri, 22 Jul 2016 17:11:20 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH 1/2] mm: add cond_resched to generic_swapfile_activate
In-Reply-To: <alpine.LRH.2.02.1607221656530.4818@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.LRH.2.02.1607221710580.4818@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1607221656530.4818@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

The function generic_swapfile_activate can take quite long time, it iterates
over all blocks of a file, so add cond_resched to it. I observed about 1 second
stalls when activating a swapfile that was almost unfragmented - this patch
fixes it.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 mm/page_io.c |    2 ++
 1 file changed, 2 insertions(+)

Index: linux-4.7-rc7/mm/page_io.c
===================================================================
--- linux-4.7-rc7.orig/mm/page_io.c	2016-05-30 17:34:37.000000000 +0200
+++ linux-4.7-rc7/mm/page_io.c	2016-07-11 17:23:33.000000000 +0200
@@ -166,6 +166,8 @@ int generic_swapfile_activate(struct swa
 		unsigned block_in_page;
 		sector_t first_block;
 
+		cond_resched();
+
 		first_block = bmap(inode, probe_block);
 		if (first_block == 0)
 			goto bad_bmap;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
