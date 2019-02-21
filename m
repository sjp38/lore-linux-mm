Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3130BC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:15:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFDE92077B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:15:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="iX4Jfbx4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFDE92077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 819F98E00C0; Thu, 21 Feb 2019 18:15:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C9C78E00B5; Thu, 21 Feb 2019 18:15:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B9808E00C0; Thu, 21 Feb 2019 18:15:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 255408E00B5
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:15:37 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id y2so262611plr.8
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:15:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=nVKe44f2CLyy8KwCGeAW+5vhPvxVUYCV7yyDYL/xjV8=;
        b=Tyen+DPWmOAT5RG2NbYJ+KQsAen+dkvqx1yAl+LqWd7/Awpa6KqqSVBzu7YkBH0ksx
         88ySQRhFmeMkiFywGW3t0VMRrHDAs1nHshxnZ8g4DZuBMOejarwPvLOizcnXOKG0+DE0
         cuBVyBtuHM2eRVBbWvEaqVZE6aldVEGu9NbpGyPL2ncwa7XeuXcfElhYDwWDdTZuJdY3
         ruJVKRH9X5yQF0RAzNktvelmYZ/lJ4BkhRSkWa6DzdAGEW2QtXKw2g8+daHI7oQdoNx4
         d3naT4vvnc14SUrjPz3gCI1j1HdfgmfRfRWC4mRiEg7qRVg2VXIXwfBirqs0AhH/xDcC
         1XAw==
X-Gm-Message-State: AHQUAuZXlV/fRdSuJwRNVGTEqB/TNy2feRgKMBQc7fW5dvNQGxoVUhGi
	hdoy3zn3DjI/WVvAoOQswvHSIs0w1Rb39iAkucH/9CPYKSy11CdYS8A1sHUi/qb6RJJ6gVDQJXG
	gX7K2raQySrmciSthArV8/EuZS4oCzznNI5PGdazd0pXTr9rdUwVDM7eR65kxvj5+Zg==
X-Received: by 2002:a63:4652:: with SMTP id v18mr936657pgk.356.1550790936639;
        Thu, 21 Feb 2019 15:15:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYnAtXIEmn/mA5Vs+TxedX6vyiyytO+dP5qnWQ7r74Ekbr9swktnR+NHvN9fdwM7Xp4y/uQ
X-Received: by 2002:a63:4652:: with SMTP id v18mr936611pgk.356.1550790935967;
        Thu, 21 Feb 2019 15:15:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550790935; cv=none;
        d=google.com; s=arc-20160816;
        b=pE1EUEvx0k2q094SMJSgQTyLEEk9eA92iwIA5ODR12VxUt+C2qeONNSHJEESAgnXDV
         RwVbAVVhqsnCt6Lt3A5Rb/cnSts7JSMk6QSQE9CSjCW3tKgCAshEEz7ShbsGSjR5EpNa
         Ju5X70jwhVTMywoOYyQfQ41puIuImt9erem40cnmKfFok92SDcY92WL5tYEDegPW4mkA
         TwOORTljj4sgsTi6PeAoRabQBBSyS4RKvnZ18jC7eohuS767dt1fFjdxXrLoAVuS5gUU
         uR6EQ8TclydzRYCkVldidwls0L65Bx1ynifR8UlF/lkFGmpLRHZxhofhaK0Z8Mx9bJqZ
         r++w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=nVKe44f2CLyy8KwCGeAW+5vhPvxVUYCV7yyDYL/xjV8=;
        b=DXcl0PWtALUHOcJYkYld4Hdc95E6mFCgOFNySFjjXwevy6E9P6cjOFhBmkfFCLyoF6
         PFAmvXSBJOhymDsr3EO266uTYMzBT/Hcebho1IOeeLfjwp2d0wVgxbkVAwwFcYkbTM3C
         hvkjw+gvMF5z3QJOBQnERW6C23N+mKhpY7eRmZfdABsq8CetbGD22S3gjaKnN+jKmiKN
         3A+K4Ws0va0NwloESfU7OwWzuPL0UKwFKascakLk5ar7a+5iXVnaJUQ3PMqNfdmU5cLA
         RYbkimbRkNYBY42JCUNA4fHBUZeYRTja1ZwwxkI639F901Z+VbpYVc96mSzXMoAGRlHh
         EheQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=iX4Jfbx4;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id i39si152108plb.256.2019.02.21.15.15.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 15:15:35 -0800 (PST)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=iX4Jfbx4;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1LMJ0R4018055;
	Thu, 21 Feb 2019 22:21:27 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : mime-version : content-type; s=corp-2018-07-02;
 bh=nVKe44f2CLyy8KwCGeAW+5vhPvxVUYCV7yyDYL/xjV8=;
 b=iX4Jfbx4mvEtjGSFBt0o018sKkwjWE2E9ISK1CPIL2JPIMYJ5YDLvhdEBjlJ+YiXxqwb
 0gUwpKYVGv/q1SXUxYKDjWmsXn7FhDgdJ3/ACkoMDMEZ3NvZYUb2ltyDrd3R5RlfhHdt
 +SZrJwzAhaz0W/fT9Wb3RQrSzTKl8Pm9sxTUi1BKBVozHGZyKMD57dO3FwBwXWS7Yvqu
 tsTPj2CAO0HELevCKd/4gEM49QC9qyssQ6q1sPQcUqP4WxBc/7o+9488rLlgwrr2JQ5S
 aUlI2ul4eU3dqyZm+IjXsYQGKZa6rmmjN0ubUXIlwqUQe9KEgRI37iM0bhyL9ioCJA7k Ww== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2130.oracle.com with ESMTP id 2qp81ekbn0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 21 Feb 2019 22:21:26 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1LMLPwQ018408
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 21 Feb 2019 22:21:25 GMT
Received: from abhmp0020.oracle.com (abhmp0020.oracle.com [141.146.116.26])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1LMLPCf010939;
	Thu, 21 Feb 2019 22:21:25 GMT
Received: from localhost (/10.145.178.102)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 21 Feb 2019 14:21:25 -0800
Date: Thu, 21 Feb 2019 14:21:24 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Matej Kupljen <matej.kupljen@gmail.com>, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: [PATCH] tmpfs: fix uninitialized return value in shmem_link
Message-ID: <20190221222123.GC6474@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9174 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902210152
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Darrick J. Wong <darrick.wong@oracle.com>

When we made the shmem_reserve_inode call in shmem_link conditional, we
forgot to update the declaration for ret so that it always has a known
value.  Dan Carpenter pointed out this deficiency in the original patch.

Fixes: "tmpfs: fix link accounting when a tmpfile is linked in"
Reported-by: dan.carpenter@oracle.com
Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 mm/shmem.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 0905215fb016..2c012eee133d 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2848,7 +2848,7 @@ static int shmem_create(struct inode *dir, struct dentry *dentry, umode_t mode,
 static int shmem_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
 {
 	struct inode *inode = d_inode(old_dentry);
-	int ret;
+	int ret = 0;
 
 	/*
 	 * No ordinary (disk based) filesystem counts links as inodes;

