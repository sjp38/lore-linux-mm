Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60C71C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 02:33:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1687620645
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 02:33:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="P4AM2r4O"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1687620645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACCE08E0006; Tue, 25 Jun 2019 22:33:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A55A18E0002; Tue, 25 Jun 2019 22:33:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F6DD8E0006; Tue, 25 Jun 2019 22:33:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7162E8E0002
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 22:33:25 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id i133so821617ioa.11
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 19:33:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=6o4YpGypPLzjpZ+ZkqPbxHMhFQ/fAokL7gT/kdrS3rU=;
        b=lnPCpEpibS9PqNO1zW9K+UBBeWXx0+KSfYw8oRj8WzzlptTyjSWuXEr8LzwQf2BZcQ
         cg/Y97b7+Kdz5mKHI4rYOPdTBP2GuTXUUimsL3cQXX6zvTH3kILcHrXepNDvYIbfu6kP
         c7OOX17XGizW2LsbnhFczPUY9hcBwFNCQSBrtLaqkE41gIqPHK68Bt8QK2LyFw6+1b0f
         6Upmih89U/VU2TrgXty8g67SYm5mPWeJw302s28jgeJ1xwVpfpF6SUtCkACxv/LkTlRv
         6nxyayYmDcpdOZU7q62Du4qvglUrHCz/IYrq04x8xaM51MhCibliSM8ijdjU3oT8cNbu
         u7rw==
X-Gm-Message-State: APjAAAUHLk0sji9kB0zuaJvu3hayrOuG6gK6hR2A1uTacSav9YkxmhVO
	OqjChtPxwNUw4F4AdYLaUGJdRQlYzwnw7T0mhY8Wh1yu6ntOlvJWFIXSmbIuH1mBrX4SiKx1TGT
	cDeHZR+VrUvWEtYwmajNs2//whVuQ0n2ZHuPblfgHwGF7s/DBq6Q8OwAqIAtYxE6CUg==
X-Received: by 2002:a5e:d612:: with SMTP id w18mr2097988iom.279.1561516405221;
        Tue, 25 Jun 2019 19:33:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTE+nLHQEtw4eRCuVg68wk5pkHssYT80Qflo4wOS4P7sgjxZexLeTLNteTJIPU0++lw6Xk
X-Received: by 2002:a5e:d612:: with SMTP id w18mr2097948iom.279.1561516404518;
        Tue, 25 Jun 2019 19:33:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561516404; cv=none;
        d=google.com; s=arc-20160816;
        b=WfAy4TNIRkvc6kjei8a5zizpXpG0HCh/XvhuoP/4IwMUKGe5UCEyCDeJa4vOfViojZ
         pSHjjyyPUdl+AC6OTbN7/AO0jT7jt68FAVz+8tTJVzPLbXOLCUWwIboC7gCnfPNDV+Bq
         DqzrkelEo6A9kiMP7pq05lRv86LZ2XcIQ6H1vIdrjJCAHq6OGmCF4F2/WOWqdSVFfh6f
         2p7lIyhhouLbqmY7+Z59BwZ7ZDvblfAZGxnfgHbKpKaQw8vKqajm10BoDfu6d6Wg/v9e
         mrmT5nj0F3MuLGQAn/etLlo+PUe4JQbp+zzi9Tb8/ZO0ZvKmoIEIxn6eBlfqEf3PLyK7
         MmCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=6o4YpGypPLzjpZ+ZkqPbxHMhFQ/fAokL7gT/kdrS3rU=;
        b=x8PFW1FUuqrua9lZL7AccjNZdnTgnNjDfEFtUaLWAtH7bu/zwE9zsqsByzhLD82pqx
         +0OvVX/k0f/SdDr6YEodIhaVDdyYc1CxgidZZCFsKmfZ5wXoOvT6IY63Xixp0/cTGafk
         GUs73fO9XPM2HtdIlpIvSPlTbNkmKTojDPukZgApIx9Yqw+EotY5WkjJXVrpzg6SFmxD
         qnAD2epdydcVe6ujEB0cQN9a52miNmLl/TcFzG+fSpcwmnCG8xMmMnF1w/DWyDCRWlI9
         tnO641scACrrdjZrl+H13y4ayI/oyhQ4zjGYUzAxH7DckhZd3LagXhIGyREKqBj4/Tyk
         EFKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=P4AM2r4O;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id b5si22401745jab.52.2019.06.25.19.33.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 19:33:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=P4AM2r4O;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5Q2TGdr026619;
	Wed, 26 Jun 2019 02:33:14 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=6o4YpGypPLzjpZ+ZkqPbxHMhFQ/fAokL7gT/kdrS3rU=;
 b=P4AM2r4O8nU7c0TP/3hgIM76kuCtB1+zo+JXjO4gCVkCBD/nNSLKwF4llit6BOzR/hos
 kVaWFauOSx3tSBZ1Kfb6P8sGvXDU1tR4q+dRkLjBcvlxDoQKuW0MY8FQgfsiNWesMYbB
 5DJY7OmafEjZr2+80d2LAaWYW0pablNO6XKlpNbkUaUh8WlCsd9N/VfCLktuqrcMlFTW
 TtZhGmSg7llHlD3X8jtnVZsfOw+KwiDhbGpoAqw8vbFJ+cYyOu68k7d3v5OVSQqBKdRy
 XGnhdj8YiQjBBP6DTCVfRzJ+Uo7uR4+2Zz+kccWNVWHDl6kE2dSLvbJXB+hR4M3omUGE wQ== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by aserp2120.oracle.com with ESMTP id 2t9c9pqjkg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 26 Jun 2019 02:33:14 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5Q2WjnS020557;
	Wed, 26 Jun 2019 02:33:13 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by aserp3020.oracle.com with ESMTP id 2t9p6uh2f7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Wed, 26 Jun 2019 02:33:13 +0000
Received: from aserp3020.oracle.com (aserp3020.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5Q2XD75021253;
	Wed, 26 Jun 2019 02:33:13 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3020.oracle.com with ESMTP id 2t9p6uh2f1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 26 Jun 2019 02:33:13 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5Q2XBEe024251;
	Wed, 26 Jun 2019 02:33:11 GMT
Received: from localhost (/10.159.230.235)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 25 Jun 2019 19:33:10 -0700
Subject: [PATCH 2/5] vfs: flush and wait for io when setting the immutable
 flag via SETFLAGS
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: matthew.garrett@nebula.com, yuchao0@huawei.com, tytso@mit.edu,
        darrick.wong@oracle.com, ard.biesheuvel@linaro.org,
        josef@toxicpanda.com, hch@infradead.org, clm@fb.com,
        adilger.kernel@dilger.ca, viro@zeniv.linux.org.uk, jack@suse.com,
        dsterba@suse.com, jaegeuk@kernel.org, jk@ozlabs.org
Cc: reiserfs-devel@vger.kernel.org, linux-efi@vger.kernel.org,
        devel@lists.orangefs.org, linux-kernel@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-xfs@vger.kernel.org,
        linux-mm@kvack.org, linux-nilfs@vger.kernel.org,
        linux-mtd@lists.infradead.org, ocfs2-devel@oss.oracle.com,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Date: Tue, 25 Jun 2019 19:33:08 -0700
Message-ID: <156151638826.2283603.17232416684567376466.stgit@magnolia>
In-Reply-To: <156151637248.2283603.8458727861336380714.stgit@magnolia>
References: <156151637248.2283603.8458727861336380714.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9299 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=777 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906260027
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Darrick J. Wong <darrick.wong@oracle.com>

When we're using FS_IOC_SETFLAGS to set the immutable flag on a file, we
need to ensure that userspace can't continue to write the file after the
file becomes immutable.  To make that happen, we have to flush all the
dirty pagecache pages to disk to ensure that we can fail a page fault on
a mmap'd region, wait for pending directio to complete, and hope the
caller locked out any new writes by holding the inode lock.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/inode.c         |   21 +++++++++++++++++++--
 include/linux/fs.h |   11 +++++++++++
 2 files changed, 30 insertions(+), 2 deletions(-)


diff --git a/fs/inode.c b/fs/inode.c
index f08711b34341..65a412af3ffb 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -2193,7 +2193,8 @@ EXPORT_SYMBOL(current_time);
 
 /*
  * Generic function to check FS_IOC_SETFLAGS values and reject any invalid
- * configurations.
+ * configurations.  Once we're done, prepare the inode for whatever changes
+ * are coming down the pipeline.
  *
  * Note: the caller should be holding i_mutex, or else be sure that they have
  * exclusive access to the inode structure.
@@ -2201,6 +2202,8 @@ EXPORT_SYMBOL(current_time);
 int vfs_ioc_setflags_prepare(struct inode *inode, unsigned int oldflags,
 			     unsigned int flags)
 {
+	int ret;
+
 	/*
 	 * The IMMUTABLE and APPEND_ONLY flags can only be changed by
 	 * the relevant capability.
@@ -2211,7 +2214,21 @@ int vfs_ioc_setflags_prepare(struct inode *inode, unsigned int oldflags,
 	    !capable(CAP_LINUX_IMMUTABLE))
 		return -EPERM;
 
-	return 0;
+	/*
+	 * Now that we're done checking the new flags, flush all pending IO and
+	 * dirty mappings before setting S_IMMUTABLE on an inode via
+	 * FS_IOC_SETFLAGS.  If the flush fails we'll clear the flag before
+	 * returning error.
+	 */
+	if (!S_ISREG(inode->i_mode) || IS_IMMUTABLE(inode) ||
+	    !(flags & FS_IMMUTABLE_FL))
+		return 0;
+
+	inode_set_flags(inode, S_IMMUTABLE, S_IMMUTABLE);
+	ret = inode_drain_writes(inode);
+	if (ret)
+		inode_set_flags(inode, 0, S_IMMUTABLE);
+	return ret;
 }
 EXPORT_SYMBOL(vfs_ioc_setflags_prepare);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 48322bfd7299..51266c9dbadc 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -3561,4 +3561,15 @@ int vfs_ioc_setflags_prepare(struct inode *inode, unsigned int oldflags,
 int vfs_ioc_fssetxattr_check(struct inode *inode, const struct fsxattr *old_fa,
 			     struct fsxattr *fa);
 
+/*
+ * Flush file data before changing attributes.  Caller must hold any locks
+ * required to prevent further writes to this file until we're done setting
+ * flags.
+ */
+static inline int inode_drain_writes(struct inode *inode)
+{
+	inode_dio_wait(inode);
+	return filemap_write_and_wait(inode->i_mapping);
+}
+
 #endif /* _LINUX_FS_H */

