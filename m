Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 28F546B0253
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 00:34:56 -0400 (EDT)
Received: by pdrh1 with SMTP id h1so51841862pdr.0
        for <linux-mm@kvack.org>; Sun, 16 Aug 2015 21:34:55 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id j4si8046444pdc.90.2015.08.16.21.34.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 16 Aug 2015 21:34:55 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 3/3] mm/hwpoison: don't try to unpoison
 containment-failed pages
Date: Mon, 17 Aug 2015 04:32:11 +0000
Message-ID: <1439785924-27885-4-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <BLU436-SMTP2235CDFEDA4DEB534BF8C85807C0@phx.gbl>
 <1439785924-27885-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1439785924-27885-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <wanpeng.li@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

memory_failure() can be called at any page at any time, which means that we
can't eliminate the possibility of containment failure. In such case the be=
st
option is to leak the page intentionally (and never touch it later.)

We have an unpoison function for testing, and it cannot handle such
containment-failed pages, which results in kernel panic (visible with vario=
us
calltraces.) So this patch suggests that we limit the unpoisonable pages to
properly contained pages and ignore any other ones.

Testers are recommended to keep in mind that there're un-unpoisonable pages
when writing test programs.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git mmotm-2015-08-13-15-29.orig/mm/memory-failure.c mmotm-2015-08-13=
-15-29/mm/memory-failure.c
index 7986db56e240..613389e9e5a8 100644
--- mmotm-2015-08-13-15-29.orig/mm/memory-failure.c
+++ mmotm-2015-08-13-15-29/mm/memory-failure.c
@@ -1433,6 +1433,22 @@ int unpoison_memory(unsigned long pfn)
 		return 0;
 	}
=20
+	if (page_count(page) > 1) {
+		pr_info("MCE: Someone grabs the hwpoison page %#lx\n", pfn);
+		return 0;
+	}
+
+	if (page_mapped(page)) {
+		pr_info("MCE: Someone maps the hwpoison page %#lx\n", pfn);
+		return 0;
+	}
+
+	if (page_mapping(page)) {
+		pr_info("MCE: the hwpoison page has non-NULL mapping %#lx\n",
+			pfn);
+		return 0;
+	}
+
 	/*
 	 * unpoison_memory() can encounter thp only when the thp is being
 	 * worked by memory_failure() and the page lock is not held yet.
--=20
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
