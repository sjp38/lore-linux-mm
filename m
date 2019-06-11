Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 151BEC43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 04:49:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF1682086A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 04:49:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="xr/OkVp9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF1682086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D8C66B0010; Tue, 11 Jun 2019 00:49:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 662BF6B0266; Tue, 11 Jun 2019 00:49:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 502156B0269; Tue, 11 Jun 2019 00:49:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 290E06B0010
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 00:49:15 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id f69so11598848ywb.21
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 21:49:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=w6B62XWgEySnIWZsve79cF+lTRasJpmyyQueK4g93UE=;
        b=n/bsu5JslKWp3tlGhFrWjSylp7Z17Z3AaQG0g9+UdlTpvcHK3LJ1hC6nQe1okG7Fw1
         deD/8zN3joKxXIeTUJZzgIZ5YhoHESXTokga8SyfRDqov4AZC/jLh4OPFxG9P5UlMZKD
         ZXrfgF+SddRKxAwoOY/HNRluam/2jSXAYu72tz6/rgdbs/LeRBdhhUCqDJ8qgv9MOCsa
         vjaUtaiR39R8/deuOdcp0F7JO/+1sHZEpl0lJF3ZzA3PiHdZVSlitI/TocWkh041URws
         U3PWow4OMaVCysY2yCGdt/BXGY4ku5qjOOsStMU+ICv1zjNu3tEbp4LD1GIBN1E6LSlM
         NWlg==
X-Gm-Message-State: APjAAAWRPHXjYg6BUPSbcHT1om/YAaPtntC8DhigVCmQw2VuZyYnYhB/
	uw3vJqCo20Y3dYFbkcJ0R24VfwhY3l7lcFMVn/bp/wD0kgWhwCHcPzgVE/VA7AhazE4w1GjewSI
	nn3tM4x3HCz5G6Lwmuw7D3xGMS6HuQa3Axv9IwG2qlAiUSqbNjmaHfBJD/AbZ1WNytA==
X-Received: by 2002:a81:57d6:: with SMTP id l205mr10458545ywb.323.1560228554873;
        Mon, 10 Jun 2019 21:49:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy5Bix8VhjQO9A/7Ge9lGMX9msWKmg6Pn1RiLxy/lzPCmhnoFEMFUnwA7/t9KRmkcg8cK0Z
X-Received: by 2002:a81:57d6:: with SMTP id l205mr10458525ywb.323.1560228554289;
        Mon, 10 Jun 2019 21:49:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560228554; cv=none;
        d=google.com; s=arc-20160816;
        b=AyjZgT4gRVdtxGMGhWrbZllQ1/+xJ4dILDV3DLstWFiHhpqVodDwxni+FQnNi9VXPh
         w05sRjX992jEg26Vmgu+AWEUCL2jKfyBhebF96k7+4U+XIuMZDGrqsRMfjYe/O2Aaxbl
         RpcPjGNnQyAo++xMxV3RgD/Syp9QBNsbj1cJdTH246z42oyovCPa6DAEO1se1ZOTfD0j
         s5qbF4ffpjNU8N6qgQ85S0dhDiZRHW0rvtuVZdTb4wJVlBJhnMAqqQGTSTJ07u0buC9a
         E+Ze0JOuQsKa4b2M3z4u58O9Wsnt0SwuPVDl34rqyLvhiNQos+Ll1SHDjB1KxS6po3DU
         JoJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=w6B62XWgEySnIWZsve79cF+lTRasJpmyyQueK4g93UE=;
        b=mHEtfZfc1bHaFd5y2fLrcRZgMT/RxsVMVn07c8i3HATbCICjzj34HY9Wi4hGA8gtnJ
         rzjwzUyJRNXxbEhW7ykxDayBHZbthGbBKysZy7taPGmvjjJVqmsSg9K2Nd9prdW95dJk
         Nv37eu2leqAiZjEEvD+4rapZeom9IsrC7yNgdYhWNMsIukIwVa2z7K4OsEveb+AIlpHa
         p7PFMIE8yykUiPdklzuibIDilrqSe1sVC4qfvWIFOKQgai4EMJxP3I/bKuNzQI5H+S0l
         gXk9dIDw0O8ZT6WClC4k2AOKVjPmDIWg+YOsITbyk7FBXRKjpgvIb+sXr1ooKHfDMCDZ
         X33Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="xr/OkVp9";
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id r204si4189605ywg.461.2019.06.10.21.49.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 21:49:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="xr/OkVp9";
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5B4hbtt159138;
	Tue, 11 Jun 2019 04:49:06 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=w6B62XWgEySnIWZsve79cF+lTRasJpmyyQueK4g93UE=;
 b=xr/OkVp95W9CZa1qjVKbtngLN9J+a0uZavn2r3ArsGbLa3Idt+XiHAevESEnFd2Muawd
 IDeKByu9gQWLom5QvFu9SB6aGdiFJoCp0tz7vKlzNewkahhwnjXvO0YFc7SwTBUu/TXr
 1JAzKRa/DZxlP4ZZpnIqV/L0X1JujwSoecEOGG343C3b9FaK4zuy1R0cRIGXh59pnwVC
 rgO1+qT0i60g5fCtoX0xlqOK/qTFrDgQsRkvoiZce/aNAuX3Lrp5ll2wDFoSsEQSMY+0
 xO05b6rP2HVkV4MLCu2gbQsaloZCyjVElf52i0un57IO4AUWcCHG2FJLiCzCFi61Ne0u iQ== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2t04etjm38-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 04:49:06 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5B4jGrX167613;
	Tue, 11 Jun 2019 04:47:06 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by userp3030.oracle.com with ESMTP id 2t024u6kpg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 11 Jun 2019 04:47:06 +0000
Received: from userp3030.oracle.com (userp3030.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5B4l5Gj171026;
	Tue, 11 Jun 2019 04:47:06 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3030.oracle.com with ESMTP id 2t024u6kpc-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 04:47:05 +0000
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5B4l4Q5023284;
	Tue, 11 Jun 2019 04:47:04 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 10 Jun 2019 21:47:04 -0700
Subject: [PATCH 6/6] xfs: clean up xfs_merge_ioc_xflags
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: matthew.garrett@nebula.com, yuchao0@huawei.com, tytso@mit.edu,
        darrick.wong@oracle.com, ard.biesheuvel@linaro.org,
        josef@toxicpanda.com, clm@fb.com, adilger.kernel@dilger.ca,
        viro@zeniv.linux.org.uk, jack@suse.com, dsterba@suse.com,
        jaegeuk@kernel.org, jk@ozlabs.org
Cc: reiserfs-devel@vger.kernel.org, linux-efi@vger.kernel.org,
        devel@lists.orangefs.org, linux-kernel@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-xfs@vger.kernel.org,
        linux-mm@kvack.org, linux-nilfs@vger.kernel.org,
        linux-mtd@lists.infradead.org, ocfs2-devel@oss.oracle.com,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Date: Mon, 10 Jun 2019 21:47:01 -0700
Message-ID: <156022842153.3227213.3285668171167534801.stgit@magnolia>
In-Reply-To: <156022836912.3227213.13598042497272336695.stgit@magnolia>
References: <156022836912.3227213.13598042497272336695.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=605 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906110033
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Darrick J. Wong <darrick.wong@oracle.com>

Clean up the calling convention since we're editing the fsxattr struct
anyway.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/xfs/xfs_ioctl.c |   32 ++++++++++++++------------------
 1 file changed, 14 insertions(+), 18 deletions(-)


diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index 7b19ba2956ad..a67bc9afdd0b 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -829,35 +829,31 @@ xfs_ioc_ag_geometry(
  * Linux extended inode flags interface.
  */
 
-STATIC unsigned int
+static inline void
 xfs_merge_ioc_xflags(
-	unsigned int	flags,
-	unsigned int	start)
+	struct fsxattr	*fa,
+	unsigned int	flags)
 {
-	unsigned int	xflags = start;
-
 	if (flags & FS_IMMUTABLE_FL)
-		xflags |= FS_XFLAG_IMMUTABLE;
+		fa->fsx_xflags |= FS_XFLAG_IMMUTABLE;
 	else
-		xflags &= ~FS_XFLAG_IMMUTABLE;
+		fa->fsx_xflags &= ~FS_XFLAG_IMMUTABLE;
 	if (flags & FS_APPEND_FL)
-		xflags |= FS_XFLAG_APPEND;
+		fa->fsx_xflags |= FS_XFLAG_APPEND;
 	else
-		xflags &= ~FS_XFLAG_APPEND;
+		fa->fsx_xflags &= ~FS_XFLAG_APPEND;
 	if (flags & FS_SYNC_FL)
-		xflags |= FS_XFLAG_SYNC;
+		fa->fsx_xflags |= FS_XFLAG_SYNC;
 	else
-		xflags &= ~FS_XFLAG_SYNC;
+		fa->fsx_xflags &= ~FS_XFLAG_SYNC;
 	if (flags & FS_NOATIME_FL)
-		xflags |= FS_XFLAG_NOATIME;
+		fa->fsx_xflags |= FS_XFLAG_NOATIME;
 	else
-		xflags &= ~FS_XFLAG_NOATIME;
+		fa->fsx_xflags &= ~FS_XFLAG_NOATIME;
 	if (flags & FS_NODUMP_FL)
-		xflags |= FS_XFLAG_NODUMP;
+		fa->fsx_xflags |= FS_XFLAG_NODUMP;
 	else
-		xflags &= ~FS_XFLAG_NODUMP;
-
-	return xflags;
+		fa->fsx_xflags &= ~FS_XFLAG_NODUMP;
 }
 
 STATIC unsigned int
@@ -1504,7 +1500,7 @@ xfs_ioc_setxflags(
 		return -EOPNOTSUPP;
 
 	__xfs_ioc_fsgetxattr(ip, false, &fa);
-	fa.fsx_xflags = xfs_merge_ioc_xflags(flags, fa.fsx_xflags);
+	xfs_merge_ioc_xflags(&fa, flags);
 
 	error = mnt_want_write_file(filp);
 	if (error)

