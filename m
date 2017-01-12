Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C37FD6B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 17:46:36 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y143so81345183pfb.6
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 14:46:36 -0800 (PST)
Received: from mail-pf0-x232.google.com (mail-pf0-x232.google.com. [2607:f8b0:400e:c00::232])
        by mx.google.com with ESMTPS id 17si10598320pfb.89.2017.01.12.14.46.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 14:46:35 -0800 (PST)
Received: by mail-pf0-x232.google.com with SMTP id y143so19887330pfb.0
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 14:46:35 -0800 (PST)
Date: Thu, 12 Jan 2017 14:46:34 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2] mm, memcg: do not retry precharge charges
In-Reply-To: <alpine.DEB.2.10.1701112031250.94269@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1701121446130.12738@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1701112031250.94269@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

When memory.move_charge_at_immigrate is enabled and precharges are
depleted during move, mem_cgroup_move_charge_pte_range() will attempt to
increase the size of the precharge.

This can be allowed to do reclaim, but should not call the oom killer to
oom kill a process.  It's better to fail the attach rather than oom kill
a process attached to the memcg hierarchy.

Prevent precharges from ever looping by setting __GFP_NORETRY.  This was
probably the intention of the GFP_KERNEL & ~__GFP_NORETRY, which is
pointless as written.

Fixes: 0029e19ebf84 ("mm: memcontrol: remove explicit OOM parameter in charge path")
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/memcontrol.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4353,9 +4353,12 @@ static int mem_cgroup_do_precharge(unsigned long count)
 		return ret;
 	}
 
-	/* Try charges one by one with reclaim */
+	/*
+	 * Try charges one by one with reclaim, but do not retry.  This avoids
+	 * calling the oom killer when the precharge should just fail.
+	 */
 	while (count--) {
-		ret = try_charge(mc.to, GFP_KERNEL & ~__GFP_NORETRY, 1);
+		ret = try_charge(mc.to, GFP_KERNEL | __GFP_NORETRY, 1);
 		if (ret)
 			return ret;
 		mc.precharge++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
