Return-Path: <SRS0=c8nW=TE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3A19C43219
	for <linux-mm@archiver.kernel.org>; Sat,  4 May 2019 11:40:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E9F4206A3
	for <linux-mm@archiver.kernel.org>; Sat,  4 May 2019 11:40:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E9F4206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=dimakrasner.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D37306B0003; Sat,  4 May 2019 07:39:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE8406B0006; Sat,  4 May 2019 07:39:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD86A6B0007; Sat,  4 May 2019 07:39:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6AE8B6B0003
	for <linux-mm@kvack.org>; Sat,  4 May 2019 07:39:59 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id j3so6615623edb.14
        for <linux-mm@kvack.org>; Sat, 04 May 2019 04:39:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :message-id:subject:date:mime-version:content-transfer-encoding;
        bh=G0xCE0J8uy/jkjDse+xsF+RozepfU1fPLDYI1Z72HZQ=;
        b=csCaUurGVZCMKXSazwJmJWTF/RSdbIE6w6tze8J/agGFf9EgeLKzwHS5rIX+xZzhmS
         OD8lCss2gDXum+MIElimTLOuIcHpacH6tXWbt6C8SeJUVRuDtNTurGHodUwVS6mx/Jyt
         fTJwNrnEyDX8+TqONDjEWhj6Oy6aBCYhChU8VooDwf1MYX9mkRM+fHzBkr5ovsYGGiYa
         VqoIJUf/nK3ZH2jSXBwLTROmnxBhrzOfWzUyZtZCg5d2any++4fxZgSdk9kjzgYFXePP
         aPMK/5PNTeAMk7Go5fNzoZaCTQvkSaShxfory0aCECOeyelo67zfIJ2zJ1DvuXlntndE
         Oexw==
X-Original-Authentication-Results: mx.google.com;       arc=pass (i=1 spf=pass spfdomain=dimakrasner.com dkim=pass dkdomain=dimakrasner.com dmarc=pass fromdomain=dimakrasner.com>);       spf=pass (google.com: domain of dima@dimakrasner.com designates 136.143.188.53 as permitted sender) smtp.mailfrom=dima@dimakrasner.com
X-Gm-Message-State: APjAAAVw7qlgZqNZQr+OAX4m2xzyjlLgEjE4QJZqeEQFm87wxmVd2/ch
	MNUg8YAsxZdAAyhHCcZPqgugS7KJaQhFJE+P7UH34QjbAoYf5XizsuGbnWO9RY+R6KKFwaDp9Uq
	IN2b/xoHxKLQzZDeVqjuSkEhkW1abx2FKQFyLUh3rfL1iBApDWj0zrMw/tQlr26E/2g==
X-Received: by 2002:a50:deca:: with SMTP id d10mr14065768edl.25.1556969998813;
        Sat, 04 May 2019 04:39:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyd6TNgSP0XcAksx4SYKix+z1vjN4IN0ma1Y+1IhlQ7gyioNeWknK2mYrooWlNELtbYXt+7
X-Received: by 2002:a50:deca:: with SMTP id d10mr14065675edl.25.1556969997213;
        Sat, 04 May 2019 04:39:57 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1556969997; cv=pass;
        d=google.com; s=arc-20160816;
        b=eGj1VTTcivJTmz/PvhBaF9byqIsC1TpoMXFnhVUFsyekOL3DTvOD4C+EvvFebWLkuo
         cClrRX4kWiem8sGSRH1e88ThMVXh2wVh8MQSsaCX46nNYLljcgkRnx70iBgxIYbk1kEi
         jVYuWS2TrG5lsapxhrlTAShgflpsIgj0NP0Ve/9TdF/JpqHg1wikw9KoVDpm31HKVC3t
         AtU1YxhJf8yvg79yWc9dTE+qCFZXZCEG1PfMO+mx1S1HEqsAvtga9pReAticZym197qR
         8LShUgNUFdhIaCI3xJ/0AvLL1CW64rKzPC82q3Ndji1cF2lIjVm1V6tRDIXDRaoN26+A
         Z2fg==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:date:subject:message-id:cc
         :to:from;
        bh=G0xCE0J8uy/jkjDse+xsF+RozepfU1fPLDYI1Z72HZQ=;
        b=uNSRXAtvdG83n07274aJVlQiYj4aJjimU6UHllCcJgRZPuNgBr5H2y19vLFxZRadsn
         csnXdJ/uKgIZEw6Th87tsSNJFsqWc/OZcrSwP5WkjtCG3VWcSquj4WrYdx7h9wBC+e93
         aqYPnfXuHtwtW0+MzLlY7M0ekQ/aFNVLZ3xV3ilCeqIPp33TrrJ1Nec51lnwDRkJy5sL
         j8vOJZCOtFkzIOK2PKqEV3uW8w3wlNos5DCYGnrbKLpq6aCE3rygKWzrITnXr7c43YLh
         S5uPLqlNeD4qgj2/lDqWBchWbkknuMAV9YRvpsmrIolu0mFhOOIvHZw+rw9wrj/RwXRU
         zTdg==
ARC-Authentication-Results: i=2; mx.google.com;
       arc=pass (i=1 spf=pass spfdomain=dimakrasner.com dkim=pass dkdomain=dimakrasner.com dmarc=pass fromdomain=dimakrasner.com>);
       spf=pass (google.com: domain of dima@dimakrasner.com designates 136.143.188.53 as permitted sender) smtp.mailfrom=dima@dimakrasner.com
Received: from sender4-of-o53.zoho.com (sender4-of-o53.zoho.com. [136.143.188.53])
        by mx.google.com with ESMTPS id w9si3542033edt.395.2019.05.04.04.39.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 May 2019 04:39:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of dima@dimakrasner.com designates 136.143.188.53 as permitted sender) client-ip=136.143.188.53;
Authentication-Results: mx.google.com;
       arc=pass (i=1 spf=pass spfdomain=dimakrasner.com dkim=pass dkdomain=dimakrasner.com dmarc=pass fromdomain=dimakrasner.com>);
       spf=pass (google.com: domain of dima@dimakrasner.com designates 136.143.188.53 as permitted sender) smtp.mailfrom=dima@dimakrasner.com
ARC-Seal: i=1; a=rsa-sha256; t=1556969989; cv=none; 
	d=zoho.com; s=zohoarc; 
	b=UyyPzt9OEWvyq72H0gYBnIymjtyHlZSi8X9uSB1YWomWrUN/3sAo/9Dw0Em9GwOHjp79UQUX0ois3qa519wA0sGCV09BxY2Ugz2UBazLchaBML53t32mxz34hnXHYQ4uCCMHw/Xub9ohLhSrPOKseI2C78ZUEWscCQsGiJXd2LM=
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=zoho.com; s=zohoarc; 
	t=1556969989; h=Content-Type:Content-Transfer-Encoding:Cc:Date:From:MIME-Version:Message-ID:Subject:To:ARC-Authentication-Results; 
	bh=G0xCE0J8uy/jkjDse+xsF+RozepfU1fPLDYI1Z72HZQ=; 
	b=TSISrD6AHpEA7zxYYttzRZur0RnJDc4JsKZMaP5GN/rbkM+NVd7/Cf6sb/SS+YFtIizX9rnbsoWJnphgyQg3Krw3+5pYkStfM5adKKZyTWQlws7pH4/nI9mfUz3ujjC+km9VZ+J4TSlAuI7QuL6+7gdu0dghBQH+FKqCe+o7zhg=
ARC-Authentication-Results: i=1; mx.zoho.com;
	dkim=pass  header.i=dimakrasner.com;
	spf=pass  smtp.mailfrom=dima@dimakrasner.com;
	dmarc=pass header.from=<dima@dimakrasner.com> header.from=<dima@dimakrasner.com>
Received: from hazak.localdomain (89.237.80.180 [89.237.80.180]) by mx.zohomail.com
	with SMTPS id 1556969987874906.790317299088; Sat, 4 May 2019 04:39:47 -0700 (PDT)
From: Dima Krasner <dima@dimakrasner.com>
To: dima@dimakrasner.com
Cc: linux-mm@kvack.org,
	Hugh Dickins <hughd@google.com>
Message-ID: <20190504114140.32082-1-dima@dimakrasner.com>
Subject: [PATCH] mm: do not grant +x by default in memfd_create()
Date: Sat,  4 May 2019 14:41:40 +0300
X-Mailer: git-send-email 2.21.0
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
 include/linux/hugetlb.h |  2 +-
 include/linux/stat.h    |  1 +
 ipc/shm.c               |  3 ++-
 mm/memfd.c              |  3 ++-
 mm/mmap.c               |  3 ++-
 mm/shmem.c              | 11 ++++++-----
 7 files changed, 17 insertions(+), 11 deletions(-)

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
index 11943b60f208..ae17f6629e80 100644
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



