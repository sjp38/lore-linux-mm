Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5EEDA6B581A
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 07:07:11 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id g22so5024929qke.15
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 04:07:11 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p17si3420254qvi.74.2018.11.30.04.07.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 04:07:10 -0800 (PST)
From: Jan Stancek <jstancek@redhat.com>
Subject: [PATCH v2] mm: page_mapped: don't assume compound page is huge or THP
Date: Fri, 30 Nov 2018 13:06:57 +0100
Message-Id: <c440d69879e34209feba21e12d236d06bc0a25db.1543577156.git.jstancek@redhat.com>
In-Reply-To: <eabca57aa14f4df723173b24891f4a2d9c501f21.1543526537.git.jstancek@redhat.com>
References: <eabca57aa14f4df723173b24891f4a2d9c501f21.1543526537.git.jstancek@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, lersek@redhat.com, alex.williamson@redhat.com, aarcange@redhat.com, rientjes@google.com, kirill@shutemov.name, mgorman@techsingularity.net, mhocko@suse.com, jstancek@redhat.com
Cc: linux-kernel@vger.kernel.org

LTP proc01 testcase has been observed to rarely trigger crashes
on arm64:
    page_mapped+0x78/0xb4
    stable_page_flags+0x27c/0x338
    kpageflags_read+0xfc/0x164
    proc_reg_read+0x7c/0xb8
    __vfs_read+0x58/0x178
    vfs_read+0x90/0x14c
    SyS_read+0x60/0xc0

Issue is that page_mapped() assumes that if compound page is not
huge, then it must be THP. But if this is 'normal' compound page
(COMPOUND_PAGE_DTOR), then following loop can keep running
(for HPAGE_PMD_NR iterations) until it tries to read from memory
that isn't mapped and triggers a panic:
        for (i = 0; i < hpage_nr_pages(page); i++) {
                if (atomic_read(&page[i]._mapcount) >= 0)
                        return true;
	}

I could replicate this on x86 (v4.20-rc4-98-g60b548237fed) only
with a custom kernel module [1] which:
- allocates compound page (PAGEC) of order 1
- allocates 2 normal pages (COPY), which are initialized to 0xff
  (to satisfy _mapcount >= 0)
- 2 PAGEC page structs are copied to address of first COPY page
- second page of COPY is marked as not present
- call to page_mapped(COPY) now triggers fault on access to 2nd
  COPY page at offset 0x30 (_mapcount)

[1] https://github.com/jstancek/reproducers/blob/master/kernel/page_mapped_crash/repro.c

Fix the loop to iterate for "1 << compound_order" pages.

Debugged-by: Laszlo Ersek <lersek@redhat.com>
Suggested-by: "Kirill A. Shutemov" <kirill@shutemov.name>
Signed-off-by: Jan Stancek <jstancek@redhat.com>
---
 mm/util.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Changes in v2:
- change the loop instead so we check also mapcount of subpages

diff --git a/mm/util.c b/mm/util.c
index 8bf08b5b5760..5c9c7359ee8a 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -478,7 +478,7 @@ bool page_mapped(struct page *page)
 		return true;
 	if (PageHuge(page))
 		return false;
-	for (i = 0; i < hpage_nr_pages(page); i++) {
+	for (i = 0; i < (1 << compound_order(page)); i++) {
 		if (atomic_read(&page[i]._mapcount) >= 0)
 			return true;
 	}
-- 
1.8.3.1
