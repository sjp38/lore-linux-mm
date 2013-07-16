Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id BD8C56B0034
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 19:45:25 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 17 Jul 2013 05:08:44 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id DCF703940057
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 05:15:15 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6GNjFcl24969396
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 05:15:15 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6GNjIjg010565
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 09:45:19 +1000
Date: Wed, 17 Jul 2013 07:45:17 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 01/10] mm: zone_reclaim: remove ZONE_RECLAIM_LOCKED
Message-ID: <20130716234517.GE30164@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1373982114-19774-1-git-send-email-aarcange@redhat.com>
 <1373982114-19774-2-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373982114-19774-2-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Hush Bensen <hush.bensen@gmail.com>

On Tue, Jul 16, 2013 at 03:41:45PM +0200, Andrea Arcangeli wrote:
>Zone reclaim locked breaks zone_reclaim_mode=1. If more than one
>thread allocates memory at the same time, it forces a premature
>allocation into remote NUMA nodes even when there's plenty of clean
>cache to reclaim in the local nodes.
>
>Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
>Reviewed-by: Rik van Riel <riel@redhat.com>
>Acked-by: Rafael Aquini <aquini@redhat.com>
>Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>---
> include/linux/mmzone.h | 6 ------
> mm/vmscan.c            | 4 ----
> 2 files changed, 10 deletions(-)
>
>diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>index af4a3b7..9534a9a 100644
>--- a/include/linux/mmzone.h
>+++ b/include/linux/mmzone.h
>@@ -496,7 +496,6 @@ struct zone {
> } ____cacheline_internodealigned_in_smp;
>
> typedef enum {
>-	ZONE_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
> 	ZONE_OOM_LOCKED,		/* zone is in OOM killer zonelist */
> 	ZONE_CONGESTED,			/* zone has many dirty pages backed by
> 					 * a congested BDI
>@@ -540,11 +539,6 @@ static inline int zone_is_reclaim_writeback(const struct zone *zone)
> 	return test_bit(ZONE_WRITEBACK, &zone->flags);
> }
>
>-static inline int zone_is_reclaim_locked(const struct zone *zone)
>-{
>-	return test_bit(ZONE_RECLAIM_LOCKED, &zone->flags);
>-}
>-
> static inline int zone_is_oom_locked(const struct zone *zone)
> {
> 	return test_bit(ZONE_OOM_LOCKED, &zone->flags);
>diff --git a/mm/vmscan.c b/mm/vmscan.c
>index 2cff0d4..042fdcd 100644
>--- a/mm/vmscan.c
>+++ b/mm/vmscan.c
>@@ -3595,11 +3595,7 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
> 	if (node_state(node_id, N_CPU) && node_id != numa_node_id())
> 		return ZONE_RECLAIM_NOSCAN;
>
>-	if (zone_test_and_set_flag(zone, ZONE_RECLAIM_LOCKED))
>-		return ZONE_RECLAIM_NOSCAN;
>-
> 	ret = __zone_reclaim(zone, gfp_mask, order);
>-	zone_clear_flag(zone, ZONE_RECLAIM_LOCKED);
>
> 	if (!ret)
> 		count_vm_event(PGSCAN_ZONE_RECLAIM_FAILED);
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
