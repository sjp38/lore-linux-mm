Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA5C7C282E3
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 20:45:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 56B552171F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 20:45:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="DEmWHlp7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56B552171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC9446B0003; Fri, 19 Apr 2019 16:45:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E78EA6B0006; Fri, 19 Apr 2019 16:45:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D409C6B0007; Fri, 19 Apr 2019 16:45:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id B2A026B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 16:45:03 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id a75so4871396ywh.8
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 13:45:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BJcecETyWVwvoyBv1O0IswXJSKKY/HvHD+pqeK7LFps=;
        b=nNh8GrDmdAanRo5lPgTGV9/0GDDP5stK7x3npOf4hJjZKtL4hNxw46C2nlMmDKvB2O
         MthK2XC0CBZQT15DOYws9kERuh5H4c7prh8gLqqe0wyYORA24Bn9IM/pldCd0ypaOvdZ
         WGqH+JE4ay9q/pFpsGAz668evC0eUFtkftxBuyDe8eAkihu9r6r4IOxdr74S+tdZqpjn
         DMm6OlTJYQ9zqoJ++jajSiwh+W7IDIGFtXJ0BYlp1Ir7CLtjCqocevytM0i9f1FZ7S4Q
         RK6hn7Uw45EJdDxA5CvdE/3mvDMe2p8OvEKf1C0AECAL6VRQXDZkAV6vzjW4N19yZj+7
         rIzw==
X-Gm-Message-State: APjAAAWufa0TvLtE48JPU0M7VoPe8bcHFNaYpKdMaWbIjX+Ym/x0ftIa
	9P/q+XfJAx/fO8ujU1VjXpLwA4bCpAajZQvtSVx3K1GoV27oh36WSg1QEpp+1wgE2aW9AZ/JdVt
	KvTZ/zP5C1YEB6WGZxfYB8uLy4pAwKTBcKdBY0bWTE/R7py3tAuIV1Y3mcaQjCWMv2A==
X-Received: by 2002:a5b:987:: with SMTP id c7mr4904603ybq.499.1555706703312;
        Fri, 19 Apr 2019 13:45:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzPKAkReKWX1WhPaFnPq+gXpoxFIUiHQPMnzAAFSARPGIWOJz1WvAwTxrrX8xFl31miTXoM
X-Received: by 2002:a5b:987:: with SMTP id c7mr4904567ybq.499.1555706702480;
        Fri, 19 Apr 2019 13:45:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555706702; cv=none;
        d=google.com; s=arc-20160816;
        b=CB8Yhyv3SDUD5jxlBgUK6elr7EAncga7snS976Kgau1UXH/6ux4BvMXGq1vHJu7Ce9
         1vrcMv+hu4hWW5HUA/sEQ4wXdyinHnhiwh7cnX5Qkp/8biAgswjgwfoFHsu/MLV9vvsz
         q+/H+7CXJbpQsKpcL9NEXu8+cBALxJ5NE5tMTe2hsUmtO/LQqaDW5IDTI8oiyXdtwkw7
         9JWVkA4hDWsr971Q/splNEoFFtt/X2evUt89ELhgVM+dEd5aEPm/0ghf7bxYVM2CN8gp
         bH3+d+u48/yMFLetMiDBz+dT+q28xOyqFKgW7gc4xc+9nBnMcGN5i3WPFHrRowFHjm1Y
         zyVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=BJcecETyWVwvoyBv1O0IswXJSKKY/HvHD+pqeK7LFps=;
        b=U0lny7MzisJW3NzJgl1uYVa9z5ont9p1AcHtFMSXOogoaJeocfOBXo+XNXt1w7gWQi
         hwFs3yt0c8yMRn2C58Bv/bHcqrmvxdg6NtPkexJ6z8wlZeDTbFB3htcSfSYmsCuVDsAa
         W9WY+5PpLh/64pFmVCmyrX3Jgw0lU73xQXuGu6TcOiHaxlTFcVqFvtWZTM42vE2uO+4I
         w7fFkstnHzJkg7xsGwiAnmchP0B+nDKnETlTa/S3UX5DLnr8oQOUzCU9lqRh3hvtHt41
         nIho15n375IJYZ9EI0Js+vgoBvE34cnM/KiMjq+T2cePXtrg6LcBEUAoXGaMmJ6axTnC
         MjXg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=DEmWHlp7;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id i123si4112185ywa.262.2019.04.19.13.45.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 13:45:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=DEmWHlp7;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3JKTWBG074720;
	Fri, 19 Apr 2019 20:44:51 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=BJcecETyWVwvoyBv1O0IswXJSKKY/HvHD+pqeK7LFps=;
 b=DEmWHlp7j5aTkReUuQQWWaDlzVEfhwDetyaTRFpeUIPBcAu0R1PfmxYucGICW2b+c3Zv
 oXpGnk/NZCl0hosTnVJMJ/yILwLI5FM6Ot3CA6AH7X7X1rOxmglaj3cb2+xebVgKbtdo
 2kHfZqaD0IlKimkioWtk39Ig58OszBMyuDzuevRoclNFV5tqAetqSjni3T7nmxLZsBZz
 3l/JQlXepe8IClPvVzjEGJn0/aMG6daNRBbX0oIDbPeD00FGwBj4Ih1XhZtorrEBJNyZ
 14rII8Cj8tDo4B2vFQZiqRqq3IRh2UsqDV67Bj/S610KGzGGmVFHJ1r/h8mwqzoJhbMc bw== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2130.oracle.com with ESMTP id 2ryjv90he2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 19 Apr 2019 20:44:51 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3JKiXmI084931;
	Fri, 19 Apr 2019 20:44:51 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3020.oracle.com with ESMTP id 2ryjus24xn-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 19 Apr 2019 20:44:51 +0000
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x3JKimZi030778;
	Fri, 19 Apr 2019 20:44:49 GMT
Received: from monkey.oracle.com (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 19 Apr 2019 13:44:48 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        Yufen Yu <yuyufen@huawei.com>
Cc: Michal Hocko <mhocko@kernel.org>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH] hugetlbfs: always use address space in inode for resv_map pointer
Date: Fri, 19 Apr 2019 13:44:35 -0700
Message-Id: <20190419204435.16984-1-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190416065058.GB11561@dhcp22.suse.cz>
References: <20190416065058.GB11561@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9232 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904190143
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9232 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904190143
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Continuing discussion about commit 58b6e5e8f1ad ("hugetlbfs: fix memory
leak for resv_map") brought up the issue that inode->i_mapping may not
point to the address space embedded within the inode at inode eviction
time.  The hugetlbfs truncate routine handles this by explicitly using
inode->i_data.  However, code cleaning up the resv_map will still use
the address space pointed to by inode->i_mapping.  Luckily, private_data
is NULL for address spaces in all such cases today but, there is no
guarantee this will continue.

Change all hugetlbfs code getting a resv_map pointer to explicitly get
it from the address space embedded within the inode.  In addition, add
more comments in the code to indicate why this is being done.

Reported-by: Yufen Yu <yuyufen@huawei.com>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c | 11 +++++++++--
 mm/hugetlb.c         | 19 ++++++++++++++++++-
 2 files changed, 27 insertions(+), 3 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 9285dd4f4b1c..cbc649cd1722 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -499,8 +499,15 @@ static void hugetlbfs_evict_inode(struct inode *inode)
 	struct resv_map *resv_map;
 
 	remove_inode_hugepages(inode, 0, LLONG_MAX);
-	resv_map = (struct resv_map *)inode->i_mapping->private_data;
-	/* root inode doesn't have the resv_map, so we should check it */
+
+	/*
+	 * Get the resv_map from the address space embedded in the inode.
+	 * This is the address space which points to any resv_map allocated
+	 * at inode creation time.  If this is a device special inode,
+	 * i_mapping may not point to the original address space.
+	 */
+	resv_map = (struct resv_map *)(&inode->i_data)->private_data;
+	/* Only regular and link inodes have associated reserve maps */
 	if (resv_map)
 		resv_map_release(&resv_map->refs);
 	clear_inode(inode);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 6cdc7b2d9100..b30e97b0ef37 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -740,7 +740,15 @@ void resv_map_release(struct kref *ref)
 
 static inline struct resv_map *inode_resv_map(struct inode *inode)
 {
-	return inode->i_mapping->private_data;
+	/*
+	 * At inode evict time, i_mapping may not point to the original
+	 * address space within the inode.  This original address space
+	 * contains the pointer to the resv_map.  So, always use the
+	 * address space embedded within the inode.
+	 * The VERY common case is inode->mapping == &inode->i_data but,
+	 * this may not be true for device special inodes.
+	 */
+	return (struct resv_map *)(&inode->i_data)->private_data;
 }
 
 static struct resv_map *vma_resv_map(struct vm_area_struct *vma)
@@ -4477,6 +4485,11 @@ int hugetlb_reserve_pages(struct inode *inode,
 	 * called to make the mapping read-write. Assume !vma is a shm mapping
 	 */
 	if (!vma || vma->vm_flags & VM_MAYSHARE) {
+		/*
+		 * resv_map can not be NULL as hugetlb_reserve_pages is only
+		 * called for inodes for which resv_maps were created (see
+		 * hugetlbfs_get_inode).
+		 */
 		resv_map = inode_resv_map(inode);
 
 		chg = region_chg(resv_map, from, to);
@@ -4568,6 +4581,10 @@ long hugetlb_unreserve_pages(struct inode *inode, long start, long end,
 	struct hugepage_subpool *spool = subpool_inode(inode);
 	long gbl_reserve;
 
+	/*
+	 * Since this routine can be called in the evict inode path for all
+	 * hugetlbfs inodes, resv_map could be NULL.
+	 */
 	if (resv_map) {
 		chg = region_del(resv_map, start, end);
 		/*
-- 
2.20.1

