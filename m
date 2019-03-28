Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 724CEC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 22:06:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B2992075E
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 22:06:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="To6XGK9f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B2992075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA4EB6B0008; Thu, 28 Mar 2019 18:06:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A53F66B000C; Thu, 28 Mar 2019 18:06:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 942A26B0266; Thu, 28 Mar 2019 18:06:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 71F496B0008
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 18:06:04 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id v193so265045itv.9
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 15:06:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=efE+EqaifQWItnvqE5oHeBNSdF1slMZgpYXIiFbimNM=;
        b=XDnKCijE6X3X7pVjQwcXrjjtiqg9FwWkfup+4H9vanI+pmcv1V/DPavlnDvoj4eSiw
         e6qwf+EwuFJ12skx4cQBczEptcL20qX4jO31iS4ywKeJNze1LQs6ENXyRNSDoxi6GtIj
         mH8bM8zMFvHHvTXkHge6MvV1np0mtP63Yk37nC6W6CF1dTQrakME922eGUyeAa0c+okp
         TDnouAa4awh6FsLujHWvybmtgPyxrNuMAbBPFPhaLSCpqYAGyw+tCo4YFPgN4IRJ6/DS
         28ZTCBReJWOAbue5iM4aGVkhDj0p9S99RT9Y0qm7B3CsyX5itzAV/JfZGJwIa+tjl6YN
         BlBg==
X-Gm-Message-State: APjAAAXSkBVD2Le02KqUK+qpwFD0yD4PMLjFIqOLJ2JGXtAbJAuE+0oh
	lhFf2quwXxqGqL3ng97LpdsmTKRCY7l/D1+NZYbGNdLt3hGCXa4OZD/c3B8jB5jdrtPN/NVm9lj
	c7LahmgTYSlXGOOCerNHBFEPLLm4UgEII7ZChBmhmmlctGz3KOpgChssEhu8qJA+A/Q==
X-Received: by 2002:a24:ac6b:: with SMTP id m43mr2062562iti.28.1553810764160;
        Thu, 28 Mar 2019 15:06:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/+KqLu/JjvdwWLTMt9CN3itntzCF/z4iumjYlC2Wk5MIyhSB3TE+/OrzgW/9cmbmauzvq
X-Received: by 2002:a24:ac6b:: with SMTP id m43mr2062508iti.28.1553810763382;
        Thu, 28 Mar 2019 15:06:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553810763; cv=none;
        d=google.com; s=arc-20160816;
        b=sAs9g0yq9y8AVLGoRxa8i3ju75T+hvLnr3z23zkbL2XiThOJXAFBvnYE1KrU8HiizM
         7tQkLoc/xg/rmoNhn/e8myb7FeGjfOJieHlMtVk1NrNRfVwCUgaoUzIekV9p386V7iP0
         0GutVcSMnJyUl3t4yjXlJdsTfQZdzQ7U82czX5YBOfF/UuxV5TPpWppIx5XAxltCQ5Ok
         yfNFmRj3oYmzYqP+hOXNjboT6nlG/rEDtY+zr7ayoQtoS6PzXnNTa2DhvtH+KHDyOs1G
         w5lhI1rc2ZE+joydPHk/G8zbtqMkalM+s1uGWz64wgXs9LVoPjBjV8JPTmdrCy/8St/u
         oYHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=efE+EqaifQWItnvqE5oHeBNSdF1slMZgpYXIiFbimNM=;
        b=GVWA9AkWMhCcrWdLamEYdkwVAyYyNEuwCTUqJfIjcSuDaU9J6/dim229bfYXCGvWZ3
         8VFa3O7S041z96LGvPySbUY0szPwdx7xjOeCCR/eFWHat2zjE3F1ihXuuGd7b5BX/9jp
         g2H+Bc6Bb8pTG2rbzMcq+hO9YY6QV7KidJ8qK5pjLDs+3jHXfOX1nhSZKUoF+obAUOI0
         9nRN8MQlKy99gUevkyZXiy5vrCd96MQ188NjHgCAmTiEOZy09Elb+HMo7SX5v+2yWSUt
         FvGWvzF8lVffMAjGOPwo6cR45W1E3j5ojUbYbDWgm/P/JmwRkWnvz+CaIv/dTc6mKn02
         v19g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=To6XGK9f;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id u14si198900ior.49.2019.03.28.15.06.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 15:06:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=To6XGK9f;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2SLxmSs060297;
	Thu, 28 Mar 2019 22:05:51 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : mime-version : content-transfer-encoding;
 s=corp-2018-07-02; bh=efE+EqaifQWItnvqE5oHeBNSdF1slMZgpYXIiFbimNM=;
 b=To6XGK9fJKj9anhLwIkXsfVRTrO/rnl4b0e+jPhZakXVEEA9S4AhLDGLZD5Xl84ZVUrt
 fL4og7Mm4DjgLZoh7vDk7l/tR4AaCopqJmt7s2N9QBiR8e24wGvEN2zFT2yTsKU13/83
 94sdE6jFdDRK7tgzJCwy5yh5K4k8c3f/mhN7dwEQyGvYhTLikvR+gj10atYNRNXtwxvh
 GPFiWWagnMdp0WxDNq5fl9CDiXbOeTag9K8MKla6jjR2JFt5MEMfUSlP26cznvn4+ZpD
 ndfAExKYHUaW30O8Nnsfaqb76jPbfZxy+gvPC/nWGydJWVhTKuDQAJ8FmB6CQaMGhfO0 yA== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2120.oracle.com with ESMTP id 2re6djsc20-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Mar 2019 22:05:51 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x2SM5nqo006298
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Mar 2019 22:05:50 GMT
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x2SM5jwF009891;
	Thu, 28 Mar 2019 22:05:45 GMT
Received: from monkey.oracle.com (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 28 Mar 2019 15:05:45 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>, David Rientjes <rientjes@google.com>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        Alex Ghiti <alex@ghiti.fr>, Mike Kravetz <mike.kravetz@oracle.com>,
        Jing Xiangfeng <jingxiangfeng@huawei.com>
Subject: [PATCH REBASED] hugetlbfs: fix potential over/underflow setting node specific nr_hugepages
Date: Thu, 28 Mar 2019 15:05:33 -0700
Message-Id: <20190328220533.19884-1-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9209 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903280142
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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
This was sent upstream during 5.1 merge window, but dropped as it was
based on an earlier version of Alex Ghiti's patch which was dropped.
Now rebased on top of Alex Ghiti's "[PATCH v8 0/4] Fix free/allocation
of runtime gigantic pages" series which was just added to mmotm.

 mm/hugetlb.c | 41 ++++++++++++++++++++++++++++++++++-------
 1 file changed, 34 insertions(+), 7 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index f3e84c1bef11..f79ae4e42159 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2287,13 +2287,33 @@ static int adjust_pool_surplus(struct hstate *h, nodemask_t *nodes_allowed,
 }
 
 #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
-static int set_max_huge_pages(struct hstate *h, unsigned long count,
+static int set_max_huge_pages(struct hstate *h, unsigned long count, int nid,
 			      nodemask_t *nodes_allowed)
 {
 	unsigned long min_count, ret;
 
 	spin_lock(&hugetlb_lock);
 
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
 	 * Gigantic pages runtime allocation depend on the capability for large
 	 * page range allocation.
@@ -2445,15 +2465,22 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
 		}
 	} else if (nodes_allowed) {
 		/*
-		 * per node hstate attribute: adjust count to global,
-		 * but restrict alloc/free to the specified node.
+		 * Node specific request.  count adjustment happens in
+		 * set_max_huge_pages() after acquiring hugetlb_lock.
 		 */
-		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
 		init_nodemask_of_node(nodes_allowed, nid);
-	} else
-		nodes_allowed = &node_states[N_MEMORY];
+	} else {
+		/*
+		 * Node specific request, but we could not allocate the few
+		 * words required for a node mask.  We are unlikely to hit
+		 * this condition.  Since we can not pass down the appropriate
+		 * node mask, just return ENOMEM.
+		 */
+		err = -ENOMEM;
+		goto out;
+	}
 
-	err = set_max_huge_pages(h, count, nodes_allowed);
+	err = set_max_huge_pages(h, count, nid, nodes_allowed);
 
 out:
 	if (nodes_allowed != &node_states[N_MEMORY])
-- 
2.20.1

