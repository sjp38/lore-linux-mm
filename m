Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com [209.85.218.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3291E2802C2
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 21:42:50 -0400 (EDT)
Received: by oiab3 with SMTP id b3so40970631oia.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 18:42:50 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id oq12si5041989oeb.82.2015.07.15.18.42.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Jul 2015 18:42:49 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 2/4] mm/memory-failure: fix race in counting
 num_poisoned_pages
Date: Thu, 16 Jul 2015 01:41:56 +0000
Message-ID: <1437010894-10262-3-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1437010894-10262-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1437010894-10262-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Dean Nelson <dnelson@redhat.com>, Tony Luck <tony.luck@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

When memory_failure() is called on a page which are just freed after page
migration from soft offlining, the counter num_poisoned_pages is raised twi=
ce.
So let's fix it with using TestSetPageHWPoison.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git v4.2-rc2.orig/mm/memory-failure.c v4.2-rc2/mm/memory-failure.c
index 04d677048af7..f72d2fad0b90 100644
--- v4.2-rc2.orig/mm/memory-failure.c
+++ v4.2-rc2/mm/memory-failure.c
@@ -1671,8 +1671,8 @@ static int __soft_offline_page(struct page *page, int=
 flags)
 			if (ret > 0)
 				ret =3D -EIO;
 		} else {
-			SetPageHWPoison(page);
-			atomic_long_inc(&num_poisoned_pages);
+			if (!TestSetPageHWPoison(page))
+				atomic_long_inc(&num_poisoned_pages);
 		}
 	} else {
 		pr_info("soft offline: %#lx: isolation failed: %d, page count %d, type %=
lx\n",
--=20
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
