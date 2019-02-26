Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51325C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 19:32:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B56F22063F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 19:32:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="goSGlagK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B56F22063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 119638E0004; Tue, 26 Feb 2019 14:32:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A16C8E0001; Tue, 26 Feb 2019 14:32:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E849A8E0004; Tue, 26 Feb 2019 14:32:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id BCB408E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 14:32:42 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id 9so2931368ita.8
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 11:32:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=BY1nguEaEu/sC8qABN9/Uv4DYLbg99rDhP9JHOxhMKw=;
        b=mU1R6cIeNuO6UJCKoT28R3wa6yNoKRuaPdplI5va2rPK+OKDgK1LfWDp/osMUHi/t1
         sC7XK8jJ6wS9/XB/TFP5bns+E/mOsbAZ0i4w5RF1ZQ2pHrOmLQIOsQgBfx74KjcgEurc
         QAbxpfrIpWm/rCLjdFqBKsANWqM7vj8F/ekI8bQoPOU17hnP/Z3Q2IcuKbXS7MFfu5z3
         SaaKdZWu7D+8GjxGuZnc8hLn6hdVYzgCV3VoiWSOgCt8KmGKf5cNBJBNGfnKKtDPHDu4
         EGglacY2YoAr9E7IMttzn3v/qA6OZrQeMuTSshCXCpGdM02D4yF+5V05+7nDpFhmiFzW
         EO9A==
X-Gm-Message-State: AHQUAuazdoETq07BrrP1069Cz/k17owHgYVqTkPpQqY2HgV1M2bolKpu
	vdRYi3TwcKORZsVAMks0Yxye31+cnOHsXawbQabqLUe8TpyqGoSaTvE+V5JKOExClWKWqJ+W5f2
	K+M4JcVW5nZ7tbhqBarY+E2leSc2p0o/rdzpe94z1bMGo2OvfmKEVdkT+4NdWVUbqDA==
X-Received: by 2002:a24:5f52:: with SMTP id r79mr3708753itb.125.1551209562454;
        Tue, 26 Feb 2019 11:32:42 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib+J6D8X+EmOi2zd5PsvG14kRHuwiViRm+dSQ1LiIiXDjpHXHTzNy6+q+0agDvSiJ1vzj92
X-Received: by 2002:a24:5f52:: with SMTP id r79mr3708715itb.125.1551209561475;
        Tue, 26 Feb 2019 11:32:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551209561; cv=none;
        d=google.com; s=arc-20160816;
        b=LzX7IYL0mhExzWWLVxgSOVDoMZLPdoOmAId8GcljGWBVMWWW7pPBg6yH9QRlArl8XG
         Gy5hlwe6Yhmi5TzUXmXzZIXDnTv/onQR0cPc6hhlqHUV43XdIuxJitQb6fkytUM9nba8
         ZkQWL8bPG7nwG4HdW0CwOuRF+N1re9ANZZhiqQhDl5GYrp/YSLgwkuah6zbWWL8qkl3s
         lfOLl4+QBBvDu3oHN5yjghZHDmB2L6Akq4SGOH4AqHx5Z/7R8sYh80YbP9pk7GI3ZNNt
         EXInmoLzWfJxwW2VavmIhM9mcyW2zMiOlAVXtXTe5XwczhCSg16a6mIMpsStRpX59d5H
         41iw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=BY1nguEaEu/sC8qABN9/Uv4DYLbg99rDhP9JHOxhMKw=;
        b=umqo6mykKpkTwNX2lIqFQBiewgXFROXrZt29U5R92wguQPTeu3r7X0sRa3U6zz+HP5
         qyv4nItywdWlR/doTFqPwWGNN2Iy3CtqUqVbfxawPI3vZhxQeTUr9QsQZIkyxignLXLW
         plY42oyyjVVwbx9c0E5wLG48fwlcNp9X/bV6sMFcsQf8nX1vUWUD5L1v0OfNiuFlhgjF
         oY1fxVhzz3F6z2fAeRd1jCHr6jTQcjAh+Jl/worqYNR/wJJnkDKB/yd8+OsBh0oJ9xR/
         3JYUgEWWxGTgnlljEPqzvJilgtoOtecK5X2U1h34qCWrahQKUNTkNWkswQqR9tk6hf0p
         STqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=goSGlagK;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id g7si191193itc.68.2019.02.26.11.32.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 11:32:41 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=goSGlagK;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1QJONl3010902;
	Tue, 26 Feb 2019 19:32:28 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=BY1nguEaEu/sC8qABN9/Uv4DYLbg99rDhP9JHOxhMKw=;
 b=goSGlagKURMqpOLxCAiAjaOhByL/nQImlKu+NRo/OUnPMaX6mJ+Y5gFERbta1HnhupgI
 8sgrgDY5/YWNUbepSBE2gQVZowYimlojk5z6fePqhZUOKotEtukVk0G2N4pIh6eIZGzK
 XwGtyXeVLJAseOsvnlPJrCaqSDvywcMNdqjH0BX130yU1RoocrGtqElmGBsDjgCuQgwU
 U30/FaOtojsvJIzYfbw+Zq+m0pB6wOUXafehcT+I5brcYnGKGO4dH5SquBoOKAdnZtwC
 rxZ1/X68qWkWHrVascCOjB/6z0+Eqnib+IwPd3/j+/Tl3szHToUcjU4/l67z5p5G7Yga qg== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2130.oracle.com with ESMTP id 2qtupe6x3s-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 26 Feb 2019 19:32:28 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1QJWRqa008506
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 26 Feb 2019 19:32:27 GMT
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1QJWPjk021262;
	Tue, 26 Feb 2019 19:32:26 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 26 Feb 2019 11:32:25 -0800
Subject: Re: [PATCH v4] mm/hugetlb: Fix unsigned overflow in
 __nr_hugepages_store_common()
To: David Rientjes <rientjes@google.com>,
        Jing Xiangfeng <jingxiangfeng@huawei.com>,
        Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@kernel.org, hughd@google.com, linux-mm@kvack.org,
        n-horiguchi@ah.jp.nec.com, Andrea Arcangeli <aarcange@redhat.com>,
        kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org
References: <1550885529-125561-1-git-send-email-jingxiangfeng@huawei.com>
 <388cbbf5-7086-1d04-4c49-049021504b9d@oracle.com>
 <alpine.DEB.2.21.1902241913000.34632@chino.kir.corp.google.com>
 <8c167be7-06fa-a8c0-8ee7-0bfad41eaba2@oracle.com>
 <13400ee2-3d3b-e5d6-2d78-a770820417de@oracle.com>
 <alpine.DEB.2.21.1902251116180.167839@chino.kir.corp.google.com>
 <5C74A2DA.1030304@huawei.com>
 <alpine.DEB.2.21.1902252220310.40851@chino.kir.corp.google.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <e2bded2f-40ca-c308-5525-0a21777ed221@oracle.com>
Date: Tue, 26 Feb 2019 11:32:24 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1902252220310.40851@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9179 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902260134
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/25/19 10:21 PM, David Rientjes wrote:
> On Tue, 26 Feb 2019, Jing Xiangfeng wrote:
>> On 2019/2/26 3:17, David Rientjes wrote:
>>> On Mon, 25 Feb 2019, Mike Kravetz wrote:
>>>
>>>> Ok, what about just moving the calculation/check inside the lock as in the
>>>> untested patch below?
>>>>
>>>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

<snip>

>>>
>>> Looks good; Jing, could you test that this fixes your case?
>>
>> Yes, I have tested this patch, it can also fix my case.
> 
> Great!
> 
> Reported-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
> Tested-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
> Acked-by: David Rientjes <rientjes@google.com>

Thanks Jing and David!

Here is the patch with an updated commit message and above tags:

From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Tue, 26 Feb 2019 10:43:24 -0800
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
in underflow.  To fix, the calculation is moved to within the routine
set_max_huge_pages() where the lock is held.

Reported-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
Tested-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
Acked-by: David Rientjes <rientjes@google.com>
---
 mm/hugetlb.c | 34 ++++++++++++++++++++++++++--------
 1 file changed, 26 insertions(+), 8 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index b37e3100b7cc..a7e4223d2df5 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2274,7 +2274,7 @@ static int adjust_pool_surplus(struct hstate *h,
nodemask_t *nodes_allowed,
 }

 #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
-static int set_max_huge_pages(struct hstate *h, unsigned long count,
+static int set_max_huge_pages(struct hstate *h, unsigned long count, int nid,
 						nodemask_t *nodes_allowed)
 {
 	unsigned long min_count, ret;
@@ -2289,6 +2289,23 @@ static int set_max_huge_pages(struct hstate *h, unsigned
long count,
 		goto decrease_pool;
 	}

+	spin_lock(&hugetlb_lock);
+
+	/*
+	 * Check for a node specific request.  Adjust global count, but
+	 * restrict alloc/free to the specified node.
+	 */
+	if (nid != NUMA_NO_NODE) {
+		unsigned long old_count = count;
+		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
+		/*
+		 * If user specified count causes overflow, set to
+		 * largest possible value.
+		 */
+		if (count < old_count)
+			count = ULONG_MAX;
+	}
+
 	/*
 	 * Increase the pool size
 	 * First take pages out of surplus state.  Then make up the
@@ -2300,7 +2317,6 @@ static int set_max_huge_pages(struct hstate *h, unsigned
long count,
 	 * pool might be one hugepage larger than it needs to be, but
 	 * within all the constraints specified by the sysctls.
 	 */
-	spin_lock(&hugetlb_lock);
 	while (h->surplus_huge_pages && count > persistent_huge_pages(h)) {
 		if (!adjust_pool_surplus(h, nodes_allowed, -1))
 			break;
@@ -2421,16 +2437,18 @@ static ssize_t __nr_hugepages_store_common(bool
obey_mempolicy,
 			nodes_allowed = &node_states[N_MEMORY];
 		}
 	} else if (nodes_allowed) {
+		/* Node specific request */
+		init_nodemask_of_node(nodes_allowed, nid);
+	} else {
 		/*
-		 * per node hstate attribute: adjust count to global,
-		 * but restrict alloc/free to the specified node.
+		 * Node specific request, but we could not allocate
+		 * node mask.  Pass in ALL nodes, and clear nid.
 		 */
-		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
-		init_nodemask_of_node(nodes_allowed, nid);
-	} else
+		nid = NUMA_NO_NODE;
 		nodes_allowed = &node_states[N_MEMORY];
+	}

-	err = set_max_huge_pages(h, count, nodes_allowed);
+	err = set_max_huge_pages(h, count, nid, nodes_allowed);
 	if (err)
 		goto out;

-- 
2.17.2

