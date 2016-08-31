Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD6DD6B0038
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 02:10:20 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id w128so86353439pfd.3
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 23:10:20 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id cc15si49068559pac.249.2016.08.30.23.10.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 23:10:19 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7V6ADuD031911
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 02:10:19 -0400
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com [125.16.236.4])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2558r6a73a-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 02:10:18 -0400
Received: from localhost
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 31 Aug 2016 11:40:14 +0530
Received: from d28relay07.in.ibm.com (d28relay07.in.ibm.com [9.184.220.158])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 27662394006C
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 11:40:11 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay07.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u7V6A9jV20906126
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 11:40:09 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u7V6A1A6028021
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 11:40:09 +0530
Date: Wed, 31 Aug 2016 11:39:59 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 07/34] mm, vmscan: make kswapd reclaim in terms of nodes
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-8-git-send-email-mgorman@techsingularity.net>
 <20160829093844.GA2592@linux.vnet.ibm.com>
 <20160830120728.GV8119@techsingularity.net>
 <20160830142508.GA10514@linux.vnet.ibm.com>
 <20160830150051.GW8119@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20160830150051.GW8119@techsingularity.net>
Message-Id: <20160831060959.GA6787@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>

> > The trigger is memblock_reserve() for the complete node memory.  And
> > this is exactly what FA_DUMP does.  Here again the node has memory but
> > its all reserved so there is no free memory in the node.
> > 
> > Did you mean populated_zone() when you said zone_populated or have I
> > mistaken? populated_zone() does return 1 since it checks for
> > zone->present_pages.
> > 
> 
> Yes, I meant populated_zone(). Using present pages may have hidden
> a long-lived corner case as it was unexpected that an entire node
> would be reserved. The old code happened to survive *probably* because
> pgdat_reclaimable would look false and kswapd checks for pgdat being
> balanced would happen to do the right thing in this case.
> 
> Can you check if something like this works?
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index d572b78b65e1..cf64a5456cf6 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -830,7 +830,7 @@ unsigned long __init node_memmap_size_bytes(int, unsigned long, unsigned long);
> 
>  static inline int populated_zone(struct zone *zone)
>  {
> -	return (!!zone->present_pages);
> +	return (!!zone->managed_pages);
>  }
> 
>  extern int movable_zone;
> 

This indeed fixes the problem.
Please add my 
Tested-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
