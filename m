Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f49.google.com (mail-bk0-f49.google.com [209.85.214.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1F3EB6B0031
	for <linux-mm@kvack.org>; Sun, 26 Jan 2014 21:53:15 -0500 (EST)
Received: by mail-bk0-f49.google.com with SMTP id v15so2527186bkz.22
        for <linux-mm@kvack.org>; Sun, 26 Jan 2014 18:53:14 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id aq8si12284257bkc.241.2014.01.26.18.53.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 26 Jan 2014 18:53:14 -0800 (PST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so5305072pab.5
        for <linux-mm@kvack.org>; Sun, 26 Jan 2014 18:53:12 -0800 (PST)
Date: Sun, 26 Jan 2014 18:52:33 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: bring back /sys/kernel/mm
Message-ID: <alpine.LSU.2.11.1401261849120.1259@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Commit da29bd36224b ("mm/mm_init.c: make creation of the mm_kobj happen
earlier than device_initcall") changed to pure_initcall(mm_sysfs_init).

That's too early: mm_sysfs_init() depends on core_initcall(ksysfs_init)
to have made the kernel_kobj directory "kernel" in which to create "mm".

Make it postcore_initcall(mm_sysfs_init).  We could use core_initcall(),
and depend upon Makefile link order kernel/ mm/ fs/ ipc/ security/ ...
as core_initcall(debugfs_init) and core_initcall(securityfs_init) do;
but better not.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/mm_init.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 3.13.0+/mm/mm_init.c	2014-01-23 21:51:26.004001378 -0800
+++ linux/mm/mm_init.c	2014-01-26 18:06:40.488488209 -0800
@@ -202,4 +202,4 @@ static int __init mm_sysfs_init(void)
 
 	return 0;
 }
-pure_initcall(mm_sysfs_init);
+postcore_initcall(mm_sysfs_init);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
