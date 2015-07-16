Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id D2AC52802B9
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 21:42:49 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so34796704pdj.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 18:42:49 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id tb2si10286848pab.75.2015.07.15.18.42.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Jul 2015 18:42:49 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 1/4] mm/memory-failure: unlock_page before put_page
Date: Thu, 16 Jul 2015 01:41:56 +0000
Message-ID: <1437010894-10262-2-git-send-email-n-horiguchi@ah.jp.nec.com>
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

In "just unpoisoned" path, we do put_page and then unlock_page, which is a
wrong order and causes "freeing locked page" bug. So let's fix it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git v4.2-rc2.orig/mm/memory-failure.c v4.2-rc2/mm/memory-failure.c
index c53543d89282..04d677048af7 100644
--- v4.2-rc2.orig/mm/memory-failure.c
+++ v4.2-rc2/mm/memory-failure.c
@@ -1209,9 +1209,9 @@ int memory_failure(unsigned long pfn, int trapno, int=
 flags)
 	if (!PageHWPoison(p)) {
 		printk(KERN_ERR "MCE %#lx: just unpoisoned\n", pfn);
 		atomic_long_sub(nr_pages, &num_poisoned_pages);
+		unlock_page(hpage);
 		put_page(hpage);
-		res =3D 0;
-		goto out;
+		return 0;
 	}
 	if (hwpoison_filter(p)) {
 		if (TestClearPageHWPoison(p))
--=20
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
