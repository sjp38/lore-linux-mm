Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id 524DE6B0035
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 17:08:30 -0500 (EST)
Received: by mail-yh0-f41.google.com with SMTP id f11so915798yha.28
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 14:08:30 -0800 (PST)
Received: from smtp.outflux.net (smtp.outflux.net. [2001:19d0:2:6:c0de:0:736d:7470])
        by mx.google.com with ESMTPS id v3si23012077yhd.213.2013.12.12.14.08.28
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 14:08:29 -0800 (PST)
Date: Thu, 12 Dec 2013 14:07:57 -0800
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] mm: fix use-after-free in sys_remap_file_pages
Message-ID: <20131212220757.GA14928@www.outflux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, PaX Team <pageexec@freemail.hu>, Dmitry Vyukov <dvyukov@google.com>

From: PaX Team <pageexec@freemail.hu>

http://lkml.org/lkml/2013/9/17/30

SyS_remap_file_pages() calls mmap_region(), which calls remove_vma_list(),
which calls remove_vma(), which frees the vma.  Later (after out label)
SyS_remap_file_pages() accesses the freed vma in vm_flags = vma->vm_flags.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: PaX Team <pageexec@freemail.hu>
Signed-off-by: Kees Cook <keescook@chromium.org>
Cc: stable@vger.kernel.org
---
 mm/fremap.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/fremap.c b/mm/fremap.c
index 5bff08147768..afad07b85ef2 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -218,6 +218,8 @@ get_write_lock:
 				BUG_ON(addr != start);
 				err = 0;
 			}
+			vm_flags = vma->vm_flags;
+			vma = NULL;
 			goto out;
 		}
 		mutex_lock(&mapping->i_mmap_mutex);
-- 
1.7.9.5


-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
