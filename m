Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5D6526B0003
	for <linux-mm@kvack.org>; Sun,  4 Mar 2018 02:16:37 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id h11so7909584pfn.0
        for <linux-mm@kvack.org>; Sat, 03 Mar 2018 23:16:37 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z5sor2059669pge.412.2018.03.03.23.16.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 03 Mar 2018 23:16:36 -0800 (PST)
From: Nick Desaulniers <nick.desaulniers@gmail.com>
Subject: [PATCH] memory-failure: fix section mismatch
Date: Sat,  3 Mar 2018 23:16:11 -0800
Message-Id: <20180304071613.16899-1-nick.desaulniers@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Nick Desaulniers <nick.desaulniers@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Clang complains when a variable is declared extern twice, but with two
different sections. num_poisoned_pages is marked extern and __read_mostly
in include/linux/swapops.h, but only extern in include/linux/mm.h. Some
c source files must include both, and thus see the conflicting
declarations.

Signed-off-by: Nick Desaulniers <nick.desaulniers@gmail.com>
---
 include/linux/mm.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ad06d42adb1a..bd4bd59f02c1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2582,7 +2582,7 @@ extern int get_hwpoison_page(struct page *page);
 extern int sysctl_memory_failure_early_kill;
 extern int sysctl_memory_failure_recovery;
 extern void shake_page(struct page *p, int access);
-extern atomic_long_t num_poisoned_pages;
+extern atomic_long_t num_poisoned_pages __read_mostly;
 extern int soft_offline_page(struct page *page, int flags);
 
 
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
