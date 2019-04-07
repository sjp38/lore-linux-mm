Return-Path: <SRS0=rDiK=SJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E13F3C10F0E
	for <linux-mm@archiver.kernel.org>; Sun,  7 Apr 2019 20:27:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85F4A20880
	for <linux-mm@archiver.kernel.org>; Sun,  7 Apr 2019 20:27:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="FqmdE+7E"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85F4A20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 35ED26B000A; Sun,  7 Apr 2019 16:27:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 30C076B000C; Sun,  7 Apr 2019 16:27:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1FCD16B000E; Sun,  7 Apr 2019 16:27:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id D947B6B000A
	for <linux-mm@kvack.org>; Sun,  7 Apr 2019 16:27:40 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id m35so5713960pgl.6
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 13:27:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Kv3ME1CHuNV3vr0SQcA7uFv9ps91/aQadFGc+0Oqa8Q=;
        b=HkYIYX9/Dv7N/Bj3tuj25md4Ye4YHoCTjbw9fKzGiy7gi7he0Ig8qKxDQ1hrO2YM6r
         wTHq08mj313A1WmYTOjs2e2xN71sPNd1j9nG07f8KOrGry11w1wrZ4VUJqbrqKfgOD1B
         mHlRGKAMh5lPunTJA1Pms/WWR5o7ly8il4Ws1cxLnImWn30ZpErgyFsWwVX33HiIWb06
         svgDaoEI+m4wj8oH3Ok5HsL3x3jGyBlpWJeKBitjhMrGswd+zrUv5qgDW8tt9/ziYrPH
         5djButMyI+xffqF+NuHk+3yXExHGIGwX8uTow9MraZg8dS3PUbiZjU+n2/naaDZeESIq
         8pOA==
X-Gm-Message-State: APjAAAU4z5dc+IKvcr1FkFKVlTO7QZbl8KCt63kgAL3sxHAot1CN8ida
	jwh+Z6prYdJUiFWpUu/env0pA7FjguhDxkWHLtAjs2Noz3ZVVDdgcUWL3wt8qd0jOjJOCbunS8p
	Jddszc7tDeP39nXUEdW4f6An8jdMxMtLAbFctKCtga0tkD6GAblcnlS1yDYo8ENV4Sw==
X-Received: by 2002:aa7:91d5:: with SMTP id z21mr25745838pfa.222.1554668860438;
        Sun, 07 Apr 2019 13:27:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyY3JXs9h0l/S2PNpWUK+0KqcCmFMhNIK2wlP352waedzLBCT4NcsPoaIZT5j/RggAfaKTd
X-Received: by 2002:aa7:91d5:: with SMTP id z21mr25745801pfa.222.1554668859799;
        Sun, 07 Apr 2019 13:27:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554668859; cv=none;
        d=google.com; s=arc-20160816;
        b=dBB+oAz3Wt7H0RNsGZJC2Hy2oZnHqYR2Zv1PMQja2m2PHOq65JdoGS8n4ynrlUur5z
         euW3tiA6PPfJ5lM4YiQKjY+HDwuS5bUlTgvRNAvG4Y14DgNp4oxFMuRYB/kFagGhcZZ7
         Q5yt9qaTcbJ+ERXDjQ7gZRrVnNxPiZLYbvlTVXXxTkszM0HOD1l5ej/8aLw6jdPYhZ5w
         7fD8qEUNA+r/hKzltz8YvLy+kuoHjQ6rx62nz8u/ws78ukyuOueYLk6Npeh0j6EcxYfe
         zUMH0FHgdk/fCIVHxsdyx84BzzZI81yarjW1mBPkJHzJt6ueArD0G8Y0N1Za66qzl0CB
         Znlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=Kv3ME1CHuNV3vr0SQcA7uFv9ps91/aQadFGc+0Oqa8Q=;
        b=wpgQ79g9jIJmbQCQ/SYMrjE74oZNYBfTNjqK4b6dpCgPmJvCxRba8+3zMQMsO5YKUc
         7su6ew4xG66IEiQ2+IhhIjcw10tj0I/obpHkxCuMeuvQYpFZp5zfSPg7/ZT8V3WzgSyQ
         4/fkRnPlbgngVVZYHpuhy77wJMROSUm3sDDfuGCchheMsrZVyHArxgqyhH9tSuARmSvk
         S0TArjxrSV4HLBf/Wf0LHtJmW5mFZlt7CyeUJjUs9Vp22C5TDwtoSi2/xQ7Qo86+/qfe
         BrqS2lxnAQmmKJUhYTV01jJDX5FpFl1sZYChhf0V0GTz/f9wVMNTNQC1WhH1QS0h07qg
         9/wg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=FqmdE+7E;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id m3si24276883pfh.249.2019.04.07.13.27.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Apr 2019 13:27:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=FqmdE+7E;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x37KJMGV068386;
	Sun, 7 Apr 2019 20:27:38 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=Kv3ME1CHuNV3vr0SQcA7uFv9ps91/aQadFGc+0Oqa8Q=;
 b=FqmdE+7Eb0IBxrlLL177cZCTndZa9EnxerIHOWMihSBaobMZoAfDXGpnG3KAO2PnBn5o
 ZwG+Nv8XeBhXoUuCDPMo8M6rqDJSbmbEMqxwPv4JvxiPs+yGhldsSkGZVrESeou6My2N
 yVdhuQWdBtjo0gBw/obdeV1UDO9cU9SZxVz+DXGoP/q9uqrwEFpn1oKfKMntBqCVoB2r
 k6SHjsQde/s5HkMbDT/OuNcUZsVVVYdGUyBDXfwPr2Rf7bQPHrMNVV4VgkrME2zEiIpD
 OatzVYGxPrgkE2508YGx0ghlOoT1YMXn9+yO4UA3nQj/gqeupshVeoyk/7VZABXza44u Cw== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2130.oracle.com with ESMTP id 2rphme3be7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 07 Apr 2019 20:27:38 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x37KRcwU195361;
	Sun, 7 Apr 2019 20:27:38 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3020.oracle.com with ESMTP id 2rpkehdurk-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 07 Apr 2019 20:27:37 +0000
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x37KRauR032494;
	Sun, 7 Apr 2019 20:27:36 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Sun, 07 Apr 2019 13:27:36 -0700
Subject: [PATCH 4/4] xfs: don't allow most setxattr to immutable files
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: darrick.wong@oracle.com
Cc: david@fromorbit.com, linux-xfs@vger.kernel.org, linux-mm@kvack.org,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Date: Sun, 07 Apr 2019 13:27:29 -0700
Message-ID: <155466884962.633834.14320700092446721044.stgit@magnolia>
In-Reply-To: <155466882175.633834.15261194784129614735.stgit@magnolia>
References: <155466882175.633834.15261194784129614735.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9220 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=1 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904070194
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9220 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904070193
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Darrick J. Wong <darrick.wong@oracle.com>

The chattr manpage has this to say about immutable files:

"A file with the 'i' attribute cannot be modified: it cannot be deleted
or renamed, no link can be created to this file, most of the file's
metadata can not be modified, and the file can not be opened in write
mode."

However, we don't actually check the immutable flag in the setattr code,
which means that we can update project ids and extent size hints on
supposedly immutable files.  Therefore, reject a setattr call on an
immutable file except for the case where we're trying to unset
IMMUTABLE.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/xfs/xfs_ioctl.c |    8 ++++++++
 1 file changed, 8 insertions(+)


diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index 5a1b96dad901..1215713d7814 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -1061,6 +1061,14 @@ xfs_ioctl_setattr_xflags(
 	    !capable(CAP_LINUX_IMMUTABLE))
 		return -EPERM;
 
+	/*
+	 * If immutable is set and we are not clearing it, we're not allowed
+	 * to change anything else in the inode.
+	 */
+	if ((ip->i_d.di_flags & XFS_DIFLAG_IMMUTABLE) &&
+	    (fa->fsx_xflags & FS_XFLAG_IMMUTABLE))
+		return -EPERM;
+
 	/* diflags2 only valid for v3 inodes. */
 	di_flags2 = xfs_flags2diflags2(ip, fa->fsx_xflags);
 	if (di_flags2 && ip->i_d.di_version < 3)

