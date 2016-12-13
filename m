Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 833416B0069
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 10:54:43 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c4so171152341pfb.7
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 07:54:43 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q8si48429409pli.263.2016.12.13.07.54.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 07:54:42 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uBDFsg2K012650
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 10:54:42 -0500
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
	by mx0a-001b2d01.pphosted.com with ESMTP id 27ahhq8ete-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 10:54:41 -0500
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Tue, 13 Dec 2016 10:54:40 -0500
Date: Tue, 13 Dec 2016 09:54:35 -0600
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: memory_hotplug: zone_can_shift() returns boolean value
References: <8f85e530-4cc9-164b-ab44-6ebd78389c7b@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <8f85e530-4cc9-164b-ab44-6ebd78389c7b@gmail.com>
Message-Id: <20161213155435.fs4n44gt6g2u2f2e@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Cc: linux-mm@kvack.org, isimatu.yasuaki@jp.fujitsu.com, linux-kernel@vger.kernel.org

On Mon, Dec 12, 2016 at 03:29:04PM -0500, Yasuaki Ishimatsu wrote:
>--- a/drivers/base/memory.c
>+++ b/drivers/base/memory.c
>@@ -410,15 +410,13 @@ static ssize_t show_valid_zones(struct device *dev,
> 	sprintf(buf, "%s", zone->name);
>
> 	/* MMOP_ONLINE_KERNEL */
>-	zone_shift = zone_can_shift(start_pfn, nr_pages, ZONE_NORMAL);
>-	if (zone_shift) {
>+	if (zone_can_shift(start_pfn, nr_pages, ZONE_NORMAL, &zone_shift)) {
> 		strcat(buf, " ");
> 		strcat(buf, (zone + zone_shift)->name);
> 	}
>
> 	/* MMOP_ONLINE_MOVABLE */
>-	zone_shift = zone_can_shift(start_pfn, nr_pages, ZONE_MOVABLE);
>-	if (zone_shift) {
>+	if (zone_can_shift(start_pfn, nr_pages, ZONE_MOVABLE, &zone_shift)) {
> 		strcat(buf, " ");
> 		strcat(buf, (zone + zone_shift)->name);
> 	}

You still need to check zone_shift != 0, otherwise you may get duplicate 
output:

$ cat /sys/devices/system/node/node1/memory256/valid_zones
Movable Normal Movable
$ cat /sys/devices/system/node/node1/memory257/valid_zones
Movable Movable

>--- a/mm/memory_hotplug.c
>+++ b/mm/memory_hotplug.c
>@@ -1033,8 +1033,8 @@ static void node_states_set_node(int node, struct memory_notify *arg)
> 	node_set_state(node, N_MEMORY);
> }
>
>-int zone_can_shift(unsigned long pfn, unsigned long nr_pages,
>-		   enum zone_type target)
>+bool zone_can_shift(unsigned long pfn, unsigned long nr_pages,
>+		   enum zone_type target, int *zone_shift)
> {
> 	struct zone *zone = page_zone(pfn_to_page(pfn));
> 	enum zone_type idx = zone_idx(zone);

I think you should initialize zone_shift here. It should be 0 if the 
function returns false.

	*zone_shift = 0;

>@@ -1043,26 +1043,27 @@ int zone_can_shift(unsigned long pfn, unsigned long nr_pages,
> 	if (idx < target) {
> 		/* pages must be at end of current zone */
> 		if (pfn + nr_pages != zone_end_pfn(zone))
>-			return 0;
>+			return false;
>
> 		/* no zones in use between current zone and target */
> 		for (i = idx + 1; i < target; i++)
> 			if (zone_is_initialized(zone - idx + i))
>-				return 0;
>+				return false;
> 	}
>
> 	if (target < idx) {
> 		/* pages must be at beginning of current zone */
> 		if (pfn != zone->zone_start_pfn)
>-			return 0;
>+			return false;
>
> 		/* no zones in use between current zone and target */
> 		for (i = target + 1; i < idx; i++)
> 			if (zone_is_initialized(zone - idx + i))
>-				return 0;
>+				return false;
> 	}
>
>-	return target - idx;
>+	*zone_shift = target - idx;
>+	return true;
> }
>
> /* Must be protected by mem_hotplug_begin() */
>@@ -1089,10 +1090,13 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
> 	    !can_online_high_movable(zone))
> 		return -EINVAL;
>
>-	if (online_type == MMOP_ONLINE_KERNEL)
>-		zone_shift = zone_can_shift(pfn, nr_pages, ZONE_NORMAL);
>-	else if (online_type == MMOP_ONLINE_MOVABLE)
>-		zone_shift = zone_can_shift(pfn, nr_pages, ZONE_MOVABLE);
>+	if (online_type == MMOP_ONLINE_KERNEL) {
>+		if (!zone_can_shift(pfn, nr_pages, ZONE_NORMAL, &zone_shift))
>+			return -EINVAL;
>+	} else if (online_type == MMOP_ONLINE_MOVABLE) {
>+		if (!zone_can_shift(pfn, nr_pages, ZONE_MOVABLE, &zone_shift))
>+			return -EINVAL;
>+	}
>
> 	zone = move_pfn_range(zone_shift, pfn, pfn + nr_pages);
> 	if (!zone)
>-- 
>1.8.3.1
>

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
