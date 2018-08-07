Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id E131A6B0006
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 15:54:08 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id r3-v6so11908221wrj.21
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 12:54:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m13-v6sor905099wrh.48.2018.08.07.12.54.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Aug 2018 12:54:07 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] netfilter/x_tables: do not fail xt_alloc_table_info too easilly
Date: Tue,  7 Aug 2018 21:54:00 +0200
Message-Id: <20180807195400.23687-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Westphal <fw@strlen.de>
Cc: Vlastimil Babka <vbabka@suse.cz>, Georgi Nikolov <gnikolov@icdsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

eacd86ca3b03 ("net/netfilter/x_tables.c: use kvmalloc()
in xt_alloc_table_info()") has unintentionally fortified
xt_alloc_table_info allocation when __GFP_RETRY has been dropped from
the vmalloc fallback. Later on there was a syzbot report that this
can lead to OOM killer invocations when tables are too large and
0537250fdc6c ("netfilter: x_tables: make allocation less aggressive")
has been merged to restore the original behavior. Georgi Nikolov however
noticed that he is not able to install his iptables anymore so this can
be seen as a regression.

The primary argument for 0537250fdc6c was that this allocation path
shouldn't really trigger the OOM killer and kill innocent tasks. On the
other hand the interface requires root and as such should allow what the
admin asks for. Root inside a namespaces makes this more complicated
because those might be not trusted in general. If they are not then such
namespaces should be restricted anyway. Therefore drop the __GFP_NORETRY
and replace it by __GFP_ACCOUNT to enfore memcg constrains on it.

Fixes: 0537250fdc6c ("netfilter: x_tables: make allocation less aggressive")
Reported-by: Georgi Nikolov <gnikolov@icdsoft.com>
Suggested-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 net/netfilter/x_tables.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index d0d8397c9588..aecadd471e1d 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1178,12 +1178,7 @@ struct xt_table_info *xt_alloc_table_info(unsigned int size)
 	if (sz < sizeof(*info) || sz >= XT_MAX_TABLE_SIZE)
 		return NULL;
 
-	/* __GFP_NORETRY is not fully supported by kvmalloc but it should
-	 * work reasonably well if sz is too large and bail out rather
-	 * than shoot all processes down before realizing there is nothing
-	 * more to reclaim.
-	 */
-	info = kvmalloc(sz, GFP_KERNEL | __GFP_NORETRY);
+	info = kvmalloc(sz, GFP_KERNEL_ACCOUNT);
 	if (!info)
 		return NULL;
 
-- 
2.18.0
