Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EA2F4440D03
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 02:31:08 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id e64so6972462pfk.0
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 23:31:08 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id o30si290063pgn.211.2017.11.09.23.31.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Nov 2017 23:31:07 -0800 (PST)
Subject: [RFC PATCH] mm: fix device-dax pud write-faults triggered by
 get_user_pages()
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 09 Nov 2017 23:22:52 -0800
Message-ID: <151029856297.1840.13140526760496306393.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-nvdimm@lists.01.org

Currently only get_user_pages_fast() can safely handle the writable gup
case due to its use of pud_access_permitted() to check whether the pud
entry is writable. In the gup slow path pud_write() is used instead of
pud_access_permitted() and to date it has been unimplemented, just calls
BUG_ON().

    kernel BUG at ./include/linux/hugetlb.h:244!
    [..]
    RIP: 0010:follow_devmap_pud+0x482/0x490
    [..]
    Call Trace:
     follow_page_mask+0x28c/0x6e0
     __get_user_pages+0xe4/0x6c0
     get_user_pages_unlocked+0x130/0x1b0
     get_user_pages_fast+0x89/0xb0
     iov_iter_get_pages_alloc+0x114/0x4a0
     nfs_direct_read_schedule_iovec+0xd2/0x350
     ? nfs_start_io_direct+0x63/0x70
     nfs_file_direct_read+0x1e0/0x250
     nfs_file_read+0x90/0xc0

Use pud_access_permitted() to implement pud_write(), a later cleanup can
remove {pte,pmd,pud}_write and replace them with
{pte,pmd,pud}_access_permitted() drectly so that we only have one set of
helpers these kinds of checks. For now, implementing pud_write()
simplifies -stable backports.

Cc: <stable@vger.kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Fixes: a00cc7d9dd93 ("mm, x86: add support for PUD-sized transparent hugepages")
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---

Sending this as RFC for opinion on whether this should just be a
pud_flags() & _PAGE_RW check, like pmd_write, or pud_access_permitted()
that also takes protection keys into account.

 include/linux/hugetlb.h |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index fbf5b31d47ee..6a142b240ef7 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -242,8 +242,7 @@ static inline int pgd_write(pgd_t pgd)
 #ifndef pud_write
 static inline int pud_write(pud_t pud)
 {
-	BUG();
-	return 0;
+	return pud_access_permitted(pud, WRITE);
 }
 #endif
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
