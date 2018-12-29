Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id 08EF98E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 20:56:04 -0500 (EST)
Received: by mail-vs1-f69.google.com with SMTP id g79so12800591vsd.6
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 17:56:04 -0800 (PST)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id c13sor25672218vso.80.2018.12.28.17.56.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Dec 2018 17:56:02 -0800 (PST)
Date: Fri, 28 Dec 2018 17:55:24 -0800
Message-Id: <20181229015524.222741-1-shakeelb@google.com>
Mime-Version: 1.0
Subject: [PATCH] netfilter: account ebt_table_info to kmemcg
From: Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Roopa Prabhu <roopa@cumulusnetworks.com>, Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>, syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com

The [ip,ip6,arp]_tables use x_tables_info internally and the underlying
memory is already accounted to kmemcg. Do the same for ebtables. The
syzbot, by using setsockopt(EBT_SO_SET_ENTRIES), was able to OOM the
whole system from a restricted memcg, a potential DoS.

Reported-by: syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com
Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 net/bridge/netfilter/ebtables.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 491828713e0b..5e55cef0cec3 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1137,14 +1137,16 @@ static int do_replace(struct net *net, const void __user *user,
 	tmp.name[sizeof(tmp.name) - 1] = 0;
 
 	countersize = COUNTER_OFFSET(tmp.nentries) * nr_cpu_ids;
-	newinfo = vmalloc(sizeof(*newinfo) + countersize);
+	newinfo = __vmalloc(sizeof(*newinfo) + countersize, GFP_KERNEL_ACCOUNT,
+			    PAGE_KERNEL);
 	if (!newinfo)
 		return -ENOMEM;
 
 	if (countersize)
 		memset(newinfo->counters, 0, countersize);
 
-	newinfo->entries = vmalloc(tmp.entries_size);
+	newinfo->entries = __vmalloc(tmp.entries_size, GFP_KERNEL_ACCOUNT,
+				     PAGE_KERNEL);
 	if (!newinfo->entries) {
 		ret = -ENOMEM;
 		goto free_newinfo;
-- 
2.20.1.415.g653613c723-goog
