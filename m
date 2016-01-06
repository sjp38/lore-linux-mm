Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 935676B0006
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 00:02:41 -0500 (EST)
Received: by mail-qg0-f47.google.com with SMTP id e32so205292722qgf.3
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 21:02:41 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u132si110462344qhu.117.2016.01.05.21.02.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 21:02:41 -0800 (PST)
From: Mateusz Guzik <mguzik@redhat.com>
Subject: [PATCH 1/2] prctl: take mmap sem for writing to protect against others
Date: Wed,  6 Jan 2016 06:02:28 +0100
Message-Id: <1452056549-10048-2-git-send-email-mguzik@redhat.com>
In-Reply-To: <1452056549-10048-1-git-send-email-mguzik@redhat.com>
References: <1452056549-10048-1-git-send-email-mguzik@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Alexey Dobriyan <adobriyan@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jarod Wilson <jarod@redhat.com>, Jan Stancek <jstancek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>

The code was taking the semaphore for reading, which does not protect
against readers nor concurrent modifications.

The problem could cause a sanity checks to fail in procfs's cmdline
reader, resulting in an OOPS.

Note that some functions perform an unlocked read of various mm fields,
but they seem to be fine despite possible modificaton.

Signed-off-by: Mateusz Guzik <mguzik@redhat.com>
---
 kernel/sys.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/kernel/sys.c b/kernel/sys.c
index 6af9212..78947de 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1853,11 +1853,13 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 		user_auxv[AT_VECTOR_SIZE - 1] = AT_NULL;
 	}
 
-	if (prctl_map.exe_fd != (u32)-1)
+	if (prctl_map.exe_fd != (u32)-1) {
 		error = prctl_set_mm_exe_file(mm, prctl_map.exe_fd);
-	down_read(&mm->mmap_sem);
-	if (error)
-		goto out;
+		if (error)
+			return error;
+	}
+
+	down_write(&mm->mmap_sem);
 
 	/*
 	 * We don't validate if these members are pointing to
@@ -1894,10 +1896,8 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 	if (prctl_map.auxv_size)
 		memcpy(mm->saved_auxv, user_auxv, sizeof(user_auxv));
 
-	error = 0;
-out:
-	up_read(&mm->mmap_sem);
-	return error;
+	up_write(&mm->mmap_sem);
+	return 0;
 }
 #endif /* CONFIG_CHECKPOINT_RESTORE */
 
@@ -1963,7 +1963,7 @@ static int prctl_set_mm(int opt, unsigned long addr,
 
 	error = -EINVAL;
 
-	down_read(&mm->mmap_sem);
+	down_write(&mm->mmap_sem);
 	vma = find_vma(mm, addr);
 
 	prctl_map.start_code	= mm->start_code;
@@ -2056,7 +2056,7 @@ static int prctl_set_mm(int opt, unsigned long addr,
 
 	error = 0;
 out:
-	up_read(&mm->mmap_sem);
+	up_write(&mm->mmap_sem);
 	return error;
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
