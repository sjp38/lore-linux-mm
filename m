Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 535A96B54C6
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 16:55:25 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id p24so3394827qtl.2
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 13:55:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s17si1809175qve.22.2018.11.29.13.55.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 13:55:24 -0800 (PST)
From: Jan Stancek <jstancek@redhat.com>
Subject: [PATCH] mm: page_mapped: don't assume compound page is huge or THP
Date: Thu, 29 Nov 2018 22:53:48 +0100
Message-Id: <eabca57aa14f4df723173b24891f4a2d9c501f21.1543526537.git.jstancek@redhat.com>
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
(COMPOUND_PAGE_DTOR), then following loop can keep running until
it tries to read from memory that isn't mapped and triggers a panic:
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
- call to page_mapped(COPY) now triggers fault on access to 2nd COPY
  page at offset 0x30 (_mapcount)

[1] https://github.com/jstancek/reproducers/blob/master/kernel/page_mapped_crash/repro.c

This patch modifies page_mapped() to check for 'normal'
compound pages (COMPOUND_PAGE_DTOR).

Debugged-by: Laszlo Ersek <lersek@redhat.com>
Signed-off-by: Jan Stancek <jstancek@redhat.com>
---
 include/linux/mm.h | 9 +++++++++
 mm/util.c          | 2 ++
 2 files changed, 11 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5411de93a363..18b0bb953f92 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -700,6 +700,15 @@ static inline compound_page_dtor *get_compound_page_dtor(struct page *page)
 	return compound_page_dtors[page[1].compound_dtor];
 }
 
+static inline int PageNormalCompound(struct page *page)
+{
+	if (!PageCompound(page))
+		return 0;
+
+	page = compound_head(page);
+	return page[1].compound_dtor == COMPOUND_PAGE_DTOR;
+}
+
 static inline unsigned int compound_order(struct page *page)
 {
 	if (!PageHead(page))
diff --git a/mm/util.c b/mm/util.c
index 8bf08b5b5760..06c1640cb7b3 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -478,6 +478,8 @@ bool page_mapped(struct page *page)
 		return true;
 	if (PageHuge(page))
 		return false;
+	if (PageNormalCompound(page))
+		return false;
 	for (i = 0; i < hpage_nr_pages(page); i++) {
 		if (atomic_read(&page[i]._mapcount) >= 0)
 			return true;
-- 
1.8.3.1
