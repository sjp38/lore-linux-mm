Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4366F6B0260
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 09:43:09 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id k184so15549005wme.4
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 06:43:09 -0800 (PST)
Received: from mail-wj0-f196.google.com (mail-wj0-f196.google.com. [209.85.210.196])
        by mx.google.com with ESMTPS id 34si8386392wrj.128.2017.01.09.06.43.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jan 2017 06:43:08 -0800 (PST)
Received: by mail-wj0-f196.google.com with SMTP id kp2so84799122wjc.0
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 06:43:08 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] ila: simplify a strange allocation pattern
Date: Mon,  9 Jan 2017 15:43:02 +0100
Message-Id: <20170109144302.32726-2-mhocko@kernel.org>
In-Reply-To: <20170109144302.32726-1-mhocko@kernel.org>
References: <20170109144158.GM7495@dhcp22.suse.cz>
 <20170109144302.32726-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Tom Herbert <tom@herbertland.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

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
