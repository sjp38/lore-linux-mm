Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A7C716B0038
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 14:42:22 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p138so1786320wmg.3
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:42:22 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s23si3229089wra.10.2017.04.27.11.42.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 11:42:21 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3RIce49038520
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 14:42:19 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2a3hhy5nsc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 14:42:19 -0400
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Thu, 27 Apr 2017 14:42:19 -0400
Date: Thu, 27 Apr 2017 13:42:13 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [RFC 1/4] mm: create N_COHERENT_MEMORY
References: <20170419075242.29929-1-bsingharora@gmail.com>
 <20170419075242.29929-2-bsingharora@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20170419075242.29929-2-bsingharora@gmail.com>
Message-Id: <20170427184213.tco7hu5w2zlm4lpg@arbab-laptop.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, mhocko@kernel.org, vbabka@suse.cz, cl@linux.com

On Wed, Apr 19, 2017 at 05:52:39PM +1000, Balbir Singh wrote:
>In this patch we create N_COHERENT_MEMORY, which is different
>from N_MEMORY. A node hotplugged as coherent memory will have
>this state set. The expectation then is that this memory gets
>onlined like regular nodes. Memory allocation from such nodes
>occurs only when the the node is contained explicitly in the
>mask.

Finally got around to test drive this. From what I can see, as expected,
both kernel and userspace seem to ignore these nodes, unless you 
allocate specifically from them. Very convenient.

Is "online_coherent"/MMOP_ONLINE_COHERENT the right way to trigger this?  
That mechanism is used to specify zone, and only for a single block of 
memory. This concept applies to the node as a whole. I think it should 
be independent of memory onlining.

I mean, let's say online_kernel N blocks, some of them get allocated, 
and then you online_coherent block N+1, flipping the entire node into 
N_COHERENT_MEMORY. That doesn't seem right.

That said, this set as it stands needs an adjustment when based on top 
of Michal's onlining revamp [1]. As-is, allow_online_pfn_range() is 
returning false. The patch below fixed it for me.

[1] http://lkml.kernel.org/r/20170421120512.23960-1-mhocko@kernel.org

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 4a535f1..ccb7a84 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -869,16 +869,20 @@ bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_pages,
 	 * though so let's stick with it for simplicity for now.
 	 * TODO make sure we do not overlap with ZONE_DEVICE
 	 */
-	if (online_type == MMOP_ONLINE_KERNEL) {
+	switch (online_type) {
+	case MMOP_ONLINE_KERNEL:
 		if (zone_is_empty(movable_zone))
 			return true;
 		return movable_zone->zone_start_pfn >= pfn + nr_pages;
-	} else if (online_type == MMOP_ONLINE_MOVABLE) {
+	case MMOP_ONLINE_MOVABLE:
 		return zone_end_pfn(normal_zone) <= pfn;
+	case MMOP_ONLINE_KEEP:
+	case MMOP_ONLINE_COHERENT:
+		/* These will always succeed and inherit the current zone */
+		return true;
 	}
 
-	/* MMOP_ONLINE_KEEP will always succeed and inherits the current zone */
-	return online_type == MMOP_ONLINE_KEEP;
+	return false;
 }
 
 static void __meminit resize_zone_range(struct zone *zone, unsigned long start_pfn,


-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
