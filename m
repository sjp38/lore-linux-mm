Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 6DFF86B0038
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 04:15:29 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so37375890pac.1
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 01:15:29 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id zl5si5511330pbc.186.2015.04.06.01.15.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Apr 2015 01:15:28 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 1/2 mmotm] mm/migrate: check-before-clear PageSwapCache
Date: Mon, 6 Apr 2015 08:13:19 +0000
Message-ID: <20150406081318.GA7373@hori1.linux.bs1.fc.nec.co.jp>
References: <20150406062017.GB11515@hori1.linux.bs1.fc.nec.co.jp>
 <20150406072551.GA7539@node.dhcp.inet.fi>
 <20150406074636.GB22950@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20150406074636.GB22950@hori1.linux.bs1.fc.nec.co.jp>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <AB73753C147A344EAE53D27F09A5C01C@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

With page flag sanitization patchset, an invalid usage of ClearPageSwapCach=
e()
is detected in migration_page_copy().
migrate_page_copy() is shared by both normal and hugepage (both thp and hug=
etlb)
code path, so let's check PageSwapCache() and clear it if it's set to avoid
misuse of the invalid clear operation.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/migrate.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 25fd7f6291de..5fa399d20435 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -537,7 +537,8 @@ void migrate_page_copy(struct page *newpage, struct pag=
e *page)
 	 * Please do not reorder this without considering how mm/ksm.c's
 	 * get_ksm_page() depends upon ksm_migrate_page() and PageSwapCache().
 	 */
-	ClearPageSwapCache(page);
+	if (PageSwapCache(page))
+		ClearPageSwapCache(page);
 	ClearPagePrivate(page);
 	set_page_private(page, 0);
=20
--=20
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
