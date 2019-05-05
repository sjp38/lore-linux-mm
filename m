Return-Path: <SRS0=X77i=TF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C656C004C9
	for <linux-mm@archiver.kernel.org>; Sun,  5 May 2019 04:57:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9A28205ED
	for <linux-mm@archiver.kernel.org>; Sun,  5 May 2019 04:57:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9A28205ED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=dimakrasner.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 598CB6B0003; Sun,  5 May 2019 00:57:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 549EC6B0006; Sun,  5 May 2019 00:57:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 439BB6B0007; Sun,  5 May 2019 00:57:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E3B5F6B0003
	for <linux-mm@kvack.org>; Sun,  5 May 2019 00:57:33 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c1so7473116edi.20
        for <linux-mm@kvack.org>; Sat, 04 May 2019 21:57:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :message-id:subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KIjtZWVE4SRnLES/sk5ccLpeSnPzKXQWtQxZnXSkHWA=;
        b=B2kpYEi9qH+9DwH9KTkiZfQos8ffwV+ni5RY5Z/Cr8MB4Gb+qu3eKZtFIk9RyU+8ce
         zPeH1EiiSW63qvZjs6gITjNAs835Q//aFIDivmi3amLM4hVxulNWRm6BI0DPNqK5KhnL
         1VhYU56cf1/Nr01g/bWxnOIs+OIbuVVN1763w8dfwNkC0e6ueFdwnR7r1ZhcBxD6DE8a
         jCaIo7aBfLompbnljJ/HS9bPYdy4pGp5A1fMoCjctq7XzvppMsKRWEd4XMdjShO5ztSF
         Fz1yMbK3XZDpu0yr2VBVwP5G10jofvpFZP+qrYyjT/K8Zznn03LABy8hc+6Nh/ZrDoh+
         1CGQ==
X-Original-Authentication-Results: mx.google.com;       arc=pass (i=1 spf=pass spfdomain=dimakrasner.com dkim=pass dkdomain=dimakrasner.com dmarc=pass fromdomain=dimakrasner.com>);       spf=pass (google.com: domain of dima@dimakrasner.com designates 135.84.80.216 as permitted sender) smtp.mailfrom=dima@dimakrasner.com
X-Gm-Message-State: APjAAAWBwzivVa3wUyLs2Y1POBxvASZOxTLrGjAGSA17PWPRFA5vVTEb
	xVCMmyT5HEKCjRm+nUI2t1JAF9R6OOt5Gk1IdjGPLYuAZbdNaof6UPpRRj5cMAT+aQ2qCgbm2JB
	+ujfGzMIODSz7nCF8Y/lSgSKDM5kM/vgD2r9zMzywXVDRSwZSdfuZQvIkoQlRse5vIw==
X-Received: by 2002:a17:906:304e:: with SMTP id d14mr13238755ejd.174.1557032253347;
        Sat, 04 May 2019 21:57:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/6iEaloSYPs2UZM12ivRf6V/+GEz8J2XqnpAhDgFbdY9L3Vv2LKCOQlUHFx8/XsrzGxX+
X-Received: by 2002:a17:906:304e:: with SMTP id d14mr13238721ejd.174.1557032252085;
        Sat, 04 May 2019 21:57:32 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1557032252; cv=pass;
        d=google.com; s=arc-20160816;
        b=pvd2VQPdbQWGDZAh37zkAr7Hqt9xY0U0zIndnvxtjpe291cZfQAlixhE2KWsRAbxO3
         AQj5yhKQPsbgTk2pxRu0+xlqMlmw87D4UCrtSnwG/oCuxBXoStuVZEVEPSuwKGe8LuZt
         3A0GLQ/eWVvPNoAjhWRXLmjipH5YtTwTwDz18PMSQMKkyndLnDeSBZM8L5jhIcfVH7G8
         5yNro1hGIdh9I4PuTd9HiLAC6ZDJ575I/fJz7xhjTba8xdyA+m8v7V+GkpvBNa5j+q+d
         NFvGrcBVvDKKP5Utx8MyMZrD+e0I4e8unNo5IWB002i4gcZ2hgwizzngz1Q61s2xXJnU
         bMYg==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :subject:message-id:cc:to:from;
        bh=KIjtZWVE4SRnLES/sk5ccLpeSnPzKXQWtQxZnXSkHWA=;
        b=SHklgakRimumLCyr9lue6YJoFYVJY9gFEpQupcRyfNmk4w5apB4josX193xFnFdhFd
         0YucRBtFrt7BjJfcrXtHhMYTRxedH4G20AOuej5Yzq5qj/WVIaPlcaBjOQ9kMnd8+6TJ
         powcZiuXJSWIGIZkESZknSvCSl+CMthWN0SR7TUhxoihLB8kFDvR6ZDX9Qb3q5DbCkBT
         UpHss16aefZRjAX21ybNr7hmv/ugeKUU7mF5XC58/xX9Xm8CyR7u/bhXpjZupqxctBhF
         8493VVbf9/gd+sDioi28mqw2s+f6209zW11uOGfNdRs+IFldDl8NbXF6MsKYPfR6rG2D
         emcQ==
ARC-Authentication-Results: i=2; mx.google.com;
       arc=pass (i=1 spf=pass spfdomain=dimakrasner.com dkim=pass dkdomain=dimakrasner.com dmarc=pass fromdomain=dimakrasner.com>);
       spf=pass (google.com: domain of dima@dimakrasner.com designates 135.84.80.216 as permitted sender) smtp.mailfrom=dima@dimakrasner.com
Received: from sender-of-o51.zoho.com (sender-of-o51.zoho.com. [135.84.80.216])
        by mx.google.com with ESMTPS id q9si138328edd.416.2019.05.04.21.57.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 May 2019 21:57:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of dima@dimakrasner.com designates 135.84.80.216 as permitted sender) client-ip=135.84.80.216;
Authentication-Results: mx.google.com;
       arc=pass (i=1 spf=pass spfdomain=dimakrasner.com dkim=pass dkdomain=dimakrasner.com dmarc=pass fromdomain=dimakrasner.com>);
       spf=pass (google.com: domain of dima@dimakrasner.com designates 135.84.80.216 as permitted sender) smtp.mailfrom=dima@dimakrasner.com
ARC-Seal: i=1; a=rsa-sha256; t=1557032243; cv=none; 
	d=zoho.com; s=zohoarc; 
	b=L5YsrAeijUcTg2v1of+l9lvBUz3RRoo13nNZ+jPEoNPVPec6i2zn4dpSKcIJNNwEMK92BDD1CTH304sF6iuEKgxOvMHPbny+CqwUgEtvpQ1DxbL46qqSWSJIWwfUXR6N/OjJ/7dKNIK3sKv+doMCzRcyFv2GQWW1ZU6iHGkC1OE=
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=zoho.com; s=zohoarc; 
	t=1557032243; h=Content-Type:Content-Transfer-Encoding:Cc:Date:From:In-Reply-To:MIME-Version:Message-ID:References:Subject:To:ARC-Authentication-Results; 
	bh=KIjtZWVE4SRnLES/sk5ccLpeSnPzKXQWtQxZnXSkHWA=; 
	b=Lgtre0SyLZOV21/j5Swvi1o5F5UCIUUAgjitJmUn6fW+NnA2vU7Jnu9nlIbLgY/oZq/TAFkgzNJK8xFg1VB/HrCrIiyUKnz58rlBfvsoFhPtxEo0spRt4g4GEK/EWlh/fa1aQ8vkgI6FSpbjeXkwfLCZ9XABo6i35z+HocbyEO0=
ARC-Authentication-Results: i=1; mx.zoho.com;
	dkim=pass  header.i=dimakrasner.com;
	spf=pass  smtp.mailfrom=dima@dimakrasner.com;
	dmarc=pass header.from=<dima@dimakrasner.com> header.from=<dima@dimakrasner.com>
Received: from hazak.localdomain (89.237.80.180 [89.237.80.180]) by mx.zohomail.com
	with SMTPS id 1557032241719266.2197311963272; Sat, 4 May 2019 21:57:21 -0700 (PDT)
From: Dima Krasner <dima@dimakrasner.com>
To: dima@dimakrasner.com
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Hugh Dickins <hughd@google.com>
Message-ID: <20190505045912.12311-1-dima@dimakrasner.com>
Subject: [PATCH v2] mm: do not grant +x by default in memfd_create()
Date: Sun,  5 May 2019 07:59:12 +0300
X-Mailer: git-send-email 2.21.0
In-Reply-To: <201905050757.M2Q7kM1M%lkp@intel.com>
References: <201905050757.M2Q7kM1M%lkp@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-ZohoMailClient: External
Content-Type: text/plain; charset=utf8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This syscall allows easy fileless execution, without calling chmod() first.
Thus, some security-related restrictions (like seccomp filters that deny
chmod +x) can by bypassed using memfd_create() if the policy author is
unaware of this.

Signed-off-by: Dima Krasner <dima@dimakrasner.com>
Cc: linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>
---
 fs/hugetlbfs/inode.c    |  5 +++--
 include/linux/hugetlb.h |  4 ++--
 include/linux/stat.h    |  1 +
 ipc/shm.c               |  3 ++-
 mm/memfd.c              |  3 ++-
 mm/mmap.c               |  3 ++-
 mm/shmem.c              | 11 ++++++-----
 7 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 9285dd4f4b1c..512ac8a226ef 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -1363,7 +1363,8 @@ static int get_hstate_idx(int page_size_log)
  */
 struct file *hugetlb_file_setup(const char *name, size_t size,
 =09=09=09=09vm_flags_t acctflag, struct user_struct **user,
-=09=09=09=09int creat_flags, int page_size_log)
+=09=09=09=09int creat_flags, int page_size_log,
+=09=09=09=09umode_t mode)
 {
 =09struct inode *inode;
 =09struct vfsmount *mnt;
@@ -1393,7 +1394,7 @@ struct file *hugetlb_file_setup(const char *name, siz=
e_t size,
 =09}
=20
 =09file =3D ERR_PTR(-ENOSPC);
-=09inode =3D hugetlbfs_get_inode(mnt->mnt_sb, NULL, S_IFREG | S_IRWXUGO, 0=
);
+=09inode =3D hugetlbfs_get_inode(mnt->mnt_sb, NULL, S_IFREG | mode, 0);
 =09if (!inode)
 =09=09goto out;
 =09if (creat_flags =3D=3D HUGETLB_SHMFS_INODE)
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 11943b60f208..59486f5ea89f 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -308,7 +308,7 @@ extern const struct file_operations hugetlbfs_file_oper=
ations;
 extern const struct vm_operations_struct hugetlb_vm_ops;
 struct file *hugetlb_file_setup(const char *name, size_t size, vm_flags_t =
acct,
 =09=09=09=09struct user_struct **user, int creat_flags,
-=09=09=09=09int page_size_log);
+=09=09=09=09int page_size_log, umode_t mode);
=20
 static inline bool is_file_hugepages(struct file *file)
 {
@@ -325,7 +325,7 @@ static inline bool is_file_hugepages(struct file *file)
 static inline struct file *
 hugetlb_file_setup(const char *name, size_t size, vm_flags_t acctflag,
 =09=09struct user_struct **user, int creat_flags,
-=09=09int page_size_log)
+=09=09int page_size_log, umode_t mode)
 {
 =09return ERR_PTR(-ENOSYS);
 }
diff --git a/include/linux/stat.h b/include/linux/stat.h
index 765573dc17d6..efda7df06d6e 100644
--- a/include/linux/stat.h
+++ b/include/linux/stat.h
@@ -11,6 +11,7 @@
 #define S_IRUGO=09=09(S_IRUSR|S_IRGRP|S_IROTH)
 #define S_IWUGO=09=09(S_IWUSR|S_IWGRP|S_IWOTH)
 #define S_IXUGO=09=09(S_IXUSR|S_IXGRP|S_IXOTH)
+#define S_IRWUGO=09(S_IRUGO|S_IWUGO)
=20
 #define UTIME_NOW=09((1l << 30) - 1l)
 #define UTIME_OMIT=09((1l << 30) - 2l)
diff --git a/ipc/shm.c b/ipc/shm.c
index ce1ca9f7c6e9..a64a52e4ccf1 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -651,7 +651,8 @@ static int newseg(struct ipc_namespace *ns, struct ipc_=
params *params)
 =09=09=09acctflag =3D VM_NORESERVE;
 =09=09file =3D hugetlb_file_setup(name, hugesize, acctflag,
 =09=09=09=09  &shp->mlock_user, HUGETLB_SHMFS_INODE,
-=09=09=09=09(shmflg >> SHM_HUGE_SHIFT) & SHM_HUGE_MASK);
+=09=09=09=09(shmflg >> SHM_HUGE_SHIFT) & SHM_HUGE_MASK,
+=09=09=09=09S_IRWXUGO);
 =09} else {
 =09=09/*
 =09=09 * Do not allow no accounting for OVERCOMMIT_NEVER, even
diff --git a/mm/memfd.c b/mm/memfd.c
index 650e65a46b9c..b680fae87240 100644
--- a/mm/memfd.c
+++ b/mm/memfd.c
@@ -300,7 +300,8 @@ SYSCALL_DEFINE2(memfd_create,
 =09=09file =3D hugetlb_file_setup(name, 0, VM_NORESERVE, &user,
 =09=09=09=09=09HUGETLB_ANONHUGE_INODE,
 =09=09=09=09=09(flags >> MFD_HUGE_SHIFT) &
-=09=09=09=09=09MFD_HUGE_MASK);
+=09=09=09=09=09MFD_HUGE_MASK,
+=09=09=09=09=09S_IRWUGO);
 =09} else
 =09=09file =3D shmem_file_setup(name, 0, VM_NORESERVE);
 =09if (IS_ERR(file)) {
diff --git a/mm/mmap.c b/mm/mmap.c
index bd7b9f293b39..4494ce44ca5d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1600,7 +1600,8 @@ unsigned long ksys_mmap_pgoff(unsigned long addr, uns=
igned long len,
 =09=09file =3D hugetlb_file_setup(HUGETLB_ANON_FILE, len,
 =09=09=09=09VM_NORESERVE,
 =09=09=09=09&user, HUGETLB_ANONHUGE_INODE,
-=09=09=09=09(flags >> MAP_HUGE_SHIFT) & MAP_HUGE_MASK);
+=09=09=09=09(flags >> MAP_HUGE_SHIFT) & MAP_HUGE_MASK,
+=09=09=09=09S_IRWXUGO);
 =09=09if (IS_ERR(file))
 =09=09=09return PTR_ERR(file);
 =09}
diff --git a/mm/shmem.c b/mm/shmem.c
index 2275a0ff7c30..a903b9f783e2 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3968,7 +3968,8 @@ EXPORT_SYMBOL_GPL(shmem_truncate_range);
 /* common code */
=20
 static struct file *__shmem_file_setup(struct vfsmount *mnt, const char *n=
ame, loff_t size,
-=09=09=09=09       unsigned long flags, unsigned int i_flags)
+=09=09=09=09       unsigned long flags, unsigned int i_flags,
+=09=09=09=09       umode_t mode)
 {
 =09struct inode *inode;
 =09struct file *res;
@@ -3982,7 +3983,7 @@ static struct file *__shmem_file_setup(struct vfsmoun=
t *mnt, const char *name, l
 =09if (shmem_acct_size(flags, size))
 =09=09return ERR_PTR(-ENOMEM);
=20
-=09inode =3D shmem_get_inode(mnt->mnt_sb, NULL, S_IFREG | S_IRWXUGO, 0,
+=09inode =3D shmem_get_inode(mnt->mnt_sb, NULL, S_IFREG | mode, 0,
 =09=09=09=09flags);
 =09if (unlikely(!inode)) {
 =09=09shmem_unacct_size(flags, size);
@@ -4012,7 +4013,7 @@ static struct file *__shmem_file_setup(struct vfsmoun=
t *mnt, const char *name, l
  */
 struct file *shmem_kernel_file_setup(const char *name, loff_t size, unsign=
ed long flags)
 {
-=09return __shmem_file_setup(shm_mnt, name, size, flags, S_PRIVATE);
+=09return __shmem_file_setup(shm_mnt, name, size, flags, S_PRIVATE, S_IRWX=
UGO);
 }
=20
 /**
@@ -4023,7 +4024,7 @@ struct file *shmem_kernel_file_setup(const char *name=
, loff_t size, unsigned lon
  */
 struct file *shmem_file_setup(const char *name, loff_t size, unsigned long=
 flags)
 {
-=09return __shmem_file_setup(shm_mnt, name, size, flags, 0);
+=09return __shmem_file_setup(shm_mnt, name, size, flags, 0, S_IRWUGO);
 }
 EXPORT_SYMBOL_GPL(shmem_file_setup);
=20
@@ -4037,7 +4038,7 @@ EXPORT_SYMBOL_GPL(shmem_file_setup);
 struct file *shmem_file_setup_with_mnt(struct vfsmount *mnt, const char *n=
ame,
 =09=09=09=09       loff_t size, unsigned long flags)
 {
-=09return __shmem_file_setup(mnt, name, size, flags, 0);
+=09return __shmem_file_setup(mnt, name, size, flags, 0, S_IRWUGO);
 }
 EXPORT_SYMBOL_GPL(shmem_file_setup_with_mnt);
=20
--=20
2.21.0



