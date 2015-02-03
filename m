Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1CA4E6B0070
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 14:19:01 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id bs8so24035576wib.5
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 11:19:00 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTP id d8si2990504wij.1.2015.02.03.11.18.58
        for <linux-mm@kvack.org>;
        Tue, 03 Feb 2015 11:18:59 -0800 (PST)
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t13JGBmN009218
	for <linux-mm@kvack.org>; Tue, 3 Feb 2015 11:18:58 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1sb2d1rk2e-4
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <linux-mm@kvack.org>; Tue, 03 Feb 2015 11:18:57 -0800
Received: from facebook.com (2401:db00:20:7003:face:0:4d:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 7e6e2f32abd911e48d1d0002c95209d8-5c5dc390 for <linux-mm@kvack.org>;	Tue, 03
 Feb 2015 11:18:54 -0800
From: Shaohua Li <shli@fb.com>
Subject: [PATCH 2/2] aio: make aio .mremap handle size changes
Date: Tue, 3 Feb 2015 11:18:53 -0800
Message-ID: <798fafb96373cfab0707457a266dd137016cd1e9.1422986358.git.shli@fb.com>
In-Reply-To: <b885312bcea6e8c89889412936fb93305a4d139d.1422986358.git.shli@fb.com>
References: <b885312bcea6e8c89889412936fb93305a4d139d.1422986358.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Kernel-team@fb.com, Benjamin LaHaise <bcrl@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

mremap aio ring buffer to another smaller vma is legal. For example,
mremap the ring buffer from the begining, though after the mremap, some
ring buffer pages can't be accessed in userspace because vma size is
shrinked. The problem is ctx->mmap_size isn't changed if the new ring
buffer vma size is changed. Latter io_destroy will zap all vmas within
mmap_size, which might zap unrelated vmas.

Cc: Benjamin LaHaise <bcrl@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 fs/aio.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/aio.c b/fs/aio.c
index 1b7893e..fa354cf 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -306,6 +306,7 @@ static void aio_ring_remap(struct file *file, struct vm_area_struct *vma)
 		ctx = table->table[i];
 		if (ctx && ctx->aio_ring_file == file) {
 			ctx->user_id = ctx->mmap_base = vma->vm_start;
+			ctx->mmap_size = vma->vm_end - vma->vm_start;
 			break;
 		}
 	}
-- 
1.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
