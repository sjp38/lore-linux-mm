Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4ADBCC43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 21:31:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2A3020857
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 21:31:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="oNwLk9sR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2A3020857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D6766B0007; Mon,  1 Apr 2019 17:31:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4864B6B0008; Mon,  1 Apr 2019 17:31:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 34E746B000A; Mon,  1 Apr 2019 17:31:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1659C6B0007
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 17:31:25 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id t22so11443870qtc.13
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 14:31:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=EbYr2VB3q/CFREIQcUxEif5TEH9f2sysNHlXOiwwz74=;
        b=iRxhfxi7b2+p2y5ka4ZKtLqo8VvnRVsSqEWHyQhKuzlyNASCbD3jwv/ACDo4oF1VAp
         1INGQPVYe9SEWMmKjVK5JQanQQjyEKlnFmcL34lJ0zNwBykgoOmME0r/Y78D9fGTSn0w
         6lM+fkPx0xhWwkQNTMyF82dJMRMLrD5uUHN+/OH6AtOwXycdga0QHI9T2NMjP0LpmM0C
         LNmeaDRCiY5dBGMZaq6rz+Z3lxmdIcDf7oLqn/8wrJNMBhlFSUTlGUj6AY6+k2afbEi3
         0gvxARo3nnXuV1niyycExlE2jIShuXHpV4jsmC92DjGM1LkKfY56ZqLhaWra3ws0guXX
         tQtQ==
X-Gm-Message-State: APjAAAXGpVshxUkGzHxFVmqdjU7o/vEA7q3ePzrHOGCgNMH4dkHxSthc
	d6Ky7lVeADRegmUEZw+e9tHxqf0ktY8ytIV/zGxloI9bC0Yf8ktME5iPPUK5ERy5xn2Pu/3KDZL
	yd4zyD7QbcOhkcYPnbZWaibs7ag9Dk6bRnd3BITRxTkEpUMrcRqy2HxudW98aTLzebA==
X-Received: by 2002:ac8:2850:: with SMTP id 16mr55885550qtr.84.1554154284820;
        Mon, 01 Apr 2019 14:31:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxok8YCd/OzJDtHypn1lM7TuM2I9tg4NMvdSA40bH2KP5/8GYohj9OhL7oN94O9I6t20h9Q
X-Received: by 2002:ac8:2850:: with SMTP id 16mr55885505qtr.84.1554154284170;
        Mon, 01 Apr 2019 14:31:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554154284; cv=none;
        d=google.com; s=arc-20160816;
        b=RNtm/tpbnnO2N5eoNDCnYYFNzmkH5v9FPN+YsXyzqDKbv8NPjNBqOjOVcfFS5va2qE
         BAv4GOxRYMeFvFs1xAJmhSlrA3TrKFZXZZ0/Vflt5rGG2z2ThzYlBVd3s1LJIRWtPOTz
         +leHSy2TNGDi64RgJ78OzwVR7Rcrp/lmhPXF47kFL7Nz/joFTr2OqVEj9yhaVXOaClUx
         xlvOictfOYQrhHgGvDH6xu7T+gYpcqcQUmu2E5xM2djzVJUjd0UJkQ+AF4qgMGiuUzhM
         ca3JxReDkannuh6rPcmpGKn5sqNcjx8clQ8gle0fSzsqRShnV2rBvXGFAKZg+eFAAUnJ
         iFrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=EbYr2VB3q/CFREIQcUxEif5TEH9f2sysNHlXOiwwz74=;
        b=Nduzjk7M9JYtpSuiFt9pS6GydKTWkBwlLLy0NARZpCq7Nb+YM5qEHm4FI6iQ0JSugY
         G0tSFNFuU3RB0utDMwL7Humrz98cSVwPUq2zkOloNANmiW9uTTs6xNa07jph/LssGQyo
         r9HMBKGWUEgbi2Frx4IiRgB4U9wHUs6jI3t4TCq5uvGqdc3u8FfnK6ltUidMnDu8FyGH
         rKgIxNMmhw3Pwb40VsVJDxTSxBWBvnI13OhnUhcD2ql6ylkgqpekdw3oDX3TCliQrn7V
         S9Zk1PbOucuphaXAOGhBehn5Keqo2fGA48BPJdIQduizDXn1UqJ+4aqk24/FESkke8zs
         pmWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=oNwLk9sR;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id a66si86403qkg.30.2019.04.01.14.31.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 14:31:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=oNwLk9sR;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x31LIuRf154127;
	Mon, 1 Apr 2019 21:31:14 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : mime-version : content-transfer-encoding;
 s=corp-2018-07-02; bh=EbYr2VB3q/CFREIQcUxEif5TEH9f2sysNHlXOiwwz74=;
 b=oNwLk9sRYRY6gClhVknBNfn4Q081+Tpy1a20fIGmHjilL6VBqsXk82zmNnlFSQ71c+oZ
 w6oAgE3P/z0Bk445adOQMsC4hDyCPaC5Rmw48LANvu07GEtbUEn6/NpQkiFnhLQsIRkt
 1uRIp/YwMzr28uSBAHlEvniHfjS8YGV6xXr7H+nZKIScX0MiioWePPo1hJFPik3h8AoG
 2lRTNgeXP5DLCKzZzugc7TkVerChshNbU8OabjU0zRtcAqrWT/YBqNiE33JTTI3KNUxw
 ICD7+o1BDqNtxeVcJqtV2Wpsiq/LoqncGmetUY8rufYhi+7biOOxhLGn4iNXvf0NENWA /Q== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2rj13q1ga0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 01 Apr 2019 21:31:14 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x31LVCtu022130
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 1 Apr 2019 21:31:13 GMT
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x31LVAQg023174;
	Mon, 1 Apr 2019 21:31:11 GMT
Received: from monkey.oracle.com (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 01 Apr 2019 14:31:10 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        Yufen Yu <yuyufen@huawei.com>
Cc: Michal Hocko <mhocko@kernel.org>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH] hugetlbfs: fix memory leak for resv_map
Date: Mon,  1 Apr 2019 14:31:01 -0700
Message-Id: <20190401213101.16476-1-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9214 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=849 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904010138
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When mknod is used to create a block special file in hugetlbfs, it will
allocate an inode and kmalloc a 'struct resv_map' via resv_map_alloc().
inode->i_mapping->private_data will point the newly allocated resv_map.
However, when the device special file is opened bd_acquire() will
set i_mapping as bd_inode->imapping.  Thus the pointer to the allocated
resv_map is lost and the structure is leaked.

Programs to reproduce:
        mount -t hugetlbfs nodev hugetlbfs
        mknod hugetlbfs/dev b 0 0
        exec 30<> hugetlbfs/dev
        umount hugetlbfs/

resv_map structures are only needed for inodes which can have associated
page allocations.  To fix the leak, only allocate resv_map for those
inodes which could possibly be associated with page allocations.

Reported-by: Yufen Yu <yuyufen@huawei.com>
Suggested-by: Yufen Yu <yuyufen@huawei.com>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 6189ba80b57b..f76e44d1aa54 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -752,11 +752,17 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 					umode_t mode, dev_t dev)
 {
 	struct inode *inode;
-	struct resv_map *resv_map;
+	struct resv_map *resv_map = NULL;
 
-	resv_map = resv_map_alloc();
-	if (!resv_map)
-		return NULL;
+	/*
+	 * Reserve maps are only needed for inodes that can have associated
+	 * page allocations.
+	 */
+	if (S_ISREG(mode) || S_ISLNK(mode)) {
+		resv_map = resv_map_alloc();
+		if (!resv_map)
+			return NULL;
+	}
 
 	inode = new_inode(sb);
 	if (inode) {
@@ -791,8 +797,10 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 			break;
 		}
 		lockdep_annotate_inode_mutex_key(inode);
-	} else
-		kref_put(&resv_map->refs, resv_map_release);
+	} else {
+		if (resv_map)
+			kref_put(&resv_map->refs, resv_map_release);
+	}
 
 	return inode;
 }
-- 
2.20.1

