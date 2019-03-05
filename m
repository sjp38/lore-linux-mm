Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59D94C43381
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 04:16:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A1EC20675
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 04:16:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="uSscDkbs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A1EC20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 955138E0005; Mon,  4 Mar 2019 23:16:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9040E8E0001; Mon,  4 Mar 2019 23:16:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77EA48E0005; Mon,  4 Mar 2019 23:16:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4A8FA8E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 23:16:06 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id z123so6134664qka.20
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 20:16:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=567Z1LQrcn1jhTw4xpN14TmoibNHf0KqVc9qvZCGIJk=;
        b=mStlhSY/e4W0gx2fnUT4ejMYM8ovfwcO7UBzppoGH4ebssIk2gee6Rv3kCwvZuAiSp
         z9mKlfUtapz7Z7JfUJiFF8CpAnwKjMPYD0oGwt14EYRA0BtGeFTeZQ43xjwU3vJKKX3a
         Mbhct8oV2xPmeh+2W+QUSMmq2EaOIG9JDt7pXbs/HIg7AWnAgbqtotdGzCjlbhNUKyD2
         pLuBku5l1ZcLjxqK/SJLI2uN4Z+LlBgEtF40gwweVQWkr1CM60nuxjN6dA+PvkTXY6fP
         1w5PFU1nCnduV31hRsNBIyw8U9Vp5fLRZCVGRgv8M8Ij8RhTCMTakQxuuciTBiyqXnl6
         QAFQ==
X-Gm-Message-State: APjAAAUjdZa6MHBafeoo6cMUOy4f2XBSiSVmVp85GivUXEQ6eE+y3q8J
	U0TCwmXJjnbGJO4FUzsE97dqrCNpkMbycIT4gz6eu2cqYfJknf4YnqjczNrwDfVC4C60HLIhw5c
	Ekdq6nvjOmLwVYk6dSXgIyZ/TcNcEllA3oiGV+g2fOR5l2G9pLkuUpe4cbMCYTkY4YA==
X-Received: by 2002:a0c:89a3:: with SMTP id 32mr616082qvr.56.1551759366058;
        Mon, 04 Mar 2019 20:16:06 -0800 (PST)
X-Google-Smtp-Source: APXvYqyPCkm5qOpWcrm3fayrD99Epxwsko0/mRf24VW5idkJoH1+3ydIb8MePJ34JV0DBzNMK3Zp
X-Received: by 2002:a0c:89a3:: with SMTP id 32mr616041qvr.56.1551759365201;
        Mon, 04 Mar 2019 20:16:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551759365; cv=none;
        d=google.com; s=arc-20160816;
        b=gHokywbLVLs3szDcJScGbHG8klI+2wh66rVStieL7qzMXxNfrn4y99sVHblqakGUVb
         gXbBY1Hf8H3gYT3i+FmnHdKDD5UH9eQcjENa3WOcDJaHemfBaqLGUL8oeYAJ14f02E+s
         mL6NrT8sDQQ6y4zapJyhTTAuDgm+ycsKB45iuD7G1kWx/Mm15XbDl8yuf0BN+teR0zJT
         EdgGdlH1MMqVFVtkK9nswKIYeHgYmpAHVF7jHIGZTGlfUdz14IbiDeuX8LMswdIaq0HQ
         z/ynFiVM7mdUiO/YED01aZUUCOmX8wW3+pxb+ZsnaROjJmU3PAc3UFIvRKf6UN8ZYh7A
         piPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=567Z1LQrcn1jhTw4xpN14TmoibNHf0KqVc9qvZCGIJk=;
        b=iIMXR5Kh+AWs2JTxZNCOjBIriQ1AnfcKqCWuqA9m5/uGTLZE1/U3Mfvkz3N5LZfM0e
         Ckmo7vnkglQeOKjnMDDJqNfi+t3MSAlVv5Bo6A/gGVQrRi4awCS7F+vlkX5js0votl5s
         nbqbtFFWiNk6D9Eo5L0I+5w3INd3nY8gBB/Rt1ZiKgXznf6ntgBruAM1PQr8d6Syu9Or
         eZ/j/gazLm4vSGTUvBryEf6cqDjrYvHgedKLnwC4tOSb4o2TGUhMekq/ftp6cs1FGS+V
         GqI2E06GBFfC/ei4EEi5/WJxkXnwUSC9J0avzl5nEnho6Z33Dd19Nx7/CveahYf6ny9f
         aSlg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=uSscDkbs;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id x23si4387158qta.78.2019.03.04.20.16.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 20:16:05 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=uSscDkbs;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x254Eoam123693;
	Tue, 5 Mar 2019 04:15:50 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=567Z1LQrcn1jhTw4xpN14TmoibNHf0KqVc9qvZCGIJk=;
 b=uSscDkbsyI7z84pF+b17PGBHyt8QAUOsFr8mn2QVwDyXpe3dIxsFuNrz5vPo1o929j/H
 4Uj9hKJUQi50KxOZdZQHOs9o81Bi3VmoXmw0JSPiR5u9fq6k9InsrQYVPRibTLpcr2MD
 mreoOCEOyP8NAyehal8/ZZBiX0E0xCR9rGS/o/to5cyYBanzKrqNIG6MXSVYe3byCJjC
 5zD+pJJm8Y84oS1cJAaxdPyv3iOebESxT899JGAOozs1rFUXF4ytC7eVRaxWGXoi5emK
 3Ym9yCnBJFO7UgeVnKNnfhtmzeBtmelH13r/AAG7K7P7wPdmhMAVyPtb9mBb/Kjzy61h 4A== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2qyfbe36y6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 05 Mar 2019 04:15:50 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x254FjiH001526
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 5 Mar 2019 04:15:45 GMT
Received: from abhmp0007.oracle.com (abhmp0007.oracle.com [141.146.116.13])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x254FfDA032766;
	Tue, 5 Mar 2019 04:15:42 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 04 Mar 2019 20:15:41 -0800
Subject: Re: [PATCH v4] mm/hugetlb: Fix unsigned overflow in
 __nr_hugepages_store_common()
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Oscar Salvador <osalvador@suse.de>
Cc: David Rientjes <rientjes@google.com>,
        Jing Xiangfeng <jingxiangfeng@huawei.com>,
        "mhocko@kernel.org" <mhocko@kernel.org>,
        "hughd@google.com"
 <hughd@google.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Andrea Arcangeli <aarcange@redhat.com>,
        "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
        linux-kernel@vger.kernel.org, Alexandre Ghiti <alex@ghiti.fr>
References: <388cbbf5-7086-1d04-4c49-049021504b9d@oracle.com>
 <alpine.DEB.2.21.1902241913000.34632@chino.kir.corp.google.com>
 <8c167be7-06fa-a8c0-8ee7-0bfad41eaba2@oracle.com>
 <13400ee2-3d3b-e5d6-2d78-a770820417de@oracle.com>
 <alpine.DEB.2.21.1902251116180.167839@chino.kir.corp.google.com>
 <5C74A2DA.1030304@huawei.com>
 <alpine.DEB.2.21.1902252220310.40851@chino.kir.corp.google.com>
 <e2bded2f-40ca-c308-5525-0a21777ed221@oracle.com>
 <20190226143620.c6af15c7c897d3362b191e36@linux-foundation.org>
 <086c4a4b-a37d-f144-00c0-d9a4062cc5fe@oracle.com>
 <20190305000402.GA4698@hori.linux.bs1.fc.nec.co.jp>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <8f3aede3-c07e-ac15-1577-7667e5b70d2f@oracle.com>
Date: Mon, 4 Mar 2019 20:15:40 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190305000402.GA4698@hori.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9185 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903050029
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/4/19 4:03 PM, Naoya Horiguchi wrote:
> On Tue, Feb 26, 2019 at 04:03:23PM -0800, Mike Kravetz wrote:
>> On 2/26/19 2:36 PM, Andrew Morton wrote:
> ...
>>>>
>>>> +	} else {
>>>>  		/*
>>>> -		 * per node hstate attribute: adjust count to global,
>>>> -		 * but restrict alloc/free to the specified node.
>>>> +		 * Node specific request, but we could not allocate
>>>> +		 * node mask.  Pass in ALL nodes, and clear nid.
>>>>  		 */
>>>
>>> Ditto here, somewhat.
> 
> # I missed this part when reviewing yesterday for some reason, sorry.
> 
>>
>> I was just going to update the comments and send you a new patch, but
>> but your comment got me thinking about this situation.  I did not really
>> change the way this code operates.  As a reminder, the original code is like:
>>
>> NODEMASK_ALLOC(nodemask_t, nodes_allowed, GFP_KERNEL | __GFP_NORETRY);
>>
>> if (nid == NUMA_NO_NODE) {
>> 	/* do something */
>> } else if (nodes_allowed) {
>> 	/* do something else */
>> } else {
>> 	nodes_allowed = &node_states[N_MEMORY];
>> }
>>
>> So, the only way we get to that final else if if we can not allocate
>> a node mask (kmalloc a few words).  Right?  I wonder why we should
>> even try to continue in this case.  Why not just return right there?
> 
> Simply returning on allocation failure looks better to me.
> As you mentioned below, current behavior for this 'else' case is not
> helpful for anyone.

Thanks Naoya.  And, thank you Oscar for your suggestion.

I think the simplest thing to do would be simply return in this case.  In
practice, we will likely never hit the condition.  If we do, the system is
really low on memory and there will be other more important issues.

The revised patch below updates comments as suggested, and returns -ENOMEM
if we can not allocate a node mask.

Andrew, this is on top of Alexandre Ghiti's "hugetlb: allow to free gigantic
pages regardless of the configuration" patch.  Both patches modify
__nr_hugepages_store_common().  Alex's patch is going to change slightly
in this area.  Let me know if there is something I can do to help make
merging easier.

From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Mon, 4 Mar 2019 17:45:11 -0800
Subject: [PATCH] hugetlbfs: fix potential over/underflow setting node specific
 nr_hugepages

The number of node specific huge pages can be set via a file such as:
/sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages
When a node specific value is specified, the global number of huge
pages must also be adjusted.  This adjustment is calculated as the
specified node specific value + (global value - current node value).
If the node specific value provided by the user is large enough, this
calculation could overflow an unsigned long leading to a smaller
than expected number of huge pages.

To fix, check the calculation for overflow.  If overflow is detected,
use ULONG_MAX as the requested value.  This is inline with the user
request to allocate as many huge pages as possible.

It was also noticed that the above calculation was done outside the
hugetlb_lock.  Therefore, the values could be inconsistent and result
in underflow.  To fix, the calculation is moved within the routine
set_max_huge_pages() where the lock is held.

In addition, the code in __nr_hugepages_store_common() which tries to
handle the case of not being able to allocate a node mask would likely
result in incorrect behavior.  Luckily, it is very unlikely we will
ever take this path.  If we do, simply return ENOMEM.

Reported-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 42 +++++++++++++++++++++++++++++++++---------
 1 file changed, 33 insertions(+), 9 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c5c4558e4a79..5a190a652cac 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2274,7 +2274,7 @@ static int adjust_pool_surplus(struct hstate *h, nodemask_t *nodes_allowed,
 }
 
 #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
-static int set_max_huge_pages(struct hstate *h, unsigned long count,
+static int set_max_huge_pages(struct hstate *h, unsigned long count, int nid,
 						nodemask_t *nodes_allowed)
 {
 	unsigned long min_count, ret;
@@ -2289,6 +2289,28 @@ static int set_max_huge_pages(struct hstate *h, unsigned long count,
 		goto decrease_pool;
 	}
 
+	spin_lock(&hugetlb_lock);
+
+	/*
+	 * Check for a node specific request.
+	 * Changing node specific huge page count may require a corresponding
+	 * change to the global count.  In any case, the passed node mask
+	 * (nodes_allowed) will restrict alloc/free to the specified node.
+	 */
+	if (nid != NUMA_NO_NODE) {
+		unsigned long old_count = count;
+
+		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
+		/*
+		 * User may have specified a large count value which caused the
+		 * above calculation to overflow.  In this case, they wanted
+		 * to allocate as many huge pages as possible.  Set count to
+		 * largest possible value to align with their intention.
+		 */
+		if (count < old_count)
+			count = ULONG_MAX;
+	}
+
 	/*
 	 * Increase the pool size
 	 * First take pages out of surplus state.  Then make up the
@@ -2300,7 +2322,6 @@ static int set_max_huge_pages(struct hstate *h, unsigned long count,
 	 * pool might be one hugepage larger than it needs to be, but
 	 * within all the constraints specified by the sysctls.
 	 */
-	spin_lock(&hugetlb_lock);
 	while (h->surplus_huge_pages && count > persistent_huge_pages(h)) {
 		if (!adjust_pool_surplus(h, nodes_allowed, -1))
 			break;
@@ -2421,16 +2442,19 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
 			nodes_allowed = &node_states[N_MEMORY];
 		}
 	} else if (nodes_allowed) {
+		/* Node specific request */
+		init_nodemask_of_node(nodes_allowed, nid);
+	} else {
 		/*
-		 * per node hstate attribute: adjust count to global,
-		 * but restrict alloc/free to the specified node.
+		 * Node specific request, but we could not allocate the few
+		 * words required for a node mask.  We are unlikely to hit
+		 * this condition.  Since we can not pass down the appropriate
+		 * node mask, just return ENOMEM.
 		 */
-		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
-		init_nodemask_of_node(nodes_allowed, nid);
-	} else
-		nodes_allowed = &node_states[N_MEMORY];
+		return -ENOMEM;
+	}
 
-	err = set_max_huge_pages(h, count, nodes_allowed);
+	err = set_max_huge_pages(h, count, nid, nodes_allowed);
 	if (err)
 		goto out;
 
-- 
2.17.2

