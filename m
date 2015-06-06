Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0FEF5900016
	for <linux-mm@kvack.org>; Sat,  6 Jun 2015 05:55:19 -0400 (EDT)
Received: by labpy14 with SMTP id py14so68676836lab.0
        for <linux-mm@kvack.org>; Sat, 06 Jun 2015 02:55:18 -0700 (PDT)
Received: from mail-la0-x232.google.com (mail-la0-x232.google.com. [2a00:1450:4010:c03::232])
        by mx.google.com with ESMTPS id zz9si7044449lbb.157.2015.06.06.02.55.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Jun 2015 02:55:17 -0700 (PDT)
Received: by laew7 with SMTP id w7so68560553lae.1
        for <linux-mm@kvack.org>; Sat, 06 Jun 2015 02:55:16 -0700 (PDT)
From: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Subject: [PATCH] mm/mmap.c: optimization of do_mmap_pgoff function
Date: Sat,  6 Jun 2015 11:54:32 +0200
Message-Id: <1433584472-19151-1-git-send-email-kwapulinski.piotr@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: kirill.shutemov@linux.intel.com, riel@redhat.com, mhocko@suse.cz, sasha.levin@oracle.com, dave@stgolabs.net, koct9i@gmail.com, pfeiner@google.com, dh.herrmann@gmail.com, vishnu.ps@samsung.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Piotr Kwapulinski <kwapulinski.piotr@gmail.com>

The simple check for zero length memory mapping may be performed
earlier. It causes that in case of zero length memory mapping some
unnecessary code is not executed at all. It does not make the code less
readable and saves some CPU cycles.

Signed-off-by: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
---
 mm/mmap.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index bb50cac..aa632ad 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1258,6 +1258,9 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 
 	*populate = 0;
 
+	if (!len)
+		return -EINVAL;
+
 	/*
 	 * Does the application expect PROT_READ to imply PROT_EXEC?
 	 *
@@ -1268,9 +1271,6 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 		if (!(file && (file->f_path.mnt->mnt_flags & MNT_NOEXEC)))
 			prot |= PROT_EXEC;
 
-	if (!len)
-		return -EINVAL;
-
 	if (!(flags & MAP_FIXED))
 		addr = round_hint_to_min(addr);
 
-- 
2.3.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
