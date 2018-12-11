Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 442FB8E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:27:54 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e29so7120426ede.19
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 06:27:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ge18-v6sor4064756ejb.16.2018.12.11.06.27.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 06:27:52 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/3] mm, fault_around: do not take a reference to a locked page
Date: Tue, 11 Dec 2018 15:27:41 +0100
Message-Id: <20181211142741.2607-4-mhocko@kernel.org>
In-Reply-To: <20181211142741.2607-1-mhocko@kernel.org>
References: <20181211142741.2607-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, David Hildenbrand <david@redhat.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, William Kucharski <william.kucharski@oracle.com>

From: Michal Hocko <mhocko@suse.com>

filemap_map_pages takes a speculative reference to each page in the
range before it tries to lock that page. While this is correct it
also can influence page migration which will bail out when seeing
an elevated reference count. The faultaround code would bail on
seeing a locked page so we can pro-actively check the PageLocked
bit before page_cache_get_speculative and prevent from pointless
reference count churn.

Suggested-by: Jan Kara <jack@suse.cz>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: David Hildenbrand <david@redhat.com>
Acked-by: Hugh Dickins <hughd@google.com>
Reviewed-by: William Kucharski <william.kucharski@oracle.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/filemap.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/filemap.c b/mm/filemap.c
index 81adec8ee02c..a87f71fff879 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2553,6 +2553,13 @@ void filemap_map_pages(struct vm_fault *vmf,
 			goto next;
 
 		head = compound_head(page);
+
+		/*
+		 * Check for a locked page first, as a speculative
+		 * reference may adversely influence page migration.
+		 */
+		if (PageLocked(head))
+			goto next;
 		if (!page_cache_get_speculative(head))
 			goto next;
 
-- 
2.19.2
