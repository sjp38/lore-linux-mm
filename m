Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6F4C6440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 06:32:18 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id n137so9111648iod.20
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 03:32:18 -0800 (PST)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id k128si6231855pgc.167.2017.11.09.03.32.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Nov 2017 03:32:17 -0800 (PST)
Received: from epcas5p1.samsung.com (unknown [182.195.41.39])
	by mailout3.samsung.com (KnoxPortal) with ESMTP id 20171109113214epoutp0352a7153d07343d2906fb1a0e6fb36b4a~1Z5PPGXaQ0524505245epoutp03Y
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 11:32:14 +0000 (GMT)
From: Manjeet Pawar <manjeet.p@samsung.com>
Subject: [PATCH] mm: Replace-simple_strtoul-with-kstrtoul
Date: Thu,  9 Nov 2017 16:58:18 +0530
Message-Id: <1510226898-4310-1-git-send-email-manjeet.p@samsung.com>
Content-Type: text/plain; charset="utf-8"
References: <CGME20171109113212epcas5p4b93d4830869468901f4003bde11e3d16@epcas5p4.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, vbabka@suse.cz, mhocko@suse.com, akpm@linux-foundation.org, hughd@google.com
Cc: a.sahrawat@samsung.com, pankaj.m@samsung.com, lalit.mohan@samsung.com, Manjeet Pawar <manjeet.p@samsung.com>, Vinay Kumar Rijhwani <v.rijhwani@samsung.com>, Rohit Thapliyal <r.thapliyal@samsung.com>

simple_strtoul() is obselete now, so using newer function kstrtoul()

Signed-off-by: Manjeet Pawar <manjeet.p@samsung.com>
Signed-off-by: Vinay Kumar Rijhwani <v.rijhwani@samsung.com>
Signed-off-by: Rohit Thapliyal <r.thapliyal@samsung.com>
---
 mm/page_alloc.c |  3 +--
 mm/shmem.c      | 11 +++++------
 2 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 77e4d3c..f9d812e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7197,9 +7197,8 @@ int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *table, int write,
 
 static int __init set_hashdist(char *str)
 {
-	if (!str)
+	if (!str || kstrtoul(str, 0, (unsigned long *)&hashdist))
 		return 0;
-	hashdist = simple_strtoul(str, &str, 0);
 	return 1;
 }
 __setup("hashdist=", set_hashdist);
diff --git a/mm/shmem.c b/mm/shmem.c
index 07a1d22..bf7d905 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3470,6 +3470,7 @@ static int shmem_parse_options(char *options, struct shmem_sb_info *sbinfo,
 	struct mempolicy *mpol = NULL;
 	uid_t uid;
 	gid_t gid;
+	unsigned long mode;
 
 	while (options != NULL) {
 		this_char = options;
@@ -3522,14 +3523,13 @@ static int shmem_parse_options(char *options, struct shmem_sb_info *sbinfo,
 		} else if (!strcmp(this_char,"mode")) {
 			if (remount)
 				continue;
-			sbinfo->mode = simple_strtoul(value, &rest, 8) & 07777;
-			if (*rest)
+			if (kstrtoul(value, 8, &mode))
 				goto bad_val;
+			sbinfo->mode = mode & 07777;
 		} else if (!strcmp(this_char,"uid")) {
 			if (remount)
 				continue;
-			uid = simple_strtoul(value, &rest, 0);
-			if (*rest)
+			if (kstrtoul(value, 0, (unsigned long *)&uid))
 				goto bad_val;
 			sbinfo->uid = make_kuid(current_user_ns(), uid);
 			if (!uid_valid(sbinfo->uid))
@@ -3537,8 +3537,7 @@ static int shmem_parse_options(char *options, struct shmem_sb_info *sbinfo,
 		} else if (!strcmp(this_char,"gid")) {
 			if (remount)
 				continue;
-			gid = simple_strtoul(value, &rest, 0);
-			if (*rest)
+			if (kstrtoul(value, 0, (unsigned long *)&gid))
 				goto bad_val;
 			sbinfo->gid = make_kgid(current_user_ns(), gid);
 			if (!gid_valid(sbinfo->gid))
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
