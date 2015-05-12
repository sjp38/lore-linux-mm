Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id F2D1A6B006C
	for <linux-mm@kvack.org>; Tue, 12 May 2015 05:47:58 -0400 (EDT)
Received: by obbkp3 with SMTP id kp3so1161500obb.3
        for <linux-mm@kvack.org>; Tue, 12 May 2015 02:47:58 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id wd5si8570693obc.21.2015.05.12.02.47.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 12 May 2015 02:47:58 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 4/4] mm/memory-failure: me_huge_page() does nothing for thp
Date: Tue, 12 May 2015 09:46:47 +0000
Message-ID: <1431423998-1939-5-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1431423998-1939-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1431423998-1939-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>
Cc: Tony Luck <tony.luck@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

memory_failure() is supposed not to handle thp itself, but to split it. But
if something were wrong and page_action() were called on thp, me_huge_page(=
)
(action routine for hugepages) should be better to take no action, rather
than to take wrong action prepared for hugetlb (which triggers BUG_ON().)

This change is for potential problems, but makes sense to me because thp is
an actively developing feature and this code path can be open in the future=
.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git v4.1-rc3.orig/mm/memory-failure.c v4.1-rc3/mm/memory-failure.c
index 918256de15bf..6b5bdc575496 100644
--- v4.1-rc3.orig/mm/memory-failure.c
+++ v4.1-rc3/mm/memory-failure.c
@@ -743,6 +743,10 @@ static int me_huge_page(struct page *p, unsigned long =
pfn)
 {
 	int res =3D 0;
 	struct page *hpage =3D compound_head(p);
+
+	if (!PageHuge(hpage))
+		return MF_DELAYED;
+
 	/*
 	 * We can safely recover from error on free or reserved (i.e.
 	 * not in-use) hugepage by dequeuing it from freelist.
--=20
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
