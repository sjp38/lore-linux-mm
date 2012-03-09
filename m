Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 844386B0092
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 15:39:40 -0500 (EST)
Received: by ghbg15 with SMTP id g15so254960ghb.2
        for <linux-mm@kvack.org>; Fri, 09 Mar 2012 12:39:39 -0800 (PST)
From: Suleiman Souhlal <ssouhlal@FreeBSD.org>
Subject: [PATCH v2 11/13] memcg: Handle bypassed kernel memory charges.
Date: Fri,  9 Mar 2012 12:39:14 -0800
Message-Id: <1331325556-16447-12-git-send-email-ssouhlal@FreeBSD.org>
In-Reply-To: <1331325556-16447-1-git-send-email-ssouhlal@FreeBSD.org>
References: <1331325556-16447-1-git-send-email-ssouhlal@FreeBSD.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: suleiman@google.com, glommer@parallels.com, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, cl@linux.com, yinghan@google.com, hughd@google.com, gthelen@google.com, peterz@infradead.org, dan.magenheimer@oracle.com, hannes@cmpxchg.org, mgorman@suse.de, James.Bottomley@HansenPartnership.com, linux-mm@kvack.org, devel@openvz.org, linux-kernel@vger.kernel.org, Suleiman Souhlal <ssouhlal@FreeBSD.org>

When __mem_cgroup_try_charge() decides to bypass a slab charge
(because we are getting OOM killed or have a fatal signal pending),
we may end up with a slab that belongs to a memcg, but wasn't
charged to it. When we free such a slab page, we end up uncharging
it from the memcg, even though it was never charged, which may
lead to res_counter underflows.

To avoid this, when a charge is bypassed, we force the charge,
without checking for the bypass conditions or doing any reclaim.
This may cause the cgroup's usage to temporarily go above its limit.

Signed-off-by: Suleiman Souhlal <suleiman@google.com>
---
 mm/memcontrol.c |   15 +++++++++++++--
 1 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 72e83af..9f5e9d8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5672,16 +5672,27 @@ memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, long long delta)
 
 	ret = 0;
 
-	_memcg = memcg;
 	if (memcg && !mem_cgroup_test_flag(memcg,
 	    MEMCG_INDEPENDENT_KMEM_LIMIT)) {
+		_memcg = memcg;
 		ret = __mem_cgroup_try_charge(NULL, gfp, delta / PAGE_SIZE,
 		    &_memcg, may_oom);
 		if (ret == -ENOMEM)
 			return ret;
+		else if (ret == -EINTR) {
+			/*
+			 * __mem_cgroup_try_charge() chose to bypass to root due
+			 * to OOM kill or fatal signal.
+			 * Since our only options are to either fail the
+			 * allocation or charge it to this cgroup, force the
+			 * change, going above the limit if needed.
+			 */
+			ret = res_counter_charge_nofail(&memcg->res, delta,
+			    &fail_res);
+		}
 	}
 
-	if (memcg && _memcg == memcg)
+	if (memcg)
 		ret = res_counter_charge(&memcg->kmem, delta, &fail_res);
 
 	return ret;
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
