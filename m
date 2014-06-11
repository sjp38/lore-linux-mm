Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 984996B0137
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 04:00:54 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id k14so7518988wgh.6
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 01:00:54 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pj9si20582431wic.32.2014.06.11.01.00.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 01:00:53 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 1/2] mm, memcg: allow OOM if no memcg is eligible during direct reclaim
Date: Wed, 11 Jun 2014 10:00:23 +0200
Message-Id: <1402473624-13827-1-git-send-email-mhocko@suse.cz>
In-Reply-To: <20140611075729.GA4520@dhcp22.suse.cz>
References: <20140611075729.GA4520@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Roman Gushchin <klamm@yandex-team.ru>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

If there is no memcg eligible for reclaim because all groups under the
reclaimed hierarchy are within their guarantee then the global direct
reclaim would end up in the endless loop because zones in the zonelists
are not considered unreclaimable (as per all_unreclaimable) and so the
OOM killer would never fire and direct reclaim would be triggered
without no chance to reclaim anything.

This is not possible yet because reclaim falls back to ignore low_limit
when nobody is eligible for reclaim. Following patch will allow to set
the fallback mode to hard guarantee, though, so this is a preparatory
patch.

Memcg reclaim doesn't suffer from this because the OOM killer is
triggered after few unsuccessful attempts of the reclaim.

Fix this by checking the number of scanned pages which is obviously 0 if
nobody is eligible and also check that the whole tree hierarchy is not
eligible and tell OOM it can go ahead.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/vmscan.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8041b0667673..99137aecd95f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2570,6 +2570,13 @@ out:
 	if (aborted_reclaim)
 		return 1;
 
+	/*
+	 * If the target memcg is not eligible for reclaim then we have no option
+	 * but OOM
+	 */
+	if (!sc->nr_scanned && mem_cgroup_all_within_guarantee(sc->target_mem_cgroup))
+		return 0;
+
 	/* top priority shrink_zones still had more to do? don't OOM, then */
 	if (global_reclaim(sc) && !all_unreclaimable(zonelist, sc))
 		return 1;
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
