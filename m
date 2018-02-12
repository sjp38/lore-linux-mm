Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id D48BE6B0010
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 08:58:54 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id r27so4248565lfi.11
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 05:58:54 -0800 (PST)
Received: from forwardcorp1g.cmail.yandex.net (forwardcorp1g.cmail.yandex.net. [87.250.241.190])
        by mx.google.com with ESMTPS id i199si3140081lfe.425.2018.02.12.05.58.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Feb 2018 05:58:52 -0800 (PST)
Subject: [PATCH v3 1/2] mm/page_ref: use atomic_set_release in
 page_ref_unfreeze
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Mon, 12 Feb 2018 16:58:50 +0300
Message-ID: <151844393004.210639.4672319312617954272.stgit@buzz>
In-Reply-To: <4f64569f-b8ce-54f8-33d9-0e67216bb54c@yandex-team.ru>
References: <4f64569f-b8ce-54f8-33d9-0e67216bb54c@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>

page_ref_unfreeze() has exactly that semantic. No functional
changes: just minus one barrier and proper handling of PPro errata.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 include/linux/page_ref.h |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/linux/page_ref.h b/include/linux/page_ref.h
index 760d74a0e9a9..14d14beb1f7f 100644
--- a/include/linux/page_ref.h
+++ b/include/linux/page_ref.h
@@ -175,8 +175,7 @@ static inline void page_ref_unfreeze(struct page *page, int count)
 	VM_BUG_ON_PAGE(page_count(page) != 0, page);
 	VM_BUG_ON(count == 0);
 
-	smp_mb();
-	atomic_set(&page->_refcount, count);
+	atomic_set_release(&page->_refcount, count);
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_unfreeze))
 		__page_ref_unfreeze(page, count);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
