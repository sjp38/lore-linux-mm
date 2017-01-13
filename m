Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 19CA86B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 05:09:56 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id q20so58256024ioi.0
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 02:09:56 -0800 (PST)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id h123si12258839pfc.212.2017.01.13.02.09.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 02:09:55 -0800 (PST)
Received: by mail-pf0-x22b.google.com with SMTP id 189so29485619pfu.3
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 02:09:55 -0800 (PST)
Date: Fri, 13 Jan 2017 02:09:53 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, memcg: do not retry precharge charges
In-Reply-To: <20170113084014.GB25212@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1701130208510.69402@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1701112031250.94269@chino.kir.corp.google.com> <alpine.DEB.2.10.1701121446130.12738@chino.kir.corp.google.com> <20170113084014.GB25212@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

When memory.move_charge_at_immigrate is enabled and precharges are
depleted during move, mem_cgroup_move_charge_pte_range() will attempt to
increase the size of the precharge.

Prevent precharges from ever looping by setting __GFP_NORETRY.  This was
probably the intention of the GFP_KERNEL & ~__GFP_NORETRY, which is
pointless as written.

Fixes: 0029e19ebf84 ("mm: memcontrol: remove explicit OOM parameter in charge path")
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/memcontrol.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4353,9 +4353,9 @@ static int mem_cgroup_do_precharge(unsigned long count)
 		return ret;
 	}
 
-	/* Try charges one by one with reclaim */
+	/* Try charges one by one with reclaim, but do not retry */
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
