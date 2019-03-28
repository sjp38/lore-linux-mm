Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 652EDC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 17:50:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15AF920823
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 17:50:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="m0S3I43+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15AF920823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD8916B0008; Thu, 28 Mar 2019 13:50:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B60A96B000A; Thu, 28 Mar 2019 13:50:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9DAB56B000C; Thu, 28 Mar 2019 13:50:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 758B86B0008
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 13:50:58 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id q127so9510504qkd.2
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 10:50:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=+SmhM0DmWKGoRrKZZ98M+WstE38ttkB52h8rDI9dPag=;
        b=hINKF2TP+TpM2Vm7a+o8uUPvl68SSLpJ9mlQOXWA9D07QcKUBikHu6hLOOUP1obt9Z
         a+pIULle4qZCBJJ+K5nh1FvAdyTJbWuSwqlh+kVDVFq1APhiwJs2XQLjeXeAovMfvzfN
         iuUKHFvjcYwrXkK1fysUBm37x43AcOhqdg7mrce2UwUn8xB0YYIDZbs7eQXOJJiUNT5O
         nH+lA7AtcD5MGcRo748P9aTzXfrGXbUTw9V3ovE37kaj35VMh04E0kuzXIldqLZYLjIN
         piuM6wX7wbCS5X1dormYFMDHqpRC+l9P4XRIHRyOqbNIcPODkqQlIPQA5RcFCsrpp/+N
         ev9Q==
X-Gm-Message-State: APjAAAX02YcA7u8ByQLWtIuOhnSuKj3imbKMofjN4vqaJa1sfaQDyJcn
	6vOPzk4yu2uL/I5v8CEi7rczVAgqvBOt2RWYjUx0cMQc9Ji4zpTgdWpfAh+l1fjiV06O71zNmRs
	syZVzvM08Mf7E9eLpHBUJbAp9Yp1K6mKEH8FTr7+gnf+Mz0bpyLIbUBbydgsO0zddvA==
X-Received: by 2002:a37:96c4:: with SMTP id y187mr34217992qkd.149.1553795458246;
        Thu, 28 Mar 2019 10:50:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwE71PQsQlvOvj62HNNZAWMTaPJsQuYOi/tC1YopKQj5DiOk2sIfi+0xJKL1eLJahfj8lzX
X-Received: by 2002:a37:96c4:: with SMTP id y187mr34217962qkd.149.1553795457689;
        Thu, 28 Mar 2019 10:50:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553795457; cv=none;
        d=google.com; s=arc-20160816;
        b=XH2KmjlRlOc6P0yOD3iEeNvEITosw0vnd/d0hWgLXR1vUP3YruBRIlpwsXfUmSox6L
         YNwIJfITdsjccCS/Z4jvkbk7mcvoCNv1XbfDQK4zlFPpqhRZUyNixBRGakwNw1fkr8/g
         3aVeqUq1bTTsRB6nSlChodkq1NYjA9YwYEKH1szr2xkcUexU7VHCBGit3rDwltP/7Zkv
         B9KFH+3swU73/XHxuV9kz/9aLdKmbgvcLro8KO+t1Mynn98/oae7LwEViaLg//buClEy
         zzjh9FxfA/ywdptL8ooRtQQMrwez9aj3aYrq4gp15hb52Lxv2SrAUmnxEi4wmYSzGFzG
         rNQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=+SmhM0DmWKGoRrKZZ98M+WstE38ttkB52h8rDI9dPag=;
        b=rM8Lo8th1Tk037263Y/kJXXkXcfAKhAF0+2j5lZgFCYDQHsi2TF1dw3Op7Dl+QfL1M
         jkWIKkU5DmKjIYX/eKGsJRj8YjwVjncPPlR5hN9XjM9IGjFUmeOfGc28sdk5dpRGXLnI
         Ax5jpemqciajulsE/HD0/WStXZAC09Kah1JHZu89RK/E3hA0Bt7F8HRerGdkPbB1Zdws
         EKeW0RrEXZDZc0r3Ld7/T9SmoIHlxsH5LFp+FUj5/Q425A51SPkVhs4nvuVHhx14jcAa
         WTuZqKVll4QGbExS0e772w1arQ2RtLK4BnZzIzVmeJojy5iHUiIzTO7mHrhtnFWhdlyI
         kheQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=m0S3I43+;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id x126si5010427qke.154.2019.03.28.10.50.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 10:50:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=m0S3I43+;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2SHnInl049215;
	Thu, 28 Mar 2019 17:50:57 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=+SmhM0DmWKGoRrKZZ98M+WstE38ttkB52h8rDI9dPag=;
 b=m0S3I43+R6EcCGHOF8hLaM6kQEPuowPMGB6mnUSTClxHddNwVQ68LKEOfqrvL5rsCpY1
 xvHYGYS608Y9qipKFy1V6wDLvZSOzgepfC90dr4FZnaN544BNKAB41Q053ovcaqLOG6a
 IFMcISAGKWZuRPjtlOUMhyA6rbl7d+/q6nVBjLV8AFrTmLgwR4GAP7iw1CT4/RM1qpm8
 WVogSjJvNjHPeu5RR3uxAeNlJ1m/o0XHLrTIx1YlwVG2rQfE6+7q96mL+eKBAHln3Teu
 4pyMNGymdq+8VExMVEY5tz5bMifZ/Kp7FrPoOkQlvpOttECejh1WtQARFRnMUbkMJpQ3 jA== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2re6g187xq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Mar 2019 17:50:57 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x2SHou87026449
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Mar 2019 17:50:56 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x2SHotic006011;
	Thu, 28 Mar 2019 17:50:55 GMT
Received: from localhost (/10.159.234.216)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 28 Mar 2019 10:50:55 -0700
Subject: [PATCH 3/3] xfs: don't allow most setxattr to immutable files
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: darrick.wong@oracle.com
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-mm@kvack.org
Date: Thu, 28 Mar 2019 10:50:54 -0700
Message-ID: <155379545404.24796.5019142212767521955.stgit@magnolia>
In-Reply-To: <155379543409.24796.5783716624820175068.stgit@magnolia>
References: <155379543409.24796.5783716624820175068.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9209 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=854 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903280117
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
index 2bd1c5ab5008..9cf0bc0ae2bd 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -1067,6 +1067,14 @@ xfs_ioctl_setattr_xflags(
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

