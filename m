Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1FF61828F3
	for <linux-mm@kvack.org>; Sat,  9 Jan 2016 20:22:04 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id yy13so209922559pab.3
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 17:22:04 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id e3si16341432pfj.170.2016.01.09.17.22.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jan 2016 17:22:03 -0800 (PST)
Received: by mail-pa0-x22a.google.com with SMTP id uo6so285068289pac.1
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 17:22:03 -0800 (PST)
Date: Sat, 9 Jan 2016 17:21:44 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH mmotm] memcg: avoid vmpressure oops when memcg disabled
Message-ID: <alpine.LSU.2.11.1601091717160.10107@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

A CONFIG_MEMCG=y kernel booted with "cgroup_disable=memory" crashes on
a NULL memcg (but non-NULL root_mem_cgroup) when vmpressure kicks in.
Here's the patch I use to avoid that, but you might prefer a test on
mem_cgroup_disabled() somewhere.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
To be folded in to
mm-memcontrol-hook-up-vmpressure-to-socket-pressure.patch
if Hannes does not prefer to fix it differently.

 mm/vmpressure.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 4.4-next/mm/vmpressure.c	2016-01-06 10:32:21.387741753 -0800
+++ linux/mm/vmpressure.c	2016-01-06 10:48:05.956149779 -0800
@@ -260,7 +260,7 @@ void vmpressure(gfp_t gfp, struct mem_cg
 		enum vmpressure_levels level;
 
 		/* For now, no users for root-level efficiency */
-		if (memcg == root_mem_cgroup)
+		if (!memcg || memcg == root_mem_cgroup)
 			return;
 
 		spin_lock(&vmpr->sr_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
