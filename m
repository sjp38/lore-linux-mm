Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DB52A6B02F4
	for <linux-mm@kvack.org>; Wed, 31 May 2017 11:52:03 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j28so17321290pfk.14
        for <linux-mm@kvack.org>; Wed, 31 May 2017 08:52:03 -0700 (PDT)
Received: from mail-pg0-f67.google.com (mail-pg0-f67.google.com. [74.125.83.67])
        by mx.google.com with ESMTPS id l36si46631795plg.314.2017.05.31.08.52.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 08:52:03 -0700 (PDT)
Received: by mail-pg0-f67.google.com with SMTP id s62so2339237pgc.0
        for <linux-mm@kvack.org>; Wed, 31 May 2017 08:52:03 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/3] netfilter: use kvmalloc xt_alloc_table_info
Date: Wed, 31 May 2017 17:51:45 +0200
Message-Id: <20170531155145.17111-4-mhocko@kernel.org>
In-Reply-To: <20170531155145.17111-1-mhocko@kernel.org>
References: <20170531155145.17111-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Florian Westphal <fw@strlen.de>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Pablo Neira Ayuso <pablo@netfilter.org>

From: Michal Hocko <mhocko@suse.com>

xt_alloc_table_info basically opencodes kvmalloc so use the library
function instead.

Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Cc: Florian Westphal <fw@strlen.de>
Cc: netfilter-devel@vger.kernel.org
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 net/netfilter/x_tables.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 1770c1d9b37f..e1648238a9c9 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1003,14 +1003,10 @@ struct xt_table_info *xt_alloc_table_info(unsigned int size)
 	if ((SMP_ALIGN(size) >> PAGE_SHIFT) + 2 > totalram_pages)
 		return NULL;
 
-	if (sz <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
-		info = kmalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY);
-	if (!info) {
-		info = __vmalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY,
-				 PAGE_KERNEL);
-		if (!info)
-			return NULL;
-	}
+	info = kvmalloc(sz, GFP_KERNEL);
+	if (!info)
+		return NULL;
+
 	memset(info, 0, sizeof(*info));
 	info->size = size;
 	return info;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
