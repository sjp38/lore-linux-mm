Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C0E0E6B02C3
	for <linux-mm@kvack.org>; Wed, 31 May 2017 11:51:59 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b13so14028448pgn.4
        for <linux-mm@kvack.org>; Wed, 31 May 2017 08:51:59 -0700 (PDT)
Received: from mail-pg0-f65.google.com (mail-pg0-f65.google.com. [74.125.83.65])
        by mx.google.com with ESMTPS id f19si16727071pgk.358.2017.05.31.08.51.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 08:51:59 -0700 (PDT)
Received: by mail-pg0-f65.google.com with SMTP id u13so77945pgb.1
        for <linux-mm@kvack.org>; Wed, 31 May 2017 08:51:58 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/3] fs/file: replace alloc_fdmem with kvmalloc alternative
Date: Wed, 31 May 2017 17:51:43 +0200
Message-Id: <20170531155145.17111-2-mhocko@kernel.org>
In-Reply-To: <20170531155145.17111-1-mhocko@kernel.org>
References: <20170531155145.17111-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Alexander Viro <viro@zeniv.linux.org.uk>

From: Michal Hocko <mhocko@suse.com>

There is no real reason to duplicate kvmalloc* helpers so drop
alloc_fdmem and replace it with the appropriate library function.

Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/file.c | 22 ++++------------------
 1 file changed, 4 insertions(+), 18 deletions(-)

diff --git a/fs/file.c b/fs/file.c
index 1c2972e3a405..1fc7fbbb4510 100644
--- a/fs/file.c
+++ b/fs/file.c
@@ -30,21 +30,6 @@ unsigned int sysctl_nr_open_min = BITS_PER_LONG;
 unsigned int sysctl_nr_open_max =
 	__const_min(INT_MAX, ~(size_t)0/sizeof(void *)) & -BITS_PER_LONG;
 
-static void *alloc_fdmem(size_t size)
-{
-	/*
-	 * Very large allocations can stress page reclaim, so fall back to
-	 * vmalloc() if the allocation size will be considered "large" by the VM.
-	 */
-	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER)) {
-		void *data = kmalloc(size, GFP_KERNEL_ACCOUNT |
-				     __GFP_NOWARN | __GFP_NORETRY);
-		if (data != NULL)
-			return data;
-	}
-	return __vmalloc(size, GFP_KERNEL_ACCOUNT, PAGE_KERNEL);
-}
-
 static void __free_fdtable(struct fdtable *fdt)
 {
 	kvfree(fdt->fd);
@@ -131,13 +116,14 @@ static struct fdtable * alloc_fdtable(unsigned int nr)
 	if (!fdt)
 		goto out;
 	fdt->max_fds = nr;
-	data = alloc_fdmem(nr * sizeof(struct file *));
+	data = kvmalloc_array(nr, sizeof(struct file *), GFP_KERNEL_ACCOUNT);
 	if (!data)
 		goto out_fdt;
 	fdt->fd = data;
 
-	data = alloc_fdmem(max_t(size_t,
-				 2 * nr / BITS_PER_BYTE + BITBIT_SIZE(nr), L1_CACHE_BYTES));
+	data = kvmalloc(max_t(size_t,
+				 2 * nr / BITS_PER_BYTE + BITBIT_SIZE(nr), L1_CACHE_BYTES),
+				 GFP_KERNEL_ACCOUNT);
 	if (!data)
 		goto out_arr;
 	fdt->open_fds = data;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
