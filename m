Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 476516B0254
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 02:49:15 -0400 (EDT)
Received: by pabkd10 with SMTP id kd10so36012640pab.2
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 23:49:15 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id fj8si8160866pdb.93.2015.07.30.23.49.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 30 Jul 2015 23:49:13 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 1/5] mm/memory-failure: unlock_page before put_page
Date: Fri, 31 Jul 2015 06:46:12 +0000
Message-ID: <1438325105-10059-2-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1438325105-10059-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1438325105-10059-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Dean Nelson <dnelson@redhat.com>, Tony Luck <tony.luck@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

In "just unpoisoned" path, we do put_page and then unlock_page, which is a
wrong order and causes "freeing locked page" bug. So let's fix it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git v4.2-rc4.orig/mm/memory-failure.c v4.2-rc4/mm/memory-failure.c
index c53543d89282..04d677048af7 100644
--- v4.2-rc4.orig/mm/memory-failure.c
+++ v4.2-rc4/mm/memory-failure.c
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
