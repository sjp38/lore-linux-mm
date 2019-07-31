Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78949C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 16:59:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 132B720C01
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 16:59:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=android.com header.i=@android.com header.b="NxNTAM7e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 132B720C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=android.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9A5B8E000A; Wed, 31 Jul 2019 12:59:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A24018E0001; Wed, 31 Jul 2019 12:59:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 876EB8E000A; Wed, 31 Jul 2019 12:59:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 441218E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 12:59:02 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id q10so20057331pgi.9
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 09:59:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ddnpbwfJp/Jg1pT3kuq1L6l9gRs3Cs0gd96QxcsmyTc=;
        b=WA9w3sQ7sbrcwjcHnfKi5VzCjPfTSOnpHeXJlLSiBK7x8KY/3ZJJeL+QXEvBKtP/wR
         7Y1DN9QdkOyyd+RgppyAMCTbSmGVQ21U6rSj89LOZrlQ7mhRUfNh5no0gjFbItdYyjGy
         cJU4lT8TNuHSZJuzagb9EPYJROFKeGMp3vmKJ4c2yzKFJ5omdv3JolNlVZJgPD32hdsk
         cXxmHN+Q8c9izHVnXVTGrKqaaN59ZZBJkYtWypzQ2SwLBEk3sXKtD6KC9+/hEhpgpcH3
         mlJEpP0DbYP5wuauUMCPO2ksUI+Y1Xr0ctmJVWY0vQ5Ijmgzec1/bxY+K6sB0UpB16yH
         NdvQ==
X-Gm-Message-State: APjAAAXcbn4FoQuW5gJzAUfyg7anhUZxWdDEUh7qBq83V6IxMzGKZ1oo
	v3JElkwnik3FWj+p504XKLXi03LdntDF/yTyWoK2tCTnniUZKytw4d3mgk9DBDSV1SDeeuB8c2C
	RAoRyrGO58vP2thCvGsLEwSD0RR1jBvimVvKMIGo47LwIjUpZQZBUOcAm/wyCpfnN3Q==
X-Received: by 2002:a63:4522:: with SMTP id s34mr113811677pga.362.1564592341680;
        Wed, 31 Jul 2019 09:59:01 -0700 (PDT)
X-Received: by 2002:a63:4522:: with SMTP id s34mr113811604pga.362.1564592339996;
        Wed, 31 Jul 2019 09:58:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564592339; cv=none;
        d=google.com; s=arc-20160816;
        b=HoiubgFNeagk9xHKPxpU9IFzqCdqbw3eFH9fK0cyxMQMnYe0zDZ0km4f+XvdmOWunx
         hlJ6wfsHpNV/XkpqpGQWJVlA5DoRLgjaqq/rwFtzSbmU9H9EaKv+tppmnWeU6qUuQsIh
         JHIdFlf9DJ3BIZOUJ2CidQFhy5C62iaRJwjm3nqlFsfZuN5ZVkHj12HGcW1QuOFRFLSm
         aCYtqOlO4F4Ti4+GrFVms6u9DmaA3vyDgc7QXoB6gqqcMByR60pmd0KFgwHKYpOoc+IR
         qmpLzpKkGZhB1jbX7YGg0+zz1am0SET0uAEKUxn9/punVXLJaQnWMer4Go8LNDus3YFT
         7UAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ddnpbwfJp/Jg1pT3kuq1L6l9gRs3Cs0gd96QxcsmyTc=;
        b=qSYFx3eth8Lawj71Cc1DwBC37HWjxlD56h098/Z6lZw8WA5s3teUj1Onf7VMYah1ep
         OhcGy9Qs9HDWSoFAhRm8K62G1yW+ypuBpHHFYnwvkOs4K/J9jcgIfbyaFjpklt0jGwnk
         JQl9eMvnD6frc8YxRkzyey1Bwkf5ntrpxAhLkaLMXHQd9LWAZm57obVUAObbEqLM+tY+
         KiYsf1XmLhplXba0+q5jypkdP7++ftOr0pIs/NTn3ie5OgzDEIO5XSEHaVgu2PlLwr6z
         eL227urHsGUd6OVPAO5+E4i7dGCm4AHXb3BgmsPmy7cWtC2wLkoW4DqOo5q1dQSrjLYE
         o4Ng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=NxNTAM7e;
       spf=pass (google.com: domain of salyzyn@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=salyzyn@android.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=android.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f9sor82460297plr.31.2019.07.31.09.58.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 09:58:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of salyzyn@android.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=NxNTAM7e;
       spf=pass (google.com: domain of salyzyn@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=salyzyn@android.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=android.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=android.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ddnpbwfJp/Jg1pT3kuq1L6l9gRs3Cs0gd96QxcsmyTc=;
        b=NxNTAM7ePY8xngcq2yrLiNdxT7CuMygtVKpGXjyTP1843Lxq3fuRcpO356BEw65bML
         cslir7uf6cvVuCP9q4xsk5uosGElWGirNimNzKrc650HUmz1fcBB61CoIH5xL+D6t+CN
         lkgiXjR28DexwU9n5MUD3Rjni5SxfQKoEMJtAXxirw4R0yG+pAisAOWmheolYpwp53ID
         4zZ50cuVIfn/XOJq39llAkPYw0YtG0AM8a81+qWkiTu+RGung173hM1OoZAbjwJnu0ik
         UAxNyUzM3oGCOwLas54+/ewVgWOJ+RFTHxNEgnLne0IkbzKnN487Iy0JoBLRQK2Hoy+6
         RnyQ==
X-Google-Smtp-Source: APXvYqw/fnityvjNohJ2x3SxdKBfN0+54rDA11lGujd0yUSK2/q6bwTxrbWfMZk+DO1MQPqz4TBhTA==
X-Received: by 2002:a17:902:694a:: with SMTP id k10mr120262361plt.255.1564592339473;
        Wed, 31 Jul 2019 09:58:59 -0700 (PDT)
Received: from nebulus.mtv.corp.google.com ([2620:15c:211:200:5404:91ba:59dc:9400])
        by smtp.gmail.com with ESMTPSA id f72sm2245954pjg.10.2019.07.31.09.58.57
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 31 Jul 2019 09:58:58 -0700 (PDT)
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
Subject: [PATCH v13 5/5] overlayfs: override_creds=off option bypass creator_cred
Date: Wed, 31 Jul 2019 09:58:00 -0700
Message-Id: <20190731165803.4755-6-salyzyn@android.com>
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

By default, all access to the upper, lower and work directories is the
recorded mounter's MAC and DAC credentials.  The incoming accesses are
checked against the caller's credentials.

If the principles of least privilege are applied, the mounter's
credentials might not overlap the credentials of the caller's when
accessing the overlayfs filesystem.  For example, a file that a lower
DAC privileged caller can execute, is MAC denied to the generally
higher DAC privileged mounter, to prevent an attack vector.

We add the option to turn off override_creds in the mount options; all
subsequent operations after mount on the filesystem will be only the
caller's credentials.  The module boolean parameter and mount option
override_creds is also added as a presence check for this "feature",
existence of /sys/module/overlay/parameters/override_creds.

It was not always this way.  Circa 4.6 there was no recorded mounter's
credentials, instead privileged access to upper or work directories
were temporarily increased to perform the operations.  The MAC
(selinux) policies were caller's in all cases.  override_creds=off
partially returns us to this older access model minus the insecure
temporary credential increases.  This is to permit use in a system
with non-overlapping security models for each executable including
the agent that mounts the overlayfs filesystem.  In Android
this is the case since init, which performs the mount operations,
has a minimal MAC set of privileges to reduce any attack surface,
and services that use the content have a different set of MAC
privileges (eg: read, for vendor labelled configuration, execute for
vendor libraries and modules).  The caveats are not a problem in
the Android usage model, however they should be fixed for
completeness and for general use in time.

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
Cc: stable@vger.kernel.org # 4.4, 4.9, 4.14 & 4.19 NB: this is a desired feature
---
v12 + v13:
- Rebase

v11:
- add sb argument to ovl_revert_creds to match future work

v10:
- Rebase (and expand because of increased revert_cred usage)

v9:
- Add to the caveats

v8:
- drop pr_warn message after straw poll to remove it.
- added a use case in the commit message

v7:
- change name of internal parameter to ovl_override_creds_def
- report override_creds only if different than default

v6:
- Drop CONFIG_OVERLAY_FS_OVERRIDE_CREDS.
- Do better with the documentation.
- pr_warn message adjusted to report consequences.

v5:
- beefed up the caveats in the Documentation
- Is dependent on
  "overlayfs: check CAP_DAC_READ_SEARCH before issuing exportfs_decode_fh"
  "overlayfs: check CAP_MKNOD before issuing vfs_whiteout"
- Added prwarn when override_creds=off

v4:
- spelling and grammar errors in text

v3:
- Change name from caller_credentials / creator_credentials to the
  boolean override_creds.
- Changed from creator to mounter credentials.
- Updated and fortified the documentation.
- Added CONFIG_OVERLAY_FS_OVERRIDE_CREDS

v2:
- Forward port changed attr to stat, resulting in a build error.
- altered commit message.
---
 Documentation/filesystems/overlayfs.txt | 23 +++++++++++++++++++++++
 fs/overlayfs/copy_up.c                  |  2 +-
 fs/overlayfs/dir.c                      | 11 ++++++-----
 fs/overlayfs/file.c                     | 20 ++++++++++----------
 fs/overlayfs/inode.c                    | 18 +++++++++---------
 fs/overlayfs/namei.c                    |  6 +++---
 fs/overlayfs/overlayfs.h                |  1 +
 fs/overlayfs/ovl_entry.h                |  1 +
 fs/overlayfs/readdir.c                  |  4 ++--
 fs/overlayfs/super.c                    | 22 +++++++++++++++++++++-
 fs/overlayfs/util.c                     | 12 ++++++++++--
 11 files changed, 87 insertions(+), 33 deletions(-)

diff --git a/Documentation/filesystems/overlayfs.txt b/Documentation/filesystems/overlayfs.txt
index 1da2f1668f08..d48125076602 100644
--- a/Documentation/filesystems/overlayfs.txt
+++ b/Documentation/filesystems/overlayfs.txt
@@ -102,6 +102,29 @@ Only the lists of names from directories are merged.  Other content
 such as metadata and extended attributes are reported for the upper
 directory only.  These attributes of the lower directory are hidden.
 
+credentials
+-----------
+
+By default, all access to the upper, lower and work directories is the
+recorded mounter's MAC and DAC credentials.  The incoming accesses are
+checked against the caller's credentials.
+
+In the case where caller MAC or DAC credentials do not overlap, a
+use case available in older versions of the driver, the
+override_creds mount flag can be turned off and help when the use
+pattern has caller with legitimate credentials where the mounter
+does not.  Several unintended side effects will occur though.  The
+caller without certain key capabilities or lower privilege will not
+always be able to delete files or directories, create nodes, or
+search some restricted directories.  The ability to search and read
+a directory entry is spotty as a result of the cache mechanism not
+retesting the credentials because of the assumption, a privileged
+caller can fill cache, then a lower privilege can read the directory
+cache.  The uneven security model where cache, upperdir and workdir
+are opened at privilege, but accessed without creating a form of
+privilege escalation, should only be used with strict understanding
+of the side effects and of the security policies.
+
 whiteouts and opaque directories
 --------------------------------
 
diff --git a/fs/overlayfs/copy_up.c b/fs/overlayfs/copy_up.c
index b801c6353100..1c1b9415e533 100644
--- a/fs/overlayfs/copy_up.c
+++ b/fs/overlayfs/copy_up.c
@@ -886,7 +886,7 @@ int ovl_copy_up_flags(struct dentry *dentry, int flags)
 		dput(parent);
 		dput(next);
 	}
-	revert_creds(old_cred);
+	ovl_revert_creds(dentry->d_sb, old_cred);
 
 	return err;
 }
diff --git a/fs/overlayfs/dir.c b/fs/overlayfs/dir.c
index 702aa63f6774..49b8ffc1294f 100644
--- a/fs/overlayfs/dir.c
+++ b/fs/overlayfs/dir.c
@@ -563,7 +563,8 @@ static int ovl_create_or_link(struct dentry *dentry, struct inode *inode,
 		override_cred->fsgid = inode->i_gid;
 		if (!attr->hardlink) {
 			err = security_dentry_create_files_as(dentry,
-					attr->mode, &dentry->d_name, old_cred,
+					attr->mode, &dentry->d_name,
+					old_cred ? old_cred : current_cred(),
 					override_cred);
 			if (err) {
 				put_cred(override_cred);
@@ -579,7 +580,7 @@ static int ovl_create_or_link(struct dentry *dentry, struct inode *inode,
 			err = ovl_create_over_whiteout(dentry, inode, attr);
 	}
 out_revert_creds:
-	revert_creds(old_cred);
+	ovl_revert_creds(dentry->d_sb, old_cred);
 	return err;
 }
 
@@ -655,7 +656,7 @@ static int ovl_set_link_redirect(struct dentry *dentry)
 
 	old_cred = ovl_override_creds(dentry->d_sb);
 	err = ovl_set_redirect(dentry, false);
-	revert_creds(old_cred);
+	ovl_revert_creds(dentry->d_sb, old_cred);
 
 	return err;
 }
@@ -851,7 +852,7 @@ static int ovl_do_remove(struct dentry *dentry, bool is_dir)
 		err = ovl_remove_upper(dentry, is_dir, &list);
 	else
 		err = ovl_remove_and_whiteout(dentry, &list);
-	revert_creds(old_cred);
+	ovl_revert_creds(dentry->d_sb, old_cred);
 	if (!err) {
 		if (is_dir)
 			clear_nlink(dentry->d_inode);
@@ -1221,7 +1222,7 @@ static int ovl_rename(struct inode *olddir, struct dentry *old,
 out_unlock:
 	unlock_rename(new_upperdir, old_upperdir);
 out_revert_creds:
-	revert_creds(old_cred);
+	ovl_revert_creds(old->d_sb, old_cred);
 	if (update_nlink)
 		ovl_nlink_end(new);
 out_drop_write:
diff --git a/fs/overlayfs/file.c b/fs/overlayfs/file.c
index e235a635d9ec..d94d6ec785a7 100644
--- a/fs/overlayfs/file.c
+++ b/fs/overlayfs/file.c
@@ -32,7 +32,7 @@ static struct file *ovl_open_realfile(const struct file *file,
 	old_cred = ovl_override_creds(inode->i_sb);
 	realfile = open_with_fake_path(&file->f_path, flags, realinode,
 				       current_cred());
-	revert_creds(old_cred);
+	ovl_revert_creds(inode->i_sb, old_cred);
 
 	pr_debug("open(%p[%pD2/%c], 0%o) -> (%p, 0%o)\n",
 		 file, file, ovl_whatisit(inode, realinode), file->f_flags,
@@ -176,7 +176,7 @@ static loff_t ovl_llseek(struct file *file, loff_t offset, int whence)
 
 	old_cred = ovl_override_creds(inode->i_sb);
 	ret = vfs_llseek(real.file, offset, whence);
-	revert_creds(old_cred);
+	ovl_revert_creds(inode->i_sb, old_cred);
 
 	file->f_pos = real.file->f_pos;
 	inode_unlock(inode);
@@ -242,7 +242,7 @@ static ssize_t ovl_read_iter(struct kiocb *iocb, struct iov_iter *iter)
 	old_cred = ovl_override_creds(file_inode(file)->i_sb);
 	ret = vfs_iter_read(real.file, iter, &iocb->ki_pos,
 			    ovl_iocb_to_rwf(iocb));
-	revert_creds(old_cred);
+	ovl_revert_creds(file_inode(file)->i_sb, old_cred);
 
 	ovl_file_accessed(file);
 
@@ -278,7 +278,7 @@ static ssize_t ovl_write_iter(struct kiocb *iocb, struct iov_iter *iter)
 	ret = vfs_iter_write(real.file, iter, &iocb->ki_pos,
 			     ovl_iocb_to_rwf(iocb));
 	file_end_write(real.file);
-	revert_creds(old_cred);
+	ovl_revert_creds(file_inode(file)->i_sb, old_cred);
 
 	/* Update size */
 	ovl_copyattr(ovl_inode_real(inode), inode);
@@ -305,7 +305,7 @@ static int ovl_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	if (file_inode(real.file) == ovl_inode_upper(file_inode(file))) {
 		old_cred = ovl_override_creds(file_inode(file)->i_sb);
 		ret = vfs_fsync_range(real.file, start, end, datasync);
-		revert_creds(old_cred);
+		ovl_revert_creds(file_inode(file)->i_sb, old_cred);
 	}
 
 	fdput(real);
@@ -329,7 +329,7 @@ static int ovl_mmap(struct file *file, struct vm_area_struct *vma)
 
 	old_cred = ovl_override_creds(file_inode(file)->i_sb);
 	ret = call_mmap(vma->vm_file, vma);
-	revert_creds(old_cred);
+	ovl_revert_creds(file_inode(file)->i_sb, old_cred);
 
 	if (ret) {
 		/* Drop reference count from new vm_file value */
@@ -357,7 +357,7 @@ static long ovl_fallocate(struct file *file, int mode, loff_t offset, loff_t len
 
 	old_cred = ovl_override_creds(file_inode(file)->i_sb);
 	ret = vfs_fallocate(real.file, mode, offset, len);
-	revert_creds(old_cred);
+	ovl_revert_creds(file_inode(file)->i_sb, old_cred);
 
 	/* Update size */
 	ovl_copyattr(ovl_inode_real(inode), inode);
@@ -379,7 +379,7 @@ static int ovl_fadvise(struct file *file, loff_t offset, loff_t len, int advice)
 
 	old_cred = ovl_override_creds(file_inode(file)->i_sb);
 	ret = vfs_fadvise(real.file, offset, len, advice);
-	revert_creds(old_cred);
+	ovl_revert_creds(file_inode(file)->i_sb, old_cred);
 
 	fdput(real);
 
@@ -399,7 +399,7 @@ static long ovl_real_ioctl(struct file *file, unsigned int cmd,
 
 	old_cred = ovl_override_creds(file_inode(file)->i_sb);
 	ret = vfs_ioctl(real.file, cmd, arg);
-	revert_creds(old_cred);
+	ovl_revert_creds(file_inode(file)->i_sb, old_cred);
 
 	fdput(real);
 
@@ -589,7 +589,7 @@ static loff_t ovl_copyfile(struct file *file_in, loff_t pos_in,
 						flags);
 		break;
 	}
-	revert_creds(old_cred);
+	ovl_revert_creds(file_inode(file_out)->i_sb, old_cred);
 
 	/* Update size */
 	ovl_copyattr(ovl_inode_real(inode_out), inode_out);
diff --git a/fs/overlayfs/inode.c b/fs/overlayfs/inode.c
index 1bf11ae44313..fc1828aa30ed 100644
--- a/fs/overlayfs/inode.c
+++ b/fs/overlayfs/inode.c
@@ -61,7 +61,7 @@ int ovl_setattr(struct dentry *dentry, struct iattr *attr)
 		inode_lock(upperdentry->d_inode);
 		old_cred = ovl_override_creds(dentry->d_sb);
 		err = notify_change(upperdentry, attr, NULL);
-		revert_creds(old_cred);
+		ovl_revert_creds(dentry->d_sb, old_cred);
 		if (!err)
 			ovl_copyattr(upperdentry->d_inode, dentry->d_inode);
 		inode_unlock(upperdentry->d_inode);
@@ -257,7 +257,7 @@ int ovl_getattr(const struct path *path, struct kstat *stat,
 		stat->nlink = dentry->d_inode->i_nlink;
 
 out:
-	revert_creds(old_cred);
+	ovl_revert_creds(dentry->d_sb, old_cred);
 
 	return err;
 }
@@ -291,7 +291,7 @@ int ovl_permission(struct inode *inode, int mask)
 		mask |= MAY_READ;
 	}
 	err = inode_permission(realinode, mask);
-	revert_creds(old_cred);
+	ovl_revert_creds(inode->i_sb, old_cred);
 
 	return err;
 }
@@ -308,7 +308,7 @@ static const char *ovl_get_link(struct dentry *dentry,
 
 	old_cred = ovl_override_creds(dentry->d_sb);
 	p = vfs_get_link(ovl_dentry_real(dentry), done);
-	revert_creds(old_cred);
+	ovl_revert_creds(dentry->d_sb, old_cred);
 	return p;
 }
 
@@ -351,7 +351,7 @@ int ovl_xattr_set(struct dentry *dentry, struct inode *inode, const char *name,
 		WARN_ON(flags != XATTR_REPLACE);
 		err = vfs_removexattr(realdentry, name);
 	}
-	revert_creds(old_cred);
+	ovl_revert_creds(dentry->d_sb, old_cred);
 
 	/* copy c/mtime */
 	ovl_copyattr(d_inode(realdentry), inode);
@@ -373,7 +373,7 @@ int ovl_xattr_get(struct dentry *dentry, struct inode *inode, const char *name,
 	old_cred = ovl_override_creds(dentry->d_sb);
 	res = __vfs_getxattr(realdentry, d_inode(realdentry), name,
 			     value, size, flags);
-	revert_creds(old_cred);
+	ovl_revert_creds(dentry->d_sb, old_cred);
 	return res;
 }
 
@@ -397,7 +397,7 @@ ssize_t ovl_listxattr(struct dentry *dentry, char *list, size_t size)
 
 	old_cred = ovl_override_creds(dentry->d_sb);
 	res = vfs_listxattr(realdentry, list, size);
-	revert_creds(old_cred);
+	ovl_revert_creds(dentry->d_sb, old_cred);
 	if (res <= 0 || size == 0)
 		return res;
 
@@ -432,7 +432,7 @@ struct posix_acl *ovl_get_acl(struct inode *inode, int type)
 
 	old_cred = ovl_override_creds(inode->i_sb);
 	acl = get_acl(realinode, type);
-	revert_creds(old_cred);
+	ovl_revert_creds(inode->i_sb, old_cred);
 
 	return acl;
 }
@@ -470,7 +470,7 @@ static int ovl_fiemap(struct inode *inode, struct fiemap_extent_info *fieinfo,
 		filemap_write_and_wait(realinode->i_mapping);
 
 	err = realinode->i_op->fiemap(realinode, fieinfo, start, len);
-	revert_creds(old_cred);
+	ovl_revert_creds(inode->i_sb, old_cred);
 
 	return err;
 }
diff --git a/fs/overlayfs/namei.c b/fs/overlayfs/namei.c
index a4a452c489fa..bab1f97dc201 100644
--- a/fs/overlayfs/namei.c
+++ b/fs/overlayfs/namei.c
@@ -1079,7 +1079,7 @@ struct dentry *ovl_lookup(struct inode *dir, struct dentry *dentry,
 			goto out_free_oe;
 	}
 
-	revert_creds(old_cred);
+	ovl_revert_creds(dentry->d_sb, old_cred);
 	if (origin_path) {
 		dput(origin_path->dentry);
 		kfree(origin_path);
@@ -1106,7 +1106,7 @@ struct dentry *ovl_lookup(struct inode *dir, struct dentry *dentry,
 	kfree(upperredirect);
 out:
 	kfree(d.redirect);
-	revert_creds(old_cred);
+	ovl_revert_creds(dentry->d_sb, old_cred);
 	return ERR_PTR(err);
 }
 
@@ -1160,7 +1160,7 @@ bool ovl_lower_positive(struct dentry *dentry)
 			dput(this);
 		}
 	}
-	revert_creds(old_cred);
+	ovl_revert_creds(dentry->d_sb, old_cred);
 
 	return positive;
 }
diff --git a/fs/overlayfs/overlayfs.h b/fs/overlayfs/overlayfs.h
index 9d26d8758513..ad1a11e7ecbd 100644
--- a/fs/overlayfs/overlayfs.h
+++ b/fs/overlayfs/overlayfs.h
@@ -205,6 +205,7 @@ int ovl_want_write(struct dentry *dentry);
 void ovl_drop_write(struct dentry *dentry);
 struct dentry *ovl_workdir(struct dentry *dentry);
 const struct cred *ovl_override_creds(struct super_block *sb);
+void ovl_revert_creds(struct super_block *sb, const struct cred *oldcred);
 ssize_t ovl_do_vfs_getxattr(struct dentry *dentry, const char *name, void *buf,
 			    size_t size);
 struct super_block *ovl_same_sb(struct super_block *sb);
diff --git a/fs/overlayfs/ovl_entry.h b/fs/overlayfs/ovl_entry.h
index 28a2d12a1029..2637c5aadf7f 100644
--- a/fs/overlayfs/ovl_entry.h
+++ b/fs/overlayfs/ovl_entry.h
@@ -17,6 +17,7 @@ struct ovl_config {
 	bool nfs_export;
 	int xino;
 	bool metacopy;
+	bool override_creds;
 };
 
 struct ovl_sb {
diff --git a/fs/overlayfs/readdir.c b/fs/overlayfs/readdir.c
index 47a91c9733a5..874a1b3ff99a 100644
--- a/fs/overlayfs/readdir.c
+++ b/fs/overlayfs/readdir.c
@@ -286,7 +286,7 @@ static int ovl_check_whiteouts(struct dentry *dir, struct ovl_readdir_data *rdd)
 		}
 		inode_unlock(dir->d_inode);
 	}
-	revert_creds(old_cred);
+	ovl_revert_creds(rdd->dentry->d_sb, old_cred);
 
 	return err;
 }
@@ -918,7 +918,7 @@ int ovl_check_empty_dir(struct dentry *dentry, struct list_head *list)
 
 	old_cred = ovl_override_creds(dentry->d_sb);
 	err = ovl_dir_read_merged(dentry, list, &root);
-	revert_creds(old_cred);
+	ovl_revert_creds(dentry->d_sb, old_cred);
 	if (err)
 		return err;
 
diff --git a/fs/overlayfs/super.c b/fs/overlayfs/super.c
index 6f041e1fceda..2c1278451f38 100644
--- a/fs/overlayfs/super.c
+++ b/fs/overlayfs/super.c
@@ -53,6 +53,11 @@ module_param_named(xino_auto, ovl_xino_auto_def, bool, 0644);
 MODULE_PARM_DESC(xino_auto,
 		 "Auto enable xino feature");
 
+static bool __read_mostly ovl_override_creds_def = true;
+module_param_named(override_creds, ovl_override_creds_def, bool, 0644);
+MODULE_PARM_DESC(ovl_override_creds_def,
+		 "Use mounter's credentials for accesses");
+
 static void ovl_entry_stack_free(struct ovl_entry *oe)
 {
 	unsigned int i;
@@ -362,6 +367,9 @@ static int ovl_show_options(struct seq_file *m, struct dentry *dentry)
 	if (ofs->config.metacopy != ovl_metacopy_def)
 		seq_printf(m, ",metacopy=%s",
 			   ofs->config.metacopy ? "on" : "off");
+	if (ofs->config.override_creds != ovl_override_creds_def)
+		seq_show_option(m, "override_creds",
+				ofs->config.override_creds ? "on" : "off");
 	return 0;
 }
 
@@ -402,6 +410,8 @@ enum {
 	OPT_XINO_AUTO,
 	OPT_METACOPY_ON,
 	OPT_METACOPY_OFF,
+	OPT_OVERRIDE_CREDS_ON,
+	OPT_OVERRIDE_CREDS_OFF,
 	OPT_ERR,
 };
 
@@ -420,6 +430,8 @@ static const match_table_t ovl_tokens = {
 	{OPT_XINO_AUTO,			"xino=auto"},
 	{OPT_METACOPY_ON,		"metacopy=on"},
 	{OPT_METACOPY_OFF,		"metacopy=off"},
+	{OPT_OVERRIDE_CREDS_ON,		"override_creds=on"},
+	{OPT_OVERRIDE_CREDS_OFF,	"override_creds=off"},
 	{OPT_ERR,			NULL}
 };
 
@@ -478,6 +490,7 @@ static int ovl_parse_opt(char *opt, struct ovl_config *config)
 	config->redirect_mode = kstrdup(ovl_redirect_mode_def(), GFP_KERNEL);
 	if (!config->redirect_mode)
 		return -ENOMEM;
+	config->override_creds = ovl_override_creds_def;
 
 	while ((p = ovl_next_opt(&opt)) != NULL) {
 		int token;
@@ -558,6 +571,14 @@ static int ovl_parse_opt(char *opt, struct ovl_config *config)
 			config->metacopy = false;
 			break;
 
+		case OPT_OVERRIDE_CREDS_ON:
+			config->override_creds = true;
+			break;
+
+		case OPT_OVERRIDE_CREDS_OFF:
+			config->override_creds = false;
+			break;
+
 		default:
 			pr_err("overlayfs: unrecognized mount option \"%s\" or missing value\n", p);
 			return -EINVAL;
@@ -1674,7 +1695,6 @@ static int ovl_fill_super(struct super_block *sb, void *data, int silent)
 		       ovl_dentry_lower(root_dentry), NULL);
 
 	sb->s_root = root_dentry;
-
 	return 0;
 
 out_free_oe:
diff --git a/fs/overlayfs/util.c b/fs/overlayfs/util.c
index c588c0d66d8c..9e97e785e44c 100644
--- a/fs/overlayfs/util.c
+++ b/fs/overlayfs/util.c
@@ -37,9 +37,17 @@ const struct cred *ovl_override_creds(struct super_block *sb)
 {
 	struct ovl_fs *ofs = sb->s_fs_info;
 
+	if (!ofs->config.override_creds)
+		return NULL;
 	return override_creds(ofs->creator_cred);
 }
 
+void ovl_revert_creds(struct super_block *sb, const struct cred *old_cred)
+{
+	if (old_cred)
+		revert_creds(old_cred);
+}
+
 ssize_t ovl_do_vfs_getxattr(struct dentry *dentry, const char *name, void *buf,
 			    size_t size)
 {
@@ -798,7 +806,7 @@ int ovl_nlink_start(struct dentry *dentry)
 	 * value relative to the upper inode nlink in an upper inode xattr.
 	 */
 	err = ovl_set_nlink_upper(dentry);
-	revert_creds(old_cred);
+	ovl_revert_creds(dentry->d_sb, old_cred);
 
 out:
 	if (err)
@@ -816,7 +824,7 @@ void ovl_nlink_end(struct dentry *dentry)
 
 		old_cred = ovl_override_creds(dentry->d_sb);
 		ovl_cleanup_index(dentry);
-		revert_creds(old_cred);
+		ovl_revert_creds(dentry->d_sb, old_cred);
 	}
 
 	ovl_inode_unlock(inode);
-- 
2.22.0.770.g0f2c4a37fd-goog

