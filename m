Return-Path: <SRS0=rDiK=SJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDC49C10F0E
	for <linux-mm@archiver.kernel.org>; Sun,  7 Apr 2019 20:27:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 725CE20880
	for <linux-mm@archiver.kernel.org>; Sun,  7 Apr 2019 20:27:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Bf+U77Rr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 725CE20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24A6F6B0007; Sun,  7 Apr 2019 16:27:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FB1C6B0008; Sun,  7 Apr 2019 16:27:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C4126B000A; Sun,  7 Apr 2019 16:27:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id BEA226B0007
	for <linux-mm@kvack.org>; Sun,  7 Apr 2019 16:27:26 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id n23so8393297plp.23
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 13:27:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=8Z5m1t1XYo17k81EeuKWtqQr0sJBxzEuI/QLbKGy0SI=;
        b=lDAYltWFStZHo0ph43QE7ff6dE75sPJZM9xRGp8frto0BV50DlzTZA4sDE7agXwILy
         2XJDx+on/Nstcf6hR05Bh1grAEdCxUf/86QD1eWbznmv7U1GsfdOZL/OZVvFRAP+VOHG
         GDaA6fKXcxnWFkQ4JmsU5Ylf5edsYGsuDo+6zNX485b2C5x4MeDahJiU2Glqy43yBVpS
         O6xr+ZuRaO4PhP7bKPhSZO1Kuwh/qI1mF5isequg625Aamn8Fb+iOtKHe12rd2qs6zVd
         ai/2je4LllVST61LYeZeBLRQywYEphGv2WJLtte0MwSLR+PDWFCjuAvl81lMcAdB6dM7
         DVDQ==
X-Gm-Message-State: APjAAAUpDm9+Y1Z8eQFecVYbCDJlRole/9AeCmBD82HKryjanxn/hh+A
	2kEZ+F8/JDlrJAqpNF7gcVk/KyM5AgNY/AHiQYstyj7CgiqbltVjeQ/nitxDiaYnpjFp2TqbQXW
	BhO9WPW+vXUKSCzXgRbfhjNsnbymeQzgl6b33PVCpuN30KNouYjey3pN9xnNf90raHA==
X-Received: by 2002:a17:902:d701:: with SMTP id w1mr26742118ply.124.1554668846379;
        Sun, 07 Apr 2019 13:27:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxeGeeMuid3LL+BgIDRNE/A+dFMiIv8zyVFcqFmYrwGud9paT40qtp1bOZW7jCuJfw6v8LO
X-Received: by 2002:a17:902:d701:: with SMTP id w1mr26742085ply.124.1554668845778;
        Sun, 07 Apr 2019 13:27:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554668845; cv=none;
        d=google.com; s=arc-20160816;
        b=v8r893AEkXPNL8MDo5GEc0pQrlDldqGMIfxLetsUE2bVZ3R2jL/opN+g9v3EyCWdTz
         YzNc6yXzhd7aRhGdHWgWGaDxnk9bpC3pFkxUpHL2Z4TCsbdBxu36iOPQjiGJbKB5EHq0
         vCmj2ePws7dykSahdSwGAFmv+xs3lCK+XXyWbhSjJxWtMPRmYObv6JrbUCyg+Ul0OrOT
         zX2WO8twwKtbk+E4PB0eEifOFzld8n32o4nVnEbblw83HsSvX98k/U0fSVwUCPdXddwj
         WnQ0RSeyfy0OB58ZGAqdgZr1Mu9WY3AwJdEH/LZo+ts0YEI4JNyx3n0QrRlI4sMoN64Y
         VTHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=8Z5m1t1XYo17k81EeuKWtqQr0sJBxzEuI/QLbKGy0SI=;
        b=HvEKl9IFFXnsW7rWEd6GlXVrDrOkJaAf7dEmzAUhzTAi1pXyW6gML8rqrfHwTYfCGM
         KCYxq1Gjl6VzNaooN76q7UICXc/DXDAMRr69KlobBJLnxgOuUbwJ+H1kVJY3X7EC4aJg
         9EU7FrvnN7Wqj4sXGjesORE4tara2w+h7pVk9tdPBStspyQMwbVF/AolYH5SLpF2frR5
         7GfwuMuiC0mvXs5jR7x6YQGKDwmELOe7XOqqakGqXAfdXcG2CrJA+KRB9Q8vK1zlS5FS
         SCmKB3RJup8DS9wnZB+KZ45yduNIfD8klLGZm7RoERPMfOj13Dt3ZcR/tjv6XqhWuobZ
         voEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Bf+U77Rr;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id g31si9064462plg.154.2019.04.07.13.27.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Apr 2019 13:27:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Bf+U77Rr;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x37KJAPu068364;
	Sun, 7 Apr 2019 20:27:24 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=8Z5m1t1XYo17k81EeuKWtqQr0sJBxzEuI/QLbKGy0SI=;
 b=Bf+U77RrhMcfTj1v1gaW3yOQVeLbEwkx+IqYrvDZSHA4XvFsHoVdzDQp1UJmGyYGl1NY
 nLmP2BJmYhQ+lLH/nQ4fJGT5knqbikx5g72pw8AfspalqslfMMd+EyB1qTEXgHUtZpvm
 pwcVuKpb4P0r25JdLmQfPxNFhFqQXAyaHml+q2pWD5UPO8SPBRLfcaEUDXqOxHQAMOTs
 VFadZXcrryQADXtYye8y12fGrQgz9yCanT8vW5eNfdCu3nroDUxu9oR7JBBT8TxSceVc
 n/PO+0jiArYAl3Q7QA/0NTDttRHUGrR1eUS80qh8BkUZbNCK9FDSqJX08JYUdsr85KVZ Xw== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2130.oracle.com with ESMTP id 2rphme3be2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 07 Apr 2019 20:27:24 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x37KPpp5193773;
	Sun, 7 Apr 2019 20:27:24 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3020.oracle.com with ESMTP id 2rpkehduqn-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 07 Apr 2019 20:27:23 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x37KRMgr027225;
	Sun, 7 Apr 2019 20:27:23 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Sun, 07 Apr 2019 13:27:22 -0700
Subject: [PATCH 2/4] xfs: unlock inode when xfs_ioctl_setattr_get_trans
 can't get transaction
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: darrick.wong@oracle.com
Cc: david@fromorbit.com, linux-xfs@vger.kernel.org, linux-mm@kvack.org,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Date: Sun, 07 Apr 2019 13:27:16 -0700
Message-ID: <155466883603.633834.5683596746694707981.stgit@magnolia>
In-Reply-To: <155466882175.633834.15261194784129614735.stgit@magnolia>
References: <155466882175.633834.15261194784129614735.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9220 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=1 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=911
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904070193
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9220 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=938 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904070193
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Darrick J. Wong <darrick.wong@oracle.com>

We passed an inode into xfs_ioctl_setattr_get_trans with join_flags
indicating which locks are held on that inode.  If we can't allocate a
transaction then we need to unlock the inode before we bail out.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/xfs/xfs_ioctl.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)


diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index 6ecdbb3af7de..91938c4f3c67 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -1142,7 +1142,7 @@ xfs_ioctl_setattr_get_trans(
 
 	error = xfs_trans_alloc(mp, &M_RES(mp)->tr_ichange, 0, 0, 0, &tp);
 	if (error)
-		return ERR_PTR(error);
+		goto out_unlock;
 
 	xfs_ilock(ip, XFS_ILOCK_EXCL);
 	xfs_trans_ijoin(tp, ip, XFS_ILOCK_EXCL | join_flags);

