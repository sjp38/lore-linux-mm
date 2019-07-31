Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4FC0C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 16:58:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 68FCE208E4
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 16:58:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=android.com header.i=@android.com header.b="hDP6kaU1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 68FCE208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=android.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0867A8E0008; Wed, 31 Jul 2019 12:58:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 037F08E0001; Wed, 31 Jul 2019 12:58:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1AC68E0008; Wed, 31 Jul 2019 12:58:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id ACCA38E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 12:58:50 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e25so43652859pfn.5
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 09:58:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=mqrvp78QJlpAOzw9fgR7kExVE2j6YAgtswabVLFsEKw=;
        b=VheZ+CrAtlmb5JF4PWUVCxXx590LXO8Q+ubjzb+8ikSZFQOFrScnjMGZ1hxAJ2ppeP
         VWzAOKE8se5Qw3sKkOOK7VD/hERTUYqddAGA8vefZ/8MvTbePFrhf/HRLet7dKOFCl1O
         X3iggVKqhZA4faM7ak3/S7gBmnA6ECm2wway9GIdkR6/POUOaQSCWTGKuk1aoAiPPQRD
         BWAHJmk+/VE7ZU9l/QvgCJU2WXB+nv0k/cjlCLY9jkbrlQ/d8XJsK6A/NPA3l6lFTEzy
         EcBoFLBlbcv76whnTfs3yNKdA9XUuz1aNVhmuQl/CyYMhZhU37gWlCw/18z6aG1xck+P
         fcjw==
X-Gm-Message-State: APjAAAVgBYql7ncVrSGbLktbIh5LcqqWXtZLq1Dsb8jsCvhOyeB812Ip
	AcpY5t657/SJERF0yOeq003XIJ8j+IoKtOegKmCl8qWWfsJeeAcGiFgEaWAyOOmNcMaReOsYy0y
	BUi7FdXMoeL/yG+luBnhQTHB76R5j7m7IWsyeueVCUL2W7FIAWV3dM0/zPO7fVpcLNw==
X-Received: by 2002:a17:902:9a85:: with SMTP id w5mr121452448plp.221.1564592330347;
        Wed, 31 Jul 2019 09:58:50 -0700 (PDT)
X-Received: by 2002:a17:902:9a85:: with SMTP id w5mr121452386plp.221.1564592328987;
        Wed, 31 Jul 2019 09:58:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564592328; cv=none;
        d=google.com; s=arc-20160816;
        b=XnhBu26BOez8VLtI52Sijjc90SiwXeE6iDKvFgbmcpNICu8byVRyklnMwOpjq8+g6y
         Ggsx1hE3CJuL56aqaZ/N79nUd1oqXT+/6jO/W7OvEXcHi4OzZBRXbx1GsStafrWJymDL
         VjQi0iAuAvSmOOQZRWfsTojFEbwlZZBrTHxIT5/Fc3it7dc+ODj8+zqHBVEuQdXrrpel
         CvJEx+I/EM9jGrKWZnp/EzMVwEGrLQiFMawHozTZFz97B1S5WIzY/0LRSzV1p6kAHXjZ
         dUYHdz7BCAxZAmgL/+hqdheyDiBg3sPtpFAew89l7jXP5c0aXuTfidHxaH2X/jBu5JxE
         TaRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=mqrvp78QJlpAOzw9fgR7kExVE2j6YAgtswabVLFsEKw=;
        b=utWwzhWqmkJ1c0LmG27JltikpMj07DK0GCwMrZ2dmwW2vp8IgaOZjjzM58TU8uIwvT
         byOSvp5nDj4OqfSHo54Ip2GV2GArzzwjxAWsTDGI3zHZhcXxT8Vkk3SUcpspzYkDZcKJ
         7OtcPxYrDMO9+NyODLmE5Xl2uCuVdBWb5DbmDax+LGHGKRFXNsXEjQIw8iwy6QWv8Pg/
         v1NIV8nr6No4Jees2moIIe9iK+hAyfanfund27ctS3R/ZBuDud2hhJmpWTt/zxpmLQug
         hCd8EIcczstx+KUDTN2cikCYuH/1Ozbrr2CPbTLrAcM34jIUUIQvLpWu0KZV6wC949Zs
         oXQA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=hDP6kaU1;
       spf=pass (google.com: domain of salyzyn@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=salyzyn@android.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=android.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d2sor83674684pln.13.2019.07.31.09.58.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 09:58:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of salyzyn@android.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=hDP6kaU1;
       spf=pass (google.com: domain of salyzyn@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=salyzyn@android.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=android.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=android.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=mqrvp78QJlpAOzw9fgR7kExVE2j6YAgtswabVLFsEKw=;
        b=hDP6kaU1NcYTT8Ncbn8yYBCQdBrusiuNRh8U9KureQ4LZhhXGLpANTSfvgOfqQlZKq
         VPG7XZ4P92k/KXlBktnvxCF150d8d3KylfuVgVeKMa2iuEFsPUTMupjDUD67Z46OqmZh
         7SjvYV5dvK2PynVShna7gXH3d3FfIgcczAogHNoxzKxedgwHKSTVha6/NIazeKvyBtqo
         gZTdl1QA8a5G6h+1E1jh/03KSKvg/voO94DGIfJA6Xped+vEahzXhxfFCY/MWGvc505o
         uyMsIAWuHLM/OhdgLS35O/Xac5WdHB55F0HW+slYxtY8ijFN6K5yX0/q9GG2PxaHnXCe
         TluA==
X-Google-Smtp-Source: APXvYqxGMolBRhsvM9UzN1Lxeh7QHhb9SosmOWflXeRYxn78Bc9Zh2WWF5AnDKoq96esMVfQv4t5yg==
X-Received: by 2002:a17:902:76c7:: with SMTP id j7mr117914657plt.247.1564592328532;
        Wed, 31 Jul 2019 09:58:48 -0700 (PDT)
Received: from nebulus.mtv.corp.google.com ([2620:15c:211:200:5404:91ba:59dc:9400])
        by smtp.gmail.com with ESMTPSA id f72sm2245954pjg.10.2019.07.31.09.58.46
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 31 Jul 2019 09:58:47 -0700 (PDT)
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
Subject: [PATCH v13 3/5] overlayfs: handle XATTR_NOSECURITY flag for get xattr method
Date: Wed, 31 Jul 2019 09:57:58 -0700
Message-Id: <20190731165803.4755-4-salyzyn@android.com>
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

Because of the overlayfs getxattr recursion, the incoming inode fails
to update the selinux sid resulting in avc denials being reported
against a target context of u:object_r:unlabeled:s0.

Solution is to respond to the XATTR_NOSECURITY flag in get xattr
method that calls the __vfs_getxattr handler instead so that the
context can be read in, rather than being denied with an -EACCES
when vfs_getxattr handler is called.

For the use case where access is to be blocked by the security layer.

The path then would be security(dentry) ->
__vfs_getxattr(dentry...XATTR_NOSECURITY) ->
handler->get(dentry...XATTR_NOSECURITY) ->
__vfs_getxattr(realdentry...XATTR_NOSECURITY) ->
lower_handler->get(realdentry...XATTR_NOSECURITY) which
would report back through the chain data and success as expected,
the logging security layer at the top would have the data to
determine the access permissions and report back to the logs and
the caller that the target context was blocked.

For selinux this would solve the cosmetic issue of the selinux log
and allow audit2allow to correctly report the rule needed to address
the access problem.

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
v13 - rebase to use __vfs_getxattr flags option.

v12 - Added back to patch series as get xattr with flag option.

v11 - Squashed out of patch series and replaced with per-thread flag
      solution.

v10 - Added to patch series as __get xattr method.
---
 fs/overlayfs/inode.c     | 5 +++--
 fs/overlayfs/overlayfs.h | 2 +-
 fs/overlayfs/super.c     | 4 ++--
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/overlayfs/inode.c b/fs/overlayfs/inode.c
index 7663aeb85fa3..1bf11ae44313 100644
--- a/fs/overlayfs/inode.c
+++ b/fs/overlayfs/inode.c
@@ -363,7 +363,7 @@ int ovl_xattr_set(struct dentry *dentry, struct inode *inode, const char *name,
 }
 
 int ovl_xattr_get(struct dentry *dentry, struct inode *inode, const char *name,
-		  void *value, size_t size)
+		  void *value, size_t size, int flags)
 {
 	ssize_t res;
 	const struct cred *old_cred;
@@ -371,7 +371,8 @@ int ovl_xattr_get(struct dentry *dentry, struct inode *inode, const char *name,
 		ovl_i_dentry_upper(inode) ?: ovl_dentry_lower(dentry);
 
 	old_cred = ovl_override_creds(dentry->d_sb);
-	res = vfs_getxattr(realdentry, name, value, size);
+	res = __vfs_getxattr(realdentry, d_inode(realdentry), name,
+			     value, size, flags);
 	revert_creds(old_cred);
 	return res;
 }
diff --git a/fs/overlayfs/overlayfs.h b/fs/overlayfs/overlayfs.h
index 6934bcf030f0..ab3d031c422b 100644
--- a/fs/overlayfs/overlayfs.h
+++ b/fs/overlayfs/overlayfs.h
@@ -356,7 +356,7 @@ int ovl_permission(struct inode *inode, int mask);
 int ovl_xattr_set(struct dentry *dentry, struct inode *inode, const char *name,
 		  const void *value, size_t size, int flags);
 int ovl_xattr_get(struct dentry *dentry, struct inode *inode, const char *name,
-		  void *value, size_t size);
+		  void *value, size_t size, int flags);
 ssize_t ovl_listxattr(struct dentry *dentry, char *list, size_t size);
 struct posix_acl *ovl_get_acl(struct inode *inode, int type);
 int ovl_update_time(struct inode *inode, struct timespec64 *ts, int flags);
diff --git a/fs/overlayfs/super.c b/fs/overlayfs/super.c
index a7b21f2ea2dd..6f041e1fceda 100644
--- a/fs/overlayfs/super.c
+++ b/fs/overlayfs/super.c
@@ -856,7 +856,7 @@ ovl_posix_acl_xattr_get(const struct xattr_handler *handler,
 			struct dentry *dentry, struct inode *inode,
 			const char *name, void *buffer, size_t size, int flags)
 {
-	return ovl_xattr_get(dentry, inode, handler->name, buffer, size);
+	return ovl_xattr_get(dentry, inode, handler->name, buffer, size, flags);
 }
 
 static int __maybe_unused
@@ -938,7 +938,7 @@ static int ovl_other_xattr_get(const struct xattr_handler *handler,
 			       const char *name, void *buffer, size_t size,
 			       int flags)
 {
-	return ovl_xattr_get(dentry, inode, name, buffer, size);
+	return ovl_xattr_get(dentry, inode, name, buffer, size, flags);
 }
 
 static int ovl_other_xattr_set(const struct xattr_handler *handler,
-- 
2.22.0.770.g0f2c4a37fd-goog

