Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 216226B0283
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 10:37:29 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id h65so9170663lfi.1
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 07:37:29 -0800 (PST)
Received: from mail-lf0-f65.google.com (mail-lf0-f65.google.com. [209.85.215.65])
        by mx.google.com with ESMTPS id r76si5864802lfi.288.2017.01.12.07.37.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 07:37:27 -0800 (PST)
Received: by mail-lf0-f65.google.com with SMTP id v186so2355922lfa.2
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 07:37:27 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 4/6] ila: simplify a strange allocation pattern
Date: Thu, 12 Jan 2017 16:37:15 +0100
Message-Id: <20170112153717.28943-5-mhocko@kernel.org>
In-Reply-To: <20170112153717.28943-1-mhocko@kernel.org>
References: <20170112153717.28943-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Tom Herbert <tom@herbertland.com>, Eric Dumazet <eric.dumazet@gmail.com>

From: Michal Hocko <mhocko@suse.com>

alloc_ila_locks seemed to c&p from alloc_bucket_locks allocation
pattern which is quite unusual. The default allocation size is 320 *
sizeof(spinlock_t) which is sub page unless lockdep is enabled when the
performance benefit is really questionable and not worth the subtle code
IMHO. Also note that the context when we call ila_init_net (modprobe or
a task creating a net namespace) has to be properly configured.

Let's just simplify the code and use kvmalloc helper which is a
transparent way to use kmalloc with vmalloc fallback.

Cc: Tom Herbert <tom@herbertland.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 net/ipv6/ila/ila_xlat.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/net/ipv6/ila/ila_xlat.c b/net/ipv6/ila/ila_xlat.c
index af8f52ee7180..2fd5ca151dcf 100644
--- a/net/ipv6/ila/ila_xlat.c
+++ b/net/ipv6/ila/ila_xlat.c
@@ -41,13 +41,7 @@ static int alloc_ila_locks(struct ila_net *ilan)
 	size = roundup_pow_of_two(nr_pcpus * LOCKS_PER_CPU);
 
 	if (sizeof(spinlock_t) != 0) {
-#ifdef CONFIG_NUMA
-		if (size * sizeof(spinlock_t) > PAGE_SIZE)
-			ilan->locks = vmalloc(size * sizeof(spinlock_t));
-		else
-#endif
-		ilan->locks = kmalloc_array(size, sizeof(spinlock_t),
-					    GFP_KERNEL);
+		ilan->locks = kvmalloc(size * sizeof(spinlock_t), GFP_KERNEL);
 		if (!ilan->locks)
 			return -ENOMEM;
 		for (i = 0; i < size; i++)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
