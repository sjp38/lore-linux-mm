Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7F2926B0038
	for <linux-mm@kvack.org>; Thu, 14 May 2015 06:41:24 -0400 (EDT)
Received: by obbkp3 with SMTP id kp3so49840374obb.3
        for <linux-mm@kvack.org>; Thu, 14 May 2015 03:41:24 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id xs4si12464017obc.67.2015.05.14.03.41.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 14 May 2015 03:41:23 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 4/4] mm/memory-failure: me_huge_page() does nothing for
 thp
Date: Thu, 14 May 2015 10:39:13 +0000
Message-ID: <1431599951-32545-5-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1431599951-32545-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1431599951-32545-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>
Cc: Dean Nelson <dnelson@redhat.com>, Tony Luck <tony.luck@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

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
index 5e7795079c58..0e15fd39636a 100644
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
