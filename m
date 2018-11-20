Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 303116B203F
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 08:43:40 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id t2so1272280edb.22
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 05:43:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s4sor6858427edx.12.2018.11.20.05.43.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 05:43:38 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 3/3] mm, fault_around: do not take a reference to a locked page
Date: Tue, 20 Nov 2018 14:43:23 +0100
Message-Id: <20181120134323.13007-4-mhocko@kernel.org>
In-Reply-To: <20181120134323.13007-1-mhocko@kernel.org>
References: <20181120134323.13007-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Hildenbrand <david@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

From: Michal Hocko <mhocko@suse.com>

filemap_map_pages takes a speculative reference to each page in the
range before it tries to lock that page. While this is correct it
also can influence page migration which will bail out when seeing
an elevated reference count. The faultaround code would bail on
seeing a locked page so we can pro-actively check the PageLocked
bit before page_cache_get_speculative and prevent from pointless
reference count churn.

Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
Suggested-by: Jan Kara <jack@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/filemap.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/filemap.c b/mm/filemap.c
index 81adec8ee02c..c76d6a251770 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2553,6 +2553,9 @@ void filemap_map_pages(struct vm_fault *vmf,
 			goto next;
 
 		head = compound_head(page);
+
+		if (PageLocked(head))
+			goto next;
 		if (!page_cache_get_speculative(head))
 			goto next;
 
-- 
2.19.1
