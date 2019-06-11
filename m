Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E671CC43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 04:46:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8939720820
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 04:46:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="KouHoeBM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8939720820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 357676B0269; Tue, 11 Jun 2019 00:46:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 306F56B026C; Tue, 11 Jun 2019 00:46:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A99E6B026D; Tue, 11 Jun 2019 00:46:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id F03576B0269
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 00:46:39 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id p13so12566329ywm.20
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 21:46:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=WxybxO3WrS/x7Dg3DJBiQISzcpEZ9jMIUmRFYzJs8ZE=;
        b=UiYJLG94KBi/z2krdrisCOLfWDndR7CdcwWk+LxqulBY1tqcARKsy9tWdEylNgEc5c
         uo9Nu0RRaRnS92Oyx9RWCoR4MZ9GaJ7n9ZVSiQ72hwQhcVvrrOD8ugspHW8cADPUmwWs
         9vSxn3EDNWGQNNQ8XigqrJBkGUmNBYxdDia+Pv8CUPo8LnAaxu3gd0gF0tnCH/uwRo8Q
         yicI3MN/zJBWr7r1+hEcdNKySx9ULL3nCcjWrf2eip8Brz9QYbBgU/mtMeOYzIBs1h6L
         dH/yCKDNoIgnTLWNecOzhwHsAEUuWmTsAS6jrcm8L0ETz61crZdA0FyzSNkB29wX918H
         t0+w==
X-Gm-Message-State: APjAAAUCze2qn6CeTSkFJ6Z93KKrpFyGUGY08S3aamEt+VtIAOKa3p+A
	uHfRS03VEGwCG7QytsidkCbINGA7esjvGNDj/6SqhJnVhJPX1a5cYY1S+EIBlORNh3rzbCcxxDI
	jdMlOLn4f5kzH8xcWgLs6eaW1L8/j46X50OL1FqxruASRghoBOiK7hGJjQH13/Y3RGA==
X-Received: by 2002:a0d:fcc7:: with SMTP id m190mr37350360ywf.215.1560228399646;
        Mon, 10 Jun 2019 21:46:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzokJxbgld8wKDXHNhGGM79MlYhhVVnYlinmmEQ0QUvJPuIWDX13ADJmK7KFD8lQMT4OUHn
X-Received: by 2002:a0d:fcc7:: with SMTP id m190mr37350342ywf.215.1560228398744;
        Mon, 10 Jun 2019 21:46:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560228398; cv=none;
        d=google.com; s=arc-20160816;
        b=EtXzB/JMOt9Gkw3sSbD6oQP8g63gxoG70JRSfb9f0w++HYm7mZ51EiN3J7eCr/1k0S
         eRCXUXk6wtys98uyQAjANFeGVXutW32/57CdfkzjhfaY0ZphiUQQ3ptsOH5kFA19gPe0
         rwI3UwjVBE7OjM2XV1uCE/A/FgvPZ7ApeBju2Tdo5tAeCI6L4D43tibQGB0SY7cB5H6k
         di6S4jNq47J8dQDHoX7elRpQWs69keuV2uEOVX0cOfQ1OhDeivnoQHtIKzuZcht6UJw3
         8j1pnkAI4QIdGw+38lBvD9NcLmMYqB8RDZcY8GEu0f/r3+MIspuIt75NzrkhPBKpYJol
         +jXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=WxybxO3WrS/x7Dg3DJBiQISzcpEZ9jMIUmRFYzJs8ZE=;
        b=gIO5lCxsvq1ylENKVymjCWN3P2zldrBpIe4X1Sy1V0wguZZY//BNeut4PCQjxvRInU
         C/X2mE0QSJXW2RudEBEwpz+ircXUtGWvuC/VIJ365mq1f225+mwUqoTdQJUt7OlBh7hQ
         iByCw5J1jPXXm9wpd6ES1gKgAVnt7Chs5Zndz51RtFLjHkSdNdgFEsm21YZUJdut2Lh5
         6ITpDvyx68lDIDQARe8Bck9FmYxwY0uB2FUuJ+buqfV8VLjRpobSuYfxF4tYP8d9tJEE
         WOx93etGgYHMWgXD0HNA/MvInlr8KNyNYCzlT1Urh+wm/b8yC4Nff6GQIIfv8scjN23E
         0AKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=KouHoeBM;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id k190si1748011ywa.454.2019.06.10.21.46.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 21:46:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=KouHoeBM;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5B4hbOv168944;
	Tue, 11 Jun 2019 04:46:31 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=WxybxO3WrS/x7Dg3DJBiQISzcpEZ9jMIUmRFYzJs8ZE=;
 b=KouHoeBMQ/ymJf6HIOOrACaaQzi7UEt0l1lJrCBY0Vn59xdS7jQ9hMIUdvJI75TqqQ70
 60qYSdgHRavV6Nveb0KGPeviNFpJ1DIDV5gpXL2DrMktYZbGv3/Ekelwz1ITy2d+Oovj
 MuJCe0Zg8/vDKONBYcIrkeccye2h2rsHFM6XJpvlrviysaSF6dVxlEeRkZDYzsh6lrxG
 RZL35DazP7WD7+QGfndOUgSBM28R9yUqdp3FKJ6eyepAURXNdu/ORgi5/VFzSP6Mg2nJ
 odqAoXgCSh44u0npPvoyht0hzz065yX0OrK92+kPtZVRwl75a8hRHlPOFyIwZCnSmgW8 Fw== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2t05nqjh61-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 04:46:31 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5B4k8Ct173748;
	Tue, 11 Jun 2019 04:46:30 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by aserp3020.oracle.com with ESMTP id 2t0p9r34gu-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 11 Jun 2019 04:46:30 +0000
Received: from aserp3020.oracle.com (aserp3020.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5B4kUI9174363;
	Tue, 11 Jun 2019 04:46:30 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3020.oracle.com with ESMTP id 2t0p9r34gm-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 04:46:30 +0000
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5B4kSKb002743;
	Tue, 11 Jun 2019 04:46:28 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 10 Jun 2019 21:46:27 -0700
Subject: [PATCH 2/6] vfs: flush and wait for io when setting the immutable
 flag via SETFLAGS
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
Date: Mon, 10 Jun 2019 21:46:25 -0700
Message-ID: <156022838496.3227213.3771632042609589318.stgit@magnolia>
In-Reply-To: <156022836912.3227213.13598042497272336695.stgit@magnolia>
References: <156022836912.3227213.13598042497272336695.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906110033
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
 fs/btrfs/ioctl.c       |    3 +++
 fs/efivarfs/file.c     |    5 +++++
 fs/ext2/ioctl.c        |    5 +++++
 fs/ext4/ioctl.c        |    3 +++
 fs/f2fs/file.c         |    3 +++
 fs/hfsplus/ioctl.c     |    3 +++
 fs/nilfs2/ioctl.c      |    3 +++
 fs/ocfs2/ioctl.c       |    3 +++
 fs/orangefs/file.c     |   11 ++++++++---
 fs/orangefs/protocol.h |    3 +++
 fs/reiserfs/ioctl.c    |    3 +++
 fs/ubifs/ioctl.c       |    3 +++
 include/linux/fs.h     |   34 ++++++++++++++++++++++++++++++++++
 13 files changed, 79 insertions(+), 3 deletions(-)


diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index 7ddda5b4b6a6..f431813b2454 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -214,6 +214,9 @@ static int btrfs_ioctl_setflags(struct file *file, void __user *arg)
 	fsflags = btrfs_mask_fsflags_for_type(inode, fsflags);
 	old_fsflags = btrfs_inode_flags_to_fsflags(binode->flags);
 	ret = vfs_ioc_setflags_check(inode, old_fsflags, fsflags);
+	if (ret)
+		goto out_unlock;
+	ret = vfs_ioc_setflags_flush_data(inode, fsflags);
 	if (ret)
 		goto out_unlock;
 
diff --git a/fs/efivarfs/file.c b/fs/efivarfs/file.c
index f4f6c1bec132..845016a67724 100644
--- a/fs/efivarfs/file.c
+++ b/fs/efivarfs/file.c
@@ -163,6 +163,11 @@ efivarfs_ioc_setxflags(struct file *file, void __user *arg)
 		return error;
 
 	inode_lock(inode);
+	error = vfs_ioc_setflags_flush_data(inode, flags);
+	if (error) {
+		inode_unlock(inode);
+		return error;
+	}
 	inode_set_flags(inode, i_flags, S_IMMUTABLE);
 	inode_unlock(inode);
 
diff --git a/fs/ext2/ioctl.c b/fs/ext2/ioctl.c
index 88b3b9720023..75f75619237c 100644
--- a/fs/ext2/ioctl.c
+++ b/fs/ext2/ioctl.c
@@ -65,6 +65,11 @@ long ext2_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 			inode_unlock(inode);
 			goto setflags_out;
 		}
+		ret = vfs_ioc_setflags_flush_data(inode, flags);
+		if (ret) {
+			inode_unlock(inode);
+			goto setflags_out;
+		}
 
 		flags = flags & EXT2_FL_USER_MODIFIABLE;
 		flags |= oldflags & ~EXT2_FL_USER_MODIFIABLE;
diff --git a/fs/ext4/ioctl.c b/fs/ext4/ioctl.c
index 6aa1df1918f7..a05341b94d98 100644
--- a/fs/ext4/ioctl.c
+++ b/fs/ext4/ioctl.c
@@ -290,6 +290,9 @@ static int ext4_ioctl_setflags(struct inode *inode,
 	jflag = flags & EXT4_JOURNAL_DATA_FL;
 
 	err = vfs_ioc_setflags_check(inode, oldflags, flags);
+	if (err)
+		goto flags_out;
+	err = vfs_ioc_setflags_flush_data(inode, flags);
 	if (err)
 		goto flags_out;
 
diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index 183ed1ac60e1..d3cf4bdb8738 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -1681,6 +1681,9 @@ static int __f2fs_ioc_setflags(struct inode *inode, unsigned int flags)
 	oldflags = fi->i_flags;
 
 	err = vfs_ioc_setflags_check(inode, oldflags, flags);
+	if (err)
+		return err;
+	err = vfs_ioc_setflags_flush_data(inode, flags);
 	if (err)
 		return err;
 
diff --git a/fs/hfsplus/ioctl.c b/fs/hfsplus/ioctl.c
index 862a3c9481d7..f8295fa35237 100644
--- a/fs/hfsplus/ioctl.c
+++ b/fs/hfsplus/ioctl.c
@@ -104,6 +104,9 @@ static int hfsplus_ioctl_setflags(struct file *file, int __user *user_flags)
 	inode_lock(inode);
 
 	err = vfs_ioc_setflags_check(inode, oldflags, flags);
+	if (err)
+		goto out_unlock_inode;
+	err = vfs_ioc_setflags_flush_data(inode, flags);
 	if (err)
 		goto out_unlock_inode;
 
diff --git a/fs/nilfs2/ioctl.c b/fs/nilfs2/ioctl.c
index 0632336d2515..a3c200ab9f60 100644
--- a/fs/nilfs2/ioctl.c
+++ b/fs/nilfs2/ioctl.c
@@ -149,6 +149,9 @@ static int nilfs_ioctl_setflags(struct inode *inode, struct file *filp,
 	oldflags = NILFS_I(inode)->i_flags;
 
 	ret = vfs_ioc_setflags_check(inode, oldflags, flags);
+	if (ret)
+		goto out;
+	ret = vfs_ioc_setflags_flush_data(inode, flags);
 	if (ret)
 		goto out;
 
diff --git a/fs/ocfs2/ioctl.c b/fs/ocfs2/ioctl.c
index 467a2faf0305..e91ca0dad3d7 100644
--- a/fs/ocfs2/ioctl.c
+++ b/fs/ocfs2/ioctl.c
@@ -107,6 +107,9 @@ static int ocfs2_set_inode_attr(struct inode *inode, unsigned flags,
 	flags |= oldflags & ~mask;
 
 	status = vfs_ioc_setflags_check(inode, oldflags, flags);
+	if (status)
+		goto bail_unlock;
+	status = vfs_ioc_setflags_flush_data(inode, flags);
 	if (status)
 		goto bail_unlock;
 
diff --git a/fs/orangefs/file.c b/fs/orangefs/file.c
index a35c17017210..fec5dfbc3dac 100644
--- a/fs/orangefs/file.c
+++ b/fs/orangefs/file.c
@@ -389,6 +389,8 @@ static long orangefs_ioctl(struct file *file, unsigned int cmd, unsigned long ar
 			     (unsigned long long)uval);
 		return put_user(uval, (int __user *)arg);
 	} else if (cmd == FS_IOC_SETFLAGS) {
+		struct inode *inode = file_inode(file);
+
 		ret = 0;
 		if (get_user(uval, (int __user *)arg))
 			return -EFAULT;
@@ -399,11 +401,14 @@ static long orangefs_ioctl(struct file *file, unsigned int cmd, unsigned long ar
 		 * the flags and then updates the flags with some new
 		 * settings. So, we ignore it in the following edit. bligon.
 		 */
-		if ((uval & ~ORANGEFS_MIRROR_FL) &
-		    (~(FS_IMMUTABLE_FL | FS_APPEND_FL | FS_NOATIME_FL))) {
+		if ((uval & ~ORANGEFS_MIRROR_FL) & ~ORANGEFS_VFS_FL) {
 			gossip_err("orangefs_ioctl: the FS_IOC_SETFLAGS only supports setting one of FS_IMMUTABLE_FL|FS_APPEND_FL|FS_NOATIME_FL\n");
 			return -EINVAL;
 		}
+		ret = vfs_ioc_setflags_flush_data(inode,
+						  uval & ORANGEFS_VFS_FL);
+		if (ret)
+			goto out;
 		val = uval;
 		gossip_debug(GOSSIP_FILE_DEBUG,
 			     "orangefs_ioctl: FS_IOC_SETFLAGS: %llu\n",
@@ -412,7 +417,7 @@ static long orangefs_ioctl(struct file *file, unsigned int cmd, unsigned long ar
 					      "user.pvfs2.meta_hint",
 					      &val, sizeof(val), 0);
 	}
-
+out:
 	return ret;
 }
 
diff --git a/fs/orangefs/protocol.h b/fs/orangefs/protocol.h
index d403cf29a99b..3dbe1c4534ce 100644
--- a/fs/orangefs/protocol.h
+++ b/fs/orangefs/protocol.h
@@ -129,6 +129,9 @@ static inline void ORANGEFS_khandle_from(struct orangefs_khandle *kh,
 #define ORANGEFS_IMMUTABLE_FL FS_IMMUTABLE_FL
 #define ORANGEFS_APPEND_FL    FS_APPEND_FL
 #define ORANGEFS_NOATIME_FL   FS_NOATIME_FL
+#define ORANGEFS_VFS_FL				(FS_IMMUTABLE_FL | \
+						 FS_APPEND_FL | \
+						 FS_NOATIME_FL)
 #define ORANGEFS_MIRROR_FL    0x01000000ULL
 #define ORANGEFS_FS_ID_NULL       ((__s32)0)
 #define ORANGEFS_ATTR_SYS_UID                   (1 << 0)
diff --git a/fs/reiserfs/ioctl.c b/fs/reiserfs/ioctl.c
index 92bcb1ecd994..50494f54392c 100644
--- a/fs/reiserfs/ioctl.c
+++ b/fs/reiserfs/ioctl.c
@@ -77,6 +77,9 @@ long reiserfs_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 			err = vfs_ioc_setflags_check(inode,
 						     REISERFS_I(inode)->i_attrs,
 						     flags);
+			if (err)
+				goto setflags_out;
+			err = vfs_ioc_setflags_flush_data(inode, flags);
 			if (err)
 				goto setflags_out;
 			if ((flags & REISERFS_NOTAIL_FL) &&
diff --git a/fs/ubifs/ioctl.c b/fs/ubifs/ioctl.c
index bdea836fc38b..ff4a43314599 100644
--- a/fs/ubifs/ioctl.c
+++ b/fs/ubifs/ioctl.c
@@ -110,6 +110,9 @@ static int setflags(struct inode *inode, int flags)
 	mutex_lock(&ui->ui_mutex);
 	oldflags = ubifs2ioctl(ui->flags);
 	err = vfs_ioc_setflags_check(inode, oldflags, flags);
+	if (err)
+		goto out_unlock;
+	err = vfs_ioc_setflags_flush_data(inode, flags);
 	if (err)
 		goto out_unlock;
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 8dad3c80b611..9c899c63957e 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -3548,7 +3548,41 @@ static inline struct sock *io_uring_get_socket(struct file *file)
 
 int vfs_ioc_setflags_check(struct inode *inode, int oldflags, int flags);
 
+/*
+ * Do we need to flush the file data before changing attributes?  When we're
+ * setting the immutable flag we must stop all directio writes and flush the
+ * dirty pages so that we can fail the page fault on the next write attempt.
+ */
+static inline bool vfs_ioc_setflags_need_flush(struct inode *inode, int flags)
+{
+	if (S_ISREG(inode->i_mode) && !IS_IMMUTABLE(inode) &&
+	    (flags & FS_IMMUTABLE_FL))
+		return true;
+
+	return false;
+}
+
+/*
+ * Flush file data before changing attributes.  Caller must hold any locks
+ * required to prevent further writes to this file until we're done setting
+ * flags.
+ */
+static inline int inode_flush_data(struct inode *inode)
+{
+	inode_dio_wait(inode);
+	return filemap_write_and_wait(inode->i_mapping);
+}
+
+/* Flush file data before changing attributes, if necessary. */
+static inline int vfs_ioc_setflags_flush_data(struct inode *inode, int flags)
+{
+	if (vfs_ioc_setflags_need_flush(inode, flags))
+		return inode_flush_data(inode);
+	return 0;
+}
+
 int vfs_ioc_fssetxattr_check(struct inode *inode, const struct fsxattr *old_fa,
 			     struct fsxattr *fa);
 
+
 #endif /* _LINUX_FS_H */

