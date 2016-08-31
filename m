Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id D6A716B0038
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 13:33:34 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id g185so92093856ith.2
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 10:33:34 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a19si715248qkb.55.2016.08.31.10.33.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 10:33:33 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7VHXHw9023415
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 13:33:33 -0400
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
	by mx0b-001b2d01.pphosted.com with ESMTP id 255q3sh7d2-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 13:33:32 -0400
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 1 Sep 2016 03:33:30 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id AE7A12BB0054
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 03:33:26 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u7VHXQHd2425338
	for <linux-mm@kvack.org>; Thu, 1 Sep 2016 03:33:26 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u7VHXQ2Q012849
	for <linux-mm@kvack.org>; Thu, 1 Sep 2016 03:33:26 +1000
Date: Wed, 31 Aug 2016 23:03:20 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 07/34] mm, vmscan: make kswapd reclaim in terms of nodes
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-8-git-send-email-mgorman@techsingularity.net>
 <20160829093844.GA2592@linux.vnet.ibm.com>
 <20160830120728.GV8119@techsingularity.net>
 <20160830142508.GA10514@linux.vnet.ibm.com>
 <20160830150051.GW8119@techsingularity.net>
 <20160831060959.GA6787@linux.vnet.ibm.com>
 <20160831084942.GX8119@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20160831084942.GX8119@techsingularity.net>
Message-Id: <20160831173320.GA5851@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>

> mm, vmscan: Only allocate and reclaim from zones with pages managed by the buddy allocator
> 
> Firmware Assisted Dump (FA_DUMP) on ppc64 reserves substantial amounts
> of memory when booting a secondary kernel. Srikar Dronamraju reported that
> multiple nodes may have no memory managed by the buddy allocator but still
> return true for populated_zone().
> 
> Commit 1d82de618ddd ("mm, vmscan: make kswapd reclaim in terms of nodes")
> was reported to cause kswapd to spin at 100% CPU usage when fadump was
> enabled. The old code happened to deal with the situation of a populated
> node with zero free pages by co-incidence but the current code tries to
> reclaim populated zones without realising that is impossible.
> 
> We cannot just convert populated_zone() as many existing users really
> need to check for present_pages. This patch introduces a managed_zone()
> helper and uses it in the few cases where it is critical that the check
> is made for managed pages -- zonelist constuction and page reclaim.

one nit
s/constuction/construction/

> 

Verified that it works fine.

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
