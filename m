Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58D95C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 19:33:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E382C2070C
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 19:33:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=android.com header.i=@android.com header.b="JgyFAcOE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E382C2070C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=android.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 721976B0008; Mon, 12 Aug 2019 15:33:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D18C6B000A; Mon, 12 Aug 2019 15:33:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 570006B000C; Mon, 12 Aug 2019 15:33:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0020.hostedemail.com [216.40.44.20])
	by kanga.kvack.org (Postfix) with ESMTP id 21CF96B0008
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 15:33:35 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id C724F8248AA1
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 19:33:34 +0000 (UTC)
X-FDA: 75814775148.27.pen97_3c3923d83785d
X-HE-Tag: pen97_3c3923d83785d
X-Filterd-Recvd-Size: 41914
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com [209.85.210.193])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 19:33:33 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id f17so46205420pfn.6
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 12:33:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=android.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=qQDoNC//YjslEeXhLjaQUVpjxLzd5OisNFvXld4ffMA=;
        b=JgyFAcOELIUHYIzQzNcL5emTl1cGBJ7Ckd5W5+A7qGMhOmxMwb9enFCVQAUJwn9WXk
         HEO6G3PDZBGM7ZSYrHzqTce0vs2TMhK1yrJPpBC7VyHujfZuRina658NxXENpEzTXHeT
         BOw3IxNzfNpElEn1V/aEyWgsCOBL48Z/wBJOlvipJBwVjixYcR6a+cslL1qldKRDamJd
         tYmtLPt6TkeSi+7JSXZcZVBpPQ7KIyHv9EttA0Ua9v4aaIJT3QUHcTGt7aZ6//Ys5SZ9
         MdH+RmaQ9tqFhtKRmU7GzOUAKMABdes0dgR0sAzrjQNeDXeAkbiK68V38Bm52N1i56pg
         DVPQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=qQDoNC//YjslEeXhLjaQUVpjxLzd5OisNFvXld4ffMA=;
        b=YebwbM1B3qy/1ISO3bj+YQ1oDspHzp9hynQvlqMi0t0GAZnlyU+iOptsCJMp18sotc
         LmRWZ+WCp+PXY9kUV79pGv0kJeW4zVd9anWul+7YTHplcpSHXOOoz1NikfvBS0iQqSZl
         idU3DwqX0ruGYOgqStUtgfiB7oxwi7rOn4+oIYp9SOzlyK3umEn4/A5tA1EzQZKHApze
         JRqwcE350wW5nT3K+j5aF9rxsFXCDT/43S9/Aei7EAAj5jO1h7PqzcY3S+vgqP6Q3KQS
         N2uFvUoQ8bfEcyi6GcJ2Hn3W+0zs/QNoD2o4IwV5h9fcpLWNwNQHEfLgde2JYruW7Jx8
         wcaA==
X-Gm-Message-State: APjAAAUIiPUTCmTa3Tlde/TCMqMQmFKgvFgdWBkfwLhTbEmRSjlD3V8f
	4yA/pnacBiq46HhLCxXfRrEOuw==
X-Google-Smtp-Source: APXvYqzjh8Zp7kAoL9WS1QvaT8Z3GJ//lW3Ykq6brHpPB8kcjwe8lOH/Ot4Fo4uDIteHdDrtCSCKzg==
X-Received: by 2002:aa7:8e17:: with SMTP id c23mr37263334pfr.227.1565638412237;
        Mon, 12 Aug 2019 12:33:32 -0700 (PDT)
Received: from nebulus.mtv.corp.google.com ([2620:15c:211:200:5404:91ba:59dc:9400])
        by smtp.gmail.com with ESMTPSA id x17sm7385598pff.62.2019.08.12.12.33.29
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 12 Aug 2019 12:33:31 -0700 (PDT)
From: Mark Salyzyn <salyzyn@android.com>
To: linux-kernel@vger.kernel.org
Cc: kernel-team@android.com,
	Mark Salyzyn <salyzyn@android.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	linux-security-module@vger.kernel.org,
	stable@vger.kernel.org,
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
	"Theodore Ts'o" <tytso@mit.edu>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	Chao Yu <yuchao0@huawei.com>,
	Miklos Szeredi <miklos@szeredi.hu>,
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
	"Darrick J. Wong" <darrick.wong@oracle.com>,
	linux-xfs@vger.kernel.org,
	Hugh Dickins <hughd@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Serge Hallyn <serge@hallyn.com>,
	James Morris <jmorris@namei.org>,
	Mimi Zohar <zohar@linux.ibm.com>,
	Paul Moore <paul@paul-moore.com>,
	Eric Paris <eparis@parisplace.org>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vyacheslav Dubeyko <slava@dubeyko.com>,
	=?UTF-8?q?Ernesto=20A=2E=20Fern=C3=A1ndez?= <ernesto.mnd.fernandez@gmail.com>,
	Mathieu Malaterre <malat@debian.org>,
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
	linux-unionfs@vger.kernel.org,
	reiserfs-devel@vger.kernel.org,
	linux-mm@kvack.org,
	netdev@vger.kernel.org,
	linux-integrity@vger.kernel.org,
	selinux@vger.kernel.org
Subject: [PATCH] Add flags option to get xattr method paired to __vfs_getxattr
Date: Mon, 12 Aug 2019 12:32:49 -0700
Message-Id: <20190812193320.200472-1-salyzyn@android.com>
X-Mailer: git-send-email 2.23.0.rc1.153.gdeed80330f-goog
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add a flag option to get xattr method that could have a bit flag of
XATTR_NOSECURITY passed to it.  XATTR_NOSECURITY is generally then
set in the __vfs_getxattr path.

This handles the case of a union filesystem driver that is being
requested by the security layer to report back the xattr data.

For the use case where access is to be blocked by the security layer.

The path then could be security(dentry) ->
__vfs_getxattr(dentry...XATTR_NOSECUIRTY) ->
handler->get(dentry...XATTR_NOSECURITY) ->
__vfs_getxattr(lower_dentry...XATTR_NOSECUIRTY) ->
lower_handler->get(lower_dentry...XATTR_NOSECUIRTY)
which would report back through the chain data and success as
expected, the logging security layer at the top would have the
data to determine the access permissions and report back the target
context that was blocked.

Without the get handler flag, the path on a union filesystem would be
the errant security(dentry) -> __vfs_getxattr(dentry) ->
handler->get(dentry) -> vfs_getxattr(lower_dentry) -> nested ->
security(lower_dentry, log off) -> lower_handler->get(lower_dentry)
which would report back through the chain no data, and -EACCES.

For selinux for both cases, this would translate to a correctly
determined blocked access. In the first case with this change a correct a=
vc
log would be reported, in the second legacy case an incorrect avc log
would be reported against an uninitialized u:object_r:unlabeled:s0
context making the logs cosmetically useless for audit2allow.

This patch series is inert and is the wide-spread addition of the
flags option for xattr functions, and a replacement of _vfs_getxattr
with __vfs_getxattr(...XATTR_NOSECURITY).

Signed-off-by: Mark Salyzyn <salyzyn@android.com>
Cc: Stephen Smalley <sds@tycho.nsa.gov>
Cc: linux-kernel@vger.kernel.org
Cc: kernel-team@android.com
Cc: linux-security-module@vger.kernel.org
Cc: stable@vger.kernel.org # 4.4, 4.9, 4.14 & 4.19
---
Removed from an overlayfs patch set, and made independent.
Expect this to be the basis of some security improvements.
---
 fs/9p/acl.c                       |  3 ++-
 fs/9p/xattr.c                     |  3 ++-
 fs/afs/xattr.c                    |  6 +++---
 fs/btrfs/xattr.c                  |  3 ++-
 fs/ceph/xattr.c                   |  3 ++-
 fs/cifs/xattr.c                   |  2 +-
 fs/ecryptfs/inode.c               |  6 ++++--
 fs/ecryptfs/mmap.c                |  2 +-
 fs/ext2/xattr_trusted.c           |  2 +-
 fs/ext2/xattr_user.c              |  2 +-
 fs/ext4/xattr_security.c          |  2 +-
 fs/ext4/xattr_trusted.c           |  2 +-
 fs/ext4/xattr_user.c              |  2 +-
 fs/f2fs/xattr.c                   |  4 ++--
 fs/fuse/xattr.c                   |  4 ++--
 fs/gfs2/xattr.c                   |  3 ++-
 fs/hfs/attr.c                     |  2 +-
 fs/hfsplus/xattr.c                |  3 ++-
 fs/hfsplus/xattr_trusted.c        |  3 ++-
 fs/hfsplus/xattr_user.c           |  3 ++-
 fs/jffs2/security.c               |  3 ++-
 fs/jffs2/xattr_trusted.c          |  3 ++-
 fs/jffs2/xattr_user.c             |  3 ++-
 fs/jfs/xattr.c                    |  5 +++--
 fs/kernfs/inode.c                 |  3 ++-
 fs/nfs/nfs4proc.c                 |  6 ++++--
 fs/ocfs2/xattr.c                  |  9 +++++---
 fs/orangefs/xattr.c               |  3 ++-
 fs/overlayfs/super.c              |  8 ++++---
 fs/posix_acl.c                    |  2 +-
 fs/reiserfs/xattr_security.c      |  3 ++-
 fs/reiserfs/xattr_trusted.c       |  3 ++-
 fs/reiserfs/xattr_user.c          |  3 ++-
 fs/squashfs/xattr.c               |  2 +-
 fs/xattr.c                        | 36 +++++++++++++++----------------
 fs/xfs/xfs_xattr.c                |  3 ++-
 include/linux/xattr.h             |  9 ++++----
 include/uapi/linux/xattr.h        |  5 +++--
 mm/shmem.c                        |  3 ++-
 net/socket.c                      |  3 ++-
 security/commoncap.c              |  6 ++++--
 security/integrity/evm/evm_main.c |  3 ++-
 security/selinux/hooks.c          | 11 ++++++----
 security/smack/smack_lsm.c        |  5 +++--
 44 files changed, 119 insertions(+), 81 deletions(-)

diff --git a/fs/9p/acl.c b/fs/9p/acl.c
index 6261719f6f2a..cb14e8b312bc 100644
--- a/fs/9p/acl.c
+++ b/fs/9p/acl.c
@@ -214,7 +214,8 @@ int v9fs_acl_mode(struct inode *dir, umode_t *modep,
=20
 static int v9fs_xattr_get_acl(const struct xattr_handler *handler,
 			      struct dentry *dentry, struct inode *inode,
-			      const char *name, void *buffer, size_t size)
+			      const char *name, void *buffer, size_t size,
+			      int flags)
 {
 	struct v9fs_session_info *v9ses;
 	struct posix_acl *acl;
diff --git a/fs/9p/xattr.c b/fs/9p/xattr.c
index ac8ff8ca4c11..5cfa772452fd 100644
--- a/fs/9p/xattr.c
+++ b/fs/9p/xattr.c
@@ -139,7 +139,8 @@ ssize_t v9fs_listxattr(struct dentry *dentry, char *b=
uffer, size_t buffer_size)
=20
 static int v9fs_xattr_handler_get(const struct xattr_handler *handler,
 				  struct dentry *dentry, struct inode *inode,
-				  const char *name, void *buffer, size_t size)
+				  const char *name, void *buffer, size_t size,
+				  int flags)
 {
 	const char *full_name =3D xattr_full_name(handler, name);
=20
diff --git a/fs/afs/xattr.c b/fs/afs/xattr.c
index 5552d034090a..e6509c21f08a 100644
--- a/fs/afs/xattr.c
+++ b/fs/afs/xattr.c
@@ -334,7 +334,7 @@ static const struct xattr_handler afs_xattr_yfs_handl=
er =3D {
 static int afs_xattr_get_cell(const struct xattr_handler *handler,
 			      struct dentry *dentry,
 			      struct inode *inode, const char *name,
-			      void *buffer, size_t size)
+			      void *buffer, size_t size, int flags)
 {
 	struct afs_vnode *vnode =3D AFS_FS_I(inode);
 	struct afs_cell *cell =3D vnode->volume->cell;
@@ -361,7 +361,7 @@ static const struct xattr_handler afs_xattr_afs_cell_=
handler =3D {
 static int afs_xattr_get_fid(const struct xattr_handler *handler,
 			     struct dentry *dentry,
 			     struct inode *inode, const char *name,
-			     void *buffer, size_t size)
+			     void *buffer, size_t size, int flags)
 {
 	struct afs_vnode *vnode =3D AFS_FS_I(inode);
 	char text[16 + 1 + 24 + 1 + 8 + 1];
@@ -397,7 +397,7 @@ static const struct xattr_handler afs_xattr_afs_fid_h=
andler =3D {
 static int afs_xattr_get_volume(const struct xattr_handler *handler,
 			      struct dentry *dentry,
 			      struct inode *inode, const char *name,
-			      void *buffer, size_t size)
+			      void *buffer, size_t size, int flags)
 {
 	struct afs_vnode *vnode =3D AFS_FS_I(inode);
 	const char *volname =3D vnode->volume->name;
diff --git a/fs/btrfs/xattr.c b/fs/btrfs/xattr.c
index 95d9aebff2c4..1e522e145344 100644
--- a/fs/btrfs/xattr.c
+++ b/fs/btrfs/xattr.c
@@ -353,7 +353,8 @@ ssize_t btrfs_listxattr(struct dentry *dentry, char *=
buffer, size_t size)
=20
 static int btrfs_xattr_handler_get(const struct xattr_handler *handler,
 				   struct dentry *unused, struct inode *inode,
-				   const char *name, void *buffer, size_t size)
+				   const char *name, void *buffer, size_t size,
+				   int flags)
 {
 	name =3D xattr_full_name(handler, name);
 	return btrfs_getxattr(inode, name, buffer, size);
diff --git a/fs/ceph/xattr.c b/fs/ceph/xattr.c
index 37b458a9af3a..edb7eb9ae83e 100644
--- a/fs/ceph/xattr.c
+++ b/fs/ceph/xattr.c
@@ -1171,7 +1171,8 @@ int __ceph_setxattr(struct inode *inode, const char=
 *name,
=20
 static int ceph_get_xattr_handler(const struct xattr_handler *handler,
 				  struct dentry *dentry, struct inode *inode,
-				  const char *name, void *value, size_t size)
+				  const char *name, void *value, size_t size,
+				  int flags)
 {
 	if (!ceph_is_valid_xattr(name))
 		return -EOPNOTSUPP;
diff --git a/fs/cifs/xattr.c b/fs/cifs/xattr.c
index 9076150758d8..7f71c06ce631 100644
--- a/fs/cifs/xattr.c
+++ b/fs/cifs/xattr.c
@@ -199,7 +199,7 @@ static int cifs_creation_time_get(struct dentry *dent=
ry, struct inode *inode,
=20
 static int cifs_xattr_get(const struct xattr_handler *handler,
 			  struct dentry *dentry, struct inode *inode,
-			  const char *name, void *value, size_t size)
+			  const char *name, void *value, size_t size, int flags)
 {
 	ssize_t rc =3D -EOPNOTSUPP;
 	unsigned int xid;
diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
index 18426f4855f1..c710c7533729 100644
--- a/fs/ecryptfs/inode.c
+++ b/fs/ecryptfs/inode.c
@@ -1018,7 +1018,8 @@ ecryptfs_getxattr_lower(struct dentry *lower_dentry=
, struct inode *lower_inode,
 		goto out;
 	}
 	inode_lock(lower_inode);
-	rc =3D __vfs_getxattr(lower_dentry, lower_inode, name, value, size);
+	rc =3D __vfs_getxattr(lower_dentry, lower_inode, name, value, size,
+			    XATTR_NOSECURITY);
 	inode_unlock(lower_inode);
 out:
 	return rc;
@@ -1103,7 +1104,8 @@ const struct inode_operations ecryptfs_main_iops =3D=
 {
=20
 static int ecryptfs_xattr_get(const struct xattr_handler *handler,
 			      struct dentry *dentry, struct inode *inode,
-			      const char *name, void *buffer, size_t size)
+			      const char *name, void *buffer, size_t size,
+			      int flags)
 {
 	return ecryptfs_getxattr(dentry, inode, name, buffer, size);
 }
diff --git a/fs/ecryptfs/mmap.c b/fs/ecryptfs/mmap.c
index cffa0c1ec829..2362be3e3b4d 100644
--- a/fs/ecryptfs/mmap.c
+++ b/fs/ecryptfs/mmap.c
@@ -422,7 +422,7 @@ static int ecryptfs_write_inode_size_to_xattr(struct =
inode *ecryptfs_inode)
 	}
 	inode_lock(lower_inode);
 	size =3D __vfs_getxattr(lower_dentry, lower_inode, ECRYPTFS_XATTR_NAME,
-			      xattr_virt, PAGE_SIZE);
+			      xattr_virt, PAGE_SIZE, XATTR_NOSECURITY);
 	if (size < 0)
 		size =3D 8;
 	put_unaligned_be64(i_size_read(ecryptfs_inode), xattr_virt);
diff --git a/fs/ext2/xattr_trusted.c b/fs/ext2/xattr_trusted.c
index 49add1107850..8d313664f0fa 100644
--- a/fs/ext2/xattr_trusted.c
+++ b/fs/ext2/xattr_trusted.c
@@ -18,7 +18,7 @@ ext2_xattr_trusted_list(struct dentry *dentry)
 static int
 ext2_xattr_trusted_get(const struct xattr_handler *handler,
 		       struct dentry *unused, struct inode *inode,
-		       const char *name, void *buffer, size_t size)
+		       const char *name, void *buffer, size_t size, int flags)
 {
 	return ext2_xattr_get(inode, EXT2_XATTR_INDEX_TRUSTED, name,
 			      buffer, size);
diff --git a/fs/ext2/xattr_user.c b/fs/ext2/xattr_user.c
index c243a3b4d69d..712b7c95cc64 100644
--- a/fs/ext2/xattr_user.c
+++ b/fs/ext2/xattr_user.c
@@ -20,7 +20,7 @@ ext2_xattr_user_list(struct dentry *dentry)
 static int
 ext2_xattr_user_get(const struct xattr_handler *handler,
 		    struct dentry *unused, struct inode *inode,
-		    const char *name, void *buffer, size_t size)
+		    const char *name, void *buffer, size_t size, int flags)
 {
 	if (!test_opt(inode->i_sb, XATTR_USER))
 		return -EOPNOTSUPP;
diff --git a/fs/ext4/xattr_security.c b/fs/ext4/xattr_security.c
index 197a9d8a15ef..50fb71393fb6 100644
--- a/fs/ext4/xattr_security.c
+++ b/fs/ext4/xattr_security.c
@@ -15,7 +15,7 @@
 static int
 ext4_xattr_security_get(const struct xattr_handler *handler,
 			struct dentry *unused, struct inode *inode,
-			const char *name, void *buffer, size_t size)
+			const char *name, void *buffer, size_t size, int flags)
 {
 	return ext4_xattr_get(inode, EXT4_XATTR_INDEX_SECURITY,
 			      name, buffer, size);
diff --git a/fs/ext4/xattr_trusted.c b/fs/ext4/xattr_trusted.c
index e9389e5d75c3..64bd8f86c1f1 100644
--- a/fs/ext4/xattr_trusted.c
+++ b/fs/ext4/xattr_trusted.c
@@ -22,7 +22,7 @@ ext4_xattr_trusted_list(struct dentry *dentry)
 static int
 ext4_xattr_trusted_get(const struct xattr_handler *handler,
 		       struct dentry *unused, struct inode *inode,
-		       const char *name, void *buffer, size_t size)
+		       const char *name, void *buffer, size_t size, int flags)
 {
 	return ext4_xattr_get(inode, EXT4_XATTR_INDEX_TRUSTED,
 			      name, buffer, size);
diff --git a/fs/ext4/xattr_user.c b/fs/ext4/xattr_user.c
index d4546184b34b..b7301373820e 100644
--- a/fs/ext4/xattr_user.c
+++ b/fs/ext4/xattr_user.c
@@ -21,7 +21,7 @@ ext4_xattr_user_list(struct dentry *dentry)
 static int
 ext4_xattr_user_get(const struct xattr_handler *handler,
 		    struct dentry *unused, struct inode *inode,
-		    const char *name, void *buffer, size_t size)
+		    const char *name, void *buffer, size_t size, int flags)
 {
 	if (!test_opt(inode->i_sb, XATTR_USER))
 		return -EOPNOTSUPP;
diff --git a/fs/f2fs/xattr.c b/fs/f2fs/xattr.c
index b32c45621679..76559da8dfba 100644
--- a/fs/f2fs/xattr.c
+++ b/fs/f2fs/xattr.c
@@ -24,7 +24,7 @@
=20
 static int f2fs_xattr_generic_get(const struct xattr_handler *handler,
 		struct dentry *unused, struct inode *inode,
-		const char *name, void *buffer, size_t size)
+		const char *name, void *buffer, size_t size, int flags)
 {
 	struct f2fs_sb_info *sbi =3D F2FS_SB(inode->i_sb);
=20
@@ -79,7 +79,7 @@ static bool f2fs_xattr_trusted_list(struct dentry *dent=
ry)
=20
 static int f2fs_xattr_advise_get(const struct xattr_handler *handler,
 		struct dentry *unused, struct inode *inode,
-		const char *name, void *buffer, size_t size)
+		const char *name, void *buffer, size_t size, int flags)
 {
 	if (buffer)
 		*((char *)buffer) =3D F2FS_I(inode)->i_advise;
diff --git a/fs/fuse/xattr.c b/fs/fuse/xattr.c
index 433717640f78..d1ef7808304e 100644
--- a/fs/fuse/xattr.c
+++ b/fs/fuse/xattr.c
@@ -176,7 +176,7 @@ int fuse_removexattr(struct inode *inode, const char =
*name)
=20
 static int fuse_xattr_get(const struct xattr_handler *handler,
 			 struct dentry *dentry, struct inode *inode,
-			 const char *name, void *value, size_t size)
+			 const char *name, void *value, size_t size, int flags)
 {
 	return fuse_getxattr(inode, name, value, size);
 }
@@ -199,7 +199,7 @@ static bool no_xattr_list(struct dentry *dentry)
=20
 static int no_xattr_get(const struct xattr_handler *handler,
 			struct dentry *dentry, struct inode *inode,
-			const char *name, void *value, size_t size)
+			const char *name, void *value, size_t size, int flags)
 {
 	return -EOPNOTSUPP;
 }
diff --git a/fs/gfs2/xattr.c b/fs/gfs2/xattr.c
index bbe593d16bea..a9db067a99c1 100644
--- a/fs/gfs2/xattr.c
+++ b/fs/gfs2/xattr.c
@@ -588,7 +588,8 @@ static int __gfs2_xattr_get(struct inode *inode, cons=
t char *name,
=20
 static int gfs2_xattr_get(const struct xattr_handler *handler,
 			  struct dentry *unused, struct inode *inode,
-			  const char *name, void *buffer, size_t size)
+			  const char *name, void *buffer, size_t size,
+			  int flags)
 {
 	struct gfs2_inode *ip =3D GFS2_I(inode);
 	struct gfs2_holder gh;
diff --git a/fs/hfs/attr.c b/fs/hfs/attr.c
index 74fa62643136..08222a9c5d31 100644
--- a/fs/hfs/attr.c
+++ b/fs/hfs/attr.c
@@ -115,7 +115,7 @@ static ssize_t __hfs_getxattr(struct inode *inode, en=
um hfs_xattr_type type,
=20
 static int hfs_xattr_get(const struct xattr_handler *handler,
 			 struct dentry *unused, struct inode *inode,
-			 const char *name, void *value, size_t size)
+			 const char *name, void *value, size_t size, int flags)
 {
 	return __hfs_getxattr(inode, handler->flags, value, size);
 }
diff --git a/fs/hfsplus/xattr.c b/fs/hfsplus/xattr.c
index bb0b27d88e50..381c2aaedbc8 100644
--- a/fs/hfsplus/xattr.c
+++ b/fs/hfsplus/xattr.c
@@ -839,7 +839,8 @@ static int hfsplus_removexattr(struct inode *inode, c=
onst char *name)
=20
 static int hfsplus_osx_getxattr(const struct xattr_handler *handler,
 				struct dentry *unused, struct inode *inode,
-				const char *name, void *buffer, size_t size)
+				const char *name, void *buffer, size_t size,
+				int flags)
 {
 	/*
 	 * Don't allow retrieving properly prefixed attributes
diff --git a/fs/hfsplus/xattr_trusted.c b/fs/hfsplus/xattr_trusted.c
index fbad91e1dada..54d926314f8c 100644
--- a/fs/hfsplus/xattr_trusted.c
+++ b/fs/hfsplus/xattr_trusted.c
@@ -14,7 +14,8 @@
=20
 static int hfsplus_trusted_getxattr(const struct xattr_handler *handler,
 				    struct dentry *unused, struct inode *inode,
-				    const char *name, void *buffer, size_t size)
+				    const char *name, void *buffer,
+				    size_t size, int flags)
 {
 	return hfsplus_getxattr(inode, name, buffer, size,
 				XATTR_TRUSTED_PREFIX,
diff --git a/fs/hfsplus/xattr_user.c b/fs/hfsplus/xattr_user.c
index 74d19faf255e..4d2b1ffff887 100644
--- a/fs/hfsplus/xattr_user.c
+++ b/fs/hfsplus/xattr_user.c
@@ -14,7 +14,8 @@
=20
 static int hfsplus_user_getxattr(const struct xattr_handler *handler,
 				 struct dentry *unused, struct inode *inode,
-				 const char *name, void *buffer, size_t size)
+				 const char *name, void *buffer, size_t size,
+				 int flags)
 {
=20
 	return hfsplus_getxattr(inode, name, buffer, size,
diff --git a/fs/jffs2/security.c b/fs/jffs2/security.c
index c2332e30f218..e6f42fe435af 100644
--- a/fs/jffs2/security.c
+++ b/fs/jffs2/security.c
@@ -50,7 +50,8 @@ int jffs2_init_security(struct inode *inode, struct ino=
de *dir,
 /* ---- XATTR Handler for "security.*" ----------------- */
 static int jffs2_security_getxattr(const struct xattr_handler *handler,
 				   struct dentry *unused, struct inode *inode,
-				   const char *name, void *buffer, size_t size)
+				   const char *name, void *buffer, size_t size,
+				   int flags)
 {
 	return do_jffs2_getxattr(inode, JFFS2_XPREFIX_SECURITY,
 				 name, buffer, size);
diff --git a/fs/jffs2/xattr_trusted.c b/fs/jffs2/xattr_trusted.c
index 5d6030826c52..9dccaae549f5 100644
--- a/fs/jffs2/xattr_trusted.c
+++ b/fs/jffs2/xattr_trusted.c
@@ -18,7 +18,8 @@
=20
 static int jffs2_trusted_getxattr(const struct xattr_handler *handler,
 				  struct dentry *unused, struct inode *inode,
-				  const char *name, void *buffer, size_t size)
+				  const char *name, void *buffer, size_t size,
+				  int flags)
 {
 	return do_jffs2_getxattr(inode, JFFS2_XPREFIX_TRUSTED,
 				 name, buffer, size);
diff --git a/fs/jffs2/xattr_user.c b/fs/jffs2/xattr_user.c
index 9d027b4abcf9..c0983a3e810b 100644
--- a/fs/jffs2/xattr_user.c
+++ b/fs/jffs2/xattr_user.c
@@ -18,7 +18,8 @@
=20
 static int jffs2_user_getxattr(const struct xattr_handler *handler,
 			       struct dentry *unused, struct inode *inode,
-			       const char *name, void *buffer, size_t size)
+			       const char *name, void *buffer, size_t size,
+			       int flags)
 {
 	return do_jffs2_getxattr(inode, JFFS2_XPREFIX_USER,
 				 name, buffer, size);
diff --git a/fs/jfs/xattr.c b/fs/jfs/xattr.c
index db41e7803163..5c79a35bf62f 100644
--- a/fs/jfs/xattr.c
+++ b/fs/jfs/xattr.c
@@ -925,7 +925,7 @@ static int __jfs_xattr_set(struct inode *inode, const=
 char *name,
=20
 static int jfs_xattr_get(const struct xattr_handler *handler,
 			 struct dentry *unused, struct inode *inode,
-			 const char *name, void *value, size_t size)
+			 const char *name, void *value, size_t size, int flags)
 {
 	name =3D xattr_full_name(handler, name);
 	return __jfs_getxattr(inode, name, value, size);
@@ -942,7 +942,8 @@ static int jfs_xattr_set(const struct xattr_handler *=
handler,
=20
 static int jfs_xattr_get_os2(const struct xattr_handler *handler,
 			     struct dentry *unused, struct inode *inode,
-			     const char *name, void *value, size_t size)
+			     const char *name, void *value, size_t size,
+			     int flags)
 {
 	if (is_known_namespace(name))
 		return -EOPNOTSUPP;
diff --git a/fs/kernfs/inode.c b/fs/kernfs/inode.c
index f3f3984cce80..89db24ce644e 100644
--- a/fs/kernfs/inode.c
+++ b/fs/kernfs/inode.c
@@ -309,7 +309,8 @@ int kernfs_xattr_set(struct kernfs_node *kn, const ch=
ar *name,
=20
 static int kernfs_vfs_xattr_get(const struct xattr_handler *handler,
 				struct dentry *unused, struct inode *inode,
-				const char *suffix, void *value, size_t size)
+				const char *suffix, void *value, size_t size,
+				int flags)
 {
 	const char *name =3D xattr_full_name(handler, suffix);
 	struct kernfs_node *kn =3D inode->i_private;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1406858bae6c..1905597f86fb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7218,7 +7218,8 @@ static int nfs4_xattr_set_nfs4_acl(const struct xat=
tr_handler *handler,
=20
 static int nfs4_xattr_get_nfs4_acl(const struct xattr_handler *handler,
 				   struct dentry *unused, struct inode *inode,
-				   const char *key, void *buf, size_t buflen)
+				   const char *key, void *buf, size_t buflen,
+				   int flags)
 {
 	return nfs4_proc_get_acl(inode, buf, buflen);
 }
@@ -7243,7 +7244,8 @@ static int nfs4_xattr_set_nfs4_label(const struct x=
attr_handler *handler,
=20
 static int nfs4_xattr_get_nfs4_label(const struct xattr_handler *handler=
,
 				     struct dentry *unused, struct inode *inode,
-				     const char *key, void *buf, size_t buflen)
+				     const char *key, void *buf, size_t buflen,
+				     int flags)
 {
 	if (security_ismaclabel(key))
 		return nfs4_get_security_label(inode, buf, buflen);
diff --git a/fs/ocfs2/xattr.c b/fs/ocfs2/xattr.c
index 90c830e3758e..525835807c86 100644
--- a/fs/ocfs2/xattr.c
+++ b/fs/ocfs2/xattr.c
@@ -7242,7 +7242,8 @@ int ocfs2_init_security_and_acl(struct inode *dir,
  */
 static int ocfs2_xattr_security_get(const struct xattr_handler *handler,
 				    struct dentry *unused, struct inode *inode,
-				    const char *name, void *buffer, size_t size)
+				    const char *name, void *buffer, size_t size,
+				    int flags)
 {
 	return ocfs2_xattr_get(inode, OCFS2_XATTR_INDEX_SECURITY,
 			       name, buffer, size);
@@ -7314,7 +7315,8 @@ const struct xattr_handler ocfs2_xattr_security_han=
dler =3D {
  */
 static int ocfs2_xattr_trusted_get(const struct xattr_handler *handler,
 				   struct dentry *unused, struct inode *inode,
-				   const char *name, void *buffer, size_t size)
+				   const char *name, void *buffer, size_t size,
+				   int flags)
 {
 	return ocfs2_xattr_get(inode, OCFS2_XATTR_INDEX_TRUSTED,
 			       name, buffer, size);
@@ -7340,7 +7342,8 @@ const struct xattr_handler ocfs2_xattr_trusted_hand=
ler =3D {
  */
 static int ocfs2_xattr_user_get(const struct xattr_handler *handler,
 				struct dentry *unused, struct inode *inode,
-				const char *name, void *buffer, size_t size)
+				const char *name, void *buffer, size_t size,
+				int flags)
 {
 	struct ocfs2_super *osb =3D OCFS2_SB(inode->i_sb);
=20
diff --git a/fs/orangefs/xattr.c b/fs/orangefs/xattr.c
index bdc285aea360..ef4180bff7bb 100644
--- a/fs/orangefs/xattr.c
+++ b/fs/orangefs/xattr.c
@@ -541,7 +541,8 @@ static int orangefs_xattr_get_default(const struct xa=
ttr_handler *handler,
 				      struct inode *inode,
 				      const char *name,
 				      void *buffer,
-				      size_t size)
+				      size_t size,
+				      int flags)
 {
 	return orangefs_inode_getxattr(inode, name, buffer, size);
=20
diff --git a/fs/overlayfs/super.c b/fs/overlayfs/super.c
index b368e2e102fa..a7b21f2ea2dd 100644
--- a/fs/overlayfs/super.c
+++ b/fs/overlayfs/super.c
@@ -854,7 +854,7 @@ static unsigned int ovl_split_lowerdirs(char *str)
 static int __maybe_unused
 ovl_posix_acl_xattr_get(const struct xattr_handler *handler,
 			struct dentry *dentry, struct inode *inode,
-			const char *name, void *buffer, size_t size)
+			const char *name, void *buffer, size_t size, int flags)
 {
 	return ovl_xattr_get(dentry, inode, handler->name, buffer, size);
 }
@@ -919,7 +919,8 @@ ovl_posix_acl_xattr_set(const struct xattr_handler *h=
andler,
=20
 static int ovl_own_xattr_get(const struct xattr_handler *handler,
 			     struct dentry *dentry, struct inode *inode,
-			     const char *name, void *buffer, size_t size)
+			     const char *name, void *buffer, size_t size,
+			     int flags)
 {
 	return -EOPNOTSUPP;
 }
@@ -934,7 +935,8 @@ static int ovl_own_xattr_set(const struct xattr_handl=
er *handler,
=20
 static int ovl_other_xattr_get(const struct xattr_handler *handler,
 			       struct dentry *dentry, struct inode *inode,
-			       const char *name, void *buffer, size_t size)
+			       const char *name, void *buffer, size_t size,
+			       int flags)
 {
 	return ovl_xattr_get(dentry, inode, name, buffer, size);
 }
diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 84ad1c90d535..cd55621e570b 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -832,7 +832,7 @@ EXPORT_SYMBOL (posix_acl_to_xattr);
 static int
 posix_acl_xattr_get(const struct xattr_handler *handler,
 		    struct dentry *unused, struct inode *inode,
-		    const char *name, void *value, size_t size)
+		    const char *name, void *value, size_t size, int flags)
 {
 	struct posix_acl *acl;
 	int error;
diff --git a/fs/reiserfs/xattr_security.c b/fs/reiserfs/xattr_security.c
index 20be9a0e5870..eedfa07a4fd0 100644
--- a/fs/reiserfs/xattr_security.c
+++ b/fs/reiserfs/xattr_security.c
@@ -11,7 +11,8 @@
=20
 static int
 security_get(const struct xattr_handler *handler, struct dentry *unused,
-	     struct inode *inode, const char *name, void *buffer, size_t size)
+	     struct inode *inode, const char *name, void *buffer, size_t size,
+	     int flags)
 {
 	if (IS_PRIVATE(inode))
 		return -EPERM;
diff --git a/fs/reiserfs/xattr_trusted.c b/fs/reiserfs/xattr_trusted.c
index 5ed48da3d02b..2d11d98605dd 100644
--- a/fs/reiserfs/xattr_trusted.c
+++ b/fs/reiserfs/xattr_trusted.c
@@ -10,7 +10,8 @@
=20
 static int
 trusted_get(const struct xattr_handler *handler, struct dentry *unused,
-	    struct inode *inode, const char *name, void *buffer, size_t size)
+	    struct inode *inode, const char *name, void *buffer, size_t size,
+	    int flags)
 {
 	if (!capable(CAP_SYS_ADMIN) || IS_PRIVATE(inode))
 		return -EPERM;
diff --git a/fs/reiserfs/xattr_user.c b/fs/reiserfs/xattr_user.c
index a573ca45bacc..2a59d85c69c9 100644
--- a/fs/reiserfs/xattr_user.c
+++ b/fs/reiserfs/xattr_user.c
@@ -9,7 +9,8 @@
=20
 static int
 user_get(const struct xattr_handler *handler, struct dentry *unused,
-	 struct inode *inode, const char *name, void *buffer, size_t size)
+	 struct inode *inode, const char *name, void *buffer, size_t size,
+	 int flags)
 {
 	if (!reiserfs_xattrs_user(inode->i_sb))
 		return -EOPNOTSUPP;
diff --git a/fs/squashfs/xattr.c b/fs/squashfs/xattr.c
index e1e3f3dd5a06..d8d58c990652 100644
--- a/fs/squashfs/xattr.c
+++ b/fs/squashfs/xattr.c
@@ -204,7 +204,7 @@ static int squashfs_xattr_handler_get(const struct xa=
ttr_handler *handler,
 				      struct dentry *unused,
 				      struct inode *inode,
 				      const char *name,
-				      void *buffer, size_t size)
+				      void *buffer, size_t size, int flags)
 {
 	return squashfs_xattr_get(inode, handler->flags, name,
 		buffer, size);
diff --git a/fs/xattr.c b/fs/xattr.c
index 90dd78f0eb27..71f887518d6f 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -281,7 +281,7 @@ vfs_getxattr_alloc(struct dentry *dentry, const char =
*name, char **xattr_value,
 		return PTR_ERR(handler);
 	if (!handler->get)
 		return -EOPNOTSUPP;
-	error =3D handler->get(handler, dentry, inode, name, NULL, 0);
+	error =3D handler->get(handler, dentry, inode, name, NULL, 0, 0);
 	if (error < 0)
 		return error;
=20
@@ -292,32 +292,20 @@ vfs_getxattr_alloc(struct dentry *dentry, const cha=
r *name, char **xattr_value,
 		memset(value, 0, error + 1);
 	}
=20
-	error =3D handler->get(handler, dentry, inode, name, value, error);
+	error =3D handler->get(handler, dentry, inode, name, value, error, 0);
 	*xattr_value =3D value;
 	return error;
 }
=20
 ssize_t
 __vfs_getxattr(struct dentry *dentry, struct inode *inode, const char *n=
ame,
-	       void *value, size_t size)
+	       void *value, size_t size, int flags)
 {
 	const struct xattr_handler *handler;
-
-	handler =3D xattr_resolve_name(inode, &name);
-	if (IS_ERR(handler))
-		return PTR_ERR(handler);
-	if (!handler->get)
-		return -EOPNOTSUPP;
-	return handler->get(handler, dentry, inode, name, value, size);
-}
-EXPORT_SYMBOL(__vfs_getxattr);
-
-ssize_t
-vfs_getxattr(struct dentry *dentry, const char *name, void *value, size_=
t size)
-{
-	struct inode *inode =3D dentry->d_inode;
 	int error;
=20
+	if (flags & XATTR_NOSECURITY)
+		goto nolsm;
 	error =3D xattr_permission(inode, name, MAY_READ);
 	if (error)
 		return error;
@@ -339,7 +327,19 @@ vfs_getxattr(struct dentry *dentry, const char *name=
, void *value, size_t size)
 		return ret;
 	}
 nolsm:
-	return __vfs_getxattr(dentry, inode, name, value, size);
+	handler =3D xattr_resolve_name(inode, &name);
+	if (IS_ERR(handler))
+		return PTR_ERR(handler);
+	if (!handler->get)
+		return -EOPNOTSUPP;
+	return handler->get(handler, dentry, inode, name, value, size, flags);
+}
+EXPORT_SYMBOL(__vfs_getxattr);
+
+ssize_t
+vfs_getxattr(struct dentry *dentry, const char *name, void *value, size_=
t size)
+{
+	return __vfs_getxattr(dentry, dentry->d_inode, name, value, size, 0);
 }
 EXPORT_SYMBOL_GPL(vfs_getxattr);
=20
diff --git a/fs/xfs/xfs_xattr.c b/fs/xfs/xfs_xattr.c
index 3123b5aaad2a..cafc99c48e20 100644
--- a/fs/xfs/xfs_xattr.c
+++ b/fs/xfs/xfs_xattr.c
@@ -18,7 +18,8 @@
=20
 static int
 xfs_xattr_get(const struct xattr_handler *handler, struct dentry *unused=
,
-		struct inode *inode, const char *name, void *value, size_t size)
+		struct inode *inode, const char *name, void *value, size_t size,
+		int flags)
 {
 	int xflags =3D handler->flags;
 	struct xfs_inode *ip =3D XFS_I(inode);
diff --git a/include/linux/xattr.h b/include/linux/xattr.h
index 6dad031be3c2..4df9dcdc48c5 100644
--- a/include/linux/xattr.h
+++ b/include/linux/xattr.h
@@ -30,10 +30,10 @@ struct xattr_handler {
 	const char *prefix;
 	int flags;      /* fs private flags */
 	bool (*list)(struct dentry *dentry);
-	int (*get)(const struct xattr_handler *, struct dentry *dentry,
+	int (*get)(const struct xattr_handler *handler, struct dentry *dentry,
 		   struct inode *inode, const char *name, void *buffer,
-		   size_t size);
-	int (*set)(const struct xattr_handler *, struct dentry *dentry,
+		   size_t size, int flags);
+	int (*set)(const struct xattr_handler *handler, struct dentry *dentry,
 		   struct inode *inode, const char *name, const void *buffer,
 		   size_t size, int flags);
 };
@@ -46,7 +46,8 @@ struct xattr {
 	size_t value_len;
 };
=20
-ssize_t __vfs_getxattr(struct dentry *, struct inode *, const char *, vo=
id *, size_t);
+ssize_t __vfs_getxattr(struct dentry *dentry, struct inode *inode,
+		       const char *name, void *buffer, size_t size, int flags);
 ssize_t vfs_getxattr(struct dentry *, const char *, void *, size_t);
 ssize_t vfs_listxattr(struct dentry *d, char *list, size_t size);
 int __vfs_setxattr(struct dentry *, struct inode *, const char *, const =
void *, size_t, int);
diff --git a/include/uapi/linux/xattr.h b/include/uapi/linux/xattr.h
index c1395b5bd432..1216d777d210 100644
--- a/include/uapi/linux/xattr.h
+++ b/include/uapi/linux/xattr.h
@@ -17,8 +17,9 @@
 #if __UAPI_DEF_XATTR
 #define __USE_KERNEL_XATTR_DEFS
=20
-#define XATTR_CREATE	0x1	/* set value, fail if attr already exists */
-#define XATTR_REPLACE	0x2	/* set value, fail if attr does not exist */
+#define XATTR_CREATE	 0x1	/* set value, fail if attr already exists */
+#define XATTR_REPLACE	 0x2	/* set value, fail if attr does not exist */
+#define XATTR_NOSECURITY 0x4	/* get value, do not involve security check=
 */
 #endif
=20
 /* Namespaces */
diff --git a/mm/shmem.c b/mm/shmem.c
index 626d8c74b973..34d3818b4424 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3206,7 +3206,8 @@ static int shmem_initxattrs(struct inode *inode,
=20
 static int shmem_xattr_handler_get(const struct xattr_handler *handler,
 				   struct dentry *unused, struct inode *inode,
-				   const char *name, void *buffer, size_t size)
+				   const char *name, void *buffer, size_t size,
+				   int flags)
 {
 	struct shmem_inode_info *info =3D SHMEM_I(inode);
=20
diff --git a/net/socket.c b/net/socket.c
index 6a9ab7a8b1d2..6b0fea92dd02 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -300,7 +300,8 @@ static const struct dentry_operations sockfs_dentry_o=
perations =3D {
=20
 static int sockfs_xattr_get(const struct xattr_handler *handler,
 			    struct dentry *dentry, struct inode *inode,
-			    const char *suffix, void *value, size_t size)
+			    const char *suffix, void *value, size_t size,
+			    int flags)
 {
 	if (value) {
 		if (dentry->d_name.len + 1 > size)
diff --git a/security/commoncap.c b/security/commoncap.c
index f4ee0ae106b2..378a2f66a73d 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -297,7 +297,8 @@ int cap_inode_need_killpriv(struct dentry *dentry)
 	struct inode *inode =3D d_backing_inode(dentry);
 	int error;
=20
-	error =3D __vfs_getxattr(dentry, inode, XATTR_NAME_CAPS, NULL, 0);
+	error =3D __vfs_getxattr(dentry, inode, XATTR_NAME_CAPS, NULL, 0,
+			       XATTR_NOSECURITY);
 	return error > 0;
 }
=20
@@ -586,7 +587,8 @@ int get_vfs_caps_from_disk(const struct dentry *dentr=
y, struct cpu_vfs_cap_data
=20
 	fs_ns =3D inode->i_sb->s_user_ns;
 	size =3D __vfs_getxattr((struct dentry *)dentry, inode,
-			      XATTR_NAME_CAPS, &data, XATTR_CAPS_SZ);
+			      XATTR_NAME_CAPS, &data, XATTR_CAPS_SZ,
+			      XATTR_NOSECURITY);
 	if (size =3D=3D -ENODATA || size =3D=3D -EOPNOTSUPP)
 		/* no data, that's ok */
 		return -ENODATA;
diff --git a/security/integrity/evm/evm_main.c b/security/integrity/evm/e=
vm_main.c
index f9a81b187fae..921c8f2afcaf 100644
--- a/security/integrity/evm/evm_main.c
+++ b/security/integrity/evm/evm_main.c
@@ -100,7 +100,8 @@ static int evm_find_protected_xattrs(struct dentry *d=
entry)
 		return -EOPNOTSUPP;
=20
 	list_for_each_entry_rcu(xattr, &evm_config_xattrnames, list) {
-		error =3D __vfs_getxattr(dentry, inode, xattr->name, NULL, 0);
+		error =3D __vfs_getxattr(dentry, inode, xattr->name, NULL, 0,
+				       XATTR_NOSECURITY);
 		if (error < 0) {
 			if (error =3D=3D -ENODATA)
 				continue;
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 74dd46de01b6..b0822da0658f 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -552,7 +552,8 @@ static int sb_finish_set_opts(struct super_block *sb)
 			goto out;
 		}
=20
-		rc =3D __vfs_getxattr(root, root_inode, XATTR_NAME_SELINUX, NULL, 0);
+		rc =3D __vfs_getxattr(root, root_inode, XATTR_NAME_SELINUX, NULL,
+				    0, XATTR_NOSECURITY);
 		if (rc < 0 && rc !=3D -ENODATA) {
 			if (rc =3D=3D -EOPNOTSUPP)
 				pr_warn("SELinux: (dev %s, type "
@@ -1378,12 +1379,14 @@ static int inode_doinit_use_xattr(struct inode *i=
node, struct dentry *dentry,
 		return -ENOMEM;
=20
 	context[len] =3D '\0';
-	rc =3D __vfs_getxattr(dentry, inode, XATTR_NAME_SELINUX, context, len);
+	rc =3D __vfs_getxattr(dentry, inode, XATTR_NAME_SELINUX, context, len,
+			    XATTR_NOSECURITY);
 	if (rc =3D=3D -ERANGE) {
 		kfree(context);
=20
 		/* Need a larger buffer.  Query for the right size. */
-		rc =3D __vfs_getxattr(dentry, inode, XATTR_NAME_SELINUX, NULL, 0);
+		rc =3D __vfs_getxattr(dentry, inode, XATTR_NAME_SELINUX, NULL, 0,
+				    XATTR_NOSECURITY);
 		if (rc < 0)
 			return rc;
=20
@@ -1394,7 +1397,7 @@ static int inode_doinit_use_xattr(struct inode *ino=
de, struct dentry *dentry,
=20
 		context[len] =3D '\0';
 		rc =3D __vfs_getxattr(dentry, inode, XATTR_NAME_SELINUX,
-				    context, len);
+				    context, len, XATTR_NOSECURITY);
 	}
 	if (rc < 0) {
 		kfree(context);
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 4c5e5a438f8b..158b35772be1 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -292,7 +292,8 @@ static struct smack_known *smk_fetch(const char *name=
, struct inode *ip,
 	if (buffer =3D=3D NULL)
 		return ERR_PTR(-ENOMEM);
=20
-	rc =3D __vfs_getxattr(dp, ip, name, buffer, SMK_LONGLABEL);
+	rc =3D __vfs_getxattr(dp, ip, name, buffer, SMK_LONGLABEL,
+			    XATTR_NOSECURITY);
 	if (rc < 0)
 		skp =3D ERR_PTR(rc);
 	else if (rc =3D=3D 0)
@@ -3442,7 +3443,7 @@ static void smack_d_instantiate(struct dentry *opt_=
dentry, struct inode *inode)
 			} else {
 				rc =3D __vfs_getxattr(dp, inode,
 					XATTR_NAME_SMACKTRANSMUTE, trattr,
-					TRANS_TRUE_SIZE);
+					TRANS_TRUE_SIZE, XATTR_NOSECURITY);
 				if (rc >=3D 0 && strncmp(trattr, TRANS_TRUE,
 						       TRANS_TRUE_SIZE) !=3D 0)
 					rc =3D -EINVAL;
--=20
2.23.0.rc1.153.gdeed80330f-goog


