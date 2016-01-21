Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 820F46B0009
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 05:49:48 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id u188so220791977wmu.1
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 02:49:48 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.24])
        by mx.google.com with ESMTPS id k5si1057377wjf.120.2016.01.21.02.49.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jan 2016 02:49:47 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] proc: add missing 'mm' variable in nommu is_stack()
Date: Thu, 21 Jan 2016 11:49:42 +0100
Message-ID: <2208534.bqAiu8Kgku@wuerfel>
In-Reply-To: <1453226559-17322-1-git-send-email-hannes@cmpxchg.org>
References: <1453226559-17322-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@fb.com>, Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

A recent revert left an incomplete function in fs/proc/task_nommu.c,
causing a build error for any NOMMU configuration with procfs:

fs/proc/task_nommu.c:132:28: error: 'mm' undeclared (first use in this function)
   stack = vma->vm_start <= mm->start_stack &&

Evidently, there is just a missing variable that is available
in the calling function but not inside of is_stack(). This
adds it.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: e87d4fd02f40 ("proc: revert /proc/<pid>/maps [stack:TID] annotation")
---
This came up today on my ARM randconfig builds with linux-next.
I did not run the kernel to see if the code actually works, but
it seems straightforward enough.

diff --git a/fs/proc/task_nommu.c b/fs/proc/task_nommu.c
index 60ab72e38f78..faacb0c0d857 100644
--- a/fs/proc/task_nommu.c
+++ b/fs/proc/task_nommu.c
@@ -126,6 +126,7 @@ unsigned long task_statm(struct mm_struct *mm,
 static int is_stack(struct proc_maps_private *priv,
 		    struct vm_area_struct *vma, int is_pid)
 {
+	struct mm_struct *mm = vma->vm_mm;
 	int stack = 0;
 
 	if (is_pid) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
