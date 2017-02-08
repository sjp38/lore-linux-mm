Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 085266B0038
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 18:07:22 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id v184so208037143pgv.6
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 15:07:21 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f8si8349864pln.60.2017.02.08.15.07.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 15:07:20 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v18N4Goj107266
	for <linux-mm@kvack.org>; Wed, 8 Feb 2017 18:07:20 -0500
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28g80237m1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 Feb 2017 18:07:20 -0500
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gwshan@linux.vnet.ibm.com>;
	Thu, 9 Feb 2017 09:07:17 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id E9DB93578053
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 10:07:15 +1100 (EST)
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v18N77lu30671046
	for <linux-mm@kvack.org>; Thu, 9 Feb 2017 10:07:15 +1100
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v18N6hqP029964
	for <linux-mm@kvack.org>; Thu, 9 Feb 2017 10:06:43 +1100
Date: Thu, 9 Feb 2017 10:06:18 +1100
From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/page_alloc: Fix nodes for reclaim in fast path
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
References: <1486532455-29613-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <20170208100850.GD5686@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170208100850.GD5686@dhcp22.suse.cz>
Message-Id: <20170208230618.GA4142@gwshan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, linux-mm@kvack.org, mgorman@suse.de, akpm@linux-foundation.org, anton@samba.org, mpe@ellerman.id.au, "# v3 . 16+" <stable@vger.kernel.org>

On Wed, Feb 08, 2017 at 11:08:50AM +0100, Michal Hocko wrote:
>On Wed 08-02-17 16:40:55, Gavin Shan wrote:
>> When @node_reclaim_node isn't 0, the page allocator tries to reclaim
>> pages if the amount of free memory in the zones are below the low
>> watermark. On Power platform, none of NUMA nodes are scanned for page
>> reclaim because no nodes match the condition in zone_allows_reclaim().
>> On Power platform, RECLAIM_DISTANCE is set to 10 which is the distance
>> of Node-A to Node-A. So the preferred node even won't be scanned for
>> page reclaim.
>
>This is quite confusing. I can see 56608209d34b ("powerpc/numa: Set a
>smaller value for RECLAIM_DISTANCE to enable zone reclaim") which
>enforced the zone_reclaim by reducing the RECLAIM_DISTANCE, now you are
>building on top of that. Having RECLAIM_DISTANCE == LOCAL_DISTANCE is
>really confusing. What are distances of other nodes (in other words what
>does numactl --hardware tells)? I am wondering whether we shouldn't
>rather revert 56608209d34b as the node_reclaim (these days) is not
>enabled by default anymore.
>

Michael, Yeah, it's a bit confusing. Let me try to summarize the history:
the code 56608209d34b (2.6.35) depends, which is shown in its commit log,
was removed by 957f822a0ab9 (3.10). Since then, the code change introduced
by 56608209d34b (2.6.35) becomes obsoleted. However, the local pagecache
(with @node_reclaim_mode turned on manually) was able to be shrinked at
that point (3.10) until 5f7a75acdb24 (3.16) was merged. This patch fixes
the issue introduced by 5f7a75acdb24 and needs go to 3.16+. Hope this
makes things more clear, not more confusing :-)

Yes, I already planned to set PowerPC specific RECLAIM_DISTANCE to 30, same
value to the generic one, as I said in the last reply of the thread:
https://patchwork.ozlabs.org/patch/718830/

>
>> Fixes: 5f7a75acdb24 ("mm: page_alloc: do not cache reclaim distances")
>> Cc: <stable@vger.kernel.org> # v3.16+
>> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
>
>anyway the patch looks OK as it brings the previous behavior back. Not
>that I would be entirely happy about that behavior as it is quite nasty
>- e.g. it will trigger direct reclaim from the allocator fast path way
>too much and basically skip the kswapd wake up most of the time if there
>is anything reclaimable... But this used to be there before as well.
>
>Acked-by: Michal Hocko <mhocko@suse.com>
>
>but I would really like to get rid of the ppc specific RECLAIM_DISTANCE
>if possible as well.
>

Yes, I will post one patch for this and you will be copied.

Thanks,
Gavin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
