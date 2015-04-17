Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7EBE96B006C
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 22:09:47 -0400 (EDT)
Received: by oblw8 with SMTP id w8so58099626obl.0
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 19:09:47 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id g2si6772052oic.49.2015.04.16.19.09.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 16 Apr 2015 19:09:46 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 2/2] mm/hwpoison-inject: check PageLRU of hpage
Date: Fri, 17 Apr 2015 02:08:52 +0000
Message-ID: <1429236509-8796-2-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1429236509-8796-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1429236509-8796-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dean Nelson <dnelson@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hwpoison injector checks PageLRU of the raw target page to find out whether
the page is an appropriate target, but current code now filters out thp tai=
l
pages, which prevents us from testing for such cases via this interface.
So let's check hpage instead of p.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/hwpoison-inject.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git v4.0.orig/mm/hwpoison-inject.c v4.0/mm/hwpoison-inject.c
index 2b3f933e3282..4ca5fe0042e1 100644
--- v4.0.orig/mm/hwpoison-inject.c
+++ v4.0/mm/hwpoison-inject.c
@@ -34,12 +34,12 @@ static int hwpoison_inject(void *data, u64 val)
 	if (!hwpoison_filter_enable)
 		goto inject;
=20
-	if (!PageLRU(p) && !PageHuge(p))
-		shake_page(p, 0);
+	if (!PageLRU(hpage) && !PageHuge(p))
+		shake_page(hpage, 0);
 	/*
 	 * This implies unable to support non-LRU pages.
 	 */
-	if (!PageLRU(p) && !PageHuge(p))
+	if (!PageLRU(hpage) && !PageHuge(p))
 		goto put_out;
=20
 	/*
--=20
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
