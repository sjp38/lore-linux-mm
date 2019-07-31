Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DAF4C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 16:58:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B65F0216C8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 16:58:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=android.com header.i=@android.com header.b="fmiQSh9y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B65F0216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=android.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47E438E0009; Wed, 31 Jul 2019 12:58:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42F648E0001; Wed, 31 Jul 2019 12:58:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F8678E0009; Wed, 31 Jul 2019 12:58:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id EB95C8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 12:58:55 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id d6so37810462pls.17
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 09:58:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=p6RSnHZej7dMZQfosYc1rQOAXMnG8HF3vzAcSS3MG98=;
        b=Y6NiWo3AOm9ozJLETG8957zLVGwPorJiJX8MqtAf0YXT3cPcaPI4inETePptreRfWm
         FFEOnwpyj0dJGz3fo74CsFe04KUetkAfmeMOIG9ma1mys0hwjXfkwEIIMz9TpoDe8qMC
         ktewerGYqpkUj75l18741Wl09lg6RdTeGL9PCwL5iBTUesemKZVZ+nJAFqPMHtiRamRl
         5/aJPAyIfX3WDePpXLRzz+bQZl78X03/0YhvhlDIjPHQvymXCxbxMl1fFUKDX1VTh1Gl
         puOJf5jfskCc1rDM1ZEPSYBDKa4S53o51xKzT3k20/kA8kApK3llbmbMB8KzjyVTqSAo
         +1/Q==
X-Gm-Message-State: APjAAAWSHW7078Knv6RbIJGaQxbaofgde2vsj2KJbhBBHkGjEevo+u3S
	DB+cd/Bt2yNRX08MFoPQfnVRLxGmmblYoQZvl8J80QagXYujav3wE/VaLfPTA1wWIfGrFCgvLWK
	JUSUiH0rrZL/lq0CT8YNyEwfrxOm4V+xeTB34j/FDPX06i6pRgHsCQQE362AnQ6lstQ==
X-Received: by 2002:a17:902:306:: with SMTP id 6mr123058695pld.148.1564592335601;
        Wed, 31 Jul 2019 09:58:55 -0700 (PDT)
X-Received: by 2002:a17:902:306:: with SMTP id 6mr123058621pld.148.1564592334268;
        Wed, 31 Jul 2019 09:58:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564592334; cv=none;
        d=google.com; s=arc-20160816;
        b=R68j8rNtXyd5OKLEAJol0T9FAsRcPC0BqvpBZYbgSrbeVEy4K8URR+Il1O03DxaYx+
         J0vtlN1VvF198gGkufgt1g4Dma305Vhjf8NaLFdvNQ1MxNq9gX3J0j6M3h9RjTJ7qG0l
         8YRmOy28046+K/qNpwUBQTvr9StOKEWo65a2PcVAlXgC5tuktq3XkOWK+iddKSgUzuVI
         sHy1aZTZghKZ9oHrXjI3jLXwiaDX0YBWYn7wtbRAeD+5XJeXbQTG8mE/tS1oTq5p3RkM
         T6t699QwDUnELn24zLQKL1/UnLRh6cguDSvPVpun80BA28w/lWp48l4ppeEKc/Ha6RJo
         Bmbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=p6RSnHZej7dMZQfosYc1rQOAXMnG8HF3vzAcSS3MG98=;
        b=mDSA7+Ch1AbUVDgxMK6r1i7sy2TO5UuOQnpVWsbgZf39pPeyQS/N7eTy3O/9ryPqDm
         rPxD1E0LSEP5URkYexg+vOk6mGU5IPxq72CfNGcqIFi15pGiPdLKWB8Cia6rt5BBEImn
         XidVGqY0Gz467bKzv1iq7CPEVFBKKDEdVX2DXBL7Ha5NzEuW9alAw5K8Sv8m2HsBNdzO
         VYLQy1JR+4a24HDVy51puAsPPnoARAHr4HenWaPrtZvbNN4pSdUbeyy8LoX9ZplrXPvW
         7ofJlLQtXKOuLVpaqe/+ACZ38qa2Ad6RBdE1oDroYovNE97HJlXOBLWoFXelKAhZQuiD
         EUtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=fmiQSh9y;
       spf=pass (google.com: domain of salyzyn@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=salyzyn@android.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=android.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bc5sor83423215plb.36.2019.07.31.09.58.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 09:58:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of salyzyn@android.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=fmiQSh9y;
       spf=pass (google.com: domain of salyzyn@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=salyzyn@android.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=android.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=android.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=p6RSnHZej7dMZQfosYc1rQOAXMnG8HF3vzAcSS3MG98=;
        b=fmiQSh9yv929qF/IP6Uym2pEsxsKnDznkX0VjJ8cIh+7NzZrkbqvPCG3bssMygeAbK
         NmkNsix4uTqi91gMmHKksLpNQD7b0D1A9bda6aSayMw9sPfvhUAJO63BySMzz39Ednc6
         +iWQAfEEJ8NQ6QfBslJvC3DyBQUS6s3R1R0XZUZMZgKOLtN+EIac6ejHjwc9qbdb5uvz
         eiCuyG0A6yFWZLw5lHrPP3O5DsRBGnqxHkq8vNdP6QJnUoh2+fIqC3yhPbsH+qEpXwib
         mUbx7N0k3Aa9YqKq/FSCQYABcvQoWcmd3n7QaLFSg3+9u/w9YuhZ+4mMF/9YdnWbfIFZ
         JhFA==
X-Google-Smtp-Source: APXvYqyB1157MtzfYeWJ1dBcWuMDKOUJgOnzq0VC5i1SowoHtyq/iVzFaALo7AjUpN0O6A6XZS+NfQ==
X-Received: by 2002:a17:902:9a85:: with SMTP id w5mr121452633plp.221.1564592333814;
        Wed, 31 Jul 2019 09:58:53 -0700 (PDT)
Received: from nebulus.mtv.corp.google.com ([2620:15c:211:200:5404:91ba:59dc:9400])
        by smtp.gmail.com with ESMTPSA id f72sm2245954pjg.10.2019.07.31.09.58.51
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 31 Jul 2019 09:58:53 -0700 (PDT)
From: Mark Salyzyn <salyzyn@android.com>
To: linux-kernel@vger.kernel.org
Cc: kernel-team@android.com,
	Mark Salyzyn <salyzyn@android.com>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Jonathan Corbet <corbet@lwn.net>,
	Vivek Goyal <vgoyal@redhat.com>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Amir Goldstein <amir73il@gmail.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	linux-unionfs@vger.kernel.org,
	linux-doc@vger.kernel.org,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Latchesar Ionkov <lucho@ionkov.net>,
	Dominique Martinet <asmadeus@codewreck.org>,
	David Howells <dhowells@redhat.com>,
	Chris Mason <clm@fb.com>,
	Josef Bacik <josef@toxicpanda.com>,
	David Sterba <dsterba@suse.com>,
	Jeff Layton <jlayton@kernel.org>,
	Sage Weil <sage@redhat.com>,
	Ilya Dryomov <idryomov@gmail.com>,
	Steve French <sfrench@samba.org>,
	Tyler Hicks <tyhicks@canonical.com>,
	Jan Kara <jack@suse.com>,
	Theodore Ts'o <tytso@mit.edu>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	Chao Yu <yuchao0@huawei.com>,
	Bob Peterson <rpeterso@redhat.com>,
	Andreas Gruenbacher <agruenba@redhat.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Richard Weinberger <richard@nod.at>,
	Dave Kleikamp <shaggy@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Tejun Heo <tj@kernel.org>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	Mark Fasheh <mark@fasheh.com>,
	Joel Becker <jlbec@evilplan.org>,
	Joseph Qi <joseph.qi@linux.alibaba.com>,
	Mike Marshall <hubcap@omnibond.com>,
	Martin Brandenburg <martin@omnibond.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Phillip Lougher <phillip@squashfs.org.uk>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	linux-xfs@vger.kernel.org,
	Hugh Dickins <hughd@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mathieu Malaterre <malat@debian.org>,
	=?UTF-8?q?Ernesto=20A=20=2E=20Fern=C3=A1ndez?= <ernesto.mnd.fernandez@gmail.com>,
	Vyacheslav Dubeyko <slava@dubeyko.com>,
	v9fs-developer@lists.sourceforge.net,
	linux-afs@lists.infradead.org,
	linux-btrfs@vger.kernel.org,
	ceph-devel@vger.kernel.org,
	linux-cifs@vger.kernel.org,
	samba-technical@lists.samba.org,
	ecryptfs@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org,
	cluster-devel@redhat.com,
	linux-mtd@lists.infradead.org,
	jfs-discussion@lists.sourceforge.net,
	linux-nfs@vger.kernel.org,
	ocfs2-devel@oss.oracle.com,
	devel@lists.orangefs.org,
	reiserfs-devel@vger.kernel.org,
	linux-mm@kvack.org,
	netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	stable@vger.kernel.org
Subject: [PATCH v13 4/5] overlayfs: internal getxattr operations without sepolicy checking
Date: Wed, 31 Jul 2019 09:57:59 -0700
Message-Id: <20190731165803.4755-5-salyzyn@android.com>
X-Mailer: git-send-email 2.22.0.770.g0f2c4a37fd-goog
In-Reply-To: <20190731165803.4755-1-salyzyn@android.com>
References: <20190731165803.4755-1-salyzyn@android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Check impure, opaque, origin & meta xattr with no sepolicy audit
(using __vfs_getxattr) since these operations are internal to
overlayfs operations and do not disclose any data.  This became
an issue for credential override off since sys_admin would have
been required by the caller; whereas would have been inherently
present for the creator since it performed the mount.

This is a change in operations since we do not check in the new
ovl_do_vfs_getxattr function if the credential override is off or
not.  Reasoning is that the sepolicy check is unnecessary overhead,
especially since the check can be expensive.

Because for override credentials off, this affects _everyone_ that
underneath performs private xattr calls without the appropriate
sepolicy permissions and sys_admin capability.  Providing blanket
support for sys_admin would be bad for all possible callers.

For the override credentials on, this will affect only the mounter,
should it lack sepolicy permissions. Not considered a security
problem since mounting by definition has sys_admin capabilities,
but sepolicy contexts would still need to be crafted.

It should be noted that there is precedence, __vfs_getxattr is used
in other filesystems for their own internal trusted xattr management.

Signed-off-by: Mark Salyzyn <salyzyn@android.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: Vivek Goyal <vgoyal@redhat.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Amir Goldstein <amir73il@gmail.com>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: Stephen Smalley <sds@tycho.nsa.gov>
Cc: linux-unionfs@vger.kernel.org
Cc: linux-doc@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: kernel-team@android.com
Cc: Eric Van Hensbergen <ericvh@gmail.com>
Cc: Latchesar Ionkov <lucho@ionkov.net>
Cc: Dominique Martinet <asmadeus@codewreck.org>
Cc: David Howells <dhowells@redhat.com>
Cc: Chris Mason <clm@fb.com>
Cc: Josef Bacik <josef@toxicpanda.com>
Cc: David Sterba <dsterba@suse.com>
Cc: Jeff Layton <jlayton@kernel.org>
Cc: Sage Weil <sage@redhat.com>
Cc: Ilya Dryomov <idryomov@gmail.com>
Cc: Steve French <sfrench@samba.org>
Cc: Tyler Hicks <tyhicks@canonical.com>
Cc: Jan Kara <jack@suse.com>
Cc: Theodore Ts'o <tytso@mit.edu>
Cc: Andreas Dilger <adilger.kernel@dilger.ca>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Chao Yu <yuchao0@huawei.com>
Cc: Bob Peterson <rpeterso@redhat.com>
Cc: Andreas Gruenbacher <agruenba@redhat.com>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: Richard Weinberger <richard@nod.at>
Cc: Dave Kleikamp <shaggy@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: Mark Fasheh <mark@fasheh.com>
Cc: Joel Becker <jlbec@evilplan.org>
Cc: Joseph Qi <joseph.qi@linux.alibaba.com>
Cc: Mike Marshall <hubcap@omnibond.com>
Cc: Martin Brandenburg <martin@omnibond.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Phillip Lougher <phillip@squashfs.org.uk>
Cc: Darrick J. Wong <darrick.wong@oracle.com>
Cc: linux-xfs@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mathieu Malaterre <malat@debian.org>
Cc: Ernesto A. Fernández <ernesto.mnd.fernandez@gmail.com>
Cc: Vyacheslav Dubeyko <slava@dubeyko.com>
Cc: v9fs-developer@lists.sourceforge.net
Cc: linux-afs@lists.infradead.org
Cc: linux-btrfs@vger.kernel.org
Cc: ceph-devel@vger.kernel.org
Cc: linux-cifs@vger.kernel.org
Cc: samba-technical@lists.samba.org
Cc: ecryptfs@vger.kernel.org
Cc: linux-ext4@vger.kernel.org
Cc: linux-f2fs-devel@lists.sourceforge.net
Cc: linux-fsdevel@vger.kernel.org
Cc: cluster-devel@redhat.com
Cc: linux-mtd@lists.infradead.org
Cc: jfs-discussion@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org
Cc: ocfs2-devel@oss.oracle.com
Cc: devel@lists.orangefs.org
Cc: reiserfs-devel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: netdev@vger.kernel.org
Cc: linux-security-module@vger.kernel.org
Cc: stable@vger.kernel.org # 4.4, 4.9, 4.14 & 4.19
---
v13 - rebase to use __vfs_getxattr flags option

v12 - rebase

v11 - switch name to ovl_do_vfs_getxattr, fortify comment

v10 - added to patch series
---
 fs/overlayfs/namei.c     | 12 +++++++-----
 fs/overlayfs/overlayfs.h |  2 ++
 fs/overlayfs/util.c      | 25 ++++++++++++++++---------
 3 files changed, 25 insertions(+), 14 deletions(-)

diff --git a/fs/overlayfs/namei.c b/fs/overlayfs/namei.c
index 9702f0d5309d..a4a452c489fa 100644
--- a/fs/overlayfs/namei.c
+++ b/fs/overlayfs/namei.c
@@ -106,10 +106,11 @@ int ovl_check_fh_len(struct ovl_fh *fh, int fh_len)
 
 static struct ovl_fh *ovl_get_fh(struct dentry *dentry, const char *name)
 {
-	int res, err;
+	ssize_t res;
+	int err;
 	struct ovl_fh *fh = NULL;
 
-	res = vfs_getxattr(dentry, name, NULL, 0);
+	res = ovl_do_vfs_getxattr(dentry, name, NULL, 0);
 	if (res < 0) {
 		if (res == -ENODATA || res == -EOPNOTSUPP)
 			return NULL;
@@ -123,7 +124,7 @@ static struct ovl_fh *ovl_get_fh(struct dentry *dentry, const char *name)
 	if (!fh)
 		return ERR_PTR(-ENOMEM);
 
-	res = vfs_getxattr(dentry, name, fh, res);
+	res = ovl_do_vfs_getxattr(dentry, name, fh, res);
 	if (res < 0)
 		goto fail;
 
@@ -141,10 +142,11 @@ static struct ovl_fh *ovl_get_fh(struct dentry *dentry, const char *name)
 	return NULL;
 
 fail:
-	pr_warn_ratelimited("overlayfs: failed to get origin (%i)\n", res);
+	pr_warn_ratelimited("overlayfs: failed to get origin (%zi)\n", res);
 	goto out;
 invalid:
-	pr_warn_ratelimited("overlayfs: invalid origin (%*phN)\n", res, fh);
+	pr_warn_ratelimited("overlayfs: invalid origin (%*phN)\n",
+			    (int)res, fh);
 	goto out;
 }
 
diff --git a/fs/overlayfs/overlayfs.h b/fs/overlayfs/overlayfs.h
index ab3d031c422b..9d26d8758513 100644
--- a/fs/overlayfs/overlayfs.h
+++ b/fs/overlayfs/overlayfs.h
@@ -205,6 +205,8 @@ int ovl_want_write(struct dentry *dentry);
 void ovl_drop_write(struct dentry *dentry);
 struct dentry *ovl_workdir(struct dentry *dentry);
 const struct cred *ovl_override_creds(struct super_block *sb);
+ssize_t ovl_do_vfs_getxattr(struct dentry *dentry, const char *name, void *buf,
+			    size_t size);
 struct super_block *ovl_same_sb(struct super_block *sb);
 int ovl_can_decode_fh(struct super_block *sb);
 struct dentry *ovl_indexdir(struct super_block *sb);
diff --git a/fs/overlayfs/util.c b/fs/overlayfs/util.c
index f5678a3f8350..c588c0d66d8c 100644
--- a/fs/overlayfs/util.c
+++ b/fs/overlayfs/util.c
@@ -40,6 +40,13 @@ const struct cred *ovl_override_creds(struct super_block *sb)
 	return override_creds(ofs->creator_cred);
 }
 
+ssize_t ovl_do_vfs_getxattr(struct dentry *dentry, const char *name, void *buf,
+			    size_t size)
+{
+	return __vfs_getxattr(dentry, d_inode(dentry), name, buf, size,
+			      XATTR_NOSECURITY);
+}
+
 struct super_block *ovl_same_sb(struct super_block *sb)
 {
 	struct ovl_fs *ofs = sb->s_fs_info;
@@ -537,9 +544,9 @@ void ovl_copy_up_end(struct dentry *dentry)
 
 bool ovl_check_origin_xattr(struct dentry *dentry)
 {
-	int res;
+	ssize_t res;
 
-	res = vfs_getxattr(dentry, OVL_XATTR_ORIGIN, NULL, 0);
+	res = ovl_do_vfs_getxattr(dentry, OVL_XATTR_ORIGIN, NULL, 0);
 
 	/* Zero size value means "copied up but origin unknown" */
 	if (res >= 0)
@@ -550,13 +557,13 @@ bool ovl_check_origin_xattr(struct dentry *dentry)
 
 bool ovl_check_dir_xattr(struct dentry *dentry, const char *name)
 {
-	int res;
+	ssize_t res;
 	char val;
 
 	if (!d_is_dir(dentry))
 		return false;
 
-	res = vfs_getxattr(dentry, name, &val, 1);
+	res = ovl_do_vfs_getxattr(dentry, name, &val, 1);
 	if (res == 1 && val == 'y')
 		return true;
 
@@ -837,13 +844,13 @@ int ovl_lock_rename_workdir(struct dentry *workdir, struct dentry *upperdir)
 /* err < 0, 0 if no metacopy xattr, 1 if metacopy xattr found */
 int ovl_check_metacopy_xattr(struct dentry *dentry)
 {
-	int res;
+	ssize_t res;
 
 	/* Only regular files can have metacopy xattr */
 	if (!S_ISREG(d_inode(dentry)->i_mode))
 		return 0;
 
-	res = vfs_getxattr(dentry, OVL_XATTR_METACOPY, NULL, 0);
+	res = ovl_do_vfs_getxattr(dentry, OVL_XATTR_METACOPY, NULL, 0);
 	if (res < 0) {
 		if (res == -ENODATA || res == -EOPNOTSUPP)
 			return 0;
@@ -852,7 +859,7 @@ int ovl_check_metacopy_xattr(struct dentry *dentry)
 
 	return 1;
 out:
-	pr_warn_ratelimited("overlayfs: failed to get metacopy (%i)\n", res);
+	pr_warn_ratelimited("overlayfs: failed to get metacopy (%zi)\n", res);
 	return res;
 }
 
@@ -878,7 +885,7 @@ ssize_t ovl_getxattr(struct dentry *dentry, char *name, char **value,
 	ssize_t res;
 	char *buf = NULL;
 
-	res = vfs_getxattr(dentry, name, NULL, 0);
+	res = ovl_do_vfs_getxattr(dentry, name, NULL, 0);
 	if (res < 0) {
 		if (res == -ENODATA || res == -EOPNOTSUPP)
 			return -ENODATA;
@@ -890,7 +897,7 @@ ssize_t ovl_getxattr(struct dentry *dentry, char *name, char **value,
 		if (!buf)
 			return -ENOMEM;
 
-		res = vfs_getxattr(dentry, name, buf, res);
+		res = ovl_do_vfs_getxattr(dentry, name, buf, res);
 		if (res < 0)
 			goto fail;
 	}
-- 
2.22.0.770.g0f2c4a37fd-goog

