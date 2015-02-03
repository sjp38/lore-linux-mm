Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2A9CA6B006C
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 14:19:00 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id rd3so99746133pab.3
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 11:18:59 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTP id zn6si3628246pac.28.2015.02.03.11.18.58
        for <linux-mm@kvack.org>;
        Tue, 03 Feb 2015 11:18:59 -0800 (PST)
Received: from pps.filterd (m0044008 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t13JG2nY002655
	for <linux-mm@kvack.org>; Tue, 3 Feb 2015 11:18:58 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1sb2cq8cv2-12
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <linux-mm@kvack.org>; Tue, 03 Feb 2015 11:18:58 -0800
Received: from facebook.com (2401:db00:20:7003:face:0:4d:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 7e74f63cabd911e49dd80002c95209d8-57dd3390 for <linux-mm@kvack.org>;	Tue, 03
 Feb 2015 11:18:54 -0800
From: Shaohua Li <shli@fb.com>
Subject: [PATCH 1/2] mremap: don't allow VM_MIXEDMAP vma expanding
Date: Tue, 3 Feb 2015 11:18:52 -0800
Message-ID: <b885312bcea6e8c89889412936fb93305a4d139d.1422986358.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Kernel-team@fb.com, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andy Lutomirski <luto@amacapital.net>

Drivers using vm_insert_page() will set VM_MIXEDMAP, but their .fault
handler are likely not prepared to handle expansion.

Cc: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Andy Lutomirski <luto@amacapital.net>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 mm/mremap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mremap.c b/mm/mremap.c
index 17fa018..3b886dc 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -354,7 +354,7 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 	if (new_len > old_len) {
 		unsigned long pgoff;
 
-		if (vma->vm_flags & (VM_DONTEXPAND | VM_PFNMAP))
+		if (vma->vm_flags & (VM_DONTEXPAND | VM_PFNMAP | VM_MIXEDMAP))
 			goto Efault;
 		pgoff = (addr - vma->vm_start) >> PAGE_SHIFT;
 		pgoff += vma->vm_pgoff;
-- 
1.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
