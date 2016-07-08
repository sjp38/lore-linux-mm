Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 85F1A6B0253
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 17:48:20 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e189so119592524pfa.2
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 14:48:20 -0700 (PDT)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id j87si81240pfa.273.2016.07.08.14.48.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 14:48:19 -0700 (PDT)
Received: by mail-pf0-x235.google.com with SMTP id h14so16232687pfe.1
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 14:48:19 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 2/2] mm: refuse wrapped vm_brk requests
Date: Fri,  8 Jul 2016 14:48:14 -0700
Message-Id: <1468014494-25291-3-git-send-email-keescook@chromium.org>
In-Reply-To: <1468014494-25291-1-git-send-email-keescook@chromium.org>
References: <1468014494-25291-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kees Cook <keescook@chromium.org>, Hector Marco-Gisbert <hecmargi@upv.es>, Ismael Ripoll Ripoll <iripoll@upv.es>, Alexander Viro <viro@zeniv.linux.org.uk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Michal Hocko <mhocko@suse.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The vm_brk() alignment calculations should refuse to overflow. The ELF
loader depending on this, but it has been fixed now. No other unsafe
callers have been found.

Reported-by: Hector Marco-Gisbert <hecmargi@upv.es>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 mm/mmap.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index de2c1769cc68..1874ee0e1266 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2625,16 +2625,18 @@ static inline void verify_mm_writelocked(struct mm_struct *mm)
  *  anonymous maps.  eventually we may be able to do some
  *  brk-specific accounting here.
  */
-static int do_brk(unsigned long addr, unsigned long len)
+static int do_brk(unsigned long addr, unsigned long request)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma, *prev;
-	unsigned long flags;
+	unsigned long flags, len;
 	struct rb_node **rb_link, *rb_parent;
 	pgoff_t pgoff = addr >> PAGE_SHIFT;
 	int error;
 
-	len = PAGE_ALIGN(len);
+	len = PAGE_ALIGN(request);
+	if (len < request)
+		return -ENOMEM;
 	if (!len)
 		return 0;
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
