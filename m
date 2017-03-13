Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 11D266B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 04:33:19 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id d66so12733074wmi.2
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 01:33:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a2si9957212wmd.120.2017.03.13.01.33.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Mar 2017 01:33:17 -0700 (PDT)
Date: Mon, 13 Mar 2017 09:33:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 RFC] mm/vmscan: more restrictive condition for retry
 of shrink_zones
Message-ID: <20170313083314.GA31518@dhcp22.suse.cz>
References: <1489316770-25362-1-git-send-email-ysxie@foxmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1489316770-25362-1-git-send-email-ysxie@foxmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <ysxie@foxmail.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz, riel@redhat.com, shakeelb@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xieyisheng1@huawei.com, guohanjun@huawei.com, qiuxishi@huawei.com

Please do not post new version after a single feedback and try to wait
for more review to accumulate. This is in the 3rd version and it is not
clear why it is still an RFC.

On Sun 12-03-17 19:06:10, Yisheng Xie wrote:
> From: Yisheng Xie <xieyisheng1@huawei.com>
> 
> When we enter do_try_to_free_pages, the may_thrash is always clear, and
> it will retry shrink zones to tap cgroup's reserves memory by setting
> may_thrash when the former shrink_zones reclaim nothing.
> 
> However, when memcg is disabled or on legacy hierarchy, it should not do
> this useless retry at all, for we do not have any cgroup's reserves
> memory to tap, and we have already done hard work but made no progress.
> 
> To avoid this time costly and useless retrying, add a stub function
> mem_cgroup_thrashed() and return true when memcg is disabled or on
> legacy hierarchy.

Have you actually seen this as a bad behavior? On which workload? Or
have spotted this by the code review?

Please note that more than _what_ it is more interesting _why_ the patch
has been prepared.

I agree the current additional round of reclaim is just lame because we
are trying hard to control the retry logic from the page allocator which
is a sufficient justification to fix this IMO. But I really hate the
name. At this point we do not have any idea that the memcg is trashing
as the name of the function suggests.

All of them simply might not have any reclaimable pages. So I would
suggest either a better name e.g. memcg_allow_lowmem_reclaim() or,
preferably, fix this properly. E.g. something like the following.
---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index bae698484e8e..989ba9761921 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -99,6 +99,9 @@ struct scan_control {
 	/* Can cgroups be reclaimed below their normal consumption range? */
 	unsigned int may_thrash:1;
 
+	/* Did we have any memcg protected by the low limit */
+	unsigned int memcg_low_protection:1;
+
 	unsigned int hibernation_mode:1;
 
 	/* One of the zones is ready for compaction */
@@ -2513,6 +2516,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			if (mem_cgroup_low(root, memcg)) {
 				if (!sc->may_thrash)
 					continue;
+				sc->memcg_low_protection = true;
 				mem_cgroup_events(memcg, MEMCG_LOW, 1);
 			}
 
@@ -2774,7 +2778,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		return 1;
 
 	/* Untapped cgroup reserves?  Don't OOM, retry. */
-	if (!sc->may_thrash) {
+	if ( sc->memcg_low_protection && !sc->may_thrash) {
 		sc->priority = initial_priority;
 		sc->may_thrash = 1;
 		goto retry;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
