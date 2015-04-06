Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 90ACC6B006C
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 04:15:30 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so37764146pdb.1
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 01:15:30 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id z5si5513861pbw.167.2015.04.06.01.15.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Apr 2015 01:15:29 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 2/2 mmotm] mm/page-writeback: check-before-clear PageReclaim
Date: Mon, 6 Apr 2015 08:13:25 +0000
Message-ID: <20150406081325.GB7373@hori1.linux.bs1.fc.nec.co.jp>
References: <20150406062017.GB11515@hori1.linux.bs1.fc.nec.co.jp>
 <20150406072551.GA7539@node.dhcp.inet.fi>
 <20150406074636.GB22950@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20150406074636.GB22950@hori1.linux.bs1.fc.nec.co.jp>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <E335D1B6A3BBB04E8FBC5AB0EFA2BC01@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

With page flag sanitization patchset, an invalid usage of ClearPageReclaim(=
)
is detected in set_page_dirty().
This can be called from __unmap_hugepage_range(), so let's check PageReclai=
m
flag before trying to clear it to avoid the misuse.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/page-writeback.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 22f3714d35e6..38aa0d8f19d3 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2225,7 +2225,8 @@ int set_page_dirty(struct page *page)
 		 * it will confuse readahead and make it restart the size rampup
 		 * process. But it's a trivial problem.
 		 */
-		ClearPageReclaim(page);
+		if (PageReclaim(page))
+			ClearPageReclaim(page);
 #ifdef CONFIG_BLOCK
 		if (!spd)
 			spd =3D __set_page_dirty_buffers;
--=20
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
