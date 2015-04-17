Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6DDB76B0038
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 22:09:45 -0400 (EDT)
Received: by oblw8 with SMTP id w8so58099099obl.0
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 19:09:45 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id in9si6740457oeb.100.2015.04.16.19.09.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 16 Apr 2015 19:09:44 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 1/2] mm/hwpoison-inject: fix refcounting in no-injection case
Date: Fri, 17 Apr 2015 02:08:52 +0000
Message-ID: <1429236509-8796-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dean Nelson <dnelson@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hwpoison injection via debugfs:hwpoison/corrupt-pfn takes a refcount of
the target page. But current code doesn't release it if the target page
is not supposed to be injected, which results in memory leak.
This patch simply adds the refcount releasing code.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/hwpoison-inject.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git v4.0.orig/mm/hwpoison-inject.c v4.0/mm/hwpoison-inject.c
index 329caf56df22..2b3f933e3282 100644
--- v4.0.orig/mm/hwpoison-inject.c
+++ v4.0/mm/hwpoison-inject.c
@@ -40,7 +40,7 @@ static int hwpoison_inject(void *data, u64 val)
 	 * This implies unable to support non-LRU pages.
 	 */
 	if (!PageLRU(p) && !PageHuge(p))
-		return 0;
+		goto put_out;
=20
 	/*
 	 * do a racy check with elevated page count, to make sure PG_hwpoison
@@ -52,11 +52,14 @@ static int hwpoison_inject(void *data, u64 val)
 	err =3D hwpoison_filter(hpage);
 	unlock_page(hpage);
 	if (err)
-		return 0;
+		goto put_out;
=20
 inject:
 	pr_info("Injecting memory failure at pfn %#lx\n", pfn);
 	return memory_failure(pfn, 18, MF_COUNT_INCREASED);
+put_out:
+	put_page(hpage);
+	return 0;
 }
=20
 static int hwpoison_unpoison(void *data, u64 val)
--=20
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
