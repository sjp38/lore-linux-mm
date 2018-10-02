Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 34A6E6B000C
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 07:54:24 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id v4-v6so1073058oix.2
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 04:54:24 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 92-v6si7753881otx.189.2018.10.02.04.54.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 04:54:23 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w92Brwxa052477
	for <linux-mm@kvack.org>; Tue, 2 Oct 2018 07:54:22 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mv6f9kyp6-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 02 Oct 2018 07:54:21 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 2 Oct 2018 12:54:19 +0100
Date: Tue, 2 Oct 2018 17:24:12 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] mm, numa: Remove rate-limiting of automatic numa
 balancing migration
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20181001100525.29789-1-mgorman@techsingularity.net>
 <20181001100525.29789-2-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20181001100525.29789-2-mgorman@techsingularity.net>
Message-Id: <20181002115412.GA4593@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Jirka Hladky <jhladky@redhat.com>, Rik van Riel <riel@surriel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

* Mel Gorman <mgorman@techsingularity.net> [2018-10-01 11:05:24]:

> Rate limiting of page migrations due to automatic NUMA balancing was
> introduced to mitigate the worst-case scenario of migrating at high
> frequency due to false sharing or slowly ping-ponging between nodes.
> Since then, a lot of effort was spent on correctly identifying these
> pages and avoiding unnecessary migrations and the safety net may no longer
> be required.
> 
> Jirka Hladky reported a regression in 4.17 due to a scheduler patch that
> avoids spreading STREAM tasks wide prematurely. However, once the task
> was properly placed, it delayed migrating the memory due to rate limiting.
> Increasing the limit fixed the problem for him.
> 
> Currently, the limit is hard-coded and does not account for the real
> capabilities of the hardware. Even if an estimate was attempted, it would
> not properly account for the number of memory controllers and it could
> not account for the amount of bandwidth used for normal accesses. Rather
> than fudging, this patch simply eliminates the rate limiting.
> 
> However, Jirka reports that a STREAM configuration using multiple
> processes achieved similar performance to 4.16. In local tests, this patch
> improved performance of STREAM relative to the baseline but it is somewhat
> machine-dependent. Most workloads show little or not performance difference
> implying that there is not a heavily reliance on the throttling mechanism
> and it is safe to remove.
> 
> STREAM on 2-socket machine
>                          4.19.0-rc5             4.19.0-rc5
>                          numab-v1r1       noratelimit-v1r1
> MB/sec copy     43298.52 (   0.00%)    44673.38 (   3.18%)
> MB/sec scale    30115.06 (   0.00%)    31293.06 (   3.91%)
> MB/sec add      32825.12 (   0.00%)    34883.62 (   6.27%)
> MB/sec triad    32549.52 (   0.00%)    34906.60 (   7.24%
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
Reviewed-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

-- 
Thanks and Regards
Srikar Dronamraju
