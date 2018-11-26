Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 730786B445D
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 18:23:40 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id s27so8827838pgm.4
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 15:23:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r12sor2512417plo.58.2018.11.26.15.23.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 15:23:39 -0800 (PST)
Date: Mon, 26 Nov 2018 15:23:37 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 04/10] mm/khugepaged: collapse_shmem() stop if punched or
 truncated
In-Reply-To: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1811261522040.2275@eggly.anvils>
References: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org

Huge tmpfs testing showed that although collapse_shmem() recognizes a
concurrently truncated or hole-punched page correctly, its handling of
holes was liable to refill an emptied extent.  Add check to stop that.

Fixes: f3f0e1d2150b2 ("khugepaged: add support of collapse for tmpfs/shmem pages")
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: stable@vger.kernel.org # 4.8+
---
 mm/khugepaged.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index c13625c1ad5e..2070c316f06e 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1359,6 +1359,17 @@ static void collapse_shmem(struct mm_struct *mm,
 
 		VM_BUG_ON(index != xas.xa_index);
 		if (!page) {
+			/*
+			 * Stop if extent has been truncated or hole-punched,
+			 * and is now completely empty.
+			 */
+			if (index == start) {
+				if (!xas_next_entry(&xas, end - 1)) {
+					result = SCAN_TRUNCATED;
+					break;
+				}
+				xas_set(&xas, index);
+			}
 			if (!shmem_charge(mapping->host, 1)) {
 				result = SCAN_FAIL;
 				break;
-- 
2.20.0.rc0.387.gc7a69e6b6c-goog
